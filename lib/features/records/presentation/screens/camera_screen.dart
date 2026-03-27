import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:snippet_app/features/records/presentation/providers/camera_provider.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/app/router.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  late final CameraNotifier _cameraNotifier;

  @override
  void initState() {
    super.initState();
    _cameraNotifier = ref.read(cameraProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cameraNotifier.initializeCamera();
    });
  }

  @override
  void dispose() {
    _cameraNotifier.disposeCamera();
    super.dispose();
  }

  Future<void> _handleCapture() async {
    final imagePath = await ref.read(cameraProvider.notifier).capturePhoto();
    if (imagePath != null && mounted) {
      context.push(AppRoutes.imageHighlighter, extra: imagePath);
    }
  }

  Future<void> _handleGalleryPick() async {
    final imagePath = await ref.read(cameraProvider.notifier).pickFromGallery();
    if (imagePath != null && mounted) {
      context.push(AppRoutes.imageHighlighter, extra: imagePath);
    }
  }

  Future<void> _handlePermissionDenied() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카메라 권한 필요'),
        content: const Text(
          '책 속 문장을 촬영하려면 카메라 권한이 필요합니다.\n'
          '기기 설정 > Snippet > 카메라 권한을 허용해주세요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cameraProvider);

    // 에러 처리
    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (state.error!.message.contains('권한')) {
          _handlePermissionDenied();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!.message),
              backgroundColor: DesignTokens.errorMain,
            ),
          );
          context.pop();
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 카메라 프리뷰
          if (state.isInitialized && state.controller != null)
            Center(child: CameraPreview(state.controller!))
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // 닫기 버튼
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
            ),
          ),

          // 촬영 및 갤러리 버튼
          if (state.isInitialized)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 갤러리 버튼
                    IconButton(
                      icon: const Icon(
                        Icons.photo_library,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: state.isProcessing ? null : _handleGalleryPick,
                    ),

                    // 촬영 버튼
                    GestureDetector(
                      onTap: state.isProcessing ? null : _handleCapture,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: state.isProcessing
                              ? Colors.grey.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                        child: state.isProcessing
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : null,
                      ),
                    ),

                    // 빈 공간 (대칭을 위해)
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
