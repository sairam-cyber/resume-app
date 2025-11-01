// lib/profile/posted_jobs_screen.dart

import 'package:flutter/material.dart';
import 'package:rezume_app/models/job_model.dart';
import 'package:rezume_app/models/job_listing_model.dart'; // <-- IMPORT THIS
import 'package:rezume_app/services/job_service.dart'; // <-- IMPORT THIS
import 'package:rezume_app/profile/create_job_screen.dart';
import 'package:rezume_app/profile/applicants_screen.dart'; // <-- 1. ADD THIS IMPORT

class PostedJobsScreen extends StatefulWidget {
  final Color themeColor;

  const PostedJobsScreen({super.key, required this.themeColor});

  @override
  State<PostedJobsScreen> createState() => _PostedJobsScreenState();
}

class _PostedJobsScreenState extends State<PostedJobsScreen> {
  
  final JobService _jobService = JobService();
  List<JobListingModel> _postedJobs = []; // <-- Use JobListingModel
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyJobs();
  }

  Future<void> _fetchMyJobs() async {
    setState(() { _isLoading = true; });
    final result = await _jobService.getMyJobs();
    if (mounted) {
      if (result['success']) {
        setState(() {
          _postedJobs = result['jobs'];
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

  void _navigateToCreateJobScreen() async {
    final newJobFromForm = await Navigator.push<Job>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateJobScreen(themeColor: widget.themeColor),
      ),
    );

    if (newJobFromForm != null) {
      // --- Save to backend ---
      final result = await _jobService.createJob(newJobFromForm);
      if (mounted) {
        if (result['success']) {
          // Add the newly created job (with ID) to the list
          setState(() {
            _postedJobs.insert(0, result['job']);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job posted!'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Posted Jobs'),
        backgroundColor: widget.themeColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _postedJobs.isEmpty
              ? _buildEmptyState()
              : _buildJobList(),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateJobScreen,
        backgroundColor: widget.themeColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    // ... (unchanged)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No jobs posted yet.',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Click the "+" button to create one.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildJobList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _postedJobs.length,
      itemBuilder: (context, index) {
        final job = _postedJobs[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: widget.themeColor.withOpacity(0.1),
              child: Icon(Icons.work_outline_rounded, color: widget.themeColor),
            ),
            title: Text(
              job.role,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            subtitle: Text(
              '${job.location} • ${job.salary}\n${job.openings} Openings',
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            isThreeLine: true,
            onTap: () {
              // --- 2. THIS IS THE CHANGE ---
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApplicantsScreen(
                    jobId: job.id,
                    jobTitle: job.role,
                    themeColor: widget.themeColor,
                  ),
                ),
              );
              // --- END OF CHANGE ---
            },
          ),
        );
      },
    );
  }
}