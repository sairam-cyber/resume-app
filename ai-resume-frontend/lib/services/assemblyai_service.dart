// lib/services/assemblyai_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; 

class AssemblyAiService {
  // ⚠️ Your API key is visible here. Be careful sharing this file.
  final String _apiKey = '275fa44f0202481a86b1d2b56dd8f29a';
  final String _uploadUrl = 'https://api.assemblyai.com/v2/upload';
  final String _transcriptUrl = 'https://api.assemblyai.com/v2/transcript';

  // This is the main function you'll call from your screen
  Future<String> transcribe(String filePath) async {
    try {
      // 1. Upload the audio file
      print('Uploading file...');
      final uploadUrl = await _uploadFile(filePath);

      // 2. Submit the file for transcription
      print('Submitting for transcription...');
      final transcriptId = await _submitForTranscription(uploadUrl);

      // 3. Poll for the transcription results
      print('Waiting for results...');
      final String text = await _pollForResults(transcriptId);
      
      return text;
    } catch (e) {
      print('Error in transcription process: $e');
      rethrow;
    }
  }

  // --- *** THIS IS THE NEW UPLOAD FUNCTION *** ---
  Future<String> _uploadFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Audio file not found at $filePath');
    }

    // 1. Read the file bytes manually
    final fileBytes = await file.readAsBytes();

    // 2. Create the multipart request
    final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl))
      ..headers['authorization'] = _apiKey;

    // 3. Add the file using `fromBytes`, not `fromPath`
    // This gives us full control over the metadata.
    request.files.add(http.MultipartFile.fromBytes(
      'file', // AssemblyAI's expected field name
      fileBytes,
      filename: 'resume_audio.wav', // The filename the server sees
      contentType: MediaType('audio', 'wav'), // Explicitly set MIME type
    ));

    // 4. Send the request
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = json.decode(responseBody);
      return data['upload_url'];
    } else {
      // The responseBody will now contain AssemblyAI's error message
      throw Exception('Failed to upload file: $responseBody');
    }
  }
  // --- *** END OF THE NEW FUNCTION *** ---


  // Step 2: Submit the uploaded file's URL for transcription
  Future<String> _submitForTranscription(String audioUrl) async {
    final response = await http.post(
      Uri.parse(_transcriptUrl),
      headers: {
        'authorization': _apiKey,
        'content-type': 'application/json',
      },
      body: json.encode({'audio_url': audioUrl}),
    );

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseBody['id'];
    } else {
      throw Exception('Failed to submit transcription: ${responseBody['error']}');
    }
  }

  // Step 3: Poll for transcription results until "completed"
  Future<String> _pollForResults(String transcriptId) async {
    while (true) {
      final response = await http.get(
        Uri.parse('$_transcriptUrl/$transcriptId'),
        headers: {'authorization': _apiKey},
      );

      final responseBody = json.decode(response.body);
      final status = responseBody['status'];

      if (status == 'completed') {
        return responseBody['text'] ?? 'No text found.';
      } else if (status == 'error') {
        throw Exception(
            'Transcription failed: ${responseBody['error']}');
      } else {
        // Wait for 5 seconds before polling again
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }
}