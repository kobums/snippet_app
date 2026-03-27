import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/records/data/models/ocr_result.dart';
import 'package:snippet_app/features/records/domain/repositories/ocr_repository.dart';

class ExtractTextFromImageUseCase {
  final OcrRepository _repository;

  ExtractTextFromImageUseCase(this._repository);

  Future<Result<OcrResult>> call(String imagePath) {
    return _repository.recognizeText(imagePath);
  }
}
