// lib/profile/org_edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:rezume_app/services/org_service.dart'; // <-- ADDED
import 'package:rezume_app/models/org_model.dart'; // <-- ADDED

class OrgEditProfileScreen extends StatefulWidget {
  final String orgName; // Initial data from profile screen
  final String orgEmail; // Initial data from profile screen
  final Color themeColor;

  const OrgEditProfileScreen({
    super.key,
    required this.orgName,
    required this.orgEmail,
    required this.themeColor,
  });

  @override
  State<OrgEditProfileScreen> createState() => _OrgEditProfileScreenState();
}

class _OrgEditProfileScreenState extends State<OrgEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orgService = OrgService(); // <-- ADDED
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _hasNewImage = false;

  @override
  void initState() {
    super.initState();
    // Use initial data passed from profile screen
    _nameController = TextEditingController(text: widget.orgName);
    _emailController = TextEditingController(text: widget.orgEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      final result = await _orgService.updateMeOrg(
        _nameController.text,
        _emailController.text,
      );

      if (mounted) {
        setState(() { _isLoading = false; });
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Pop and signal update
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
        title: const Text('Edit Organization Profile'),
        backgroundColor: widget.themeColor,
        elevation: 0,
        actions: [
          _isLoading
              ? const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)))
              : IconButton(
                  icon: const Icon(Icons.check_rounded),
                  tooltip: 'Save',
                  onPressed: _saveProfile,
                )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // --- Photo Upload ---
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: widget.themeColor.withOpacity(0.1),
                    child: Text(
                      _nameController.text.isNotEmpty ? _nameController.text.substring(0, 1).toUpperCase() : '?',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: widget.themeColor),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Dummy image picking
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Feature not implemented.')),
                        );
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: widget.themeColor,
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Organization Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Organization Name',
                  prefixIcon: Icon(Icons.business_rounded, color: widget.themeColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.themeColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Organization name cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Organization Email',
                  prefixIcon: Icon(Icons.email_outlined, color: widget.themeColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.themeColor, width: 2),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email cannot be empty';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}