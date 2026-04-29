enum RecordType {
  snippet,
  diary,
  review;

  String toJson() => name;

  static RecordType fromJson(String json) {
    return RecordType.values.firstWhere(
      (type) => type.name == json,
      orElse: () => RecordType.snippet,
    );
  }

  String get label {
    switch (this) {
      case RecordType.snippet:
        return '스니펫';
      case RecordType.diary:
        return '독서일기';
      case RecordType.review:
        return '리뷰';
    }
  }
}

class RecordDto {
  final int id;
  final int bookId;
  final String bookTitle;
  final String bookAuthor;
  final String bookCoverUrl;
  final RecordType type;
  final String text;
  final String? tag;
  final int? relatedPage;
  final String createDate;

  RecordDto({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookCoverUrl,
    required this.type,
    required this.text,
    this.tag,
    this.relatedPage,
    required this.createDate,
  });

  factory RecordDto.fromJson(Map<String, dynamic> json) {
    return RecordDto(
      id: json['id'] as int,
      bookId: json['bookId'] as int,
      bookTitle: json['bookTitle'] as String,
      bookAuthor: json['bookAuthor'] as String? ?? '',
      bookCoverUrl: json['bookCoverUrl'] as String? ?? '',
      type: RecordType.fromJson(json['type'] as String),
      text: json['text'] as String,
      tag: json['tag'] as String?,
      relatedPage: json['relatedPage'] as int?,
      createDate: json['createDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookCoverUrl': bookCoverUrl,
      'type': type.toJson(),
      'text': text,
      'tag': tag,
      'relatedPage': relatedPage,
      'createDate': createDate,
    };
  }

  RecordDto copyWith({
    int? id,
    int? bookId,
    String? bookTitle,
    String? bookAuthor,
    String? bookCoverUrl,
    RecordType? type,
    String? text,
    String? tag,
    int? relatedPage,
    String? createDate,
  }) {
    return RecordDto(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      bookCoverUrl: bookCoverUrl ?? this.bookCoverUrl,
      type: type ?? this.type,
      text: text ?? this.text,
      tag: tag ?? this.tag,
      relatedPage: relatedPage ?? this.relatedPage,
      createDate: createDate ?? this.createDate,
    );
  }
}

class RecordAddRequestDto {
  final RecordType type;
  final String text;
  final String? tag;
  final int? relatedPage;

  RecordAddRequestDto({
    required this.type,
    required this.text,
    this.tag,
    this.relatedPage,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      'text': text,
      'tag': tag,
      'relatedPage': relatedPage,
    };
  }
}
