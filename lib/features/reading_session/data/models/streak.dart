class StreakDto {
  final int currentStreak;
  final int maxStreak;
  final String? lastReadDate;

  const StreakDto({
    required this.currentStreak,
    required this.maxStreak,
    this.lastReadDate,
  });

  factory StreakDto.fromJson(Map<String, dynamic> json) => StreakDto(
        currentStreak: json['currentStreak'] as int? ?? 0,
        maxStreak: json['maxStreak'] as int? ?? 0,
        lastReadDate: json['lastReadDate'] as String?,
      );

  factory StreakDto.empty() =>
      const StreakDto(currentStreak: 0, maxStreak: 0, lastReadDate: null);
}
