// lib/templates/resume_builder_screen.dart

import 'package:flutter/material.dart';
import 'package:rezume_app/models/resume_template_model.dart';
import 'package:rezume_app/services/resume_service.dart'; // <-- ADD THIS
import 'package:url_launcher/url_launcher.dart'; // <-- ADD THIS

// PDF generation imports are no longer needed here
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// Dummy data is no longer needed here

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ResumeBuilderScreen extends StatefulWidget {
  final ResumeTemplate template;
  final String templateName;

  const ResumeBuilderScreen({
    super.key,
    required this.template,
    required this.templateName,
  });

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  // --- REMOVED: The hardcoded _questionFlow is gone ---

  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final FocusNode _chatFocusNode = FocusNode();

  // --- NEW: State for backend communication ---
  final ResumeService _resumeService = ResumeService();
  String? _resumeId; // To store the ID of the resume-in-progress
  bool _isLoading = true; // For chat messages
  bool _isGeneratingPdf = false; // For the final button
  bool _isConversationComplete = false;

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  @override
  void dispose() {
    _textController.dispose();
    _chatFocusNode.dispose();
    super.dispose();
  }

  // --- NEW: Starts the chat by calling the backend ---
  Future<void> _startConversation() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _resumeService.startResume(widget.templateName);

    if (mounted) {
      if (result['success']) {
        setState(() {
          _resumeId = result['resumeId'];
          _messages.add(ChatMessage(
            text: result['question']!,
            isUser: false,
          ));
          _isLoading = false;
        });
        _chatFocusNode.requestFocus();
      } else {
        // Handle error
        setState(() {
          _messages.add(ChatMessage(
            text: 'Error starting chat: ${result['message']}',
            isUser: false,
          ));
          _isLoading = false;
        });
      }
    }
  }

  // --- MODIFIED: Sends answer to the backend ---
  void _sendMessage() async {
    if (_isConversationComplete || _isLoading || _resumeId == null) return;

    String userInput = _textController.text.trim();
    if (userInput.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: userInput, isUser: true));
      _isLoading = true;
    });
    _textController.clear();

    final result = await _resumeService.askNextQuestion(_resumeId!, userInput);

    if (mounted) {
      if (result['success']) {
        setState(() {
          _messages.add(ChatMessage(
            text: result['question']!,
            isUser: false,
          ));
          _isConversationComplete = result['isComplete'];
          _isLoading = false;
        });
        if (!_isConversationComplete) {
          _chatFocusNode.requestFocus();
        }
      } else {
        // Handle error
        setState(() {
          _messages.add(ChatMessage(
            text: 'Error: ${result['message']}',
            isUser: false,
          ));
          _isLoading = false;
        });
      }
    }
  }

  // --- MODIFIED: Calls backend to generate PDF and opens the URL ---
  Future<void> _generatePdf() async {
    if (_resumeId == null) return;

    setState(() {
      _isGeneratingPdf = true;
    });

    final result = await _resumeService.generatePdf(_resumeId!);

    if (mounted) {
      setState(() {
        _isGeneratingPdf = false;
      });

      if (result['success']) {
        final String? pdfUrl = result['resume']?['pdfUrl'];
        if (pdfUrl != null) {
          final Uri url = Uri.parse(pdfUrl);
          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open PDF: $pdfUrl')),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error generating PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- REMOVED: _generateFullPdf and _buildPdfSection ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: Text("Building with '${widget.templateName}'"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatMessage(
                  isUser: message.isUser,
                  message: message.text,
                );
              },
            ),
          ),
          if (_isConversationComplete) _buildGenerateButton(),
          if (!_isConversationComplete) _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: _isGeneratingPdf
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton.icon(
              icon: const Icon(Icons.description_rounded, size: 20),
              label: const Text('Generate PDF Resume'),
              onPressed: _generatePdf, // <-- Calls the new backend function
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                foregroundColor: Colors.white,
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
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      // ... (rest of the styling is unchanged)
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _chatFocusNode,
              enabled: !_isLoading, // <-- Disable when loading
              decoration: InputDecoration(
                hintText: _isLoading ? "Thinking..." : "Type your answer...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              ),
              onSubmitted: (text) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8.0),
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 3)),
                )
              : IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF007BFF)),
                  onPressed: _sendMessage,
                ),
        ],
      ),
    );
  }

  // Chat bubble UI (Unchanged)
  Widget _buildChatMessage({required bool isUser, required String message}) {
    // ... (This widget is unchanged)
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF007BFF) : Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: isUser
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  )
                ],
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}