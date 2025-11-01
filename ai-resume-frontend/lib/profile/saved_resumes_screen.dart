// lib/profile/saved_resumes_screen.dart

import 'package:flutter/material.dart';
import 'package:rezume_app/models/resume_model.dart';
import 'package:rezume_app/services/user_service.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- ADD for opening PDF
import 'package:intl/intl.dart'; // <-- ADD for formatting date

class SavedResumesScreen extends StatefulWidget {
  const SavedResumesScreen({super.key});

  @override
  State<SavedResumesScreen> createState() => _SavedResumesScreenState();
}

class _SavedResumesScreenState extends State<SavedResumesScreen> {
  final UserService _userService = UserService();
  late Future<List<ResumeModel>> _resumesFuture;

  @override
  void initState() {
    super.initState();
    _resumesFuture = _fetchResumes();
  }

  Future<List<ResumeModel>> _fetchResumes() async {
    final result = await _userService.getMyResumes();
    if (result['success']) {
      return result['resumes'] as List<ResumeModel>;
    } else {
      throw Exception(result['message']);
    }
  }

  Future<void> _openPdfUrl(String? pdfUrl) async {
    if (pdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF is not yet generated for this resume.')),
      );
      return;
    }
    
    final Uri url = Uri.parse(pdfUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open PDF: $pdfUrl')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Saved Resumes'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: FutureBuilder<List<ResumeModel>>(
        future: _resumesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'You have not saved any resumes yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final resumes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: resumes.length,
            itemBuilder: (context, index) {
              final resume = resumes[index];
              final formattedDate = DateFormat('MMM dd, yyyy').format(resume.createdAt);
              
              return _buildResumeCard(
                title: '${resume.template} Template',
                subtitle: 'Created on: $formattedDate',
                onTap: () {
                  _openPdfUrl(resume.pdfUrl);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildResumeCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    const Color color = Color(0xFF0056b3); // Dark blue
    final Color bgColor = Colors.blue[50]!; // Light blue

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Card(
        elevation: 1.5,
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 16,
          ),
          leading: const Icon(
            Icons.article_rounded,
            color: color,
            size: 28,
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: color,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: color.withOpacity(0.7)),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}