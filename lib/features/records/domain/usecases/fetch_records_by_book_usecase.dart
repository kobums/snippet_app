import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/records/data/models/record.dart';
import 'package:snippet_app/features/records/domain/repositories/record_repository.dart';

class FetchRecordsByBookUseCase {
  final RecordRepository _repository;

  FetchRecordsByBookUseCase(this._repository);

  Future<Result<List<RecordDto>>> call(int bookId, {RecordType? type}) {
    return _repository.getRecordsByBook(bookId, type: type);
  }
}
