import 'package:flutter/material.dart';
import 'package:rezume_app/app/localization/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  final String role; // 'User' or 'Organization'
  final Function(int)? onNavigateToTab;

  const HomeScreen({super.key, required this.role, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- REMOVED: Language state is no longer managed here ---
  // String _selectedLanguage = 'en';
  // final List<Map<String, String>> _languageOptions = [ ... ];
  // String _getTutorialMessage(String langCode) { ... }
  // Map<String, String> _getStepDetails(String langCode, int step) { ... }

  // --- Define Color Themes ---
  final Color _userPrimaryColor = Color(0xFF007BFF);
  final Color _orgPrimaryColor = Colors.indigo.shade600;
  final Color _orgBackgroundColor = Colors.indigo.shade50;

  // --- Helper getters for current theme based on widget.role ---
  Color get _currentPrimaryColor =>
      widget.role == 'User' ? _userPrimaryColor : _orgPrimaryColor;
  Color get _currentBackgroundColor =>
      widget.role == 'User' ? Color(0xFFF0F8FF) : _orgBackgroundColor;

  @override
  Widget build(BuildContext context) {
    // Get localizations
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: _currentBackgroundColor,
      // --- AppBar has been removed as per your original file ---

      // --- We need to wrap the body in a SafeArea ---
      // --- to avoid the status bar at the top ---
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header Text ---
                Text(
                  widget.role == 'User'
                      ? (loc?.translate('How to Get Started') ??
                          'How to Get Started')
                      : 'Find Top Talent',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // --- REMOVED: Language Toggle Buttons ---
                // _buildLanguageToggleButtons(),
                // const SizedBox(height: 16),

                // 2. Video Player Section
                Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 60,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 3. Dynamic Tutorial Text (Now uses localization)
                Center(
                  child: Text(
                    // --- MODIFIED: Uses localization key ---
                    loc?.translate('tutorialMessage') ??
                        'Tutorial is being shown in your selected language',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Conditional Features/Suggestions Section
                if (widget.role == 'User') ...[
                  // --- User Features (Now use localization) ---
                  _buildFeatureCard(
                    icon: Icons.article_rounded,
                    // --- MODIFIED: Pass translated strings ---
                    title: loc?.translate('step1Title') ??
                        'Step 1: Choose a Template',
                    subtitle: loc?.translate('step1Subtitle') ??
                        'Pick a professional template that fits your style.',
                    onTap: () {
                      widget.onNavigateToTab?.call(1); // Navigate to Templates
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.auto_awesome_rounded,
                    // --- MODIFIED: Pass translated strings ---
                    title: loc?.translate('step2Title') ??
                        'Step 2: Fill in Details with AI',
                    subtitle: loc?.translate('step2Subtitle') ??
                        'Use our AI assistant to help you write details.',
                    onTap: () {
                      widget.onNavigateToTab?.call(1); // Navigate to Templates
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.download_for_offline_rounded,
                    // --- MODIFIED: Pass translated strings ---
                    title: loc?.translate('step3Title') ??
                        'Step 3: Download your Resume',
                    subtitle: loc?.translate('step3Subtitle') ??
                        'Download your completed resume as a PDF.',
                    onTap: () {
                      /* Show download options */
                    },
                  ),
                ] else ...[
                  // --- Organization Features (unchanged) ---
                  _buildFeatureCard(
                    icon: Icons.search_rounded,
                    title: 'Search Candidate Profiles',
                    subtitle:
                        'Filter candidates by skills, experience, and location.',
                    onTap: () {
                      widget.onNavigateToTab?.call(2);
                    },
                  ),
                  // ... other org cards
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- REMOVED: _buildLanguageToggleButtons() ---

  // --- MODIFIED: Helper Method for Feature Cards ---
  // This now accepts the final strings, not keys or steps.
  Widget _buildFeatureCard({
    required IconData icon,
    required VoidCallback onTap,
    required String title,
    required String subtitle,
  }) {
    // --- Determine text (simplified) ---
    String cardTitle = title;
    String cardSubtitle = subtitle;
    // --- End of text logic ---

    final Color color = _currentPrimaryColor == _userPrimaryColor
        ? Color(0xFF0056b3) // Dark blue for user
        : Colors.indigo.shade800; // Dark indigo for org

    final Color bgColor = _currentBackgroundColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Card(
        elevation: 1.5,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: bgColor, width: 1),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          leading: Icon(icon, color: color, size: 28),
          title: Text(
            cardTitle, // Use the determined title
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 17, color: color),
          ),
          subtitle: Text(cardSubtitle,
              style: TextStyle(color: color.withOpacity(0.7))),
          trailing:
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
        ),
      ),
    );
  }
}