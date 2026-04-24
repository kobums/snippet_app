import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/reading_session/data/datasources/reading_session_remote_datasource.dart';
import 'package:snippet_app/features/reading_session/data/models/reading_session.dart';
import 'package:snippet_app/features/reading_session/data/models/reading_session_stats.dart';
import 'package:snippet_app/features/reading_session/domain/repositories/reading_session_repository.dart';

class ReadingSessionRepositoryImpl implements ReadingSessionRepository {
  final ReadingSessionRemoteDataSource _remote;

  ReadingSessionRepositoryImpl(this._remote);

  @override
  Future<Result<int>> createSession(ReadingSessionAddRequestDto data) async {
    try {
      final id = await _remote.createSession(data);
      return Success(id);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<List<ReadingSessionDto>>> getAllSessions() async {
    try {
      final sessions = await _remote.getAllSessions();
      return Success(sessions);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<List<ReadingSessionDto>>> getSessionsByBook(int userBookId) async {
    try {
      final sessions = await _remote.getSessionsByBook(userBookId);
      return Success(sessions);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<ReadingSessionStatsDto>> getStats(int userBookId) async {
    try {
      final stats = await _remote.getStats(userBookId);
      return Success(stats);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }
}
