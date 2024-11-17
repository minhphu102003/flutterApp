import 'dart:convert';

class AuthToken {
  AuthToken({
    required this.success,
    required this.userId,
    required this.email,
    required this.username,
    required this.phone,
    required this.roles, 
    required this.token,
  });

  bool success;
  String userId;
  String email;
  String username;
  String phone; 
  List<String> roles; 
  String token;

  factory AuthToken.fromJson(String str) => AuthToken.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

 factory AuthToken.fromMap(Map<String, dynamic> json) {
    final data = json['data'] ?? {}; // Dữ liệu thực tế nằm trong `data`
    return AuthToken(
      success: json["success"] ?? false,
      userId: data["userId"] ?? '',
      email: data["email"] ?? '',
      username: data["username"] ?? '',
      phone: data["phone"] ?? '',
      roles: List<String>.from(data["roles"] ?? []),
      token: data["token"] ?? '',
    );
  }

  // Hàm từ AuthToken -> Map
  Map<String, dynamic> toMap() => {
        "success": success,
        "data": {
          "userId": userId,
          "email": email,
          "username": username,
          "phone": phone,
          "roles": roles,
          "token": token,
        },
      };
  @override
  String toString() {
    JsonEncoder encoder = const JsonEncoder.withIndent('    ');
    return encoder.convert(toMap());
  }
}
