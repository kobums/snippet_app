class Snippet {
  final int id;
  final String text;
  final String? tag;
  final String? bookTitle;

  Snippet({
    required this.id,
    required this.text,
    this.tag,
    this.bookTitle,
  });

  factory Snippet.fromJson(Map<String, dynamic> json) {
    return Snippet(
      id: json['id'] as int,
      text: json['text'] as String,
      tag: json['tag'] as String?,
      bookTitle: json['bookTitle'] as String?,
    );
  }
}
