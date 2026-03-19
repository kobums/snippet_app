import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/auth/data/models/user.dart';

abstract class AuthRepository {
  Future<Result<User>> login(String email, String password);
  Future<Result<User>> register(String email, String password, String name);
  Future<Result<User>> checkAuth();
  Future<Result<void>> logout();
}
