class BookSearchDto {
  final String title;
  final String author;
  final String publisher;
  final String pubDate;
  final String isbn;
  final String coverUrl;
  final int? totalPage;

  BookSearchDto({
    required this.title,
    required this.author,
    required this.publisher,
    required this.pubDate,
    required this.isbn,
    required this.coverUrl,
    this.totalPage,
  });

  factory BookSearchDto.fromJson(Map<String, dynamic> json) {
    return BookSearchDto(
      title: json['title'] as String,
      author: json['author'] as String,
      publisher: json['publisher'] as String,
      pubDate: json['pubDate'] as String,
      isbn: json['isbn'] as String,
      coverUrl: json['coverUrl'] as String,
      totalPage: json['totalPage'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'publisher': publisher,
      'pubDate': pubDate,
      'isbn': isbn,
      'coverUrl': coverUrl,
      'totalPage': totalPage,
    };
  }
}
