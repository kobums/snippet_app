import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/suggestion/data/datasources/suggestion_remote_datasource.dart';
import 'package:snippet_app/features/suggestion/data/models/suggestion_dto.dart';
import 'package:snippet_app/features/suggestion/domain/repositories/suggestion_repository.dart';

class SuggestionRepositoryImpl implements SuggestionRepository {
  final SuggestionRemoteDataSource _remote;

  SuggestionRepositoryImpl(this._remote);

  @override
  Future<Result<void>> submit(SuggestionAddRequestDto data) async {
    try {
      await _remote.submit(data);
      return const Success(null);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }
}
