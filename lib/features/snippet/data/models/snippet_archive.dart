class SnippetArchive {
  final int id;
  final String text;
  final String? tag;
  final String bookTitle;
  final String bookAuthor;
  final String coverUrl;
  final String affiliateUrl;

  SnippetArchive({
    required this.id,
    required this.text,
    this.tag,
    required this.bookTitle,
    required this.bookAuthor,
    required this.coverUrl,
    required this.affiliateUrl,
  });

  factory SnippetArchive.fromJson(Map<String, dynamic> json) {
    return SnippetArchive(
      id: json['id'] as int,
      text: json['text'] as String,
      tag: json['tag'] as String?,
      bookTitle: json['bookTitle'] ?? '',
      bookAuthor: json['bookAuthor'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
      affiliateUrl: json['affiliateUrl'] ?? '',
    );
  }
}
