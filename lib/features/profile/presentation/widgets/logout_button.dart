import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      child: InkWell(
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                '로그아웃',
                style: AppTypography.h4,
              ),
              content: Text(
                '정말 로그아웃 하시겠습니까?',
                style: AppTypography.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: DesignTokens.errorMain,
                  ),
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          );

          if (confirmed == true && context.mounted) {
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) {
              context.go(AppRoutes.login);
            }
          }
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignTokens.space16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout,
                color: DesignTokens.errorMain,
                size: 20,
              ),
              const SizedBox(width: DesignTokens.space12),
              Text(
                '로그아웃',
                style: AppTypography.bodyLarge.copyWith(
                  color: DesignTokens.errorMain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
