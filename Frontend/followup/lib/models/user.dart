// 用户模型
class User {
  final int id;
  final String username;
  final DateTime? createdAt; // 注册时间

  User({
    required this.id,
    required this.username,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

// 登录响应模型
class LoginResponse {
  final String accessToken;
  final String tokenType;
  final User user;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
