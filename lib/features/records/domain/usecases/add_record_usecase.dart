import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/records/data/models/record.dart';
import 'package:snippet_app/features/records/domain/repositories/record_repository.dart';

class AddRecordUseCase {
  final RecordRepository _repository;

  AddRecordUseCase(this._repository);

  Future<Result<int>> call(int bookId, RecordAddRequestDto data) {
    return _repository.createRecord(bookId, data);
  }
}
