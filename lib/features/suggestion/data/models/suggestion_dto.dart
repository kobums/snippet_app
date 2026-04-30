enum SuggestionCategory {
  feature,
  bug,
  improvement,
  other;

  String toJson() => switch (this) {
        SuggestionCategory.feature => 'FEATURE',
        SuggestionCategory.bug => 'BUG',
        SuggestionCategory.improvement => 'IMPROVEMENT',
        SuggestionCategory.other => 'OTHER',
      };

  String get label => switch (this) {
        SuggestionCategory.feature => '기능 추가',
        SuggestionCategory.bug => '버그 신고',
        SuggestionCategory.improvement => '개선 제안',
        SuggestionCategory.other => '기타',
      };
}

class SuggestionAddRequestDto {
  final SuggestionCategory category;
  final String? title;
  final String content;

  const SuggestionAddRequestDto({
    required this.category,
    this.title,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'category': category.toJson(),
        if (title != null && title!.isNotEmpty) 'title': title,
        'content': content,
      };
}

class SuggestionDto {
  final int id;
  final String category;
  final String? title;
  final String content;
  final String status;
  final DateTime createDate;

  const SuggestionDto({
    required this.id,
    required this.category,
    this.title,
    required this.content,
    required this.status,
    required this.createDate,
  });

  factory SuggestionDto.fromJson(Map<String, dynamic> json) => SuggestionDto(
        id: json['id'] as int,
        category: json['category'] as String,
        title: json['title'] as String?,
        content: json['content'] as String,
        status: json['status'] as String,
        createDate: DateTime.parse(json['createDate'] as String),
      );
}
