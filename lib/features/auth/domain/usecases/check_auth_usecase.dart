import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/auth/data/models/user.dart';
import 'package:snippet_app/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthUseCase {
  final AuthRepository _repository;

  CheckAuthUseCase(this._repository);

  Future<Result<User>> call() {
    return _repository.checkAuth();
  }
}
