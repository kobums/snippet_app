import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/records/domain/repositories/record_repository.dart';

class UpdateRecordUseCase {
  final RecordRepository _repository;

  UpdateRecordUseCase(this._repository);

  Future<Result<void>> call(int id, Map<String, dynamic> updates) {
    return _repository.patchRecord(id, updates);
  }
}
