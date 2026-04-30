import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/suggestion/data/models/suggestion_dto.dart';

abstract class SuggestionRepository {
  Future<Result<void>> submit(SuggestionAddRequestDto data);
}
