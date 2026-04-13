class LoginParams {
  final String email;
  final String password;

  LoginParams({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterParams {
  final String email;
  final String password;
  final String name;
  final String code;

  RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'code': code,
    };
  }
}
