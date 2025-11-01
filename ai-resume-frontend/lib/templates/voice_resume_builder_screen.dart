// lib/templates/voice_resume_builder_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';

// PDF Generation Imports
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Dummy data to pre-fill the form (from resume_builder_screen.dart)
final Map<String, dynamic> _fullDriverResumeData = {
  'fullName': 'Rajesh Kumar Singh',
  'jobTitle': 'Professional Driver',
  'contact': {
    'phone': '+91 98765 43210',
    'email': 'rajesh.kumar@email.com',
    'location': 'Mumbai, Maharashtra'
  },
  'license': 'Valid Driving License (LMV & HMV)',
  'summary':
      'Reliable and safety-focused professional driver with 8+ years of experience in passenger and goods transportation. Proven track record of maintaining a 100% accident-free driving record while delivering exceptional customer service. Skilled in route optimization, vehicle maintenance, and compliance with traffic regulations. Committed to punctuality and ensuring safe, comfortable journeys for all passengers.',
  'skills': [
    'Defensive Driving',
    'Route Planning & GPS Navigation',
    'Vehicle Maintenance & Inspection',
    'Time Management',
    'Customer Service Excellence',
    'Traffic Law Compliance',
    'Load Securing & Cargo Management',
    'DOT Regulations Knowledge',
    'Clean Driving Record',
    'Fuel Efficiency Optimization',
    'Emergency Response',
    'Multi-vehicle Operation',
  ],
  'experience': [
    {
      'position': 'Senior Company Driver',
      'company': 'Tata Corporate Services | Mumbai, MH',
      'duration': 'June 2020 - Present',
      'details': [
        'Safely transport executives and VIP clients across Mumbai metropolitan area, maintaining 99% on-time performance record',
        'Reduced fuel costs by 18% through strategic route optimization and efficient driving practices, saving 85,000 annually',
        'Maintained pristine vehicle condition with zero breakdown incidents over 4 years through proactive maintenance',
        'Awarded \'Driver of the Year 2023\' for outstanding service and zero traffic violations',
        'Successfully managed scheduling for 5+ executives simultaneously, coordinating 30+ trips weekly',
      ]
    },
    // ... (other experiences from resume_builder_screen)
  ],
  'education': {
    'degree': 'Higher Secondary Certificate (12th)',
    'institution': 'Maharashtra State Board | Pune, Maharashtra',
    'year': '2015',
  },
  'certifications': [
    'Valid LMV & HMV Driving License (Exp: 2028)',
    'Defensive Driving Certification - National Safety Council (2022)',
    'First Aid & CPR Certified - Red Cross India (2023)',
    'Vehicle Maintenance Training - Auto Service Training Institute (2021)',
    'GPS Navigation & Route Optimization Workshop (2020)',
  ],
  'languages': ['English', 'Hindi', 'Marathi'],
};

// Enum to manage the state of the screen
enum VoiceBuildState {
  idle,
  listening,
  processing,
  editing,
}

class VoiceResumeBuilderScreen extends StatefulWidget {
  const VoiceResumeBuilderScreen({super.key});

  @override
  State<VoiceResumeBuilderScreen> createState() =>
      _VoiceResumeBuilderScreenState();
}

class _VoiceResumeBuilderScreenState extends State<VoiceResumeBuilderScreen>
    with TickerProviderStateMixin {
  VoiceBuildState _currentState = VoiceBuildState.idle;
  int _processingStep = 0;
  final List<String> _processingSteps = [
    'Extracting features...',
    'Converting into JSON...',
    'Building a resume...',
  ];

  // Controllers for the editable form
  final _nameController =
      TextEditingController(text: _fullDriverResumeData['fullName']);
  final _jobTitleController =
      TextEditingController(text: _fullDriverResumeData['jobTitle']);
  final _phoneController =
      TextEditingController(text: _fullDriverResumeData['contact']['phone']);
  final _emailController =
      TextEditingController(text: _fullDriverResumeData['contact']['email']);
  final _locationController =
      TextEditingController(text: _fullDriverResumeData['contact']['location']);
  final _summaryController =
      TextEditingController(text: _fullDriverResumeData['summary']);
  final _skillsController = TextEditingController(
      text: (_fullDriverResumeData['skills'] as List).join(', '));

  // Animation controller for the listening state
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _jobTitleController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _startListening() {
    setState(() {
      _currentState = VoiceBuildState.listening;
    });

    // Simulate listening for 3 seconds
    Timer(const Duration(seconds: 3), () {
      _startProcessing();
    });
  }

  void _startProcessing() {
    setState(() {
      _currentState = VoiceBuildState.processing;
      _processingStep = 0;
    });

    // Simulate the multi-step process
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_processingStep < _processingSteps.length - 1) {
        setState(() {
          _processingStep++;
        });
      } else {
        timer.cancel();
        // Finished processing, move to editing
        setState(() {
          _currentState = VoiceBuildState.editing;
        });
      }
    });
  }

  // --- PDF Generation Logic (copied from resume_builder_screen.dart) ---
  Future<void> _generateFullPdf() async {
    final pdf = pw.Document();
    pw.ThemeData myTheme;

    // Load fonts
    try {
      final fontData =
          await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      final hindiFontData =
          await rootBundle.load("assets/fonts/NotoSansDevanagari-Regular.ttf");
      final odiaFontData =
          await rootBundle.load("assets/fonts/NotoSansOriya-Regular.ttf");
      final ttf = pw.Font.ttf(fontData);
      final hindiTtf = pw.Font.ttf(hindiFontData);
      final odiaTtf = pw.Font.ttf(odiaFontData);
      myTheme = pw.ThemeData.withFont(
        base: ttf,
        fontFallback: [hindiTtf, odiaTtf],
      );
    } catch (e) {
      print('Custom fonts not found. Using default fonts. Error: $e');
      myTheme = pw.ThemeData.base();
    }

    // --- Get Data from Controllers ---
    final String fullName = _nameController.text;
    final String jobTitle = _jobTitleController.text;
    final String phone = _phoneController.text;
    final String email = _emailController.text;
    final String location = _locationController.text;
    final String summary = _summaryController.text;
    final List skills =
        _skillsController.text.split(',').map((s) => s.trim()).toList();

    // Use dummy data for sections not in the form
    final String license = _fullDriverResumeData['license'];
    final List experience = _fullDriverResumeData['experience'];
    final Map education = _fullDriverResumeData['education'];
    final List certifications = _fullDriverResumeData['certifications'];

    pdf.addPage(
      pw.Page(
        theme: myTheme,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                fullName,
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: pw.Text(
                  jobTitle,
                  style:
                      const pw.TextStyle(fontSize: 16, color: PdfColors.grey),
                ),
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(phone),
                  pw.Text(email),
                  pw.Text(location),
                ],
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4.0),
                child: pw.Text(
                  'License: $license',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 12),
              _buildPdfSection('Professional Summary', myTheme),
              pw.Text(summary),
              pw.SizedBox(height: 12),
              _buildPdfSection('Core Skills', myTheme),
              pw.Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children:
                    skills.map((s) => pw.Text('• ${s.toString()}')).toList(),
              ),
              pw.SizedBox(height: 12),
              _buildPdfSection('Work Experience', myTheme),
              ...experience.map((exp) {
                final Map<String, dynamic> e =
                    exp is Map<String, dynamic> ? exp : {};
                final expDetails = e['details'] as List? ?? [];
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6.0),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        e['position']?.toString() ?? '',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '${e['company']?.toString() ?? ''} | ${e['duration']?.toString() ?? ''}',
                        style: const pw.TextStyle(color: PdfColors.grey700),
                      ),
                      if (expDetails.isNotEmpty) pw.SizedBox(height: 4),
                      ...expDetails.map(
                        (d) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('• ',
                                  style: const pw.TextStyle(fontSize: 14)),
                              pw.Expanded(child: pw.Text(d.toString())),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              pw.Wrap(children: [
                pw.Container(
                    width: 240,
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(height: 12),
                          _buildPdfSection('Education', myTheme),
                          pw.Text(
                            education['degree']?.toString() ?? '',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(education['institution']?.toString() ?? ''),
                          if ((education['year'] ?? '').toString().isNotEmpty)
                            pw.Text('Year: ${education['year']}'),
                        ])),
                pw.Container(
                    width: 240,
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(height: 12),
                          _buildPdfSection(
                              'Certifications & Licenses', myTheme),
                          ...certifications.map(
                            (l) => pw.Padding(
                              padding:
                                  const pw.EdgeInsets.symmetric(vertical: 2.0),
                              child: pw.Text('• ${l.toString()}'),
                            ),
                          ),
                        ])),
              ])
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPdfSection(String title, pw.ThemeData theme) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.Divider(thickness: 1, color: PdfColors.black),
        pw.SizedBox(height: 6),
      ],
    );
  }
  // --- END: PDF Generation Logic ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: const Text('Build with Voice'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCurrentStateWidget(),
      ),
    );
  }

  Widget _buildCurrentStateWidget() {
    switch (_currentState) {
      case VoiceBuildState.idle:
        return _buildIdle();
      case VoiceBuildState.listening:
        return _buildListening();
      case VoiceBuildState.processing:
        return _buildProcessing();
      case VoiceBuildState.editing:
        return _buildEditing();
    }
  }

  Widget _buildIdle() {
    return Center(
      key: const ValueKey('idle'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Tap the mic to start',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _startListening,
            child: const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFF007BFF),
              child: Icon(Icons.mic, color: Colors.white, size: 60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListening() {
    return Center(
      key: const ValueKey('listening'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Listening...',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          const SizedBox(height: 20),
          ScaleTransition(
            scale: _scaleAnimation,
            child: const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.mic, color: Colors.white, size: 60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessing() {
    return Center(
      key: const ValueKey('processing'),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              _processingSteps[_processingStep],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            // Multi-step progress bar
            ProgressIndicatorBar(
              steps: _processingSteps,
              currentStep: _processingStep,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditing() {
    return SingleChildScrollView(
      key: const ValueKey('editing'),
      padding: const EdgeInsets.all(16.0),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your resume is ready. Please review and edit.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: _buildInputDecoration('Full Name', Icons.person),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jobTitleController,
              decoration: _buildInputDecoration('Job Title', Icons.work),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: _buildInputDecoration('Phone', Icons.phone),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: _buildInputDecoration('Email', Icons.email),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: _buildInputDecoration('Location', Icons.location_on),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _summaryController,
              decoration: _buildInputDecoration('Summary', Icons.article,
                  alignLabel: true),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _skillsController,
              decoration: _buildInputDecoration(
                  'Skills (comma-separated)', Icons.star,
                  alignLabel: true),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: const Text('Generate Updated PDF',
                  style: TextStyle(color: Colors.white)),
              onPressed: _generateFullPdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon,
      {bool alignLabel = false}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      alignLabelWithHint: alignLabel,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}

// A helper widget for the multi-step progress bar
class ProgressIndicatorBar extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const ProgressIndicatorBar({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length, (index) {
        bool isActive = index <= currentStep;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.0),
            height: 8.0,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF007BFF) : Colors.grey[300],
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        );
      }),
    );
  }
}
