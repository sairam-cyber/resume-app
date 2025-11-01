// lib/models/org_model.dart

class OrgModel {
  final String id;
  final String orgName;
  final String email;

  OrgModel({
    required this.id,
    required this.orgName,
    required this.email,
  });

  factory OrgModel.fromJson(Map<String, dynamic> json) {
    return OrgModel(
      id: json['_id'] ?? '',
      orgName: json['orgName'] ?? 'Organization',
      email: json['email'] ?? '',
    );
  }
}