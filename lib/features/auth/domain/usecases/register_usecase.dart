import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Result<String>> call(String email, String password, String name) {
    return _repository.register(email, password, name);
  }
}
