// lib/templates/voice_resume_builder_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';

// PDF Generation Imports
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rezume_app/app/localization/app_localizations.dart';

// --- NEW IMPORTS ---
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rezume_app/services/assemblyai_service.dart';
import 'package:rezume_app/services/resume_service.dart';
// --- END NEW IMPORTS ---


// Dummy data to pre-fill the form (This is unchanged)
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
  error, // Added error state
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
  String _errorMessage = ''; // For showing errors

  // --- NEW: Audio recording state ---
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AssemblyAiService _assemblyAiService = AssemblyAiService();
  final ResumeService _resumeService = ResumeService();
  String? _audioPath;

  // Controllers for the editable form (pre-filled with dummy data)
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
    _audioRecorder.dispose(); // Dispose recorder
    _nameController.dispose();
    _jobTitleController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    // Request microphone permission
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      setState(() {
        _currentState = VoiceBuildState.error;
        _errorMessage = 'Microphone permission is required to record audio.';
      });
      return;
    }

    try {
      // Get a temporary path to save the audio
      final directory = await getApplicationDocumentsDirectory();
      _audioPath = '${directory.path}/resume_audio.wav';

      // Start recording
      // --- *** THIS IS THE FIX YOU PROVIDED *** ---
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.wav), // <-- CORRECTED
        path: _audioPath!,
      );
      // --- *** END OF FIX *** ---

      setState(() {
        _currentState = VoiceBuildState.listening;
      });
    } catch (e) {
      print('Error starting recording: $e');
      setState(() {
        _currentState = VoiceBuildState.error;
        _errorMessage = 'Failed to start recording.';
      });
    }
  }

  // --- This function is UNCHANGED from the previous turn ---
  Future<void> _stopAndTranscribe() async {
    try {
      // Stop the recording
      final path = await _audioRecorder.stop();
      if (path == null) {
        throw Exception('Audio path not found after stopping.');
      }
      print('Audio saved to: $path');

      setState(() {
        _currentState = VoiceBuildState.processing;
      });

      // 1. Transcribe the audio
      final String transcribedText = await _assemblyAiService.transcribe(path);
      print('Transcribed Text: $transcribedText');

      // 2. Parse the text with AI
      final result = await _resumeService.parseVoiceResume(transcribedText);

      if (mounted) {
        if (result['success']) {
          final data = result['data'];
          setState(() {
            // Populate all controllers from the parsed JSON
            _nameController.text = data['fullName'] ?? '';
            _jobTitleController.text = data['jobTitle'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _emailController.text = data['email'] ?? '';
            _locationController.text = data['location'] ?? '';
            _summaryController.text = data['summary'] ?? '';
            _skillsController.text = data['skills'] ?? '';

            _currentState = VoiceBuildState.editing;
          });
        } else {
          // If parsing fails, just put the raw text in summary as a fallback
          setState(() {
            _summaryController.text = transcribedText;
            _currentState = VoiceBuildState.editing;
          });
          // Show a non-blocking snackbar error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'AI parsing failed. Please edit manually. Error: ${result['message']}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error stopping or transcribing: $e');
      if (mounted) {
        setState(() {
          _currentState = VoiceBuildState.error;
          _errorMessage = 'Failed to process audio: $e';
        });
      }
    }
  }
  // --- END OF UNCHANGED FUNCTION ---


  // --- PDF Generation Logic (This is unchanged) ---
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
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: Text(loc?.translate('voice_builder_title') ?? 'Build with Voice'),
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
      case VoiceBuildState.error:
        return _buildError();
    }
  }

  Widget _buildIdle() {
    final loc = AppLocalizations.of(context);
    return Center(
      key: const ValueKey('idle'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            loc?.translate('voice_builder_tap_mic') ?? 'Tap the mic to start',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _startListening, // <-- Start recording
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
    final loc = AppLocalizations.of(context);
    return Center(
      key: const ValueKey('listening'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            loc?.translate('voice_builder_listening') ?? 'Listening...',
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          const SizedBox(height: 20),
          // Pulsing mic icon
          ScaleTransition(
            scale: _scaleAnimation,
            child: const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.mic, color: Colors.white, size: 60),
            ),
          ),
          const SizedBox(height: 30),
          // --- NEW: Stop Button ---
          ElevatedButton.icon(
            icon: const Icon(Icons.stop_circle_outlined),
            label: Text(loc?.translate('voice_builder_stop') ?? 'Stop'),
            onPressed: _stopAndTranscribe, // <-- Stop and transcribe
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProcessing() {
    final loc = AppLocalizations.of(context);
    // Get the localized steps for the progress bar
    final List<String> processingSteps = [
      loc?.translate('voice_builder_step1') ?? 'Uploading audio...',
      loc?.translate('voice_builder_step2') ?? 'Transcribing text...',
      loc?.translate('voice_builder_step3') ?? 'Populating resume...',
    ];

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
              loc?.translate('voice_builder_processing') ??
                  'Processing your audio...',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            // You can use a simple text or the progress bar from your old code
            ProgressIndicatorBar(
              steps: processingSteps,
              // We don't have multi-step polling here, so just show first step
              currentStep: 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    final loc = AppLocalizations.of(context);
    return Center(
      key: const ValueKey('error'),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 20),
            Text(
              loc?.translate('voice_builder_error') ?? 'An Error Occurred',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage, // Display the specific error
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () =>
                  setState(() => _currentState = VoiceBuildState.idle),
              child: Text(loc?.translate('voice_builder_try_again') ?? 'Try Again'),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildEditing() {
    final loc = AppLocalizations.of(context);
    return SingleChildScrollView(
      key: const ValueKey('editing'),
      padding: const EdgeInsets.all(16.0),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc?.translate('voice_builder_review') ??
                  'Your resume is ready. Please review and edit.',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: _buildInputDecoration(
                  loc?.translate('voice_builder_full_name') ?? 'Full Name',
                  Icons.person),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jobTitleController,
              decoration: _buildInputDecoration(
                  loc?.translate('voice_builder_job_title') ?? 'Job Title',
                  Icons.work),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: _buildInputDecoration(
                  loc?.translate('voice_builder_phone') ?? 'Phone', Icons.phone),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: _buildInputDecoration(
                  loc?.translate('voice_builder_email') ?? 'Email', Icons.email),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: _buildInputDecoration(
                  loc?.translate('voice_builder_location') ?? 'Location',
                  Icons.location_on),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _summaryController,
              decoration: _buildInputDecoration(
                  loc?.translate('voice_builder_summary') ?? 'Summary',
                  Icons.article,
                  alignLabel: true),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _skillsController,
              decoration: _buildInputDecoration(
                  loc?.translate('voice_builder_skills') ??
                      'Skills (comma-separated)',
                  Icons.star,
                  alignLabel: true),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: Text(
                  loc?.translate('voice_builder_generate_pdf') ??
                      'Generate Updated PDF',
                  style: const TextStyle(color: Colors.white)),
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

// A helper widget for the multi-step progress bar (Unchanged)
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