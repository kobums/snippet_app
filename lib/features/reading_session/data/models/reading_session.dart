class ReadingSessionDto {
  final int id;
  final int userBookId;
  final int bookId;
  final String bookTitle;
  final String bookAuthor;
  final String bookCoverUrl;
  final int durationSeconds;
  final int startPage;
  final int endPage;
  final int pagesRead;
  final double secondsPerPage;
  final String sessionDate;
  final String createDate;

  ReadingSessionDto({
    required this.id,
    required this.userBookId,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookCoverUrl,
    required this.durationSeconds,
    required this.startPage,
    required this.endPage,
    required this.pagesRead,
    required this.secondsPerPage,
    required this.sessionDate,
    required this.createDate,
  });

  factory ReadingSessionDto.fromJson(Map<String, dynamic> json) {
    return ReadingSessionDto(
      id: json['id'] as int,
      userBookId: json['userBookId'] as int,
      bookId: json['bookId'] as int,
      bookTitle: json['bookTitle'] as String,
      bookAuthor: json['bookAuthor'] as String? ?? '',
      bookCoverUrl: json['bookCoverUrl'] as String? ?? '',
      durationSeconds: json['durationSeconds'] as int,
      startPage: json['startPage'] as int,
      endPage: json['endPage'] as int,
      pagesRead: json['pagesRead'] as int,
      secondsPerPage: (json['secondsPerPage'] as num).toDouble(),
      sessionDate: json['sessionDate'] as String,
      createDate: json['createDate'] as String,
    );
  }
}

class ReadingSessionAddRequestDto {
  final int userBookId;
  final int durationSeconds;
  final int startPage;
  final int endPage;
  final String sessionDate;

  ReadingSessionAddRequestDto({
    required this.userBookId,
    required this.durationSeconds,
    required this.startPage,
    required this.endPage,
    required this.sessionDate,
  });

  Map<String, dynamic> toJson() => {
        'userBookId': userBookId,
        'durationSeconds': durationSeconds,
        'startPage': startPage,
        'endPage': endPage,
        'sessionDate': sessionDate,
      };
}
