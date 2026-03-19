import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/auth/data/models/user.dart';
import 'package:snippet_app/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Result<User>> call(String email, String password) {
    return _repository.login(email, password);
  }
}
