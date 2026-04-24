import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/components/app_button.dart';
import 'package:snippet_app/features/library/presentation/providers/library_provider.dart';
import 'package:snippet_app/features/reading_session/presentation/providers/reading_session_provider.dart';
import 'package:snippet_app/features/reading_session/presentation/widgets/share_card_widget.dart';
import 'package:snippet_app/features/reading_session/reading_session_providers.dart';

class SessionCompleteScreen extends ConsumerStatefulWidget {
  const SessionCompleteScreen({super.key});

  @override
  ConsumerState<SessionCompleteScreen> createState() =>
      _SessionCompleteScreenState();
}

class _SessionCompleteScreenState extends ConsumerState<SessionCompleteScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _showBookTitle = true;
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readingSessionProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: DesignTokens.textPrimary),
          onPressed: () => _exitSession(context),
        ),
        title: const Text(
          '독서 완료',
          style: TextStyle(
            fontSize: DesignTokens.fontSize18,
            fontWeight: DesignTokens.fontMedium,
            color: DesignTokens.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(state),
            const SizedBox(height: DesignTokens.space32),
            _buildShareCardSection(state),
            const SizedBox(height: DesignTokens.space24),
            _buildPhotoSection(),
            const SizedBox(height: DesignTokens.space32),
            AppButton(
              text: '완료',
              onPressed: () => _exitSession(context),
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),
            const SizedBox(height: DesignTokens.space16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ReadingSessionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.book != null)
          Text(
            state.book!.title,
            style: const TextStyle(
              fontSize: DesignTokens.fontSize20,
              fontWeight: DesignTokens.fontMedium,
              color: DesignTokens.textPrimary,
            ),
          ),
        const SizedBox(height: DesignTokens.space20),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: '독서 시간',
                value: state.formattedTime,
                icon: Icons.timer_outlined,
              ),
            ),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: _StatCard(
                label: '읽은 페이지',
                value: '${state.pagesRead} p',
                icon: Icons.menu_book_rounded,
              ),
            ),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: _StatCard(
                label: '페이스',
                value: state.paceLabel,
                icon: Icons.speed_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShareCardSection(ReadingSessionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '공유 카드',
              style: TextStyle(
                fontSize: DesignTokens.fontSize16,
                fontWeight: DesignTokens.fontMedium,
                color: DesignTokens.textPrimary,
              ),
            ),
            Row(
              children: [
                const Text(
                  '책 제목 표시',
                  style: TextStyle(
                    fontSize: DesignTokens.fontSize12,
                    color: DesignTokens.textSecondary,
                  ),
                ),
                const SizedBox(width: DesignTokens.space8),
                Switch(
                  value: _showBookTitle,
                  onChanged: (v) => setState(() => _showBookTitle = v),
                  activeThumbColor: DesignTokens.primaryMain,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.space12),
        Screenshot(
          controller: _screenshotController,
          child: ShareCardWidget(
            session: state,
            showBookTitle: _showBookTitle,
          ),
        ),
        const SizedBox(height: DesignTokens.space16),
        _isSharing
            ? const Center(child: CircularProgressIndicator())
            : AppButton(
                text: '인스타그램에 공유',
                onPressed: () => _shareCard(),
                variant: AppButtonVariant.outlined,
                isFullWidth: true,
              ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    final state = ref.read(readingSessionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '사진 추가',
          style: TextStyle(
            fontSize: DesignTokens.fontSize16,
            fontWeight: DesignTokens.fontMedium,
            color: DesignTokens.textPrimary,
          ),
        ),
        const SizedBox(height: DesignTokens.space4),
        Text(
          '공유 카드 배경으로 사용됩니다',
          style: const TextStyle(
            fontSize: DesignTokens.fontSize12,
            color: DesignTokens.textSecondary,
          ),
        ),
        const SizedBox(height: DesignTokens.space12),
        Row(
          children: [
            Expanded(
              child: _PhotoButton(
                icon: Icons.camera_alt_outlined,
                label: '촬영',
                onTap: () => _pickPhoto(ImageSource.camera),
              ),
            ),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: _PhotoButton(
                icon: Icons.photo_library_outlined,
                label: '갤러리',
                onTap: () => _pickPhoto(ImageSource.gallery),
              ),
            ),
            if (state.photoPath != null) ...[
              const SizedBox(width: DesignTokens.space12),
              Expanded(
                child: _PhotoButton(
                  icon: Icons.delete_outline,
                  label: '제거',
                  onTap: () =>
                      ref.read(readingSessionProvider.notifier).setPhoto(''),
                  isDestructive: true,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1080,
    );
    if (file != null) {
      ref.read(readingSessionProvider.notifier).setPhoto(file.path);
    }
  }

  Future<void> _shareCard() async {
    setState(() => _isSharing = true);
    try {
      final image = await _screenshotController.capture(pixelRatio: 3.0);
      if (image == null) return;
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/reading_session_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(filePath).writeAsBytes(image);
      await Share.shareXFiles([XFile(filePath)]);
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _exitSession(BuildContext context) {
    ref.read(sessionJustCompletedProvider.notifier).signal();
    ref.read(readingSessionProvider.notifier).reset();
    ref.read(libraryProvider.notifier).loadAllBooks();
    context.pop();
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: DesignTokens.neutral100,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: DesignTokens.textSecondary),
          const SizedBox(height: DesignTokens.space8),
          Text(
            value,
            style: const TextStyle(
              fontSize: DesignTokens.fontSize16,
              fontWeight: DesignTokens.fontMedium,
              color: DesignTokens.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.space4),
          Text(
            label,
            style: const TextStyle(
              fontSize: DesignTokens.fontSize10,
              color: DesignTokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PhotoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _PhotoButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.space16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDestructive
                ? DesignTokens.error.withValues(alpha: 0.4)
                : DesignTokens.neutral300,
          ),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDestructive
                  ? DesignTokens.error
                  : DesignTokens.textSecondary,
            ),
            const SizedBox(height: DesignTokens.space4),
            Text(
              label,
              style: TextStyle(
                fontSize: DesignTokens.fontSize12,
                color: isDestructive
                    ? DesignTokens.error
                    : DesignTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
