import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dashboard state
class DashboardState {
  final int selectedProgressFilter;
  final int currentTab;
  final Map<int, double> scrollPositions;
  final Map<int, bool> showFixedHeaders;

  DashboardState({
    this.selectedProgressFilter = 1, // 기본값: 읽는중
    this.currentTab = 0,
    Map<int, double>? scrollPositions,
    Map<int, bool>? showFixedHeaders,
  })  : scrollPositions = scrollPositions ?? {0: 0.0, 1: 0.0, 2: 0.0},
        showFixedHeaders = showFixedHeaders ?? {0: false, 1: false, 2: false};

  DashboardState copyWith({
    int? selectedProgressFilter,
    int? currentTab,
    Map<int, double>? scrollPositions,
    Map<int, bool>? showFixedHeaders,
  }) {
    return DashboardState(
      selectedProgressFilter:
          selectedProgressFilter ?? this.selectedProgressFilter,
      currentTab: currentTab ?? this.currentTab,
      scrollPositions: scrollPositions ?? this.scrollPositions,
      showFixedHeaders: showFixedHeaders ?? this.showFixedHeaders,
    );
  }
}

/// Dashboard notifier
class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    return DashboardState();
  }

  /// 진행 상태 필터 변경 (0: 대기중, 1: 읽는중, 2: 완독)
  void setProgressFilter(int index) {
    state = state.copyWith(selectedProgressFilter: index);
  }

  /// 탭 관련 메서드
  void setCurrentTab(int index) {
    state = state.copyWith(currentTab: index);
  }

  void setScrollPosition(int tab, double position) {
    final newScrollPositions = Map<int, double>.from(state.scrollPositions);
    newScrollPositions[tab] = position;
    state = state.copyWith(scrollPositions: newScrollPositions);
  }

  void setFixedHeaderVisible(int tab, bool visible) {
    final newHeaders = Map<int, bool>.from(state.showFixedHeaders);
    newHeaders[tab] = visible;
    state = state.copyWith(showFixedHeaders: newHeaders);
  }
}

/// Dashboard provider
final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);
