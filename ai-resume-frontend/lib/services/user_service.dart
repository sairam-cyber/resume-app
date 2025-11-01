// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rezume_app/models/user_model.dart';
import 'package:rezume_app/models/resume_model.dart'; // <-- ADDED

class UserService {
  final String _baseUrl = 'http://10.166.14.85:5000';       

  // Helper to get token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> getMe() async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'No token found'};

    final response = await http.get(
      Uri.parse('$_baseUrl/api/user/me'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {'success': true, 'user': UserModel.fromJson(data)};
    } else {
      final body = json.decode(response.body);
      return {'success': false, 'message': body['msg'] ?? 'Failed to load user'};
    }
  }

  // --- NEW: Update User Profile ---
  Future<Map<String, dynamic>> updateMe(String fullName, String phoneNumber) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'No token found'};

    final response = await http.put(
      Uri.parse('$_baseUrl/api/user/me'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: json.encode({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {'success': true, 'user': UserModel.fromJson(data)};
    } else {
      final body = json.decode(response.body);
      return {'success': false, 'message': body['msg'] ?? 'Failed to update user'};
    }
  }

  // --- NEW: Get User's Resumes ---
  Future<Map<String, dynamic>> getMyResumes() async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'No token found'};

    final response = await http.get(
      Uri.parse('$_baseUrl/api/user/resumes'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<ResumeModel> resumes = data.map((r) => ResumeModel.fromJson(r)).toList();
      return {'success': true, 'resumes': resumes};
    } else {
      final body = json.decode(response.body);
      return {'success': false, 'message': body['msg'] ?? 'Failed to load resumes'};
    }
  }
}