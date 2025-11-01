// lib/ats_checker/ats_results_screen.dart

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:rezume_app/ats_checker/resume_editor_screen.dart';

class AtsResultsScreen extends StatefulWidget {
  // --- ADD THESE PARAMETERS ---
  final String resumeId;
  final int atsScore;
  final String scoreMessage;
  final List<Map<String, dynamic>> suggestions;

  const AtsResultsScreen({
    super.key,
    required this.resumeId,
    required this.atsScore,
    required this.scoreMessage,
    required this.suggestions,
  });
  // --- END ---

  @override
  State<AtsResultsScreen> createState() => _AtsResultsScreenState();
}

class _AtsResultsScreenState extends State<AtsResultsScreen> {
  // Removed all fake data generation and initState

  Color _getScoreColor(int score) {
    if (score < 50) {
      return Colors.red.shade600;
    } else if (score < 75) {
      return Colors.orange.shade600;
    } else {
      return Colors.green.shade600;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'suggestion':
        return Colors.blue;
      case 'tip':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // --- *** NEW HELPER FUNCTION TO FIX THE ERROR *** ---
  /// Safely maps icon names from the API to actual IconData objects.
  IconData _getIconForString(String? iconName) {
    if (iconName == null) return Icons.info_outline;

    // Check for common keywords in the string from Gemini
    switch (iconName.toLowerCase()) {
      case 'article':
      case 'text':
      case 'summary':
        return Icons.article_rounded;
      case 'check':
      case 'correct':
        return Icons.check_circle_outline_rounded;
      case 'warning':
      case 'critical':
        return Icons.warning_amber_rounded;
      case 'tip':
      case 'lightbulb':
      case 'suggestion':
        return Icons.lightbulb_outline_rounded;
      case 'keyword':
      case 'keywords':
        return Icons.vpn_key_outlined;
      case 'format':
      case 'formatting':
        return Icons.format_align_left_rounded;
      case 'skill':
      case 'skills':
        return Icons.star_border_rounded;
      case 'experience':
        return Icons.work_outline_rounded;
      default:
        return Icons.info_outline; // Default fallback
    }
  }
  // --- *** END OF NEW FUNCTION *** ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Your ATS Score'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        Text('YOUR SCORE',
                            style: TextStyle(color: Colors.blue[800])),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.atsScore}%', // <-- Use widget.atsScore
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(
                                widget.atsScore), // <-- Use widget.atsScore
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.scoreMessage, // <-- Use widget.scoreMessage
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'AI Suggestions to Improve',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                itemCount:
                    widget.suggestions.length, // <-- Use widget.suggestions
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final suggestion =
                      widget.suggestions[index]; // <-- Use widget.suggestions
                  return _buildSuggestionCard(
                    // --- *** THIS IS THE FIX *** ---
                    // Replaced the int.parse() with the new helper function
                    icon: _getIconForString(suggestion['icon'] as String?),
                    // --- *** END OF FIX *** ---
                    title: suggestion['title'],
                    subtitle: suggestion['subtitle'],
                    severity: suggestion['severity'] ?? 'suggestion',
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResumeEditorScreen(
                        resumeId: widget.resumeId, // <-- PASS resumeId
                        suggestions: widget.suggestions,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Edit My Resume',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String severity,
  }) {
    return Card(
      elevation: 1.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: Icon(icon, color: _getSeverityColor(severity), size: 28),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}