import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';

class DeleteAccountButton extends ConsumerWidget {
  const DeleteAccountButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      child: InkWell(
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                '회원탈퇴',
                style: AppTypography.h4.copyWith(
                  color: DesignTokens.errorMain,
                ),
              ),
              content: Text(
                '정말 회원탈퇴 하시겠습니까?\n\n모든 데이터가 삭제되며 복구할 수 없습니다.',
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
                    '탈퇴',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );

          if (confirmed == true && context.mounted) {
            try {
              await ref.read(authProvider.notifier).deleteAccount();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', '')),
                    backgroundColor: DesignTokens.errorMain,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
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
                Icons.delete_forever,
                color: DesignTokens.errorMain,
                size: 20,
              ),
              const SizedBox(width: DesignTokens.space12),
              Text(
                '회원탈퇴',
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
