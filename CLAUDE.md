# Snippet Flutter App

## 기술 스택
- **Flutter 3.11+** / Dart
- **Riverpod 3.2.1** 상태 관리 (Notifier 패턴)
- **Dio 5.9.1** HTTP 클라이언트
- **go_router 14.8.1** 선언적 라우팅
- **SharedPreferences** + **FlutterSecureStorage** 로컬 저장
- **fl_chart** 차트 / **table_calendar** 캘린더
- **home_widget** 홈 화면 위젯
- **Google Fonts** (Inter)

## 아키텍처

Feature-first Clean Architecture + Riverpod DI

```
Screen → Provider (thin Notifier) → UseCase → Repository → DataSource → Backend
```

- **Sealed class Result<T>**: `Success<T>` / `Failure<T>` with `when()` 패턴 매칭
- **Sealed class AppError**: NetworkError, ServerError, AuthError, ValidationError, CacheError, UnknownError
- **UseCase**: 단일 책임 클래스, Riverpod provider로 주입
- **Repository**: domain/에 추상 인터페이스, data/에 구현체

## 디렉토리 구조

```
lib/
├── main.dart                      # 앱 진입점 (SharedPreferences override)
├── app/
│   ├── main_screen.dart           # ShellRoute 하단 내비게이션
│   ├── router.dart                # go_router 선언적 라우팅
│   └── providers.dart             # Dio, SharedPreferences, SecureStorage
├── core/
│   ├── design_tokens.dart         # 색상, 간격, 반경, 그림자, 블러, 애니메이션
│   ├── typography.dart            # Display/Heading/Body/Label/Caption
│   ├── theme.dart                 # Material 3 테마 (Inter 폰트)
│   ├── animations.dart            # fadeIn, slideIn, scaleIn, PageRoute 헬퍼
│   ├── constants.dart             # API URL, Storage key 상수
│   ├── error/app_error.dart       # Sealed AppError 타입
│   ├── error/error_handler.dart   # DioException → AppError 변환
│   ├── result/result.dart         # Sealed Result<T> 타입
│   └── utils/temp_id_generator.dart
├── components/                    # 재사용 UI 컴포넌트 (app_* 접두사)
│   ├── app_button.dart            # primary/secondary/outlined/ghost/danger
│   ├── app_tab_bar.dart
│   ├── app_refresh_indicator.dart  # pull-to-refresh + 햅틱
│   ├── app_app_bar.dart / app_card.dart / app_fab.dart / app_input.dart / app_select.dart
│   ├── search_field.dart / section_header.dart
│   └── month_navigator.dart / year_navigator.dart
├── widgets/                       # 공통 위젯
│   ├── glass_container.dart       # 글래스모피즘 (subtle/medium/strong)
│   ├── glass_bottom_nav.dart
│   ├── loading_shimmer.dart / action_button.dart
│   └── layout/bottom_nav_layout.dart
└── features/                      # 기능별 모듈
    ├── auth/
    │   ├── auth_providers.dart     # DI (datasource → repository → usecase)
    │   ├── data/
    │   │   ├── datasources/       # auth_local_datasource, auth_remote_datasource
    │   │   ├── models/            # user.dart, auth_params.dart
    │   │   └── repositories/      # auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── repositories/      # auth_repository.dart (추상)
    │   │   └── usecases/          # check_auth, login, logout, register
    │   └── presentation/
    │       ├── providers/         # auth_provider.dart (AuthNotifier)
    │       └── screens/           # splash, login, register
    ├── snippet/
    │   ├── snippet_providers.dart
    │   ├── data/                  # datasources, models (snippet, snippet_archive), repositories
    │   ├── domain/                # repositories, usecases (fetch_snippets, handle_swipe, fetch_archive, update_widget)
    │   └── presentation/
    │       ├── providers/         # snippet_provider.dart
    │       ├── screens/           # snippet_screen, home_screen, archive_screen
    │       └── widgets/           # swipe_card.dart
    ├── dashboard/
    │   ├── dashboard_providers.dart
    │   ├── data/                  # datasources (stats_remote, calendar_share), models (stats), repositories
    │   ├── domain/                # repositories, usecases (monthly/yearly/category/insights stats)
    │   └── presentation/
    │       ├── providers/         # stats_provider.dart
    │       ├── screens/           # dashboard_screen, stats_screen, reading_calendar_screen
    │       └── widgets/           # dashboard_stats/progress/library_section, reading_calendar, charts
    ├── records/
    │   ├── records_providers.dart
    │   ├── data/                  # datasources, models (record), repositories
    │   ├── domain/                # repositories, usecases (add/delete/update/fetch records)
    │   └── presentation/
    │       ├── providers/         # record_provider.dart
    │       ├── screens/           # records_screen
    │       └── widgets/           # record_card, add/edit_record_bottom_sheet
    ├── library/
    │   ├── library_providers.dart
    │   ├── data/                  # datasources (book/user_book remote), models (user_book, book_search), repositories
    │   ├── domain/                # repositories, usecases (add/delete/update/fetch/search books)
    │   └── presentation/
    │       ├── providers/         # book_provider.dart, library_provider.dart
    │       ├── screens/           # library_screen, book_search_screen, books/ (have/borrow/wishlist)
    │       └── widgets/           # book_grid, book_grid_card, add/detail_bottom_sheet
    └── profile/
        └── presentation/
            ├── screens/           # mypage_screen
            └── widgets/           # profile_card, settings_section, logout_button, etc.
```

## 내비게이션 (go_router)

```
AppRoutes:
  /              → SplashScreen (인증 체크)
  /login         → LoginScreen
  /register      → RegisterScreen
  ShellRoute (MainScreen 하단 내비게이션):
    /snippet     → SnippetScreen (스와이프 | 보관함)
    /dashboard   → DashboardScreen (통계 | 진행 | 서재)
    /records     → RecordsScreen (스니펫 | 독서일기 | 리뷰)
    /library     → LibraryScreen (소장 | 대출 | 위시)
    /profile     → MyPageScreen
  Full-screen routes:
    /book-search      → BookSearchScreen
    /archive          → ArchiveScreen
    /stats            → StatsScreen
    /readingCalendar  → ReadingCalendarScreen
```

## 디자인 시스템
- **DesignTokens**: 색상, 간격(4px 기반), 반경, 그림자, 블러, 애니메이션 속도
- **AppTypography**: 텍스트 계층 (Display → Caption), withColor/withWeight 유틸리티
- **AppTheme**: Material 3, scaffold 배경 transparent, Inter 폰트
- **GlassContainer**: 글래스모피즘 효과 (subtle/medium/strong 3단계)
- 모든 화면 흰색 배경 사용

## 컨벤션
- Feature 모듈: `features/{name}/data|domain|presentation/`
- DI 설정: `features/{name}/{name}_providers.dart`
- 화면: `*_screen.dart`
- 위젯: 기능별 `presentation/widgets/`
- 컴포넌트: `app_*` 접두사 (재사용 UI, `components/`)
- 모델: `*Dto` 접미사
- Provider: `*Provider`, `*Notifier`, `*State`
- DataSource: `*_datasource.dart` (remote/local)
- UseCase: `*_usecase.dart` (단일 책임)
- Repository: domain/에 추상, data/에 `*_impl.dart`
- API URL에 하이픈(-) 사용 금지
- API Base URL: `core/constants.dart`에서 설정
