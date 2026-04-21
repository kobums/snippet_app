class ReadingSessionStatsDto {
  final int totalSessions;
  final int totalSeconds;
  final int totalPagesRead;
  final double avgSecondsPerPage;

  ReadingSessionStatsDto({
    required this.totalSessions,
    required this.totalSeconds,
    required this.totalPagesRead,
    required this.avgSecondsPerPage,
  });

  factory ReadingSessionStatsDto.fromJson(Map<String, dynamic> json) {
    return ReadingSessionStatsDto(
      totalSessions: (json['totalSessions'] as num).toInt(),
      totalSeconds: (json['totalSeconds'] as num).toInt(),
      totalPagesRead: (json['totalPagesRead'] as num).toInt(),
      avgSecondsPerPage: (json['avgSecondsPerPage'] as num).toDouble(),
    );
  }

  factory ReadingSessionStatsDto.empty() {
    return ReadingSessionStatsDto(
      totalSessions: 0,
      totalSeconds: 0,
      totalPagesRead: 0,
      avgSecondsPerPage: 0,
    );
  }
}
