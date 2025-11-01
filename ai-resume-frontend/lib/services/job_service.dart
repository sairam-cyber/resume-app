// lib/services/job_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rezume_app/models/job_model.dart';
import 'package:rezume_app/models/job_listing_model.dart';
import 'package:rezume_app/models/application_model.dart';

class JobService {
  final String _baseUrl = 'http://10.166.14.85:5000';

  // Helper to get token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- ORG: Create Job ---
  Future<Map<String, dynamic>> createJob(Job job) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'No token found'};

    final response = await http.post(
      Uri.parse('$_baseUrl/api/job'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: json.encode({
        'role': job.role,
        'location': job.location,
        'salary': job.salary,
        'openings': job.openings,
        'description': job.description,
      }),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'job': JobListingModel.fromJson(json.decode(response.body))};
    } else {
      final body = json.decode(response.body);
      return {'success': false, 'message': body['msg'] ?? 'Failed to create job'};
    }
  }

  // --- ORG: Get My Posted Jobs ---
  Future<Map<String, dynamic>> getMyJobs() async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'No token found'};

    final response = await http.get(
      Uri.parse('$_baseUrl/api/job/my-jobs'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<JobListingModel> jobs = data.map((j) => JobListingModel.fromJson(j)).toList();
      return {'success': true, 'jobs': jobs};
    } else {
      final body = json.decode(response.body);
      return {'success': false, 'message': body['msg'] ?? 'Failed to load jobs'};
    }
  }

  // --- USER: Get All Jobs ---
  Future<Map<String, dynamic>> getAllJobs() async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'No token found'};

    final response = await http.get(
      Uri.parse('$_baseUrl/api/job'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<JobListingModel> jobs = data.map((j) => JobListingModel.fromJson(j)).toList();
      return {'success': true, 'jobs': jobs};
    } else {
      final body = json.decode(response.body);
      return {'success': false, 'message': body['msg'] ?? 'Failed to load jobs'};
    }
  }

  // --- USER: Apply for Job ---
  Future<Map<String, dynamic>> applyForJob(String jobId) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'No token found'};

    final response = await http.post(
      Uri.parse('$_baseUrl/api/job/apply/$jobId'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );

    final body = json.decode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'message': body['msg']};
    } else {
      return {'success': false, 'message': body['msg'] ?? 'Failed to apply'};
    }
  }

// --- ADD THIS FUNCTION ---
  Future<Map<String, dynamic>> getApplicants(String jobId) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'No token found'};

    final response = await http.get(
      Uri.parse('$_baseUrl/api/job/applicants/$jobId'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<ApplicationModel> apps = data.map((a) => ApplicationModel.fromJson(a)).toList();
      return {'success': true, 'applications': apps};
    } else {
      final body = json.decode(response.body);
      return {'success': false, 'message': body['msg'] ?? 'Failed to load applicants'};
    }
  }

    // --- ADD THIS FUNCTION ---
    Future<Map<String, dynamic>> acceptApplicant(String applicationId) async {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'No token found'};

      final response = await http.post(
        Uri.parse('$_baseUrl/api/job/accept-applicant'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: json.encode({
          'applicationId': applicationId,
        }),
      );
      
      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': body['msg']};
      } else {
        return {'success': false, 'message': body['msg'] ?? 'Failed to accept'};
      }
    }
}