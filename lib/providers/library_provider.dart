import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_book.dart';
import 'book_provider.dart';

class LibraryState {
  final List<UserBookDto> allBooks;
  final String searchQuery;
  final bool isLoading;

  LibraryState({
    this.allBooks = const [],
    this.searchQuery = '',
    this.isLoading = false,
  });

  LibraryState copyWith({
    List<UserBookDto>? allBooks,
    String? searchQuery,
    bool? isLoading,
  }) {
    return LibraryState(
      allBooks: allBooks ?? this.allBooks,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LibraryNotifier extends Notifier<LibraryState> {
  @override
  LibraryState build() {
    // Load all books on initialization
    Future.microtask(() => loadAllBooks());
    return LibraryState();
  }

  Future<void> loadAllBooks() async {
    state = state.copyWith(isLoading: true);

    try {
      final api = ref.read(userBookApiProvider);
      // Use monthly endpoint without year/month to get all books
      // OR we need to add a getAllUserBooks method to the API service
      // For now, let's use monthly without parameters
      final books = await api.getMonthlyUserBooks();
      state = state.copyWith(allBooks: books, isLoading: false);
    } catch (e) {
      print('Load all books error: $e');
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  List<UserBookDto> get filteredBooks {
    if (state.searchQuery.isEmpty) {
      return state.allBooks;
    }

    final query = state.searchQuery.toLowerCase();
    return state.allBooks.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
    }).toList();
  }

  List<UserBookDto> get recentBooks {
    // Sort by createDate descending, take first 5
    final sorted = List<UserBookDto>.from(state.allBooks);
    sorted.sort((a, b) {
      final aDate = DateTime.tryParse(a.createDate) ?? DateTime(1900);
      final bDate = DateTime.tryParse(b.createDate) ?? DateTime(1900);
      return bDate.compareTo(aDate);
    });
    return sorted.take(5).toList();
  }

  List<UserBookDto> get readingBooks {
    return state.allBooks
        .where((book) => book.status == BookStatus.reading)
        .toList();
  }

  List<UserBookDto> get borrowedBooks {
    return state.allBooks
        .where((book) => book.type == BookType.borrow)
        .toList();
  }

  List<UserBookDto> get wishlistBooks {
    return state.allBooks
        .where((book) => book.type == BookType.wish)
        .toList();
  }

  List<UserBookDto> getBooksHave() {
    return state.allBooks
        .where((book) => book.type == BookType.have)
        .toList();
  }

  List<UserBookDto> getBooksBorrow() {
    return state.allBooks
        .where((book) => book.type == BookType.borrow)
        .toList();
  }

  List<UserBookDto> getBooksWish() {
    return state.allBooks
        .where((book) => book.type == BookType.wish)
        .toList();
  }

  List<UserBookDto> searchInCategory(BookType type, String query) {
    final q = query.toLowerCase();
    return state.allBooks
        .where((book) => book.type == type)
        .where((book) =>
            book.title.toLowerCase().contains(q) ||
            book.author.toLowerCase().contains(q))
        .toList();
  }

  Future<void> refreshBooks() async {
    await loadAllBooks();
  }
}

final libraryProvider = NotifierProvider<LibraryNotifier, LibraryState>(() {
  return LibraryNotifier();
});
