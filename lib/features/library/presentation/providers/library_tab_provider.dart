import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryTabState {
  final int currentTab;
  final Map<int, double> scrollPositions;
  final Map<int, bool> showFixedHeaders;
  final Map<int, String> searchQueries;

  LibraryTabState({
    this.currentTab = 0,
    Map<int, double>? scrollPositions,
    Map<int, bool>? showFixedHeaders,
    Map<int, String>? searchQueries,
  })  : scrollPositions = scrollPositions ?? {0: 0.0, 1: 0.0, 2: 0.0},
        showFixedHeaders = showFixedHeaders ?? {0: false, 1: false, 2: false},
        searchQueries = searchQueries ?? {0: '', 1: '', 2: ''};

  LibraryTabState copyWith({
    int? currentTab,
    Map<int, double>? scrollPositions,
    Map<int, bool>? showFixedHeaders,
    Map<int, String>? searchQueries,
  }) {
    return LibraryTabState(
      currentTab: currentTab ?? this.currentTab,
      scrollPositions: scrollPositions ?? this.scrollPositions,
      showFixedHeaders: showFixedHeaders ?? this.showFixedHeaders,
      searchQueries: searchQueries ?? this.searchQueries,
    );
  }
}

class LibraryTabNotifier extends Notifier<LibraryTabState> {
  @override
  LibraryTabState build() => LibraryTabState();

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

  void setSearchQuery(int tab, String query) {
    final newQueries = Map<int, String>.from(state.searchQueries);
    newQueries[tab] = query;
    state = state.copyWith(searchQueries: newQueries);
  }

  void resetTabState(int tab) {
    setScrollPosition(tab, 0.0);
    setFixedHeaderVisible(tab, false);
  }
}

final libraryTabProvider =
    NotifierProvider<LibraryTabNotifier, LibraryTabState>(() {
  return LibraryTabNotifier();
});
