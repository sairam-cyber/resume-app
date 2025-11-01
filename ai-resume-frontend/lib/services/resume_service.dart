// lib/services/resume_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ResumeService {
  final String _baseUrl = 'http://10.166.14.85:5000'; // Your IP

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Get user's preferred language
  Future<String> _getUserLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    // --- THIS IS THE FIX ---
    // It now reads 'languageCode' to match your LanguageProvider
    return prefs.getString('languageCode') ?? 'en';
    // --- END OF FIX ---
  }

  // Starts the conversation with the backend
  Future<Map<String, dynamic>> startResume(String templateName) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'No token found'};

    final language = await _getUserLanguage();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/resume/start'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: json.encode({
        'template': templateName, // e.g., "Modern"
        'language': language, // Send user's language preference
      }),
    );

    final body = json.decode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': true,
        'resumeId': body['resumeId'],
        'question': body['question'],
      };
    } else {
      return {'success': false, 'message': body['msg'] ?? 'Error'};
    }
  }

  // Sends an answer and gets the next question
  Future<Map<String, dynamic>> askNextQuestion(
      String resumeId, String answer) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'No token found'};

    final response = await http.post(
      Uri.parse('$_baseUrl/api/resume/next'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: json.encode({
        'resumeId': resumeId,
        'answer': answer,
      }),
    );

    final body = json.decode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': true,
        'question': body['question'],
        'isComplete': body['isComplete'],
      };
    } else {
      return {'success': false, 'message': body['msg'] ?? 'Error'};
    }
  }

  // Tells the backend to generate the final PDF
  Future<Map<String, dynamic>> generatePdf(String resumeId) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'No token found'};

    final response = await http.post(
      Uri.parse('$_baseUrl/api/resume/generate-pdf'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: json.encode({
        'resumeId': resumeId,
      }),
    );

    final body = json.decode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'resume': body['resume']};
    } else {
      return {'success': false, 'message': body['msg'] ?? 'Error'};
    }
  }

  // --- ADD THIS FUNCTION ---
  Future<Map<String, dynamic>> parseVoiceResume(String transcribedText) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'No token found'};

    final language = await _getUserLanguage();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/resume/parse-voice'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: json.encode({
        'transcribedText': transcribedText,
        'language': language,
      }),
    );

    final body = json.decode(response.body);
    if (response.statusCode == 200) {
      // The body is the JSON object itself
      return {'success': true, 'data': body};
    } else {
      return {'success': false, 'message': body['msg'] ?? 'Error parsing text'};
    }
  }
}