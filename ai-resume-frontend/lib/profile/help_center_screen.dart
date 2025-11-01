import 'package:flutter/material.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  // Helper method for building the new contact cards
  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    // These colors match your app's theme
    const Color color = Color(0xFF0056b3); // Dark blue
    final Color bgColor = Colors.blue[50]!; // Light blue

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Card(
        elevation: 1.5,
        color: bgColor,
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
            color: color,
            size: 28,
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: color,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Make sure this is here
      appBar: AppBar(
        title: const Text("Help Center"),
      ),
      // Use this as the 'body' of your Help Center Scaffold
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Header Text ---
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // --- 2. New Contact Cards ---
            _buildContactCard(
              icon: Icons.phone_in_talk_rounded,
              title: 'Customer Support',
              subtitle: '+91 12345 67890',
              onTap: () {
                // Add logic to launch the phone dialer
              },
            ),

            _buildContactCard(
              icon: Icons.alternate_email_rounded,
              title: 'Support Email',
              subtitle: 'help@rezoom.app',
              onTap: () {
                // Add logic to launch an email client
              },
            ),

            _buildContactCard(
              icon: Icons.location_on_rounded,
              title: 'Office Address',
              subtitle: '123 Tech Park, Bangalore, India',
              onTap: () {
                // Add logic to open this in Google Maps
              },
            ),
          ],
        ),
      ),
    );
  }
}
