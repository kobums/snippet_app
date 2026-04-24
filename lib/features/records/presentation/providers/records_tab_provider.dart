import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecordsTabState {
  final int currentTab;
  final Map<int, double> scrollPositions;
  final Map<int, bool> showFixedHeaders;

  RecordsTabState({
    this.currentTab = 0,
    Map<int, double>? scrollPositions,
    Map<int, bool>? showFixedHeaders,
  })  : scrollPositions = scrollPositions ?? {0: 0.0, 1: 0.0, 2: 0.0, 3: 0.0},
        showFixedHeaders = showFixedHeaders ?? {0: false, 1: false, 2: false, 3: false};

  RecordsTabState copyWith({
    int? currentTab,
    Map<int, double>? scrollPositions,
    Map<int, bool>? showFixedHeaders,
  }) {
    return RecordsTabState(
      currentTab: currentTab ?? this.currentTab,
      scrollPositions: scrollPositions ?? this.scrollPositions,
      showFixedHeaders: showFixedHeaders ?? this.showFixedHeaders,
    );
  }
}

class RecordsTabNotifier extends Notifier<RecordsTabState> {
  @override
  RecordsTabState build() => RecordsTabState();

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

  void resetTabState(int tab) {
    setScrollPosition(tab, 0.0);
    setFixedHeaderVisible(tab, false);
  }
}

final recordsTabProvider =
    NotifierProvider<RecordsTabNotifier, RecordsTabState>(() {
  return RecordsTabNotifier();
});
