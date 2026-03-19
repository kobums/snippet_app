import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/records/data/models/record.dart';
import 'package:snippet_app/features/records/domain/repositories/record_repository.dart';

class FetchMonthlyRecordsUseCase {
  final RecordRepository _repository;

  FetchMonthlyRecordsUseCase(this._repository);

  Future<Result<List<RecordDto>>> call(int year, int month, {RecordType? type}) {
    return _repository.getMonthlyRecords(year, month, type: type);
  }
}
