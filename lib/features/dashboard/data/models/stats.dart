class MonthlyStatsDto {
  final int month;
  final int completedCount;
  final int totalPages;
  final Map<String, int> categoryCount;

  MonthlyStatsDto({
    required this.month,
    required this.completedCount,
    required this.totalPages,
    required this.categoryCount,
  });

  factory MonthlyStatsDto.fromJson(Map<String, dynamic> json) {
    return MonthlyStatsDto(
      month: json['month'] as int,
      completedCount: json['completedCount'] as int,
      totalPages: json['totalPages'] as int,
      categoryCount: Map<String, int>.from(json['categoryCount'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'completedCount': completedCount,
      'totalPages': totalPages,
      'categoryCount': categoryCount,
    };
  }
}

class YearlyStatsDto {
  final int year;
  final int completedCount;
  final int totalPages;

  YearlyStatsDto({
    required this.year,
    required this.completedCount,
    required this.totalPages,
  });

  factory YearlyStatsDto.fromJson(Map<String, dynamic> json) {
    return YearlyStatsDto(
      year: json['year'] as int,
      completedCount: json['completedCount'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'completedCount': completedCount,
      'totalPages': totalPages,
    };
  }
}

class CategoryStatsDto {
  final String category;
  final int totalCount;
  final int completedCount;
  final double completionRate;

  CategoryStatsDto({
    required this.category,
    required this.totalCount,
    required this.completedCount,
    required this.completionRate,
  });

  factory CategoryStatsDto.fromJson(Map<String, dynamic> json) {
    return CategoryStatsDto(
      category: json['category'] as String,
      totalCount: json['totalCount'] as int,
      completedCount: json['completedCount'] as int,
      completionRate: (json['completionRate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'totalCount': totalCount,
      'completedCount': completedCount,
      'completionRate': completionRate,
    };
  }
}

class ReadingInsightsDto {
  final double averageReadingDays;
  final String topCategory;
  final int longestReadingDays;
  final String longestBook;

  ReadingInsightsDto({
    required this.averageReadingDays,
    required this.topCategory,
    required this.longestReadingDays,
    required this.longestBook,
  });

  factory ReadingInsightsDto.fromJson(Map<String, dynamic> json) {
    return ReadingInsightsDto(
      averageReadingDays: (json['averageReadingDays'] as num).toDouble(),
      topCategory: json['topCategory'] as String,
      longestReadingDays: json['longestReadingDays'] as int,
      longestBook: json['longestBook'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageReadingDays': averageReadingDays,
      'topCategory': topCategory,
      'longestReadingDays': longestReadingDays,
      'longestBook': longestBook,
    };
  }
}
