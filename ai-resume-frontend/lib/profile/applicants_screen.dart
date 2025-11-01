// lib/profile/applicants_screen.dart
import 'package:flutter/material.dart';
import 'package:rezume_app/models/application_model.dart';
import 'package:rezume_app/services/job_service.dart';
import 'package:rezume_app/profile/resume_detail_screen.dart'; // Your existing screen

class ApplicantsScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;
  final Color themeColor;

  const ApplicantsScreen({
    super.key, 
    required this.jobId,
    required this.jobTitle,
    required this.themeColor,
  });

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  final JobService _jobService = JobService();
  List<ApplicationModel> _applicants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplicants();
  }

  Future<void> _fetchApplicants() async {
    setState(() { _isLoading = true; });
    final result = await _jobService.getApplicants(widget.jobId);
    if (mounted) {
      if (result['success']) {
        setState(() {
          _applicants = result['applications'];
          _isLoading = false;
        });
      } else {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Applicants for ${widget.jobTitle}'),
        backgroundColor: widget.themeColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: widget.themeColor))
          : _applicants.isEmpty
              ? const Center(
                  child: Text(
                    'No one has applied for this job yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _applicants.length,
                  itemBuilder: (context, index) {
                    final application = _applicants[index];
                    final user = application.user;
                    
                    return Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: widget.themeColor.withOpacity(0.1),
                          child: Text(
                            user.fullName.isNotEmpty ? user.fullName[0] : '?',
                            style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(user.phoneNumber),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () {
                          // Pass the user data AND the application ID
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResumeDetailScreen(
                                // Note: This needs to be modified
                                // You are passing a 'User' model, but your
                                // ResumeDetailScreen expects 'dynamic' and tries
                                // to convert it from a 'Candidate' model.
                                // You will need to update ResumeDetailScreen
                                // to properly handle a 'UserModel' and an 'applicationId'.
                                
                                // For now, this is how you'd pass the data:
                                resumeData: user, // This is a UserModel
                                applicationId: application.id, // Pass the application ID
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}