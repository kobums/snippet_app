import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/app/providers.dart';
import 'package:snippet_app/components/section_header.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/features/profile/presentation/widgets/settings_tile.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/core/config/ocr_config.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/features/records/records_providers.dart';
import 'package:snippet_app/features/profile/presentation/widgets/theme_mode_dialog.dart';

class SettingsSection extends ConsumerWidget {
  const SettingsSection({super.key});

  Future<void> _showNotificationSettings(BuildContext context, WidgetRef ref) async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final status = settings.authorizationStatus;
    final granted = status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text(
          '알림 설정',
          style: AppTypography.h4.copyWith(color: context.colors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  granted ? Icons.notifications_active : Icons.notifications_off_outlined,
                  color: granted ? DesignTokens.success : context.colors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: DesignTokens.space8),
                Text(
                  granted ? '알림이 활성화되어 있습니다' : '알림이 비활성화되어 있습니다',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space12),
            Text(
              '• 반납 기한 D-3, D-1, D-day 알림\n• 매일 오전 9시 전송',
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            if (!granted) ...[
              const SizedBox(height: DesignTokens.space12),
              Text(
                '알림을 받으려면 기기 설정에서 알림을 허용해주세요.',
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!granted)
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await FirebaseMessaging.instance.requestPermission(
                  alert: true,
                  badge: true,
                  sound: true,
                );
                ref.read(fcmServiceProvider).initialize();
              },
              child: Text('알림 허용',
                  style: TextStyle(color: context.colors.primary)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('닫기',
                style: TextStyle(color: context.colors.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, String version) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: DesignTokens.space32,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DesignTokens.primaryLight,
                    DesignTokens.primaryLight,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusLg,
                      ),
                    ),
                    padding: const EdgeInsets.all(DesignTokens.space8),
                    child: Image.asset(
                      'images/snippetbook-removebg.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space12),
                  Text(
                    'Snippet',
                    style: AppTypography.h2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space4),
                  Text(
                    'v$version',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.space24,
                DesignTokens.space20,
                DesignTokens.space24,
                DesignTokens.space8,
              ),
              child: Column(
                children: [
                  Text(
                    '표지 없이, 문장으로만 만나는 책',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  Divider(color: context.colors.border, height: 1),
                  const SizedBox(height: DesignTokens.space12),
                  Text(
                    '© 2025 gowoobro',
                    style: AppTypography.caption.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space4),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.space16,
                0,
                DesignTokens.space16,
                DesignTokens.space16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: DesignTokens.space12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMd,
                      ),
                    ),
                  ),
                  child: Text(
                    '닫기',
                    style: AppTypography.labelLarge.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOcrEngineDialog(BuildContext context, WidgetRef ref) {
    final currentEngine = ref.read(selectedOcrEngineProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'OCR 엔진 선택',
          style: AppTypography.h4.copyWith(color: context.colors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioListTile<OcrEngine>(
              title: Row(
                children: [
                  const Expanded(child: Text('Naver Clova (한글 특화)')),
                  if (!OcrConfig.isNaverClovaConfigured) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Colors.orange[700],
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                OcrConfig.isNaverClovaConfigured
                    ? 'API 키 설정됨'
                    : '.env 파일에 API 키를 설정하세요',
                style: AppTypography.bodySmall.copyWith(
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
                  const Expanded(child: Text('Google Vision (최고 정확도)')),
                  if (!OcrConfig.isGoogleVisionConfigured) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Colors.orange[700],
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                OcrConfig.isGoogleVisionConfigured
                    ? 'API 키 설정됨'
                    : '.env 파일에 API 키를 설정하세요',
                style: AppTypography.bodySmall.copyWith(
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
        title: Text(
          'API 키 필요',
          style: AppTypography.h4.copyWith(color: context.colors.textPrimary),
        ),
        content: Text(
          '$engineName OCR을 사용하려면 .env 파일에 API 키를 설정해야 합니다.\n\n'
          '자세한 내용은 README.md를 참고하세요.',
          style: AppTypography.bodyMedium.copyWith(
            color: context.colors.textPrimary,
          ),
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
      OcrEngine.naverClova => 'Naver Clova (한글 특화)',
      OcrEngine.googleVision => 'Google Vision (최고 정확도)',
    };
  }

  String _getThemeModeName(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => '시스템 설정 따르기',
      ThemeMode.light => '라이트 모드',
      ThemeMode.dark => '다크 모드',
    };
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedEngine = ref.watch(selectedOcrEngineProvider);
    final version = ref.watch(packageVersionProvider).asData?.value ?? '';

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
            subtitle: '반납 기한 및 독서 리마인더',
            onTap: () => _showNotificationSettings(context, ref),
          ),
          const Divider(height: 1),
          SettingsTile(
            icon: Icons.palette_outlined,
            title: '테마 설정',
            subtitle: _getThemeModeName(ref.watch(themeModeProvider)),
            onTap: () => ThemeModeDialog.show(context, ref),
          ),
          const Divider(height: 1),
          SettingsTile(
            icon: Icons.info_outline,
            title: '앱 정보',
            subtitle: 'Snippet 버전 및 정보',
            onTap: () => _showAboutDialog(context, version),
          ),
          const Divider(height: 1),
          SettingsTile(
            icon: Icons.lightbulb_outline,
            title: '기능 제안하기',
            subtitle: '원하는 기능이나 개선사항을 알려주세요',
            onTap: () => context.push(AppRoutes.suggestion),
          ),
        ],
      ),
    );
  }
}
