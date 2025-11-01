// lib/models/job_model.dart

class Job {
  final String role;
  final String location;
  final String salary;
  final String openings;
  final String description;

  Job({
    required this.role,
    required this.location,
    required this.salary,
    required this.openings,
    required this.description,
  });
}