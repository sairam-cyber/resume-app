// lib/screens/onboarding/experience_level_screen.dart

import 'package:flutter/material.dart';
// Import the next screen in the flow
import 'package:rezume_app/screens/onboarding/employment_status_screen.dart';

class ExperienceLevelScreen extends StatelessWidget {
  // Pass data from registration if needed later, e.g., user details map
  // final Map<String, dynamic> registrationData;
  // const ExperienceLevelScreen({super.key, required this.registrationData});

  const ExperienceLevelScreen({super.key}); // Simplified for now

  // --- Theme Colors (User Blue) ---
  final Color _primaryColor = const Color(0xFF007BFF);
  final Color _backgroundColor = const Color(0xFFF0F8FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Your Experience'),
        backgroundColor: _primaryColor,
        automaticallyImplyLeading: false, // No back button needed in onboarding flow
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Text(
              'Have you used a resume builder before?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 12),
            Text(
              'This helps us tailor the experience for you.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 40),

            // --- Option Buttons ---
            _buildOptionCard(
              context: context,
              title: "Beginner",
              subtitle: "I'm new to this.",
              onTap: () => _navigateToNext(context, 'Beginner'),
            ),
            _buildOptionCard(
              context: context,
              title: "Intermediate",
              subtitle: "I've made a resume before.",
              onTap: () => _navigateToNext(context, 'Intermediate'),
            ),
            _buildOptionCard(
              context: context,
              title: "Expert",
              subtitle: "I'm confident in my resume skills.",
              onTap: () => _navigateToNext(context, 'Expert'),
            ),
          ],
        ),
      ),
    );
  }

  // --- Navigation Logic ---
  void _navigateToNext(BuildContext context, String selectedExperience) {
    print("Selected Experience: $selectedExperience");
    // Navigate to the Employment Status screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmploymentStatusScreen(
          // Pass registrationData along if you received it
          // registrationData: registrationData,
          selectedExperience: selectedExperience,
        ),
      ),
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
          subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: _primaryColor.withOpacity(0.7)),
        ),
      ),
    );
  }
}