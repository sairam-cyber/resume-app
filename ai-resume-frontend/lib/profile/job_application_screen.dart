// lib/profile/job_application_screen.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rezume_app/models/job_listing_model.dart'; // <-- CHANGED
import 'package:rezume_app/services/job_service.dart'; // <-- ADDED

class JobApplicationScreen extends StatefulWidget {
  final JobListingModel job; // <-- CHANGED

  const JobApplicationScreen({super.key, required this.job});

  @override
  State<JobApplicationScreen> createState() => _JobApplicationScreenState();
}

class _JobApplicationScreenState extends State<JobApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  final JobService _jobService = JobService(); // <-- ADDED

  String? _fileName;
  bool _isLoading = false;

  final Color _primaryColor = Color(0xFF007BFF);

  @override
  void initState() {
    super.initState();
    // TODO: Pre-fill with logged-in user's data from UserService.getMe()
    _nameController.text = 'John Doe';
    _emailController.text = 'john.doe@example.com';
    _phoneController.text = '+91 98765 43210';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    // ... (unchanged)
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
      });
    }
  }

  void _submitApplication() async { // <-- Make async
    if (_formKey.currentState!.validate()) {
      if (_fileName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload your resume to apply.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() { _isLoading = true; });
      
      // --- Call API ---
      // In a real app, you would upload the file (_fileName) as well.
      // For now, we just send the application.
      final result = await _jobService.applyForJob(widget.job.id);

      if (mounted) {
        setState(() { _isLoading = false; });
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Application for ${widget.job.role} submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Go back to the job list
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for ${widget.job.role}'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Job Details Card ---
              Card(
                elevation: 1,
                color: _primaryColor.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: _primaryColor.withOpacity(0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job.role,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.business,
                              size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Text(
                            widget.job.orgName, // <-- Use orgName
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Text(
                            widget.job.location,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // ... (Rest of the form is unchanged) ...
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration('Full Name', Icons.person),
                validator: (v) => v!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: _buildInputDecoration('Email Address', Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v!.isEmpty) return 'Please enter your email';
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: _buildInputDecoration('Phone Number', Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v!.length < 10 ? 'Enter a valid 10-digit number' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Upload Resume',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: Icon(
                  _fileName != null ? Icons.check_circle : Icons.attach_file,
                  color: _fileName != null ? Colors.green : Colors.grey[700],
                ),
                label: Flexible(
                  child: Text(
                    _fileName ?? "Choose File (.pdf, .doc)",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          _fileName != null ? Colors.green : Colors.grey[700],
                    ),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(
                    color:
                        _fileName != null ? Colors.green : Colors.grey.shade400,
                  ),
                ),
                onPressed: _pickFile,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitApplication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Apply Now'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    // ... (unchanged)
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
    );
  }
}