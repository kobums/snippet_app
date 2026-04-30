import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/suggestion/data/models/suggestion_dto.dart';
import 'package:snippet_app/features/suggestion/domain/repositories/suggestion_repository.dart';

class SubmitSuggestionUseCase {
  final SuggestionRepository _repository;

  SubmitSuggestionUseCase(this._repository);

  Future<Result<void>> call(SuggestionAddRequestDto data) {
    return _repository.submit(data);
  }
}
