import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/records/domain/repositories/record_repository.dart';

class DeleteRecordUseCase {
  final RecordRepository _repository;

  DeleteRecordUseCase(this._repository);

  Future<Result<void>> call(int id) {
    return _repository.deleteRecord(id);
  }
}
