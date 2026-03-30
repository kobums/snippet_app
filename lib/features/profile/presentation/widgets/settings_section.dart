import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/section_header.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/features/profile/presentation/widgets/settings_tile.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/core/config/ocr_config.dart';
import 'package:snippet_app/features/records/records_providers.dart';

class SettingsSection extends ConsumerWidget {
  const SettingsSection({super.key});

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '준비 중입니다',
          style: AppTypography.h4,
        ),
        content: Text(
          '이 기능은 곧 추가될 예정입니다.',
          style: AppTypography.bodyMedium,
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
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [DesignTokens.primaryMain, DesignTokens.accentPurple],
          ),
        ),
        child: Center(
          child: Text(
            'S',
            style: AppTypography.displaySmall.copyWith(
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  void _showOcrEngineDialog(BuildContext context, WidgetRef ref) {
    final currentEngine = ref.read(selectedOcrEngineProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('OCR 엔진 선택', style: AppTypography.h4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioListTile<OcrEngine>(
              title: const Text('ML Kit (무료, 오프라인)'),
              subtitle: const Text('Google ML Kit - 온디바이스 처리'),
              value: OcrEngine.mlKit,
              groupValue: currentEngine,
              onChanged: (value) {
                if (value != null) {
                  ref.read(selectedOcrEngineProvider.notifier).setEngine(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<OcrEngine>(
              title: Row(
                children: [
                  const Text('Naver Clova (한글 특화)'),
                  if (!OcrConfig.isNaverClovaConfigured) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: Colors.orange[700]),
                  ],
                ],
              ),
              subtitle: Text(
                OcrConfig.isNaverClovaConfigured
                    ? 'API 키 설정됨'
                    : '.env 파일에 API 키를 설정하세요',
                style: TextStyle(
                  color: OcrConfig.isNaverClovaConfigured
                      ? Colors.green[700]
                      : Colors.orange[700],
                ),
              ),
              value: OcrEngine.naverClova,
              groupValue: currentEngine,
              onChanged: (value) {
                if (value != null) {
                  if (!OcrConfig.isNaverClovaConfigured) {
                    _showApiKeyWarning(context, 'Naver Clova');
                    return;
                  }
                  ref.read(selectedOcrEngineProvider.notifier).setEngine(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<OcrEngine>(
              title: Row(
                children: [
                  const Text('Google Vision (최고 정확도)'),
                  if (!OcrConfig.isGoogleVisionConfigured) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: Colors.orange[700]),
                  ],
                ],
              ),
              subtitle: Text(
                OcrConfig.isGoogleVisionConfigured
                    ? 'API 키 설정됨'
                    : '.env 파일에 API 키를 설정하세요',
                style: TextStyle(
                  color: OcrConfig.isGoogleVisionConfigured
                      ? Colors.green[700]
                      : Colors.orange[700],
                ),
              ),
              value: OcrEngine.googleVision,
              groupValue: currentEngine,
              onChanged: (value) {
                if (value != null) {
                  if (!OcrConfig.isGoogleVisionConfigured) {
                    _showApiKeyWarning(context, 'Google Vision');
                    return;
                  }
                  ref.read(selectedOcrEngineProvider.notifier).setEngine(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _showApiKeyWarning(BuildContext context, String engineName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('API 키 필요', style: AppTypography.h4),
        content: Text(
          '$engineName OCR을 사용하려면 .env 파일에 API 키를 설정해야 합니다.\n\n'
          '자세한 내용은 README.md를 참고하세요.',
          style: AppTypography.bodyMedium,
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

  String _getOcrEngineName(OcrEngine engine) {
    return switch (engine) {
      OcrEngine.mlKit => 'ML Kit (무료)',
      OcrEngine.naverClova => 'Naver Clova (한글 특화)',
      OcrEngine.googleVision => 'Google Vision (최고 정확도)',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedEngine = ref.watch(selectedOcrEngineProvider);

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('설정'),
          const SizedBox(height: DesignTokens.space16),

          // OCR 엔진 설정
          SettingsTile(
            icon: Icons.camera_alt_outlined,
            title: 'OCR 엔진',
            subtitle: _getOcrEngineName(selectedEngine),
            onTap: () => _showOcrEngineDialog(context, ref),
          ),
          const Divider(height: 1),

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
