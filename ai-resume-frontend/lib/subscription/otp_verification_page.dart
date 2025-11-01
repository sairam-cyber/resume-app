import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'subscription_page.dart'; // To get the SubscriptionPlan model

class OtpVerificationPage extends StatefulWidget {
  final SubscriptionPlan plan;
  const OtpVerificationPage({super.key, required this.plan});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final pinController = TextEditingController();
  final String dummyOtp = "123456"; // Our hardcoded "correct" OTP

  void _verifyOtp(String pin) {
    if (pin == dummyOtp) {
      // 1. Pop all the way back to the first screen
      Navigator.of(context).popUntil((route) => route.isFirst);

      // 2. Show the Material 3 success banner AT THE TOP
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          padding: const EdgeInsets.all(16),
          content: const Text(
            'Payment Successful!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green.shade700,
          actions: [
            TextButton(
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
              child:
                  const Text('DISMISS', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      // 3. Automatically hide the banner after 4 seconds
      Future.delayed(const Duration(seconds: 4), () {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      });
    } else {
      // Show an error message if OTP is wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid OTP. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Payment'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter OTP',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'An OTP has been sent to your registered email.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // The Pinput widget
              Pinput(
                controller: pinController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                onCompleted: (pin) {
                  _verifyOtp(pin); // Automatically verify on complete
                },
              ),
              const SizedBox(height: 32),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  _verifyOtp(pinController.text);
                },
                child: const Text('Verify & Complete Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
