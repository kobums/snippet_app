import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/features/records/data/datasources/ocr_datasource.dart';
import 'package:snippet_app/features/records/data/models/ocr_result.dart';
import 'package:snippet_app/features/records/domain/repositories/ocr_repository.dart';

class OcrRepositoryImpl implements OcrRepository {
  final OcrDataSource _dataSource;

  OcrRepositoryImpl(this._dataSource);

  @override
  Future<Result<OcrResult>> recognizeText(String imagePath) async {
    try {
      final text = await _dataSource.extractTextFromImage(imagePath);

      return Success(OcrResult(
        extractedText: text,
        imagePath: imagePath,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      return Failure(
        UnknownError(
          '텍스트를 인식할 수 없습니다',
          details: e.toString(),
        ),
      );
    }
  }
}
