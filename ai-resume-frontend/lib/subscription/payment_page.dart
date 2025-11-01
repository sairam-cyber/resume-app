import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Add this import at the top
import 'subscription_page.dart'; // To get the SubscriptionPlan model
import 'otp_verification_page.dart'; // To navigate to the next step

class PaymentPage extends StatefulWidget {
  final SubscriptionPlan plan;
  final Color planColor;

  const PaymentPage({
    super.key,
    required this.plan,
    required this.planColor,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete Payment'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'UPI / QR Code'),
              Tab(text: 'Credit/Debit Card'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUpiTab(context),
            _buildCardTab(context),
          ],
        ),
        bottomNavigationBar: _buildPayButton(context),
      ),
    );
  }

  // The "Pay" button at the bottom
  Widget _buildPayButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: widget.planColor,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () {
          // Validate form if on card tab
          if (_formKey.currentState != null &&
              _formKey.currentState!.validate()) {
            // All fields are valid, proceed to OTP verification
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationPage(plan: widget.plan),
              ),
            );
          } else if (_formKey.currentState == null) {
            // UPI tab - no validation needed, proceed directly
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationPage(plan: widget.plan),
              ),
            );
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please fill all card details correctly.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Text(
          'Pay ${widget.plan.price}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- Tab 1: UPI and QR Code ---
  Widget _buildUpiTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            'Scan to Pay',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Realistic QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: QrImageView(
              data:
                  'upi://pay?pa=your-merchant-id@upi&pn=Your-Business-Name&am=${widget.plan.price.replaceAll('₹', '')}&cu=INR',
              version: QrVersions.auto,
              size: 250.0,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(8),
              errorStateBuilder: (context, error) {
                return const Center(
                  child: Text(
                    'Something went wrong...',
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Or pay using UPI apps',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          // Dummy UPI app icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildUpiIcon(Icons.g_mobiledata, 'GPay'), // Placeholder
              _buildUpiIcon(Icons.phone_android, 'PhonePe'), // Placeholder
              _buildUpiIcon(Icons.payment, 'Paytm'), // Placeholder
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpiIcon(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          child: Icon(icon, size: 28),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // --- Tab 2: Card Payment Form ---
  Widget _buildCardTab(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          TextFormField(
            controller: _cardNumberController,
            decoration: const InputDecoration(
              labelText: 'Card Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.credit_card),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              CardNumberInputFormatter(),
            ],
            validator: (value) {
              if (value == null || value.replaceAll(' ', '').length != 16) {
                return 'Enter a valid 16-digit card number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  decoration: const InputDecoration(
                    labelText: 'Expiry (MM/YY)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    ExpiryDateInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null ||
                        !RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$')
                            .hasMatch(value)) {
                      return 'MM/YY';
                    }
                    final parts = value.split('/');
                    if (parts.length != 2) return 'MM/YY';
                    final month = int.tryParse(parts[0]);
                    final year = int.tryParse(parts[1]);
                    final currentYearLastTwo = DateTime.now().year % 100;
                    if (month == null ||
                        year == null ||
                        month < 1 ||
                        month > 12 ||
                        year < currentYearLastTwo) {
                      return 'Invalid';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cvcController,
                  decoration: const InputDecoration(
                    labelText: 'CVC',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value == null || value.length < 3 || value.length > 4) {
                      return '3-4 digits';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name on Card',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter the name on the card';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

// Custom formatter for Card Number (adds space every 4 digits)
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(' ', ''); // Remove existing spaces
    if (text.length > 16) text = text.substring(0, 16); // Max 16 digits

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('  '); // Add double space
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

// Custom formatter for Expiry Date (adds '/' after 2 digits)
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', ''); // Remove existing slash
    if (text.length > 4) text = text.substring(0, 4); // Max 4 digits (MMYY)

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        // Add slash after MM if YY is started
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}
