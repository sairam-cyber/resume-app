// lib/ats_checker/resume_editor_screen.dart

import 'package:flutter/material.dart';
// For font loading
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rezume_app/services/ats_service.dart'; // <-- ADD THIS
import 'package:url_launcher/url_launcher.dart'; // <-- ADD THIS

// Helper class for chat messages
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ResumeEditorScreen extends StatefulWidget {
  final String resumeId; // <-- ADD THIS
  final List<Map<String, dynamic>> suggestions;

  const ResumeEditorScreen({
    super.key,
    required this.resumeId, // <-- ADD THIS
    required this.suggestions,
  });

  @override
  State<ResumeEditorScreen> createState() => _ResumeEditorScreenState();
}

class _ResumeEditorScreenState extends State<ResumeEditorScreen> {
  // This list will be populated from the suggestions
  final List<Map<String, String>> _suggestionFlow = [];

  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final FocusNode _chatFocusNode = FocusNode();
  int _currentQuestionIndex = 0;
  final Map<String, String> _updatedDetails = {};
  bool _isConversationComplete = false;

  final AtsService _atsService = AtsService(); // <-- ADD THIS
  bool _isGeneratingPdf = false; // <-- ADD THIS

  @override
  void initState() {
    super.initState();
    // Build the conversation flow from the suggestions
    _buildSuggestionFlow();
    _askQuestion();
  }

  void _buildSuggestionFlow() {
    // Add a welcome message first
    _suggestionFlow.add({
      'key': 'Welcome',
      'question':
          'Welcome to the AI Resume Editor. Let\'s improve your resume based on the suggestions we found.'
    });

    // Add each suggestion as a question
    for (var suggestion in widget.suggestions) {
      _suggestionFlow.add({
        'key': suggestion['title'] ?? 'Suggestion',
        'question': suggestion['subtitle'] ?? 'Please provide an update.'
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _chatFocusNode.dispose();
    super.dispose();
  }

  void _askQuestion() {
    if (_currentQuestionIndex < _suggestionFlow.length) {
      setState(() {
        _messages.add(ChatMessage(
          text: _suggestionFlow[_currentQuestionIndex]['question']!,
          isUser: false,
        ));
      });
    } else {
      setState(() {
        _messages.add(ChatMessage(
          text:
              'Great! Your resume updates are complete. You can now generate the updated PDF.',
          isUser: false,
        ));
        _isConversationComplete = true;
      });
      print('Final Updated Details: $_updatedDetails');
    }
  }

  void _sendMessage() {
    if (_isConversationComplete) return;

    String userInput = _textController.text.trim();
    if (userInput.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: userInput, isUser: true));
    });

    // Don't save the answer to the "Welcome" message
    if (_currentQuestionIndex > 0 &&
        _currentQuestionIndex < _suggestionFlow.length) {
      String key = _suggestionFlow[_currentQuestionIndex]['key']!;
      _updatedDetails[key] = userInput;
    }

    _currentQuestionIndex++;
    _textController.clear();
    if (!_isConversationComplete) {
      _chatFocusNode.requestFocus();
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      _askQuestion();
    });
  }

  // --- THIS IS THE MAIN CHANGE ---
  Future<void> _generateUpdatedPdf() async {
    setState(() {
      _isGeneratingPdf = true;
    });

    final result = await _atsService.generateEditedPdf(
      resumeId: widget.resumeId,
      userAnswers: _updatedDetails,
    );

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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF generated, but URL not found.')),
          );
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
  // --- END OF MAIN CHANGE ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using the background color from the chat UI
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: const Text("AI Resume Editor"),
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
          ? const Center(child: CircularProgressIndicator()) // <-- Show loader
          : ElevatedButton.icon(
              icon: const Icon(Icons.description_rounded, size: 20),
              label: const Text('Generate Updated PDF'),
              onPressed: _generateUpdatedPdf, // <-- Calls the new function
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

  // Chat input UI
  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              decoration: InputDecoration(
                hintText: "Type your answer...",
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
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF007BFF)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  // Chat bubble UI
  Widget _buildChatMessage({required bool isUser, required String message}) {
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