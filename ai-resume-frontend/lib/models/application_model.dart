// lib/models/application_model.dart
import 'package:rezume_app/models/user_model.dart'; // <-- THIS IS THE FIX (was 'package.')

class ApplicationModel {
  final String id;
  final String status;
  final UserModel user; // We will get the populated user object

  ApplicationModel({
    required this.id,
    required this.status,
    required this.user,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['_id'],
      status: json['status'] ?? 'Applied',
      user: UserModel.fromJson(json['user']),
    );
  }
}