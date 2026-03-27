import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:snippet_app/features/auth/presentation/screens/login_screen.dart';
import 'package:snippet_app/features/auth/presentation/screens/register_screen.dart';
import 'package:snippet_app/features/snippet/presentation/screens/snippet_screen.dart';
import 'package:snippet_app/features/snippet/presentation/screens/archive_screen.dart';
import 'package:snippet_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:snippet_app/features/dashboard/presentation/screens/stats_screen.dart';
import 'package:snippet_app/features/dashboard/presentation/screens/reading_calendar_screen.dart';
import 'package:snippet_app/features/records/presentation/screens/records_screen.dart';
import 'package:snippet_app/features/records/presentation/screens/edit_record_screen.dart';
import 'package:snippet_app/features/records/presentation/screens/add_record_screen.dart';
import 'package:snippet_app/features/records/data/models/record.dart';
import 'package:snippet_app/features/library/presentation/screens/library_screen.dart';
import 'package:snippet_app/features/library/presentation/screens/book_search_screen.dart';
import 'package:snippet_app/features/library/presentation/screens/book_detail_screen.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/profile/presentation/screens/mypage_screen.dart';
import 'package:snippet_app/app/main_screen.dart';

/// Route paths
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';

  // Shell routes (bottom nav tabs)
  static const snippet = '/snippet';
  static const dashboard = '/dashboard';
  static const records = '/records';
  static const library = '/library';
  static const profile = '/profile';

  // Sub-routes
  static const bookDetail = '/bookDetail';
  static const editRecord = '/editRecord';
  static const addRecord = '/addRecord';
  static const bookSearch = '/book-search';
  static const archive = '/archive';
  static const stats = '/stats';
  static const readingCalendar = '/readingCalendar';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.snippet,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SnippetScreen()),
          ),
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.records,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: RecordsScreen()),
          ),
          GoRoute(
            path: AppRoutes.library,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LibraryScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MyPageScreen()),
          ),
        ],
      ),

      // Full-screen routes (outside shell)
      GoRoute(
        path: AppRoutes.bookDetail,
        builder: (context, state) =>
            BookDetailScreen(book: state.extra as UserBookDto),
      ),
      GoRoute(
        path: AppRoutes.editRecord,
        builder: (context, state) =>
            EditRecordScreen(record: state.extra as RecordDto),
      ),
      GoRoute(
        path: AppRoutes.addRecord,
        builder: (context, state) {
          final params = state.extra as AddRecordScreenParams;
          return AddRecordScreen(
            books: params.books,
            initialType: params.initialType,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bookSearch,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: BookSearchScreen(
            initialBookType: state.extra as BookType?,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleTween = Tween(
              begin: 0.5,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOutCubic));
            final fadeTween = Tween(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeIn));

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: ScaleTransition(
                scale: animation.drive(scaleTween),
                alignment: Alignment.bottomRight,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      GoRoute(
        path: AppRoutes.archive,
        builder: (context, state) => const ArchiveScreen(),
      ),
      GoRoute(
        path: AppRoutes.stats,
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: AppRoutes.readingCalendar,
        builder: (context, state) {
          final year = state.uri.queryParameters['year'];
          final month = state.uri.queryParameters['month'];
          return ReadingCalendarScreen(
            initialYear: year != null ? int.tryParse(year) : null,
            initialMonth: month != null ? int.tryParse(month) : null,
          );
        },
      ),
    ],
  );
});
