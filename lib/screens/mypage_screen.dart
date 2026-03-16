import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/profile/profile_card.dart';
import '../widgets/profile/settings_section.dart';
import '../widgets/profile/logout_button.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('사용자 정보를 불러올 수 없습니다'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '프로필',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Profile Card
                  ProfileCard(user: user),
                  const SizedBox(height: 24),

                  // Settings Section
                  const SettingsSection(),
                  const SizedBox(height: 24),

                  // Logout Button
                  const LogoutButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
      ),
    );
  }
}
