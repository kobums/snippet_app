class ApiConstants {
  // static const String baseUrl = 'https://snippetapi.gowoobro.com/api';
  static const String baseUrl = 'http://10.0.1.14:8008/api';
  static const String prodUrl = 'https://snippetapi.gowoobro.com/api';

  // Auth
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authDeleteAccount = '/auth/account';

  // Snippets
  static const String snippetsCards = '/snippets/cards';
  static const String snippetsArchive = '/snippets/archive';

  // UserBooks
  static const String userbooks = '/userbooks';
  static const String userbooksMonthly = '/userbooks/monthly';
  static const String userbooksProgress = '/userbooks/progress';
  static const String userbooksAll = '/userbooks/all';

  // Records
  static const String records = '/records';
  static const String recordsByBook = '/records/bybook';
  static const String recordsMonthly = '/records/monthly';

  // Stats
  static const String statsMonthly = '/userbooks/stats/monthly';
  static const String statsYearly = '/userbooks/stats/yearly';
  static const String statsCategory = '/userbooks/stats/category';
  static const String statsInsights = '/userbooks/stats/insights';

  // Books
  static const String booksSearch = '/books/search';
}

class AppConstants {
  static const String appGroupId = 'group.com.gowoobro.snippet';
  static const String widgetProviderName = 'SnippetWidgetProvider';
  static const String widgetIosName = 'snippetWidget';

  static const int snippetFetchCount = 10;
  static const int snippetLowThreshold = 3;
}

class StorageConstants {
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
}
