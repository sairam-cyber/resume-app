// lib/profile/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:rezume_app/models/user_model.dart';
import 'package:rezume_app/services/user_service.dart';
import 'package:rezume_app/app/localization/app_localizations.dart';
import 'package:rezume_app/widgets/language_selector_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  bool _isLoading = true;
  String _initialAvatarText = '?';

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  // We'll keep a dummy job controller for now as the user model doesn't store it
  final _jobController = TextEditingController(text: 'Driver');

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final result = await _userService.getMe();
    if (mounted) {
      if (result['success']) {
        final user = result['user'] as UserModel;
        setState(() {
          _nameController.text = user.fullName;
          _phoneController.text = user.phoneNumber;
          _initialAvatarText = user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?';
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
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _jobController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      
      final result = await _userService.updateMe(
        _nameController.text,
        _phoneController.text,
      );

      if (mounted) {
        setState(() { _isLoading = false; });
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true); // Pop and signal update
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
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.translate('edit_profile_title') ?? 'Edit Profile'),
        actions: [
          const LanguageSelectorWidget(),
          const SizedBox(width: 8),
          _isLoading 
            ? const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)))
            : IconButton(
                icon: const Icon(Icons.check_rounded),
                tooltip: loc?.translate('common_save') ?? 'Save',
                onPressed: _saveProfile,
              )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue[50],
                      child: Text(
                        _initialAvatarText,
                        style: const TextStyle(fontSize: 48, color: Color(0xFF007BFF)),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Full Name
                    TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration('Full Name', Icons.person_outline_rounded),
                      validator: (v) => v!.isEmpty ? 'Name cannot be empty' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone Number
                    TextFormField(
                      controller: _phoneController,
                      decoration: _buildInputDecoration('Phone Number', Icons.phone_outlined),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.length < 10 ? 'Enter a valid 10-digit number' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Job (Dummy)
                    TextFormField(
                      controller: _jobController,
                      decoration: _buildInputDecoration('Job Description', Icons.work_outline_rounded),
                      readOnly: true, // This field is not saved to the user model
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2),
      ),
    );
  }
}