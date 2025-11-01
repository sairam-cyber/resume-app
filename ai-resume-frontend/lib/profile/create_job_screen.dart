// lib/profile/create_job_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rezume_app/models/job_model.dart'; // <-- IMPORT THE NEW MODEL

class CreateJobScreen extends StatefulWidget {
  final Color themeColor;

  const CreateJobScreen({super.key, required this.themeColor});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _openingsController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Dummy list of roles for the app
  final List<String> _jobRoles = [
    'Driver',
    'Electrician',
    'Plumber',
    'Cook',
    'Security Guard',
    'Welder',
    'Carpenter',
    'Mechanic',
    'Housekeeping',
    'AC Technician',
  ];
  String? _selectedRole;

  @override
  void dispose() {
    _jobTitleController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _openingsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _postJob() {
    // Validate all fields
    if (_formKey.currentState!.validate()) {
      // --- THIS IS THE MODIFICATION ---
      // 1. Create the new job object from the form fields
      final newJob = Job(
        role: _selectedRole!, // Validator ensures this is not null
        location: _locationController.text,
        salary: _salaryController.text,
        openings: _openingsController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : 'No description provided.',
      );

      // 2. Show the success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job posted successfully for $_selectedRole!'),
          backgroundColor: Colors.green,
        ),
      );

      // 3. Pop the screen AND return the newJob object to the previous screen
      Navigator.pop(context, newJob);
      // --- END OF MODIFICATION ---
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Job'),
        backgroundColor: widget.themeColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Job Role Dropdown ---
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                hint: const Text('Select Job Role'),
                decoration: _buildInputDecoration(
                    'Job Role *', Icons.work_outline_rounded),
                items: _jobRoles.map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a job role' : null,
              ),

              const SizedBox(height: 16),

              // --- Location ---
              TextFormField(
                controller: _locationController,
                decoration: _buildInputDecoration(
                    'Location (e.g., Rourkela, Odisha) *',
                    Icons.location_on_outlined),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 16),

              // --- Salary Range ---
              TextFormField(
                controller: _salaryController,
                decoration: _buildInputDecoration(
                    'Salary Range (e.g., ₹15,000 - ₹20,000) *',
                    Icons.currency_rupee_rounded),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a salary range' : null,
              ),
              const SizedBox(height: 16),

              // --- Number of Openings ---
              TextFormField(
                controller: _openingsController,
                decoration: _buildInputDecoration(
                    'Number of Openings *', Icons.group_add_outlined),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value!.isEmpty
                    ? 'Please enter the number of openings'
                    : null,
              ),
              const SizedBox(height: 16),

              // --- Job Description ---
              TextFormField(
                controller: _descriptionController,
                decoration: _buildInputDecoration(
                    'Job Description', Icons.description_outlined,
                    alignLabel: true),
                maxLines: 5,
                // Description can be optional, so no validator
              ),
              const SizedBox(height: 30),

              // --- Post Job Button ---
              ElevatedButton(
                onPressed: _postJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Post Job'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build consistent InputDecoration
  InputDecoration _buildInputDecoration(String label, IconData icon,
      {bool alignLabel = false}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: widget.themeColor),
      alignLabelWithHint: alignLabel,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: widget.themeColor, width: 2),
      ),
    );
  }
}
