// lib/models/resume_model.dart

class ResumeModel {
  final String id;
  final String template;
  final String? pdfUrl;
  final DateTime createdAt;

  ResumeModel({
    required this.id,
    required this.template,
    this.pdfUrl,
    required this.createdAt,
  });

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      id: json['_id'],
      template: json['template'] ?? 'Unknown',
      pdfUrl: json['pdfUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}