import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:snippet_app/features/profile/presentation/widgets/profile_card.dart';
import 'package:snippet_app/features/profile/presentation/widgets/settings_section.dart';
import 'package:snippet_app/features/profile/presentation/widgets/logout_button.dart';
import 'package:snippet_app/features/profile/presentation/widgets/delete_account_button.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('사용자 정보를 불러올 수 없습니다')));
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: CustomScrollView(
        slivers: [
          AppAppBar.sliver(title: '프로필'),
          SliverPadding(
            padding: const EdgeInsets.all(DesignTokens.space16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ProfileCard(user: user),
                const SizedBox(height: 24),
                const SettingsSection(),
                const SizedBox(height: 24),
                const LogoutButton(),
                const SizedBox(height: 12),
                const DeleteAccountButton(),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
