import 'package:flutter/material.dart';
import 'package:rezume_app/home/home_screen.dart';

class UserExperienceScreen extends StatefulWidget {
  const UserExperienceScreen({super.key});

  @override
  State<UserExperienceScreen> createState() => _UserExperienceScreenState();
}

class _UserExperienceScreenState extends State<UserExperienceScreen> {
  // Helper method for building the new journey option buttons
  Widget _buildJourneyOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Card(
        elevation: 1.5,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 16,
          ),
          leading: Icon(
            icon,
            color: const Color(0xFF007BFF), // Your app's primary blue
            size: 28,
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Keep the background clean

      // --- ADD THIS APPBAR ---
      appBar: AppBar(
        title: const Text(
          'A Quick Question',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white, // Match the body
        elevation: 0, // No shadow

        // This automatically adds the black back arrow
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      // --- END OF CHANGE ---
      // Use this as the 'body' of your user_experience_screen.dart Scaffold
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // --- Header Section ---
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue[50], // Light blue background
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                size: 44,
                color: Color(0xFF007BFF), // Your app's primary blue
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Have you created a resume before?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This helps us personalize your journey.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),

            // --- Option Buttons ---
            _buildJourneyOption(
              icon: Icons.person_add_alt_1_rounded,
              title: "I'm a Beginner",
              subtitle: 'First time making a resume',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen(role: 'User')),
                );
              },
            ),

            _buildJourneyOption(
              icon: Icons.upgrade_rounded,
              title: "I'm Experienced",
              subtitle: "I've made resumes before",
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen(role: 'User')),
                );
              },
            ),

            // "Upload Existing Resume" option has been removed.
          ],
        ),
      ),
    );
  }
}
