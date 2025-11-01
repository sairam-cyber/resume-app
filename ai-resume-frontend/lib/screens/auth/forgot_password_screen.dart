// lib/screens/auth/forgot_password_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final Color themeColor;
  final String role; // 'User' or 'Organization'

  const ForgotPasswordScreen({
    super.key,
    required this.themeColor,
    required this.role,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // --- 1. State Variables for OTP flow ---
  bool _isOtpSent = false;
  Timer? _timer;
  int _start = 120; // 2 minutes in seconds
  bool _canResend = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // --- 2. Timer Logic ---
  void _startTimer() {
    _canResend = false;
    _start = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  // --- 3. "Send Code" Logic ---
  void _sendCode() {
    if (_formKey.currentState!.validate()) {
      final contactInfo = widget.role == 'User' ? _phoneController.text : _emailController.text;
      print('Sending OTP to $contactInfo');
      setState(() {
        _isOtpSent = true;
      });
      _startTimer();
    }
  }

  // --- 4. "Verify OTP" Logic ---
  void _verifyOtp() {
    if (_otpController.text.length == 6) {
      _timer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP Verified! (Demo)')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP')),
      );
    }
  }

  // --- 5. "Change Contact" Logic ---
  void _changeContact() {
    _timer?.cancel();
    setState(() {
      _isOtpSent = false;
      _canResend = false;
      _otpController.clear();
      if (widget.role == 'User') {
        _phoneController.clear();
      } else {
        _emailController.clear();
      }
    });
  }

  // --- 6. Resend Code Logic ---
  void _resendCode() {
    if (_canResend) {
      _sendCode(); // Just call send code again for demo
    }
  }

  String get _timerText {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Determine background color based on theme
    final Color bgColor = widget.themeColor == Color(0xFF007BFF)
        ? Color(0xFFF0F8FF) // Light Blue
        : Colors.indigo.shade50; // Light Indigo

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // --- ADD BACKGROUND COLOR ---
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. Blue/Indigo Header ---
            Container(
              width: double.infinity,
              height: 300,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                // --- USE THEME COLOR ---
                color: widget.themeColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60), // For status bar + app bar
                  Text(
                    _isOtpSent ? 'Enter Code' : 'Reset Password',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. White Card with Form ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              // We add a negative margin to make it overlap the blue
              child: Transform.translate(
                offset: const Offset(0, -80), // Pulls the card up
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: _isOtpSent
                          ? _buildOtpScreen()
                          : (widget.role == 'User'
                              ? _buildPhoneScreen()
                              : _buildEmailScreen()),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI for entering the phone number ---
  Widget _buildPhoneScreen() {
    return Column(
      children: [
        Text(
          'Enter your phone number below. We will send you a verification code to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone number',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.phone,
          validator: (v) => v!.length < 10 ? 'Enter a valid number' : null,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _sendCode,
          style: ElevatedButton.styleFrom(
            // --- USE THEME COLOR ---
            backgroundColor: widget.themeColor,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text('SEND CODE'),
        ),
      ],
    );
  }

  // --- UI for entering Email ---
  Widget _buildEmailScreen() {
    return Column(
      children: [
        Text(
          'Enter your organization\'s email below. We will send you a verification code to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Organization\'s Email',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Please enter email';
            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Enter valid email';
            return null;
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _sendCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.themeColor,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text('SEND CODE'),
        ),
      ],
    );
  }

  // --- UI for entering the OTP ---
  Widget _buildOtpScreen() {
    final contactInfo = widget.role == 'User' ? _phoneController.text : _emailController.text;
    return Column(
      children: [
        Text(
          'Enter the 6-digit code sent to\n$contactInfo',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _otpController,
          decoration: InputDecoration(
            labelText: 'OTP',
            prefixIcon: Icon(Icons.password_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          validator: (v) => v!.length < 6 ? 'Enter a 6-digit OTP' : null,
        ),
        const SizedBox(height: 16),

        // Timer and Resend button
        _canResend
            ? TextButton(
                onPressed: _resendCode,
                child: Text('Resend Code', style: TextStyle(fontSize: 16, color: widget.themeColor)))
            : Text('Resend OTP in $_timerText',
                style: TextStyle(color: Colors.grey, fontSize: 16)),

        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _verifyOtp,
          style: ElevatedButton.styleFrom(
            // --- USE THEME COLOR ---
            backgroundColor: widget.themeColor,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text('VERIFY'),
        ),
        TextButton(
          onPressed: _changeContact,
          child: Text(
            widget.role == 'User' ? 'Change Number' : 'Change Email',
            style: TextStyle(color: widget.themeColor.withOpacity(0.8)),
          ),
        ),
      ],
    );
  }
}
