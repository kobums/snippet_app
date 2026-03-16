import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../glass_container.dart';
import '../../core/design_tokens.dart';
import '../../core/typography.dart';
import 'profile_field.dart';

/// Fintech Style Profile Card
/// 세련된 프로필 카드 with 디자인 토큰
class ProfileCard extends StatelessWidget {
  final User user;

  const ProfileCard({
    super.key,
    required this.user,
  });

  String _getInitial(String name) {
    if (name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(DesignTokens.space24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DesignTokens.primaryLight,
                  DesignTokens.primaryMain,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.primaryMain,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitial(user.name),
                style: AppTypography.displaySmall.copyWith(
                  color: Colors.white,
                  fontWeight: DesignTokens.fontLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.space20),

          // User name
          Text(
            user.name,
            style: AppTypography.h2.copyWith(
              color: DesignTokens.textPrimary,
            ),
          ),
          const SizedBox(height: DesignTokens.space8),

          // Email
          Text(
            user.email,
            style: AppTypography.bodyMedium.copyWith(
              color: DesignTokens.textSecondary,
            ),
          ),
          const SizedBox(height: DesignTokens.space24),

          // Divider
          Container(
            height: 1,
            color: DesignTokens.neutral200,
          ),
          const SizedBox(height: DesignTokens.space20),

          // Profile fields
          ProfileField(
            label: '이름',
            value: user.name,
          ),
          const SizedBox(height: DesignTokens.space12),
          ProfileField(
            label: '이메일',
            value: user.email,
          ),
        ],
      ),
    );
  }
}
