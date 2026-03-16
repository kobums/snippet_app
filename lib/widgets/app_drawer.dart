import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/stats_screen.dart';
import '../screens/reading_calendar_screen.dart';
import '../screens/login_screen.dart';
import '../screens/books/books_have_screen.dart';
import '../screens/books/books_borrow_screen.dart';
import '../screens/books/books_wishlist_screen.dart';
import '../screens/mypage_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Drawer(
      child: Container(
        color: const Color(0xFFF0F0F5),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Snippet',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2,
                        color: Color(0xFF7C5CBF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (user != null) ...[
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Divider(height: 1),

              // Menu items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  children: [
                    _buildMenuItem(
                      context: context,
                      icon: Icons.bar_chart_rounded,
                      title: '통계',
                      onTap: () {
                        Navigator.of(context).pop(); // Close drawer
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StatsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.calendar_month_rounded,
                      title: '독서 캘린더',
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ReadingCalendarScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        '도서 관리',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.library_books,
                      title: '소장한 책',
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BooksHaveScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.auto_stories,
                      title: '빌린 책',
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BooksBorrowScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.favorite_border,
                      title: '위시리스트',
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BooksWishlistScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.person_outline,
                      title: '프로필',
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MyPageScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Logout
              _buildMenuItem(
                context: context,
                icon: Icons.logout,
                title: '로그아웃',
                color: const Color(0xFFFF3B30),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('로그아웃'),
                      content: const Text('정말 로그아웃 하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFF3B30),
                          ),
                          child: const Text('로그아웃'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Colors.black.withValues(alpha: 0.7),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: color ?? Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }
}
