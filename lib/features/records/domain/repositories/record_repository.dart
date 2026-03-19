import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/records/data/models/record.dart';

abstract class RecordRepository {
  Future<Result<List<RecordDto>>> getRecordsByBook(int bookId, {RecordType? type});
  Future<Result<List<RecordDto>>> getMonthlyRecords(int year, int month, {RecordType? type});
  Future<Result<int>> createRecord(int bookId, RecordAddRequestDto data);
  Future<Result<void>> patchRecord(int id, Map<String, dynamic> updates);
  Future<Result<void>> deleteRecord(int id);
}
