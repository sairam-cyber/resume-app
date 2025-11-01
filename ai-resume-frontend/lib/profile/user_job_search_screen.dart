// lib/profile/user_job_search_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:rezume_app/models/job_listing_model.dart'; // <-- CHANGED
import 'package:rezume_app/services/job_service.dart'; // <-- ADDED
import 'package:rezume_app/profile/job_application_screen.dart'; 

class UserJobSearchScreen extends StatefulWidget {
  const UserJobSearchScreen({super.key});

  @override
  State<UserJobSearchScreen> createState() => _UserJobSearchScreenState();
}

class _UserJobSearchScreenState extends State<UserJobSearchScreen> {
  final JobService _jobService = JobService(); // <-- ADDED
  List<JobListingModel> _allJobs = []; // <-- CHANGED
  List<JobListingModel> _filteredJobs = []; // <-- CHANGED
  bool _isLoading = true; // <-- ADDED

  final _numberFormat = NumberFormat.compact(locale: 'en_IN');

  // --- Filter State Variables (unchanged) ---
  String _selectedJobProfile = 'Any';
  bool _isWorkFromHome = false;
  bool _isPartTime = false;
  String _selectedSalary = 'Any';
  String _selectedExperience = 'Any';
  String _selectedLocation = 'Any';

  // --- Filter Options (unchanged) ---
  final List<String> _jobProfileOptions = [
    'Any', 'Driver', 'Electrician', 'Plumber', 'Cook', 'Security Guard', 'Welder', 'Carpenter', 'Mechanic'
  ];
  final List<String> _salaryOptions = [
    'Any', 'At least 2 lakhs', 'At least 4 lakhs', 'At least 6 lakhs'
  ];
  final List<String> _experienceOptions = [
    'Any', '0-2 years', '3-5 years', '6+ years'
  ];
  final List<String> _locationOptions = [
    'Any', 'Mumbai', 'Delhi', 'Bangalore', 'Rourkela', 'Kolkata', 'Chennai', 'Hyderabad', 'Pune'
  ];

  // --- Theme Colors (User) (unchanged) ---
  final Color _primaryColor = Color(0xFF007BFF);
  final Color _backgroundColor = Color(0xFFF0F8FF);

  @override
  void initState() {
    super.initState();
    _fetchAllJobs(); // <-- CHANGED
  }

  // --- NEW: Fetch jobs from API ---
  Future<void> _fetchAllJobs() async {
    setState(() { _isLoading = true; });
    final result = await _jobService.getAllJobs();
    if (mounted) {
      if (result['success']) {
        setState(() {
          _allJobs = result['jobs'];
          _filterJobs(); // Apply default filters
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


  // --- Filtering Logic (MODIFIED) ---
  void _filterJobs() {
    List<JobListingModel> tempJobs = _allJobs; // <-- Use _allJobs

    // Job Profile
    if (_selectedJobProfile != 'Any') {
      tempJobs = tempJobs.where((j) => j.role == _selectedJobProfile).toList();
    }
    // ... (rest of the filter logic is UNCHANGED, as it works on the model properties) ...
    // Location
    if (_selectedLocation != 'Any') {
      tempJobs =
          tempJobs.where((j) => j.location == _selectedLocation).toList();
    }
    // Work From Home
    if (_isWorkFromHome) {
      tempJobs = tempJobs.where((j) => j.isWorkFromHome == true).toList();
    }
    // Part-time
    if (_isPartTime) {
      tempJobs = tempJobs.where((j) => j.jobType == 'Part-time').toList();
    }
    // Salary
    if (_selectedSalary != 'Any') {
      int minSalary = 0;
      if (_selectedSalary == 'At least 2 lakhs') minSalary = 200000;
      if (_selectedSalary == 'At least 4 lakhs') minSalary = 400000;
      if (_selectedSalary == 'At least 6 lakhs') minSalary = 600000;
      // NOTE: Our JobListingModel doesn't have salaryMin,
      // this filter will not work without updating the model or parsing the salary string.
      // For now, we'll skip this filter.
    }
    // Experience
    if (_selectedExperience != 'Any') {
      // NOTE: Our JobListingModel doesn't have experienceRequired
      // This filter will also not work.
    }

    setState(() {
      _filteredJobs = tempJobs;
    });
  }

  // --- Filter Sheet (unchanged) ---
  void _showFilterSheet() {
    // ... (This modal logic is unchanged)
    String tempProfile = _selectedJobProfile;
    String tempLocation = _selectedLocation;
    bool tempWorkFromHome = _isWorkFromHome;
    bool tempPartTime = _isPartTime;
    String tempSalary = _selectedSalary;
    String tempExperience = _selectedExperience;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24.0),
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        // Job Role
                        DropdownButtonFormField<String>(
                          value: tempProfile,
                          decoration: _buildInputDecoration('Job Role', null),
                          items: _jobProfileOptions.map((String value) {
                            return DropdownMenuItem<String>(
                                value: value, child: Text(value));
                          }).toList(),
                          onChanged: (String? newValue) {
                            setSheetState(() => tempProfile = newValue!);
                          },
                        ),
                        const SizedBox(height: 16),
                        // Location
                        DropdownButtonFormField<String>(
                          value: tempLocation,
                          decoration: _buildInputDecoration('Location', null),
                          items: _locationOptions.map((String value) {
                            return DropdownMenuItem<String>(
                                value: value, child: Text(value));
                          }).toList(),
                          onChanged: (String? newValue) {
                            setSheetState(() => tempLocation = newValue!);
                          },
                        ),
                        const SizedBox(height: 16),
                        // Checkboxes
                        CheckboxListTile(
                          title: const Text('Work from home'),
                          value: tempWorkFromHome,
                          onChanged: (bool? value) {
                            setSheetState(() => tempWorkFromHome = value!);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('Part-time'),
                          value: tempPartTime,
                          onChanged: (bool? value) {
                            setSheetState(() => tempPartTime = value!);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 16),
                        // Salary
                        DropdownButtonFormField<String>(
                          value: tempSalary,
                          decoration: _buildInputDecoration(
                              'Annual salary (in lakhs)', null),
                          items: _salaryOptions.map((String value) {
                            return DropdownMenuItem<String>(
                                value: value, child: Text(value));
                          }).toList(),
                          onChanged: (String? newValue) {
                            setSheetState(() => tempSalary = newValue!);
                          },
                        ),
                        const SizedBox(height: 16),
                        // Experience
                        DropdownButtonFormField<String>(
                          value: tempExperience,
                          decoration: _buildInputDecoration(
                              'Years of experience', null),
                          items: _experienceOptions.map((String value) {
                            return DropdownMenuItem<String>(
                                value: value, child: Text(value));
                          }).toList(),
                          onChanged: (String? newValue) {
                            setSheetState(() => tempExperience = newValue!);
                          },
                        ),
                      ],
                    ),
                  ),
                  // Bottom Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setSheetState(() {
                              tempProfile = 'Any';
                              tempLocation = 'Any';
                              tempWorkFromHome = false;
                              tempPartTime = false;
                              tempSalary = 'Any';
                              tempExperience = 'Any';
                            });
                            setState(() {
                              _selectedJobProfile = 'Any';
                              _selectedLocation = 'Any';
                              _isWorkFromHome = false;
                              _isPartTime = false;
                              _selectedSalary = 'Any';
                              _selectedExperience = 'Any';
                            });
                            _filterJobs();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 50),
                          ),
                          child: const Text('Clear All'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              _selectedJobProfile = tempProfile;
                              _selectedLocation = tempLocation;
                              _isWorkFromHome = tempWorkFromHome;
                              _isPartTime = tempPartTime;
                              _selectedSalary = tempSalary;
                              _selectedExperience = tempExperience;
                            });
                            _filterJobs();
                            Navigator.pop(context);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: _primaryColor,
                            minimumSize: const Size(0, 50),
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Helper for filter input decoration (unchanged) ---
  InputDecoration _buildInputDecoration(String label, IconData? icon) {
    // ... (unchanged)
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: _backgroundColor,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Find a Job'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
            tooltip: 'Filters',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredJobs.isEmpty
              ? const Center(
                  child: Text(
                    'No jobs match your criteria.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = _filteredJobs[index];
                    return _buildJobCard(job);
                  },
                ),
    );
  }

  Widget _buildJobCard(JobListingModel job) { // <-- CHANGED
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobApplicationScreen(job: job), // <-- Pass JobListingModel
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _primaryColor.withOpacity(0.1),
                    child: Icon(job.logo, color: _primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.role,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        Text(job.orgName, // <-- Use orgName
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoChip(
                  Icons.location_on_outlined, job.location, Colors.grey[600]!),
              if (job.isWorkFromHome)
                _buildInfoChip(Icons.home_work_outlined, 'Work from home',
                    Colors.grey[600]!),
              _buildInfoChip(
                  Icons.currency_rupee_rounded,
                  job.salary, // <-- Use salary string
                  Colors.grey[600]!),
              _buildInfoChip(Icons.group_add_outlined, // <-- Changed icon
                  '${job.openings} openings', Colors.grey[600]!), // <-- Use openings
              const SizedBox(height: 8),
              Text(
                job.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[800]),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTagChip(
                    DateFormat('MMM d').format(job.createdAt), // <-- Format date
                    Colors.green
                  ),
                  _buildTagChip(job.jobType, Colors.blue),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    // ... (unchanged)
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTagChip(String text, MaterialColor color) {
    // ... (unchanged)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color.shade700, fontWeight: FontWeight.w500),
      ),
    );
  }
}