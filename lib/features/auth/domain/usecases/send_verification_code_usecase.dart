import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/auth/domain/repositories/auth_repository.dart';

class SendVerificationCodeUseCase {
  final AuthRepository _repository;

  SendVerificationCodeUseCase(this._repository);

  Future<Result<void>> call(String email) {
    return _repository.sendVerificationCode(email);
  }
}
