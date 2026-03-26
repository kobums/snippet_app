import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/auth/domain/repositories/auth_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository _repository;

  DeleteAccountUseCase(this._repository);

  Future<Result<void>> call() {
    return _repository.deleteAccount();
  }
}
