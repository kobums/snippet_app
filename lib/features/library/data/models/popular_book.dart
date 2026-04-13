class PopularBookDto {
  final int rank;
  final String title;
  final String author;
  final String publisher;
  final String isbn13;
  final String kdc;
  final String kdcName;
  final int loanCount;
  final String coverUrl;

  const PopularBookDto({
    required this.rank,
    required this.title,
    required this.author,
    required this.publisher,
    required this.isbn13,
    required this.kdc,
    required this.kdcName,
    required this.loanCount,
    required this.coverUrl,
  });

  factory PopularBookDto.fromJson(Map<String, dynamic> json) {
    return PopularBookDto(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      publisher: json['publisher'] as String? ?? '',
      isbn13: json['isbn13'] as String? ?? '',
      kdc: json['kdc'] as String? ?? '',
      kdcName: json['kdcName'] as String? ?? '',
      loanCount: (json['loanCount'] as num?)?.toInt() ?? 0,
      coverUrl: json['coverUrl'] as String? ?? '',
    );
  }
}
