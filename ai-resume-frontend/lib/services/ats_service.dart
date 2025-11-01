// lib/services/ats_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart'; // <-- 1. ADD THIS IMPORT

class AtsService {
  final String _baseUrl = 'http://10.166.14.85:5000'; // Or 10.0.2.2 for Android emu

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- 1. Upload Resume for ATS Check ---
  Future<Map<String, dynamic>> checkAtsScore(String filePath) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'No token found'};

    try {
      var uri = Uri.parse('$_baseUrl/api/ats/check');
      var request = http.MultipartRequest('POST', uri)
        ..headers['x-auth-token'] = token
        ..files.add(await http.MultipartFile.fromPath(
          'resume', // This MUST match 'uploadMiddleware.js'
          filePath,
          // --- 2. THIS IS THE FIX ---
          // Explicitly set the file's MIME type to application/pdf
          contentType: MediaType('application', 'pdf'),
          // --- END OF FIX ---
        ));

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // (This is the error handling we added last time, keep it)
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return {'success': true, ...data};
      } else {
        try {
          final data = json.decode(responseBody);
          // Now we can show the "Error: PDFs Only!" message
          return {'success': false, 'message': data['msg'] ?? 'Upload failed'};
        } catch (e) {
          return {
            'success': false,
            'message': 'Server Error: ${response.statusCode}. Please try again.'
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // --- 2. Generate the Edited PDF ---
  Future<Map<String, dynamic>> generateEditedPdf({
    required String resumeId,
    required Map<String, String> userAnswers,
  }) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'No token found'};

    final response = await http.post(
      Uri.parse('$_baseUrl/api/ats/generate-edited-pdf'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: json.encode({
        'resumeId': resumeId,
        'userAnswers': userAnswers,
      }),
    );

    final body = json.decode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'resume': body['resume']};
    } else {
      return {'success': false, 'message': body['msg'] ?? 'Failed to generate PDF'};
    }
  }
}