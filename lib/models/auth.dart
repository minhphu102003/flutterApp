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

  factory AuthToken.fromMap(Map<String, dynamic> json) => AuthToken(
        success: json["success"] ?? false,
        userId: json["userId"] ?? '',
        email: json["email"] ?? '',
        username: json["username"] ?? '',
        phone: json["phone"] ?? '',
        roles: List<String>.from(json["roles"]?.map((x) => x) ?? []), 
        token: json["token"] ?? '',
  );

  Map<String, dynamic> toMap() => {
        "success": success,
        "userId": userId,
        "email": email,
        "username": username,
        "phone": phone,
        "roles": List<dynamic>.from(roles.map((x) => x)), // Chuyển đổi danh sách thành JSON
        "token": token,
      };

  @override
  String toString() {
    JsonEncoder encoder = const JsonEncoder.withIndent('    ');
    return encoder.convert(toMap());
  }
}
