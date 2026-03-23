import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dashboard state
class DashboardState {
  final int selectedProgressFilter;

  const DashboardState({
    this.selectedProgressFilter = 1, // 기본값: 읽는중
  });

  DashboardState copyWith({
    int? selectedProgressFilter,
  }) {
    return DashboardState(
      selectedProgressFilter: selectedProgressFilter ?? this.selectedProgressFilter,
    );
  }
}

/// Dashboard notifier
class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    return const DashboardState();
  }

  /// 진행 상태 필터 변경 (0: 대기중, 1: 읽는중, 2: 완독)
  void setProgressFilter(int index) {
    state = state.copyWith(selectedProgressFilter: index);
  }
}

/// Dashboard provider
final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);
