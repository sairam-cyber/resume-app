// lib/services/org_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rezume_app/models/org_model.dart';

class OrgService {
  final String _baseUrl = 'http://10.166.14.85:5000';

  // Helper to get token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> getMeOrg() async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'No token found'};

    final response = await http.get(
      Uri.parse('$_baseUrl/api/org/me'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {'success': true, 'org': OrgModel.fromJson(data)};
    } else {
      final body = json.decode(response.body);
      return {'success': false, 'message': body['msg'] ?? 'Failed to load organization'};
    }
  }

  Future<Map<String, dynamic>> updateMeOrg(String orgName, String email) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'No token found'};

    final response = await http.put(
      Uri.parse('$_baseUrl/api/org/me'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: json.encode({
        'orgName': orgName,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {'success': true, 'org': OrgModel.fromJson(data)};
    } else {
      final body = json.decode(response.body);
      return {'success': false, 'message': body['msg'] ?? 'Failed to update organization'};
    }
  }
}