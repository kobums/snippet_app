class User {
  final int id;
  final String email;
  final String name;
  final String? token;
  final String? refreshToken;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.token,
    this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'token': token,
      'refreshToken': refreshToken,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? name,
    String? token,
    String? refreshToken,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
