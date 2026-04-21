import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/reading_session/data/datasources/reading_session_local_datasource.dart';
import 'package:snippet_app/features/reading_session/data/models/reading_session.dart';
import 'package:snippet_app/features/reading_session/reading_session_providers.dart';

// ─── Background Task Handler ──────────────────────────────────────────────────

@pragma('vm:entry-point')
void readingSessionTaskCallback() {
  FlutterForegroundTask.setTaskHandler(_ReadingSessionTaskHandler());
}

class _ReadingSessionTaskHandler extends TaskHandler {
  int _elapsedSeconds = 0;
  bool _isPaused = false;
  int _tickCount = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final prefs = await SharedPreferences.getInstance();
    _elapsedSeconds = prefs.getInt('rs_elapsed') ?? 0;
    _isPaused = prefs.getBool('rs_paused') ?? false;
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    if (!_isPaused) {
      _elapsedSeconds++;
      _tickCount++;
      if (_tickCount % 5 == 0) {
        SharedPreferences.getInstance()
            .then((p) => p.setInt('rs_elapsed', _elapsedSeconds));
      }
    }
    FlutterForegroundTask.sendDataToMain(_elapsedSeconds);
    FlutterForegroundTask.updateService(
      notificationText: _formatTime(_elapsedSeconds),
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {}

  @override
  void onReceiveData(Object data) {
    if (data is Map<String, dynamic>) {
      final command = data['command'] as String?;
      if (command == 'pause') _isPaused = true;
      if (command == 'resume') _isPaused = false;
      if (command == 'sync') {
        _elapsedSeconds = (data['elapsed'] as int?) ?? _elapsedSeconds;
      }
    }
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

// ─── State ────────────────────────────────────────────────────────────────────

enum SessionStatus { idle, running, paused, saving, done }

class ReadingSessionState {
  final SessionStatus status;
  final UserBookDto? book;
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
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get paceLabel {
    if (pagesRead == 0) return '--';
    final minPerPage = secondsPerPage / 60;
    return '${minPerPage.toStringAsFixed(1)} min/p';
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
      status: status ?? this.status,
      book: book ?? this.book,
      startPage: startPage ?? this.startPage,
      currentPage: currentPage ?? this.currentPage,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      isRecoverable: isRecoverable ?? this.isRecoverable,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ReadingSessionNotifier extends Notifier<ReadingSessionState> {
  Timer? _timer;

  @override
  ReadingSessionState build() {
    ref.onDispose(() {
      _timer?.cancel();
      FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    });
    // 앱 시작 시 미완료 세션 감지
    Future.microtask(_checkRecoverableSession);
    return const ReadingSessionState();
  }

  Future<void> _checkRecoverableSession() async {
    final local = ref.read(readingSessionLocalDataSourceProvider);
    final persisted = await local.loadSession();
    if (persisted == null) return;
    final prefs = await SharedPreferences.getInstance();
    final elapsed = prefs.getInt('rs_elapsed') ?? 0;
    if (elapsed > 0) {
      state = state.copyWith(isRecoverable: true);
    }
  }

  Future<void> recoverSession() async {
    final local = ref.read(readingSessionLocalDataSourceProvider);
    final persisted = await local.loadSession();
    if (persisted == null) return;
    final prefs = await SharedPreferences.getInstance();
    final elapsed = prefs.getInt('rs_elapsed') ?? 0;

    final book = UserBookDto(
      id: persisted.userBookId,
      bookId: persisted.bookId,
      title: persisted.bookTitle,
      author: persisted.bookAuthor,
      coverUrl: persisted.bookCoverUrl,
      type: BookType.have,
      status: BookStatus.reading,
      readPage: persisted.startPage,
      totalPage: persisted.totalPage,
      createDate: '',
      startDate: '',
      endDate: '',
    );

    _timer?.cancel();
    state = ReadingSessionState(
      status: SessionStatus.running,
      book: book,
      startPage: persisted.startPage,
      currentPage: persisted.startPage,
      elapsedSeconds: elapsed,
      isRecoverable: false,
    );
    _startInAppTimer();
    _initAndStartForegroundTask(book);
  }

  void dismissRecovery() {
    state = state.copyWith(isRecoverable: false);
    ref.read(readingSessionLocalDataSourceProvider).clearSession();
  }

  void startSession(UserBookDto book, int startPage) {
    _timer?.cancel();
    state = ReadingSessionState(
      status: SessionStatus.running,
      book: book,
      startPage: startPage,
      currentPage: startPage,
      elapsedSeconds: 0,
    );
    // 세션 데이터 로컬 저장 (크래시 복구용)
    ref.read(readingSessionLocalDataSourceProvider).saveSession(
          PersistedSessionData(
            userBookId: book.id,
            bookId: book.bookId,
            bookTitle: book.title,
            bookCoverUrl: book.coverUrl,
            bookAuthor: book.author,
            totalPage: book.totalPage,
            startPage: startPage,
          ),
        );
    _startInAppTimer();
    _initAndStartForegroundTask(book);
  }

  void pauseSession() {
    if (state.status != SessionStatus.running) return;
    _timer?.cancel();
    state = state.copyWith(status: SessionStatus.paused);
    FlutterForegroundTask.sendDataToTask({'command': 'pause'});
    SharedPreferences.getInstance().then((p) => p.setBool('rs_paused', true));
  }

  void resumeSession() {
    if (state.status != SessionStatus.paused) return;
    state = state.copyWith(status: SessionStatus.running);
    _startInAppTimer();
    FlutterForegroundTask.sendDataToTask({'command': 'resume'});
    SharedPreferences.getInstance().then((p) => p.setBool('rs_paused', false));
  }

  void updateCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void setPhoto(String path) {
    state = state.copyWith(photoPath: path);
  }

  Future<bool> finishSession() async {
    _timer?.cancel();
    FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    await FlutterForegroundTask.stopService();
    await _clearLocalCache();

    final book = state.book;
    if (book == null) return false;

    state = state.copyWith(status: SessionStatus.saving, isSaving: true);

    final useCase = ref.read(saveReadingSessionUseCaseProvider);
    final result = await useCase(ReadingSessionAddRequestDto(
      userBookId: book.id,
      durationSeconds: state.elapsedSeconds,
      startPage: state.startPage,
      endPage: state.currentPage,
      sessionDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    ));

    return result.when(
      success: (_) {
        state = state.copyWith(status: SessionStatus.done, isSaving: false);
        return true;
      },
      failure: (error) {
        state = state.copyWith(
          status: SessionStatus.paused,
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
    state = const ReadingSessionState();
  }

  void reset() {
    state = const ReadingSessionState();
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  void _onTaskData(Object data) {
    if (data is int && state.status == SessionStatus.running) {
      // 백그라운드 복귀 시 elapsed 동기화 (2초 이상 차이날 때만)
      if (data > state.elapsedSeconds + 2) {
        state = state.copyWith(elapsedSeconds: data);
      }
    }
  }

  void _startInAppTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status == SessionStatus.running) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  void _initAndStartForegroundTask(UserBookDto book) {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'reading_session',
        channelName: '독서 세션',
        channelDescription: '독서 중 타이머가 실행됩니다',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot: false,
        allowWakeLock: true,
      ),
    );

    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_onTaskData);

    FlutterForegroundTask.startService(
      serviceId: 300,
      notificationTitle: '📚 ${book.title} 읽는 중',
      notificationText: '00:00:00',
      callback: readingSessionTaskCallback,
    );
  }

  Future<void> _clearLocalCache() async {
    await ref.read(readingSessionLocalDataSourceProvider).clearSession();
  }
}

final readingSessionProvider =
    NotifierProvider<ReadingSessionNotifier, ReadingSessionState>(
        ReadingSessionNotifier.new);
