// lib/screens/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
// Make sure this import path is correct for your project!
import 'package:rezume_app/screens/language_selection_screen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
      
  late AnimationController _controller;
  late Animation<double> _imageScaleAnimation;
  late Animation<double> _imageFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000), // Shorter duration
      vsync: this,
    );

    // Image animation
    _imageScaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _imageFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // Navigate after the animation is complete
    Timer(
      const Duration(seconds: 3), // Total 3-second delay
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LanguageSelectionScreen(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your animated custom image
            FadeTransition(
              opacity: _imageFadeAnimation,
              child: ScaleTransition(
                scale: _imageScaleAnimation,
                child: Image.asset(
                  'assets/images/rezoom_logo.png', // Your custom logo path
                  width: 200, 
                  height: 200, 
                ),
              ),
            ),
            
            // The black "REZOOM" Text widget has been removed.
            
          ],
        ),
      ),
    );
  }
}