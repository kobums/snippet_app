enum BookType {
  wish,
  have,
  borrow,
  return_;

  String toJson() => name == 'return_' ? 'return' : name;

  static BookType fromJson(String json) {
    return json == 'return' ? BookType.return_ : BookType.values.firstWhere((e) => e.name == json);
  }
}

enum BookStatus {
  none,
  waiting,
  reading,
  completed,
  dropped;

  String toJson() => name;

  static BookStatus fromJson(String json) {
    return BookStatus.values.firstWhere((e) => e.name == json);
  }
}

class UserBookDto {
  final int id;
  final int bookId;
  final String title;
  final String author;
  final String coverUrl;
  final BookType type;
  final BookStatus status;
  final int readPage;
  final int totalPage;
  final String createDate;
  final String startDate;
  final String endDate;

  UserBookDto({
    required this.id,
    required this.bookId,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.type,
    required this.status,
    required this.readPage,
    required this.totalPage,
    required this.createDate,
    required this.startDate,
    required this.endDate,
  });

  factory UserBookDto.fromJson(Map<String, dynamic> json) {
    return UserBookDto(
      id: json['id'] as int,
      bookId: json['bookId'] as int,
      title: json['title'] as String,
      author: json['author'] as String,
      coverUrl: json['coverUrl'] as String,
      type: BookType.fromJson(json['type'] as String),
      status: BookStatus.fromJson(json['status'] as String),
      readPage: json['readPage'] as int,
      totalPage: json['totalPage'] as int,
      createDate: json['createDate'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'type': type.toJson(),
      'status': status.toJson(),
      'readPage': readPage,
      'totalPage': totalPage,
      'createDate': createDate,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  UserBookDto copyWith({
    int? id,
    int? bookId,
    String? title,
    String? author,
    String? coverUrl,
    BookType? type,
    BookStatus? status,
    int? readPage,
    int? totalPage,
    String? createDate,
    String? startDate,
    String? endDate,
  }) {
    return UserBookDto(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      type: type ?? this.type,
      status: status ?? this.status,
      readPage: readPage ?? this.readPage,
      totalPage: totalPage ?? this.totalPage,
      createDate: createDate ?? this.createDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  double get progress {
    if (totalPage == 0) return 0.0;
    return (readPage / totalPage).clamp(0.0, 1.0);
  }
}
