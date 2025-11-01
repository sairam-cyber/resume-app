// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:rezume_app/main.dart';
import 'package:rezume_app/screens/auth/registration_screen.dart';
import 'package:rezume_app/screens/auth/org_registration_screen.dart';
import 'package:rezume_app/screens/auth/forgot_password_screen.dart';
import 'package:rezume_app/services/auth_service.dart'; // <-- IMPORT
import 'package:rezume_app/app/localization/app_localizations.dart';
import 'package:rezume_app/widgets/language_selector_widget.dart';

class LoginScreen extends StatefulWidget {
  final bool registrationSuccessful;

  const LoginScreen({super.key, this.registrationSuccessful = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  String _selectedRole = 'User';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ... (Your color definitions are fine) ...
  final Color _userPrimaryColor = const Color(0xFF1E40AF); // Darker blue
  final Color _userSecondaryColor = const Color(0xFF2563EB); // Rich blue
  final Color _orgPrimaryColor = const Color(0xFF0EA5E9);
  final Color _orgSecondaryColor = const Color(0xFF38BDF8);

  Color get _currentPrimaryColor =>
      _selectedRole == 'User' ? _userPrimaryColor : _orgPrimaryColor;
  Color get _currentSecondaryColor =>
      _selectedRole == 'User' ? _userSecondaryColor : _orgSecondaryColor;

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false; // <-- ADD for loading indicator

  // --- NEW: AuthService instance ---
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // ... (Your existing initState logic is fine) ...
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

    if (widget.registrationSuccessful) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Registration successful! Please login with your credentials.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- UPDATED: Login Function ---
  void _login() async {
    if (_isLoading) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> result;

      if (_selectedRole == 'User') {
        result = await _authService.loginUser(
          phoneNumber: _phoneController.text,
          password: _passwordController.text,
        );
      } else {
        result = await _authService.loginOrg(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  MainScreen(userRole: _selectedRole),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Login failed'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields correctly'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // --- UPDATED: Guest Login Function ---
  void _loginAsGuest() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.registerGuest();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                MainScreen(userRole: 'User'), // Pass 'User' role for guest
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Guest login failed'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // ... (Your _buildAnimatedRoleButton method is fine) ...
  Widget _buildAnimatedRoleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // ... (your existing logic is fine)
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [_currentPrimaryColor, _currentSecondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _currentPrimaryColor.withOpacity(0.6),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        icon,
                        color: Colors.white,
                        size: 32,
                      ),
                      if (isSelected)
                        Positioned(
                          right: -5,
                          top: -5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _currentPrimaryColor,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: _currentPrimaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSelected ? 16 : 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      letterSpacing: isSelected ? 0.5 : 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _currentPrimaryColor,
              _currentSecondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- FIX: Reduced spacing ---
                  const SizedBox(height: 24), // Was 40
                  // Header Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.article_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                loc?.translate('login_title') ?? 'Welcome\nBack!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const LanguageSelectorWidget(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc?.translate('login_subtitle') ?? 'Sign in to continue your journey',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // --- FIX: Reduced spacing ---
                  const SizedBox(height: 24), // Was 40
                  // Role Selection
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc?.translate('login_choose_role') ?? 'Choose your role',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildAnimatedRoleButton(
                              icon: Icons.person_outline_rounded,
                              label: loc?.translate('login_user') ?? 'User',
                              isSelected: _selectedRole == 'User',
                              onTap: () =>
                                  setState(() => _selectedRole = 'User'),
                            ),
                            const SizedBox(width: 16),
                            _buildAnimatedRoleButton(
                              icon: Icons.business_rounded,
                              label: loc?.translate('login_organization') ?? 'Organization',
                              isSelected: _selectedRole == 'Organization',
                              onTap: () => setState(
                                  () => _selectedRole = 'Organization'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // --- FIX: Reduced spacing ---
                  const SizedBox(height: 24), // Was 40
                  // Login Form
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // --- CONDITIONALLY SHOW PHONE FIELD ---
                              if (_selectedRole == 'User') ...[
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: InputDecoration(
                                    labelText: loc?.translate('login_phone') ?? 'Phone number',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (_selectedRole == 'User' &&
                                        (value == null ||
                                            value.trim().length < 10)) {
                                      return loc?.translate('login_phone_error') ?? 'Please enter a valid 10-digit number';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16), // Spacing after phone
                              ],
                              // --- END PHONE FIELD ---

                              // --- CONDITIONALLY SHOW EMAIL FIELD ---
                              if (_selectedRole == 'Organization') ...[
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: loc?.translate('login_email') ?? "Organization's Email",
                                    prefixIcon: Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (_selectedRole == 'Organization') {
                                      if (value == null || value.trim().isEmpty)
                                        return loc?.translate('login_email_required') ?? 'Please enter email';
                                      if (!RegExp(r'\S+@\S+\.\S+')
                                          .hasMatch(value))
                                        return loc?.translate('login_email_invalid') ?? 'Enter valid email';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16), // Spacing after email
                              ],
                              // --- END EMAIL FIELD ---

                              // --- Password Field (Always Visible) ---
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: loc?.translate('login_password') ?? 'Password',
                                  prefixIcon: Icon(Icons.lock_outline_rounded),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                obscureText: true, // Keep obscureText
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 6) {
                                    return loc?.translate('login_password_error') ?? 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordScreen(
                                        themeColor: _currentPrimaryColor,
                                        role: _selectedRole,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    loc?.translate('login_forgot_password') ?? 'Forgot password?',
                                    style: TextStyle(
                                      color: _currentPrimaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              // --- START: Added Guest Login Button ---
                              // Only show this button if the 'User' role is selected
                              if (_selectedRole == 'User') ...[
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: _loginAsGuest,
                                  style: TextButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 44),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    loc?.translate('login_guest_account') ?? 'Create Guest Account?',
                                    style: TextStyle(
                                      color: _currentPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                              // --- END: Added Guest Login Button ---

                              const SizedBox(height: 16), // Was 24
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _currentPrimaryColor,
                                      _currentSecondaryColor,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          _currentPrimaryColor.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    minimumSize:
                                        const Size(double.infinity, 56),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white))
                                      : Text(
                                          (loc?.translate('login_button') ?? 'LOGIN').toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    loc?.translate('login_no_account') ?? "Don't have an account? ",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (_selectedRole == 'User') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const RegistrationScreen(),
                                          ),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const OrgRegistrationScreen(),
                                          ),
                                        );
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      loc?.translate('login_register') ?? 'Register',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _currentPrimaryColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // --- FIX: Reduced spacing ---
                  const SizedBox(height: 24), // Was 40
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}