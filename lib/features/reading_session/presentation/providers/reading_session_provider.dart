import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/reading_session/data/datasources/reading_session_local_datasource.dart';
import 'package:snippet_app/features/reading_session/data/models/reading_session.dart';
import 'package:snippet_app/features/reading_session/reading_session_providers.dart';

const _liveActivityChannel = MethodChannel('com.gowoobro.snippet/liveActivity');

// ─── Keys ─────────────────────────────────────────────────────────────────────

const _kStartEpoch  = 'rs_start_epoch';  // epoch seconds when current run started
const _kBaseElapsed = 'rs_base_elapsed'; // accumulated seconds before current run
const _kPaused      = 'rs_paused';

// ─── Background Task Handler ──────────────────────────────────────────────────

@pragma('vm:entry-point')
void readingSessionTaskCallback() {
  FlutterForegroundTask.setTaskHandler(_ReadingSessionTaskHandler());
}

class _ReadingSessionTaskHandler extends TaskHandler {
  int _startEpoch  = 0;
  int _baseElapsed = 0;
  bool _isPaused   = false;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final prefs = await SharedPreferences.getInstance();
    _startEpoch  = prefs.getInt(_kStartEpoch)  ?? _nowEpoch();
    _baseElapsed = prefs.getInt(_kBaseElapsed) ?? 0;
    _isPaused    = prefs.getBool(_kPaused)     ?? false;
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    final elapsed = _computeElapsed();
    FlutterForegroundTask.sendDataToMain(elapsed);
    FlutterForegroundTask.updateService(notificationText: _formatTime(elapsed));
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {}

  @override
  void onReceiveData(Object data) {
    if (data is! Map<String, dynamic>) return;
    final cmd = data['command'] as String?;
    if (cmd == 'pause') {
      _baseElapsed = _computeElapsed();
      _isPaused = true;
    } else if (cmd == 'resume') {
      _startEpoch = _nowEpoch();
      _isPaused = false;
    }
  }

  int _computeElapsed() {
    if (_isPaused) return _baseElapsed;
    return _baseElapsed + (_nowEpoch() - _startEpoch);
  }

  int _nowEpoch() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }
}

// ─── State ────────────────────────────────────────────────────────────────────

enum SessionStatus { idle, running, paused, completing, saving, done }

class ReadingSessionState {
  final SessionStatus status;
  final UserBookDto?  book;
  final int startPage;
  final int currentPage;
  final int elapsedSeconds;
  final String? photoPath;
  final bool isSaving;
  final String? errorMessage;
  final bool isRecoverable;

  const ReadingSessionState({
    this.status = SessionStatus.idle,
    this.book,
    this.startPage = 0,
    this.currentPage = 0,
    this.elapsedSeconds = 0,
    this.photoPath,
    this.isSaving = false,
    this.errorMessage,
    this.isRecoverable = false,
  });

  int get pagesRead => (currentPage - startPage).clamp(0, 99999);

  double get secondsPerPage =>
      pagesRead > 0 ? elapsedSeconds / pagesRead : 0.0;

  String get formattedTime {
    final h = elapsedSeconds ~/ 3600;
    final m = (elapsedSeconds % 3600) ~/ 60;
    final s = elapsedSeconds % 60;
    return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  String get paceLabel {
    if (pagesRead == 0) return '--';
    return '${(secondsPerPage / 60).toStringAsFixed(1)} min/p';
  }

  ReadingSessionState copyWith({
    SessionStatus? status,
    UserBookDto? book,
    int? startPage,
    int? currentPage,
    int? elapsedSeconds,
    String? photoPath,
    bool clearPhoto = false,
    bool? isSaving,
    String? errorMessage,
    bool? isRecoverable,
  }) {
    return ReadingSessionState(
      status:         status         ?? this.status,
      book:           book           ?? this.book,
      startPage:      startPage      ?? this.startPage,
      currentPage:    currentPage    ?? this.currentPage,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      photoPath:      clearPhoto ? null : (photoPath ?? this.photoPath),
      isSaving:       isSaving       ?? this.isSaving,
      errorMessage:   errorMessage,
      isRecoverable:  isRecoverable  ?? this.isRecoverable,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ReadingSessionNotifier extends Notifier<ReadingSessionState> {
  Timer? _timer;

  // Wall-clock tracking — the source of truth for elapsed time on iOS.
  // _startEpoch : epoch-seconds when the current running period began.
  // _baseElapsed: seconds accumulated from all previous running periods.
  int? _startEpoch;
  int  _baseElapsed = 0;

  @override
  ReadingSessionState build() {
    ref.onDispose(() {
      _timer?.cancel();
      FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    });
    Future.microtask(_checkRecoverableSession);
    return const ReadingSessionState();
  }

  // ─── Public API ───────────────────────────────────────────────────────────

  void startSession(UserBookDto book, int startPage) {
    _timer?.cancel();
    _startEpoch  = _nowEpoch();
    _baseElapsed = 0;

    _saveEpochToPrefs(_startEpoch!, 0, false);

    state = ReadingSessionState(
      status: SessionStatus.running,
      book: book,
      startPage: startPage,
      currentPage: startPage,
      elapsedSeconds: 0,
    );

    ref.read(readingSessionLocalDataSourceProvider).saveSession(
      PersistedSessionData(
        userBookId:   book.id,
        bookId:       book.bookId,
        bookTitle:    book.title,
        bookCoverUrl: book.coverUrl,
        bookAuthor:   book.author,
        totalPage:    book.totalPage,
        startPage:    startPage,
      ),
    );

    _startInAppTimer();
    _initAndStartForegroundTask(book);
    _startLiveActivity(book);
  }

  void pauseSession() {
    if (state.status != SessionStatus.running) return;
    _timer?.cancel();
    _baseElapsed = _calculateElapsed();
    _startEpoch  = null;
    state = state.copyWith(status: SessionStatus.paused, elapsedSeconds: _baseElapsed);
    SharedPreferences.getInstance().then((p) {
      p.setInt(_kBaseElapsed, _baseElapsed);
      p.setBool(_kPaused, true);
    });
    FlutterForegroundTask.sendDataToTask({'command': 'pause'});
    _updateLiveActivity(isPaused: true);
  }

  void resumeSession() {
    if (state.status != SessionStatus.paused) return;
    _startEpoch = _nowEpoch();
    state = state.copyWith(status: SessionStatus.running);
    SharedPreferences.getInstance().then((p) {
      p.setInt(_kStartEpoch, _startEpoch!);
      p.setBool(_kPaused, false);
    });
    _startInAppTimer();
    FlutterForegroundTask.sendDataToTask({'command': 'resume'});
    _updateLiveActivity(isPaused: false);
  }

  void setPhoto(String path) => state = state.copyWith(photoPath: path);

  Future<void> prepareFinish() async {
    _timer?.cancel();
    FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    await FlutterForegroundTask.stopService();
    await _clearLocalCache();
    _endLiveActivity();
    state = state.copyWith(status: SessionStatus.completing);
  }

  Future<bool> finishSession(int endPage) async {
    final book = state.book;
    if (book == null) return false;

    state = state.copyWith(
      status: SessionStatus.saving,
      currentPage: endPage,
      isSaving: true,
    );

    final result = await ref.read(saveReadingSessionUseCaseProvider)(
      ReadingSessionAddRequestDto(
        userBookId:      book.id,
        durationSeconds: state.elapsedSeconds,
        startPage:       state.startPage,
        endPage:         endPage,
        sessionDate:     DateFormat('yyyy-MM-dd').format(DateTime.now()),
      ),
    );

    return result.when(
      success: (_) {
        state = state.copyWith(status: SessionStatus.done, isSaving: false);
        return true;
      },
      failure: (error) {
        state = state.copyWith(
          status: SessionStatus.completing,
          isSaving: false,
          errorMessage: error.message,
        );
        return false;
      },
    );
  }

  Future<void> abandonSession() async {
    _timer?.cancel();
    FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    await FlutterForegroundTask.stopService();
    await _clearLocalCache();
    _endLiveActivity();
    _startEpoch  = null;
    _baseElapsed = 0;
    state = const ReadingSessionState();
  }

  void reset() => state = const ReadingSessionState();

  Future<void> recoverSession() async {
    final local     = ref.read(readingSessionLocalDataSourceProvider);
    final persisted = await local.loadSession();
    if (persisted == null) return;

    final prefs     = await SharedPreferences.getInstance();
    final savedEpoch = prefs.getInt(_kStartEpoch)  ?? 0;
    final savedBase  = prefs.getInt(_kBaseElapsed) ?? 0;
    final wasPaused  = prefs.getBool(_kPaused)     ?? false;

    final int elapsed;
    if (wasPaused) {
      elapsed      = savedBase;
      _startEpoch  = null;
      _baseElapsed = savedBase;
    } else if (savedEpoch > 0) {
      elapsed      = savedBase + (_nowEpoch() - savedEpoch);
      _startEpoch  = savedEpoch;
      _baseElapsed = savedBase;
    } else {
      elapsed      = 0;
      _startEpoch  = _nowEpoch();
      _baseElapsed = 0;
    }

    final book = UserBookDto(
      id:         persisted.userBookId,
      bookId:     persisted.bookId,
      title:      persisted.bookTitle,
      author:     persisted.bookAuthor,
      coverUrl:   persisted.bookCoverUrl,
      type:       BookType.have,
      status:     BookStatus.reading,
      readPage:   persisted.startPage,
      totalPage:  persisted.totalPage,
      createDate: '',
      startDate:  '',
      endDate:    '',
    );

    _timer?.cancel();
    state = ReadingSessionState(
      status:         wasPaused ? SessionStatus.paused : SessionStatus.running,
      book:           book,
      startPage:      persisted.startPage,
      currentPage:    persisted.startPage,
      elapsedSeconds: elapsed,
      isRecoverable:  false,
    );

    if (!wasPaused) {
      _startInAppTimer();
      _initAndStartForegroundTask(book);
      _startLiveActivity(book);
    }
  }

  void dismissRecovery() {
    state = state.copyWith(isRecoverable: false);
    ref.read(readingSessionLocalDataSourceProvider).clearSession();
  }

  // ─── Live Activity (iOS 16.2+) ────────────────────────────────────────────

  void _startLiveActivity(UserBookDto book) {
    if (!Platform.isIOS) return;
    // timerReferenceEpoch = startEpoch - baseElapsed
    // SwiftUI: Text(Date(refEpoch), style: .timer) auto-counts from this date.
    final refEpoch = (_startEpoch! - _baseElapsed).toDouble();
    _liveActivityChannel.invokeMethod<void>('start', {
      'title':               book.title,
      'coverUrl':            book.coverUrl,
      'timerReferenceEpoch': refEpoch,
    }).catchError((_) {});
  }

  void _updateLiveActivity({required bool isPaused}) {
    if (!Platform.isIOS) return;
    final refEpoch = _startEpoch != null
        ? (_startEpoch! - _baseElapsed).toDouble()
        : (_nowEpoch()  - _baseElapsed).toDouble();
    _liveActivityChannel.invokeMethod<void>('update', {
      'timerReferenceEpoch':  refEpoch,
      'isPaused':             isPaused,
      'pausedElapsedSeconds': isPaused ? _baseElapsed : 0,
    }).catchError((_) {});
  }

  void _endLiveActivity() {
    if (!Platform.isIOS) return;
    _liveActivityChannel.invokeMethod<void>('end').catchError((_) {});
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  int _nowEpoch() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  int _calculateElapsed() {
    if (_startEpoch == null) return _baseElapsed;
    return _baseElapsed + (_nowEpoch() - _startEpoch!);
  }

  void _startInAppTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status == SessionStatus.running) {
        state = state.copyWith(elapsedSeconds: _calculateElapsed());
      }
    });
  }

  void _onTaskData(Object data) {
    // Android foreground service cross-check only.
    if (data is int &&
        state.status == SessionStatus.running &&
        data > state.elapsedSeconds + 5) {
      state = state.copyWith(elapsedSeconds: data);
    }
  }

  void _initAndStartForegroundTask(UserBookDto book) {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId:          'reading_session',
        channelName:        '독서 세션',
        channelDescription: '독서 중 타이머가 실행됩니다',
        channelImportance:  NotificationChannelImportance.LOW,
        priority:           NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound:        false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction:    ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot:  false,
        allowWakeLock:  true,
      ),
    );

    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_onTaskData);

    FlutterForegroundTask.startService(
      serviceId:        300,
      notificationTitle: '📚 ${book.title} 읽는 중',
      notificationText:  '00:00:00',
      callback:          readingSessionTaskCallback,
    );
  }

  void _saveEpochToPrefs(int startEpoch, int baseElapsed, bool paused) {
    SharedPreferences.getInstance().then((p) {
      p.setInt(_kStartEpoch,  startEpoch);
      p.setInt(_kBaseElapsed, baseElapsed);
      p.setBool(_kPaused,     paused);
    });
  }

  Future<void> _checkRecoverableSession() async {
    final local     = ref.read(readingSessionLocalDataSourceProvider);
    final persisted = await local.loadSession();
    if (persisted == null) return;
    final prefs      = await SharedPreferences.getInstance();
    final savedBase  = prefs.getInt(_kBaseElapsed) ?? 0;
    final savedEpoch = prefs.getInt(_kStartEpoch)  ?? 0;
    final wasPaused  = prefs.getBool(_kPaused)     ?? false;
    final hasElapsed = wasPaused
        ? savedBase > 0
        : (savedEpoch > 0 && (_nowEpoch() - savedEpoch) > 0);
    if (hasElapsed) state = state.copyWith(isRecoverable: true);
  }

  Future<void> _clearLocalCache() async {
    await ref.read(readingSessionLocalDataSourceProvider).clearSession();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kStartEpoch);
    await prefs.remove(_kBaseElapsed);
    await prefs.remove(_kPaused);
  }
}

final readingSessionProvider =
    NotifierProvider<ReadingSessionNotifier, ReadingSessionState>(
        ReadingSessionNotifier.new);
