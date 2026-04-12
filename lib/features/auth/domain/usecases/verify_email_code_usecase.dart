import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/auth/data/models/user.dart';
import 'package:snippet_app/features/auth/domain/repositories/auth_repository.dart';

class VerifyEmailCodeUseCase {
  final AuthRepository _repository;

  VerifyEmailCodeUseCase(this._repository);

  Future<Result<User>> call(String email, String code) {
    return _repository.verifyCode(email, code);
  }
}
