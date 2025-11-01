// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // --- IMPORTANT: Change this to your backend's IP address/domain ---
  // If using Android Emulator, use 10.0.2.2
  // If using iOS Simulator or physical device, use your computer's local IP (e.g., 192.168.1.10)
  final String _baseUrl = 'http://10.166.14.85:5000';

  // --- User Registration ---
  Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String phoneNumber,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'password': password,
      }),
    );
    return _handleAuthResponse(response);
  }

  // --- User Login ---
  Future<Map<String, dynamic>> loginUser({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phoneNumber': phoneNumber,
        'password': password,
      }),
    );
    return _handleAuthResponse(response);
  }

  // --- Guest Registration ---
  Future<Map<String, dynamic>> registerGuest() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/register-guest'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleAuthResponse(response);
  }

  // --- Organization Registration ---
  Future<Map<String, dynamic>> registerOrg({
    required String orgName,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/org-auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'orgName': orgName,
        'email': email,
        'password': password,
      }),
    );
    return _handleAuthResponse(response);
  }

  // --- Organization Login ---
  Future<Map<String, dynamic>> loginOrg({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/org-auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    return _handleAuthResponse(response);
  }

  // --- Helper for handling responses ---
  Future<Map<String, dynamic>> _handleAuthResponse(http.Response response) async {
    final body = json.decode(response.body);
    if (response.statusCode == 200) {
      // Success
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', body['token']);
      return {'success': true, 'token': body['token']};
    } else {
      // Error
      return {'success': false, 'message': body['msg'] ?? 'An error occurred'};
    }
  }
}