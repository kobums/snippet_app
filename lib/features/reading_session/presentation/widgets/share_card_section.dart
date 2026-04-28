import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/reading_session/presentation/widgets/share_card_widget.dart';

class ShareCardSection extends StatefulWidget {
  final ShareCardData initialData;
  final String? coverUrl;

  const ShareCardSection({
    super.key,
    required this.initialData,
    this.coverUrl,
  });

  @override
  State<ShareCardSection> createState() => _ShareCardSectionState();
}

class _ShareCardSectionState extends State<ShareCardSection> {
  final _screenshotController = ScreenshotController();
  final _shareButtonKey = GlobalKey();

  late ShareCardData _cardData;
  bool _showBookTitle = true;
  bool _isSharing = false;

  static const _bgCover = 'cover';
  static const _bgPhoto = 'photo';
  static const _bgNone = 'none';
  late String _bgMode;

  @override
  void initState() {
    super.initState();
    final hasCover = widget.coverUrl != null && widget.coverUrl!.isNotEmpty;
    _bgMode = hasCover ? _bgCover : _bgNone;
    _cardData = hasCover
        ? widget.initialData.copyWith(networkCoverUrl: widget.coverUrl)
        : widget.initialData.copyWith(clearNetworkCover: true);
  }

  void _applyBackground(String mode) {
    if (mode == _bgPhoto) {
      _showPhotoSourcePicker();
      return;
    }
    setState(() {
      _bgMode = mode;
      if (mode == _bgCover) {
        _cardData = _cardData.copyWith(
          networkCoverUrl: widget.coverUrl,
          clearLocalPhoto: true,
        );
      } else {
        _cardData = _cardData.copyWith(
          clearLocalPhoto: true,
          clearNetworkCover: true,
        );
      }
    });
  }

  void _showPhotoSourcePicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('촬영'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('갤러리'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1080,
    );
    if (file != null && mounted) {
      setState(() {
        _bgMode = _bgPhoto;
        _cardData = _cardData.copyWith(
          localPhotoPath: file.path,
          clearNetworkCover: true,
        );
      });
    }
  }

  Future<void> _share() async {
    final box =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : Rect.fromLTWH(0, MediaQuery.of(context).size.height / 2, 1, 1);

    setState(() => _isSharing = true);
    try {
      final image = await _screenshotController.capture(pixelRatio: 3.0);
      if (image == null) return;
      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/share_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(filePath).writeAsBytes(image);
      await Share.shareXFiles([XFile(filePath)], sharePositionOrigin: origin);
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('공유 카드', style: AppTypography.h4),
            Row(
              children: [
                Text(
                  '책 제목',
                  style: AppTypography.labelSmall
                      .copyWith(color: DesignTokens.textSecondary),
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
          child: ShareCardWidget(data: _cardData, showBookTitle: _showBookTitle),
        ),
        const SizedBox(height: DesignTokens.space16),
        Row(
          children: [
            _BgButton(
              icon: Icons.auto_stories_rounded,
              label: '책 표지',
              selected: _bgMode == _bgCover,
              onTap: () => _applyBackground(_bgCover),
            ),
            const SizedBox(width: DesignTokens.space12),
            _BgButton(
              icon: Icons.add_photo_alternate_outlined,
              label: '사진 추가',
              selected: _bgMode == _bgPhoto,
              onTap: () => _applyBackground(_bgPhoto),
            ),
            const SizedBox(width: DesignTokens.space12),
            _BgButton(
              icon: Icons.hide_image_outlined,
              label: '기본',
              selected: _bgMode == _bgNone,
              onTap: () => _applyBackground(_bgNone),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.space16),
        _isSharing
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: _shareButtonKey,
                  onPressed: _share,
                  icon: const Icon(Icons.ios_share_rounded),
                  label: const Text('공유하기'),
                  style: FilledButton.styleFrom(
                    backgroundColor: DesignTokens.primaryMain,
                    padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.space16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}

class _BgButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BgButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(vertical: DesignTokens.space12),
          decoration: BoxDecoration(
            color: selected
                ? DesignTokens.primaryMain.withValues(alpha: 0.1)
                : DesignTokens.neutral100,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(
              color: selected
                  ? DesignTokens.primaryMain
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? DesignTokens.primaryMain
                    : DesignTokens.textSecondary,
              ),
              const SizedBox(height: DesignTokens.space4),
              Text(
                label,
                style: TextStyle(
                  fontSize: DesignTokens.fontSize10,
                  color: selected
                      ? DesignTokens.primaryMain
                      : DesignTokens.textSecondary,
                  fontWeight: selected
                      ? DesignTokens.fontMedium
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
