// lib/screens/auth/registration_screen.dart

import 'package:flutter/material.dart';
import 'package:rezume_app/screens/onboarding/experience_level_screen.dart';
import 'package:rezume_app/services/auth_service.dart'; // <-- IMPORT

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // --- Form controllers and state variables ---
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedGender = '';
  bool _isLoading = false; // <-- ADD for loading indicator

  // --- Password strength variables ---
  double _passwordStrength = 0;
  String _strengthText = '';
  Color _strengthColor = Colors.grey;

  // --- NEW: AuthService instance ---
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Listener for real-time password strength check
    _passwordController.addListener(() {
      _checkPasswordStrength(_passwordController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Password strength logic (UNCHANGED) ---
  void _checkPasswordStrength(String password) {
    // ... (your existing logic is fine)
    double strength = 0;
    String text = 'Weak';
    Color color = Colors.red;

    if (password.isEmpty) {
      strength = 0;
      text = '';
      color = Colors.grey;
    } else if (password.length < 6) {
      strength = 0.25;
      text = 'Too short';
      color = Colors.red;
    } else {
      strength = 0.25;
      if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
      if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password))
        strength += 0.25;
    }

    if (strength >= 1.0) {
      text = 'Very Strong';
      color = Colors.green;
    } else if (strength >= 0.75) {
      text = 'Strong';
      color = Colors.lightGreen;
    } else if (strength >= 0.5) {
      text = 'Medium';
      color = Colors.orange;
    }

    setState(() {
      _passwordStrength = strength;
      _strengthText = text;
      _strengthColor = color;
    });
  }

  // --- UPDATED: Registration logic (navigates to onboarding for Users) ---
  void _register() async {
    if (_isLoading) return; // Prevent multiple taps

    if (_formKey.currentState!.validate()) {
      if (_selectedGender.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a gender')),
        );
        return;
      }

      setState(() {
        _isLoading = true; // Show loading indicator
      });

      // Call API
      final result = await _authService.registerUser(
        fullName: _nameController.text,
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _isLoading = false; // Hide loading indicator
        });

        if (result['success']) {
          // Navigate to onboarding flow for User registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ExperienceLevelScreen(),
            ),
          );
        } else {
          // Show error message from backend
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registration failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all mandatory fields')),
      );
    }
  }

  // --- Label helper with red star (UNCHANGED) ---
  Widget _buildMandatoryLabel(String title) {
    // ... (your existing logic is fine)
    return RichText(
      text: TextSpan(
        text: title,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700]),
        children: const <TextSpan>[
          TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // --- THIS IS THE FIX ---
    // The stray comments and code snippets have been removed from here.
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // --- LAYER 1: THE BACKGROUND ---
          Column(
            children: [
              Container(
                height: screenHeight * 0.35, // 35% of the screen
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF007BFF), // Your app's blue
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 32.0, top: 90.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.article_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'User Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(color: const Color(0xFFF0F8FF)),
              ),
            ],
          ),

          // --- LAYER 2: THE SCROLLABLE FORM CARD ---
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  top: screenHeight * 0.28, // 28% from the top
                  left: 24,
                  right: 24),
              child: Card(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // -- Full Name --
                        _buildMandatoryLabel('Full name'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'Name cannot be empty' : null,
                        ),
                        const SizedBox(height: 16),

                        // -- Phone Number --
                        _buildMandatoryLabel('Phone number'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) =>
                              v!.length < 10 ? 'Enter a valid number' : null,
                        ),
                        const SizedBox(height: 16),

                        // -- Set Password --
                        _buildMandatoryLabel('Set Password'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) =>
                              v!.length < 6 ? 'Password is too short' : null,
                        ),

                        // -- Password Strength Bar --
                        if (_passwordController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(
                                  value: _passwordStrength,
                                  backgroundColor: Colors.grey[300],
                                  color: _strengthColor,
                                  minHeight: 6,
                                ),
                                const SizedBox(height: 4),
                                Text(_strengthText,
                                    style: TextStyle(
                                        color: _strengthColor,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),

                        // -- Confirm Password --
                        _buildMandatoryLabel('Confirm Password'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => v != _passwordController.text
                              ? 'Passwords do not match'
                              : null,
                        ),
                        const SizedBox(height: 24),

                        // -- Gender --
                        _buildMandatoryLabel('Gender'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildGenderOption(
                              iconPath: 'assets/images/male_avatar.png',
                              label: 'Male',
                              isSelected: _selectedGender == 'Male',
                              onTap: () =>
                                  setState(() => _selectedGender = 'Male'),
                            ),
                            _buildGenderOption(
                              iconPath: 'assets/images/female_avatar.png',
                              label: 'Female',
                              isSelected: _selectedGender == 'Female',
                              onTap: () =>
                                  setState(() => _selectedGender = 'Female'),
                            ),
                            _buildGenderOption(
                              iconPath: 'assets/images/other_avatar.png',
                              label: 'Other',
                              isSelected: _selectedGender == 'Other',
                              onTap: () =>
                                  setState(() => _selectedGender = 'Other'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // -- SUBMIT Button --
                        ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007BFF),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            textStyle: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : const Text('SUBMIT'),
                        ),
                        const SizedBox(height: 16),
                        const Center(
                            child: Text('* Mandatory',
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget for Gender Buttons (UNCHANGED) ---
  Widget _buildGenderOption({
    String? iconPath,
    IconData? iconData,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // ... (your existing logic is fine)
    const Color selectedColor = Color(0xFF007BFF);
    final Color unselectedBgColor = Colors.grey[200]!;
    final Color selectedBgColor = selectedColor.withOpacity(0.15);
    final Color unselectedTextColor = Colors.grey[600]!;

    Widget iconWidget;
    if (iconPath != null) {
      iconWidget = Image.asset(iconPath, width: 45, height: 45);
    } else if (iconData != null) {
      iconWidget = Icon(iconData,
          size: 45, color: isSelected ? selectedColor : unselectedTextColor);
    } else {
      iconWidget = const SizedBox(width: 45, height: 45);
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: isSelected ? selectedBgColor : unselectedBgColor,
            child: iconWidget,
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? selectedColor : unselectedTextColor)),
        ],
      ),
    );
  }
}