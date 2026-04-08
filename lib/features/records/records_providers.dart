import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/app/providers.dart';
import 'package:snippet_app/core/config/ocr_config.dart';
import 'package:snippet_app/features/records/data/datasources/record_remote_datasource.dart';
import 'package:snippet_app/features/records/data/datasources/ocr_datasource.dart';
import 'package:snippet_app/features/records/data/datasources/naver_clova_ocr_datasource.dart';
import 'package:snippet_app/features/records/data/datasources/google_vision_ocr_datasource.dart';
import 'package:snippet_app/features/records/data/repositories/record_repository_impl.dart';
import 'package:snippet_app/features/records/data/repositories/ocr_repository_impl.dart';
import 'package:snippet_app/features/records/domain/repositories/record_repository.dart';
import 'package:snippet_app/features/records/domain/repositories/ocr_repository.dart';
import 'package:snippet_app/features/records/domain/usecases/add_record_usecase.dart';
import 'package:snippet_app/features/records/domain/usecases/delete_record_usecase.dart';
import 'package:snippet_app/features/records/domain/usecases/fetch_monthly_records_usecase.dart';
import 'package:snippet_app/features/records/domain/usecases/fetch_records_by_book_usecase.dart';
import 'package:snippet_app/features/records/domain/usecases/update_record_usecase.dart';
import 'package:snippet_app/features/records/domain/usecases/extract_text_from_image_usecase.dart';

// DataSources
final recordRemoteDataSourceProvider =
    Provider<RecordRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return RecordRemoteDataSourceImpl(dio);
});

// Repositories
final recordRepositoryProvider = Provider<RecordRepository>((ref) {
  final remote = ref.read(recordRemoteDataSourceProvider);
  return RecordRepositoryImpl(remote);
});

// UseCases
final fetchMonthlyRecordsUseCaseProvider =
    Provider<FetchMonthlyRecordsUseCase>((ref) {
  return FetchMonthlyRecordsUseCase(ref.read(recordRepositoryProvider));
});

final fetchRecordsByBookUseCaseProvider =
    Provider<FetchRecordsByBookUseCase>((ref) {
  return FetchRecordsByBookUseCase(ref.read(recordRepositoryProvider));
});

final addRecordUseCaseProvider = Provider<AddRecordUseCase>((ref) {
  return AddRecordUseCase(ref.read(recordRepositoryProvider));
});

final updateRecordUseCaseProvider = Provider<UpdateRecordUseCase>((ref) {
  return UpdateRecordUseCase(ref.read(recordRepositoryProvider));
});

final deleteRecordUseCaseProvider = Provider<DeleteRecordUseCase>((ref) {
  return DeleteRecordUseCase(ref.read(recordRepositoryProvider));
});

// OCR Engine 선택 (설정에서 변경 가능)
final selectedOcrEngineProvider = NotifierProvider<_SelectedOcrEngineNotifier, OcrEngine>(() {
  return _SelectedOcrEngineNotifier();
});

class _SelectedOcrEngineNotifier extends Notifier<OcrEngine> {
  @override
  OcrEngine build() {
    return OcrConfig.defaultEngine;
  }

  void setEngine(OcrEngine engine) {
    state = engine;
  }
}

// OCR DataSources (선택된 엔진에 따라 다른 datasource 반환)
final ocrDataSourceProvider = Provider<OcrDataSource>((ref) {
  final selectedEngine = ref.watch(selectedOcrEngineProvider);
  final dio = ref.read(dioProvider);

  return switch (selectedEngine) {
    OcrEngine.naverClova => NaverClovaOcrDataSource(dio),
    OcrEngine.googleVision => GoogleVisionOcrDataSource(dio),
  };
});

// OCR Repositories
final ocrRepositoryProvider = Provider<OcrRepository>((ref) {
  return OcrRepositoryImpl(ref.read(ocrDataSourceProvider));
});

// OCR UseCases
final extractTextFromImageUseCaseProvider =
    Provider<ExtractTextFromImageUseCase>((ref) {
  return ExtractTextFromImageUseCase(ref.read(ocrRepositoryProvider));
});
