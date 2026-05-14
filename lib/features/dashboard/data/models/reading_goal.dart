class ReadingGoalDto {
  final int year;
  final int targetBooks;
  final int completedBooks;

  const ReadingGoalDto({
    required this.year,
    required this.targetBooks,
    required this.completedBooks,
  });

  factory ReadingGoalDto.fromJson(Map<String, dynamic> json) => ReadingGoalDto(
        year: json['year'] as int? ?? DateTime.now().year,
        targetBooks: json['targetBooks'] as int? ?? 0,
        completedBooks: json['completedBooks'] as int? ?? 0,
      );

  factory ReadingGoalDto.empty() => ReadingGoalDto(
        year: DateTime.now().year,
        targetBooks: 0,
        completedBooks: 0,
      );

  double get progress =>
      targetBooks > 0 ? (completedBooks / targetBooks).clamp(0.0, 1.0) : 0.0;
}
