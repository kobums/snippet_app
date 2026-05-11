import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/records/data/models/record.dart';
import 'package:snippet_app/features/records/presentation/widgets/notes_export_card.dart';

class NotesExportSection extends StatefulWidget {
  final RecordDto record;

  const NotesExportSection({super.key, required this.record});

  @override
  State<NotesExportSection> createState() => _NotesExportSectionState();
}

class _NotesExportSectionState extends State<NotesExportSection> {
  final _screenshotController = ScreenshotController();
  final _shareButtonKey = GlobalKey();
  bool _isDark = false;
  bool _isSharing = false;

  Future<void> _share() async {
    final box = _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : Rect.fromLTWH(0, MediaQuery.of(context).size.height / 2, 1, 1);

    setState(() => _isSharing = true);
    try {
      final image = await _screenshotController.capture(pixelRatio: 3.0);
      if (image == null) return;
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/notes_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(image);
      await Share.shareXFiles([XFile(path)], sharePositionOrigin: origin);
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '메모 이미지',
              style: AppTypography.h4.copyWith(color: context.colors.textPrimary),
            ),
            _ModeToggle(
              isDark: _isDark,
              onToggle: (v) => setState(() => _isDark = v),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.space16),

        // Card preview
        Screenshot(
          controller: _screenshotController,
          child: NotesExportCard(record: widget.record, isDark: _isDark),
        ),
        const SizedBox(height: DesignTokens.space20),

        // Share button
        _isSharing
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: _shareButtonKey,
                  onPressed: _share,
                  icon: const Icon(Icons.ios_share_rounded),
                  label: const Text('이미지로 내보내기'),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: DesignTokens.space16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onToggle;

  const _ModeToggle({required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            icon: Icons.light_mode_rounded,
            label: '라이트',
            selected: !isDark,
            onTap: () => onToggle(false),
          ),
          const SizedBox(width: 2),
          _ToggleButton(
            icon: Icons.dark_mode_rounded,
            label: '다크',
            selected: isDark,
            onTap: () => onToggle(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space12,
          vertical: DesignTokens.space8,
        ),
        decoration: BoxDecoration(
          color: selected ? context.colors.cardBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? context.colors.textPrimary : context.colors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.captionSmall.copyWith(
                color: selected ? context.colors.textPrimary : context.colors.textSecondary,
                fontWeight: selected ? DesignTokens.fontSemiBold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
