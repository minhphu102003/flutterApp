class AccountModel {
  final String accountId;
  final String username;
  final String email;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccountModel({
    required this.accountId,
    required this.username,
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      accountId: json['accountId'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'username': username,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
