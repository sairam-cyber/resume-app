import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rezume_app/ats_checker/ats_results_screen.dart'; // Corrected path
import 'package:rezume_app/services/ats_service.dart'; // <-- ADDED THIS

class UploadResumeScreen extends StatefulWidget {
  const UploadResumeScreen({super.key});

  @override
  State<UploadResumeScreen> createState() => _UploadResumeScreenState();
}

class _UploadResumeScreenState extends State<UploadResumeScreen> {
  String? _fileName;
  String? _filePath; // <-- ADDED THIS
  bool _isLoading = false;
  final AtsService _atsService = AtsService(); // <-- ADDED THIS

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Only allow PDF as per your backend
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _filePath = result.files.single.path; // <-- STORE THE PATH
      });
    } else {
      // User canceled the picker
    }
  }

  void _checkAtsScore() async { // <-- Make async
    if (_filePath == null) return;

    setState(() {
      _isLoading = true;
    });

    // --- MODIFIED: Call the API ---
    final result = await _atsService.checkAtsScore(_filePath!);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // --- PASS THE NEW DATA ---
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AtsResultsScreen(
              resumeId: result['resumeId'],
              atsScore: result['atsScore'],
              scoreMessage: result['scoreMessage'],
              suggestions: List<Map<String, dynamic>>.from(result['suggestions']),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text("Check ATS Score"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_upload_outlined,
                  size: 100, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text(
                "Upload Your Resume",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Get an instant analysis of how well your resume scores with Applicant Tracking Systems.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              // File upload button
              OutlinedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: Text(_fileName ?? "Choose File (.pdf)"), // <-- Updated text
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: _pickFile,
              ),
              const SizedBox(height: 40),
              // Check score button
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _filePath != null ? _checkAtsScore : null, // <-- Use _filePath
                      child: const Text("Check My Score",
                          style: TextStyle(color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}