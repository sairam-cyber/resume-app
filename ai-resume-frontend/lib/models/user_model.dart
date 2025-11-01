// lib/models/user_model.dart

class UserModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final bool isGuest;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.isGuest,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? 'Guest',
      phoneNumber: json['phoneNumber'] ?? '',
      isGuest: json['isGuest'] ?? false,
    );
  }
}