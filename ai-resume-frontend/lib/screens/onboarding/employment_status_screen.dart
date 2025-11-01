// lib/screens/onboarding/employment_status_screen.dart

import 'package:flutter/material.dart';
// Import the final destination (Login Screen)
import 'package:rezume_app/screens/auth/login_screen.dart';

class EmploymentStatusScreen extends StatelessWidget {
  // Accept data from previous screens
  // final Map<String, dynamic> registrationData;
  final String selectedExperience;

  // const EmploymentStatusScreen({super.key, required this.registrationData, required this.selectedExperience});
  const EmploymentStatusScreen({super.key, required this.selectedExperience}); // Simplified

  // --- Theme Colors (User Blue) ---
  final Color _primaryColor = const Color(0xFF007BFF);
  final Color _backgroundColor = const Color(0xFFF0F8FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Your Current Role'),
        backgroundColor: _primaryColor,
        // Allow back navigation to the previous onboarding step
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Text(
              'What best describes your current role?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
             SizedBox(height: 40),

            // --- Option Buttons ---
             _buildOptionCard(
              context: context,
              title: "College Student",
              subtitle: "Currently enrolled in a college or university.",
              onTap: () => _completeOnboarding(context, 'College Student'),
            ),
             _buildOptionCard(
              context: context,
              title: "Employee / White-Collar",
              subtitle: "Working in an office or professional environment.",
              onTap: () => _completeOnboarding(context, 'Employee / White-Collar'),
            ),
             _buildOptionCard(
              context: context,
              title: "Worker / Blue-Collar",
              subtitle: "Working in a trade, manual labor, or skilled craft.",
              onTap: () => _completeOnboarding(context, 'Worker / Blue-Collar'),
            ),
             _buildOptionCard(
              context: context,
              title: "Unemployed",
              subtitle: "Currently looking for job opportunities.",
              onTap: () => _completeOnboarding(context, 'Unemployed'),
            ),
             _buildOptionCard(
              context: context,
              title: "Other",
              subtitle: "", // No subtitle for Other
              onTap: () => _completeOnboarding(context, 'Other'),
            ),
          ],
        ),
      ),
    );
  }

  // --- Navigation Logic ---
  void _completeOnboarding(BuildContext context, String selectedStatus) {
    print("Selected Experience: $selectedExperience");
    print("Selected Status: $selectedStatus");
    // Navigate to Login screen and clear the onboarding history
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(registrationSuccessful: true), // Show success message
      ),
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  // --- Helper for Option Cards ---
  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 2,
        color: Colors.white, // White cards on light blue background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _primaryColor),
          ),
          subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 15)) : null,
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: _primaryColor.withOpacity(0.7)),
        ),
      ),
    );
  }
}