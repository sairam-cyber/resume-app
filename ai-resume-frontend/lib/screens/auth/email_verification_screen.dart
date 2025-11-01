// lib/screens/auth/email_verification_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rezume_app/screens/auth/login_screen.dart'; // To navigate back

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final Color themeColor; // To pass the theme color (blue or indigo)

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.themeColor,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Timer? _timer;
  int _start = 120; // 2 minutes
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer(); // Start timer immediately
    // DUMMY: Simulate sending the code on screen load
    print('Sending verification code to ${widget.email}');
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

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

  void _resendCode() {
    if (_canResend) {
      // DUMMY: Simulate resending
      print('Resending verification code to ${widget.email}');
      _startTimer(); // Restart timer
    }
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      // DUMMY: Check if OTP is 6 digits for demo
      if (_otpController.text.length == 6) {
        _timer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email Verified Successfully! Please log in.'),
            backgroundColor: widget.themeColor, // Use the theme color
          ),
        );
        // Navigate back to Login screen, removing all previous screens
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Verification Code')),
        );
      }
    }
  }

  String get _timerText {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Check if bgColor is derived correctly
    final Color bgColor = widget.themeColor == Colors.indigo.shade600
        ? Colors.indigo.shade50 // Light Indigo
        : Color(0xFFF0F8FF); // Fallback to Light Blue

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // --- Background ---
          Column(
            children: [
              Container(
                height: screenHeight * 0.30,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.themeColor, // Use passed theme color
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(60)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 32.0, top: 80.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.mark_email_read_outlined,
                          color: Colors.white.withOpacity(0.9), size: 50),
                      SizedBox(height: 10),
                      Text('Verify Email',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Expanded(child: Container(color: bgColor)),
            ],
          ),
          // --- Form Card ---
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  top: screenHeight * 0.22, left: 24, right: 24, bottom: 24),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'Enter the 6-digit verification code sent to:\n${widget.email}',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _otpController,
                          decoration: InputDecoration(
                            labelText: 'Verification Code',
                            prefixIcon: Icon(Icons.password_rounded),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          validator: (v) =>
                              v!.length < 6 ? 'Enter 6 digits' : null,
                        ),
                        const SizedBox(height: 16),

                        // Timer and Resend button
                        _canResend
                            ? TextButton(
                                onPressed: _resendCode,
                                child: Text('Resend Code',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: widget.themeColor)))
                            : Text('Resend Code in $_timerText',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16)),

                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                widget.themeColor, // Use theme color
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            textStyle: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          child: Text('VERIFY EMAIL'),
                        ),
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
}
