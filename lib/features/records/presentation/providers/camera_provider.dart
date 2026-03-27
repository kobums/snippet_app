import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snippet_app/core/error/app_error.dart';

class CameraState {
  final CameraController? controller;
  final bool isInitialized;
  final String? capturedImagePath;
  final bool isProcessing;
  final AppError? error;

  CameraState({
    this.controller,
    this.isInitialized = false,
    this.capturedImagePath,
    this.isProcessing = false,
    this.error,
  });

  CameraState copyWith({
    CameraController? controller,
    bool? isInitialized,
    String? capturedImagePath,
    bool? isProcessing,
    AppError? error,
    bool clearError = false,
    bool clearImage = false,
  }) {
    return CameraState(
      controller: controller ?? this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
      capturedImagePath: clearImage ? null : (capturedImagePath ?? this.capturedImagePath),
      isProcessing: isProcessing ?? this.isProcessing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CameraNotifier extends Notifier<CameraState> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  CameraState build() {
    return CameraState();
  }

  Future<void> initializeCamera() async {
    print('🎥 [Camera] Starting camera initialization...');
    try {
      print('🎥 [Camera] Getting available cameras...');
      final cameras = await availableCameras();
      print('🎥 [Camera] Found ${cameras.length} cameras');

      if (cameras.isEmpty) {
        state = state.copyWith(
          error: const UnknownError('사용 가능한 카메라가 없습니다.'),
        );
        return;
      }

      print('🎥 [Camera] Initializing camera controller...');
      final camera = cameras.first;
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      // CameraController.initialize() will automatically request camera permission
      // and show iOS system dialog if needed
      print('🎥 [Camera] Calling controller.initialize() - this will request permission if needed');
      await controller.initialize();
      print('🎥 [Camera] Camera controller initialized successfully');

      state = state.copyWith(
        controller: controller,
        isInitialized: true,
        clearError: true,
      );
    } catch (e) {
      print('🎥 [Camera] ERROR: $e');

      // Check if error is permission-related
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('permission') ||
          errorMessage.contains('authorized') ||
          errorMessage.contains('access')) {
        state = state.copyWith(
          error: const ValidationError('카메라 권한이 필요합니다. 설정에서 권한을 허용해주세요.'),
        );
      } else {
        state = state.copyWith(
          error: UnknownError('카메라를 시작할 수 없습니다.', details: e.toString()),
        );
      }
    }
  }

  Future<String?> capturePhoto() async {
    if (state.controller == null || !state.isInitialized) {
      return null;
    }

    try {
      state = state.copyWith(isProcessing: true);

      final image = await state.controller!.takePicture();

      // 임시 디렉토리에 이미지 저장
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(image.path).copy(imagePath);

      state = state.copyWith(
        capturedImagePath: imagePath,
        isProcessing: false,
      );

      return imagePath;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: UnknownError('사진 촬영에 실패했습니다.', details: e.toString()),
      );
      return null;
    }
  }

  Future<String?> pickFromGallery() async {
    try {
      state = state.copyWith(isProcessing: true);

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) {
        state = state.copyWith(isProcessing: false);
        return null;
      }

      // 임시 디렉토리에 이미지 복사
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(image.path).copy(imagePath);

      state = state.copyWith(
        capturedImagePath: imagePath,
        isProcessing: false,
      );

      return imagePath;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: UnknownError('이미지 선택에 실패했습니다.', details: e.toString()),
      );
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void disposeCamera() {
    state.controller?.dispose();
  }
}

final cameraProvider = NotifierProvider<CameraNotifier, CameraState>(() {
  return CameraNotifier();
});
