// lib/profile/resume_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:rezume_app/services/job_service.dart'; // <-- 1. ADD THIS
import 'package:rezume_app/models/user_model.dart'; // <-- 2. ADD THIS

class ResumeDetailScreen extends StatelessWidget {
  final dynamic resumeData; // accept Map or Candidate object
  final String? applicationId; // <-- 3. ACCEPT THE APPLICATION ID

  const ResumeDetailScreen({
    super.key,
    required this.resumeData,
    this.applicationId, // <-- 4. MAKE IT NULLABLE
  });

  // --- 5. THE FIX: The JobService helper has been REMOVED from here ---

  Map<String, dynamic> _toMap(dynamic src) {
    if (src is Map<String, dynamic>) return src;

    // --- 6. ADD THIS BLOCK TO HANDLE USERMODEL ---
    // This handles the real user data from ApplicantsScreen
    if (src is UserModel) {
      return {
        'fullName': src.fullName,
        'jobTitle': 'Applicant', // You can change this
        'contact': {
          'phone': src.phoneNumber,
          'email': '', // Add email to UserModel if you need it here
          'location': '', // Add location to UserModel if you need it here
        },
        'qualification': '', // You'll need to fetch the user's resume for this
        'experience': [],
        'skills': [],
        'licenses': [],
        'languages': [],
        'achievements': [],
      };
    }
    // --- END OF BLOCK ---

    // This is your old logic for dummy candidates
    final dynamic s = src;
    return {
      'title': s.jobProfile ?? '',
      'fullName': s.name ?? '',
      'jobTitle': s.jobProfile ?? '',
      'contact': {
        'phone': '',
        'email': s.email ?? '',
        'location': s.location ?? ''
      },
      'experience': s.experience != null
          ? [
              {'position': '${s.experience} years total experience'}
            ]
          : [],
      'skills': s.skills ?? [],
      'licenses': [],
      'languages': [],
      'achievements': s.achievements ?? [],
      'qualification': s.qualification ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final data = _toMap(resumeData);
    // 7. DETERMINE IF WE CAN ACCEPT/REJECT
    final bool canTakeAction = applicationId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(data['fullName']?.toString() ?? 'Resume'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    data['fullName']?.toString() ?? '',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if ((data['jobTitle'] ?? '').toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
                      child: Text(
                        data['jobTitle']?.toString() ?? '',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                    ),

                  // Contact card
                  if (data['contact'] is Map)
                    Card(
                      color: Colors.indigo[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            if ((data['contact']['phone'] ?? '')
                                .toString()
                                .isNotEmpty)
                              Row(children: [
                                const Icon(Icons.phone,
                                    size: 18, color: Colors.indigo),
                                const SizedBox(width: 8),
                                Text(data['contact']['phone'].toString()),
                              ]),
                            if ((data['contact']['email'] ?? '')
                                .toString()
                                .isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Row(children: [
                                  const Icon(Icons.email,
                                      size: 18, color: Colors.indigo),
                                  const SizedBox(width: 8),
                                  Text(data['contact']['email'].toString()),
                                ]),
                              ),
                            if ((data['contact']['location'] ?? '')
                                .toString()
                                .isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Row(children: [
                                  const Icon(Icons.location_on,
                                      size: 18, color: Colors.indigo),
                                  const SizedBox(width: 8),
                                  Text(data['contact']['location'].toString()),
                                ]),
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // ... (Rest of your resume layout sections) ...
                  
                  // Qualification
                  if ((data['qualification'] ?? '').toString().isNotEmpty) ...[
                    const Text('Qualification',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(data['qualification'].toString(),
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 12),
                  ],

                  // Experience
                  if ((data['experience'] as List).isNotEmpty) ...[
                    const Text('Experience',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...((data['experience'] as List).map((exp) {
                      final Map<String, dynamic> e =
                          exp is Map<String, dynamic> ? exp : {};
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((e['company'] ?? '').toString().isNotEmpty)
                                  Text(e['company'].toString(),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                if ((e['position'] ?? '').toString().isNotEmpty)
                                  Text(
                                      '${e['position'] ?? ''} ${e['duration'] != null ? '(${e['duration']})' : ''}',
                                      style: const TextStyle(
                                          color: Colors.black54)),
                                if ((e['details'] ?? []).isNotEmpty)
                                  const SizedBox(height: 8),
                                if ((e['details'] ?? []).isNotEmpty)
                                  ...((e['details'] as List).map((d) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('• ',
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                              Expanded(
                                                  child: Text(d.toString())),
                                            ]),
                                      ))),
                              ]),
                        ),
                      );
                    })),
                  ],

                  // Achievements
                  if ((data['achievements'] as List).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Achievements',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (data['achievements'] as List)
                            .map((l) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4.0),
                                      child: Icon(Icons.star,
                                          size: 14, color: Colors.amber),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(l.toString())),
                                  ],
                                )))
                            .toList())
                  ],

                  // Skills
                  if ((data['skills'] as List).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Skills',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: (data['skills'] as List)
                            .map((s) => Chip(
                                label: Text(s.toString()),
                                backgroundColor: Colors.indigo[50],
                                labelStyle:
                                    const TextStyle(color: Colors.indigo)))
                            .toList()),
                  ],
                ],
              ),
            ),
          ),

          // --- 8. MODIFY THIS BUTTON BAR ---
          if (canTakeAction)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        // TODO: Implement reject logic
                        // This would be very similar to the accept logic
                        // e.g., await _jobService.rejectApplicant(applicationId!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Candidate Rejected'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 50),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async { // <-- Make async
                        // --- THIS IS THE FIX ---
                        // Instantiate the service *inside* the function
                        final JobService _jobService = JobService();
                        final result = await _jobService.acceptApplicant(applicationId!);
                        if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message']),
                              backgroundColor: result['success'] ? Colors.green : Colors.red,
                            ),
                          );
                          Navigator.pop(context); // Pop back to applicants list
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 50),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}