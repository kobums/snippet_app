import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/reading_session/data/models/reading_session.dart';
import 'package:snippet_app/features/reading_session/data/models/reading_session_stats.dart';

abstract class ReadingSessionRepository {
  Future<Result<int>> createSession(ReadingSessionAddRequestDto data);
  Future<Result<List<ReadingSessionDto>>> getAllSessions();
  Future<Result<List<ReadingSessionDto>>> getSessionsByBook(int userBookId);
  Future<Result<ReadingSessionStatsDto>> getStats(int userBookId);
}
