import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/records/data/datasources/record_remote_datasource.dart';
import 'package:snippet_app/features/records/data/models/record.dart';
import 'package:snippet_app/features/records/domain/repositories/record_repository.dart';

class RecordRepositoryImpl implements RecordRepository {
  final RecordRemoteDataSource _remoteDataSource;

  RecordRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<RecordDto>>> getRecordsByBook(int bookId, {RecordType? type}) async {
    try {
      final records = await _remoteDataSource.getRecordsByBook(bookId, type: type);
      return Success(records);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<List<RecordDto>>> getMonthlyRecords(int year, int month, {RecordType? type}) async {
    try {
      final records = await _remoteDataSource.getMonthlyRecords(year, month, type: type);
      return Success(records);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<int>> createRecord(int bookId, RecordAddRequestDto data) async {
    try {
      final id = await _remoteDataSource.createRecord(bookId, data);
      return Success(id);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<void>> patchRecord(int id, Map<String, dynamic> updates) async {
    try {
      await _remoteDataSource.patchRecord(id, updates);
      return const Success(null);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<void>> deleteRecord(int id) async {
    try {
      await _remoteDataSource.deleteRecord(id);
      return const Success(null);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }
}
