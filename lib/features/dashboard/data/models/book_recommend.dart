class BookRecommendDto {
  final int id;
  final String title;
  final String author;
  final String coverUrl;
  final String? category;
  final String reason;

  const BookRecommendDto({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    this.category,
    required this.reason,
  });

  factory BookRecommendDto.fromJson(Map<String, dynamic> json) => BookRecommendDto(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        author: json['author'] as String? ?? '',
        coverUrl: json['coverUrl'] as String? ?? '',
        category: json['category'] as String?,
        reason: json['reason'] as String? ?? '',
      );
}
