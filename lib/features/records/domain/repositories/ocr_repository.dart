import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/records/data/models/ocr_result.dart';

abstract class OcrRepository {
  Future<Result<OcrResult>> recognizeText(String imagePath);
}
