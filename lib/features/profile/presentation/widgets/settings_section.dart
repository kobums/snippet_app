import 'package:flutter/material.dart';
import 'package:snippet_app/components/section_header.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/features/profile/presentation/widgets/settings_tile.dart';
import 'package:snippet_app/core/design_tokens.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '준비 중입니다',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
        content: const Text(
          '이 기능은 곧 추가될 예정입니다.',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Snippet',
      applicationVersion: '2.0.0',
      applicationLegalese: '© 2024 gowoobro',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [DesignTokens.primaryMain, Color(0xFFB794F4)],
          ),
        ),
        child: const Center(
          child: Text(
            'S',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('설정'),
          const SizedBox(height: 16),

          // Settings tiles
          SettingsTile(
            icon: Icons.notifications_outlined,
            title: '알림 설정',
            subtitle: '독서 리마인더 및 알림',
            onTap: () => _showComingSoonDialog(context),
          ),
          const Divider(height: 1),
          SettingsTile(
            icon: Icons.palette_outlined,
            title: '테마 설정',
            subtitle: '다크모드 (준비중)',
            onTap: () => _showComingSoonDialog(context),
          ),
          const Divider(height: 1),
          SettingsTile(
            icon: Icons.info_outline,
            title: '앱 정보',
            subtitle: 'Snippet 버전 및 정보',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }
}
