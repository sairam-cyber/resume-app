// lib/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:rezume_app/models/user_model.dart';
import 'package:rezume_app/models/org_model.dart'; // <-- ADDED
import 'package:rezume_app/services/user_service.dart'; 
import 'package:rezume_app/services/org_service.dart'; // <-- ADDED
import 'package:rezume_app/screens/auth/login_screen.dart';
import 'package:rezume_app/profile/help_center_screen.dart';
import 'package:rezume_app/profile/edit_profile_screen.dart';
import 'package:rezume_app/profile/saved_resumes_screen.dart';
import 'package:rezume_app/profile/org_edit_profile_screen.dart';
// --- MODIFICATION: Removed PostedJobsScreen import ---
import 'package:rezume_app/profile/user_job_search_screen.dart';

class ProfileScreen extends StatefulWidget {
  // ... (class definition is unchanged) ...
  final String role; // 'User' or 'Organization'

  const ProfileScreen({super.key, required this.role});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ... (all state variables and helper functions are unchanged) ...
  // --- Theme Colors ---
  final Color _userPrimaryColor = Color(0xFF007BFF);
  final Color _orgPrimaryColor = Colors.indigo.shade600;

  Color get _currentPrimaryColor =>
      widget.role == 'User' ? _userPrimaryColor : _orgPrimaryColor;

  // --- Services ---
  final UserService _userService = UserService();
  final OrgService _orgService = OrgService(); // <-- ADDED

  // --- State ---
  bool _isLoading = true;
  bool _isGuest = false;

  // --- Profile Data ---
  String _profileName = '';
  String _profileContact = '';
  String _profileAvatarText = '';
  String _profileEmail = ''; // For orgs

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; });

    if (widget.role == 'User') {
      await _fetchUserData();
    } else {
      await _fetchOrgData();
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }
  
  // --- Fetch USER data from API ---
  Future<void> _fetchUserData() async {
    final result = await _userService.getMe();
    if (mounted) {
      if (result['success']) {
        final user = result['user'] as UserModel;
        setState(() {
          _isGuest = user.isGuest;
          _profileName = user.isGuest ? 'Guest Account' : user.fullName;
          _profileContact = user.isGuest ? 'Register to save your data!' : user.phoneNumber;
          _profileAvatarText = user.isGuest ? 'G' : (user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?');
        });
      } else {
        print(result['message']);
        setState(() {
          _isGuest = true;
          _profileName = 'Guest Account';
          _profileContact = 'Register to save your data!';
          _profileAvatarText = 'G';
        });
      }
    }
  }

  // --- Fetch ORGANIZATION data from API ---
  Future<void> _fetchOrgData() async {
    final result = await _orgService.getMeOrg();
    if (mounted) {
      if (result['success']) {
        final org = result['org'] as OrgModel;
        setState(() {
          _profileName = org.orgName;
          _profileContact = org.email;
          _profileEmail = org.email;
          _profileAvatarText = org.orgName.isNotEmpty ? org.orgName[0].toUpperCase() : '?';
        });
      } else {
        print(result['message']);
        setState(() {
          _profileName = 'Organization';
          _profileContact = 'Error loading email';
          _profileAvatarText = 'O';
        });
      }
    }
  }

  // --- UNCHANGED: Dialog to show for guests ---
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration Required'),
        content: const Text(
            'This feature is available for registered users. Please log in or create an account to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('Login / Register'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        // ... (appBar is unchanged) ...
        title: Text(
            widget.role == 'User' ? 'Your Profile' : 'Organization Profile'),
        backgroundColor: _currentPrimaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: _currentPrimaryColor))
          : Column(
              children: [
                // --- 1. Header (unchanged) ---
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: _currentPrimaryColor.withOpacity(0.1),
                        child: Text(
                          _profileAvatarText, // Dynamic
                          style: TextStyle(
                              fontSize: 48,
                              color: _currentPrimaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _profileName, // Dynamic
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _profileContact, // Dynamic
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _isGuest ? 15 : 16,
                          color: _isGuest ? Colors.grey[700] : Colors.grey[600],
                          fontStyle: _isGuest ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- 2. Button List (MODIFIED) ---
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 30.0),
                    children: [
                      // --- Edit Profile (unchanged) ---
                      _buildProfileOption(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Profile',
                        onTap: () async { // <-- Make async
                          // ... (unchanged logic)
                          if (widget.role == 'User' && _isGuest) {
                            _showLoginRequiredDialog();
                          } else if (widget.role == 'User') {
                            // Navigate and wait for a possible update
                            final bool? didUpdate = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                            if (didUpdate == true) {
                              _fetchData(); // Refetch data
                            }
                          } else {
                            // Navigate and wait for a possible update
                            final bool? didUpdate = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrgEditProfileScreen(
                                  // Pass current data to the edit screen
                                  orgName: _profileName,
                                  orgEmail: _profileEmail,
                                  themeColor: _currentPrimaryColor,
                                ),
                              ),
                            );
                            if (didUpdate == true) {
                              _fetchData(); // Refetch data
                            }
                          }
                        },
                        color: _currentPrimaryColor,
                      ),

                      if (widget.role == 'User') ...[
                        // --- User options (unchanged) ---
                        _buildProfileOption(
                          icon: Icons.article_outlined,
                          title: 'My Saved Resumes',
                          onTap: () {
                            if (_isGuest) {
                              _showLoginRequiredDialog();
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SavedResumesScreen(),
                                ),
                              );
                            }
                          },
                          color: _currentPrimaryColor,
                        ),
                        _buildProfileOption(
                          icon: Icons.work_outline_rounded,
                          title: 'Apply for Jobs',
                          onTap: () {
                            if (_isGuest) {
                              _showLoginRequiredDialog();
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const UserJobSearchScreen(),
                                ),
                              );
                            }
                          },
                          color: _currentPrimaryColor,
                        ),
                      ] else ...[
                        // --- ORGANIZATION ONLY: "Create Job" button REMOVED ---
                      ],

                      _buildProfileOption(
                        // ... (Help Center button unchanged) ...
                        icon: Icons.help_outline_rounded,
                        title: 'Help Center',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HelpCenterScreen()),
                          );
                        },
                        color: _currentPrimaryColor,
                      ),
                      const SizedBox(height: 20),
                      _buildProfileOption(
                        // ... (Logout button unchanged) ...
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        onTap: () {
                          // TODO: Clear token from SharedPreferences
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        color: Colors.red.shade600,
                        isLogout: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // --- _buildProfileOption helper is unchanged ---
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
    bool isLogout = false,
  }) {
    // ... (unchanged)
    final Color bgColor =
        isLogout ? Colors.red.shade50 : color.withOpacity(0.1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: bgColor,
        leading: Icon(icon, color: color, size: 24),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: color,
        ),
      ),
    );
  }
}