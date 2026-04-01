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
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        state = state.copyWith(
          error: const UnknownError('사용 가능한 카메라가 없습니다.'),
        );
        return;
      }

      final camera = cameras.first;
      final controller = CameraController(
        camera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );

      await controller.initialize();

      state = state.copyWith(
        controller: controller,
        isInitialized: true,
        clearError: true,
      );
    } catch (e) {
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
    state = CameraState();
  }
}

final cameraProvider = NotifierProvider<CameraNotifier, CameraState>(() {
  return CameraNotifier();
});
