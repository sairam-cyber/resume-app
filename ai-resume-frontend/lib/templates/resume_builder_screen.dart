// lib/templates/resume_builder_screen.dart

import 'package:flutter/material.dart';
import 'package:rezume_app/models/resume_template_model.dart';
import 'package:rezume_app/services/resume_service.dart';
import 'package:url_launcher/url_launcher.dart';

// --- ADD THESE IMPORTS ---
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rezume_app/services/assemblyai_service.dart';
// --- END OF IMPORTS ---

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
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final FocusNode _chatFocusNode = FocusNode();

  // --- State for backend communication ---
  final ResumeService _resumeService = ResumeService();
  String? _resumeId;
  bool _isLoading = true;
  bool _isGeneratingPdf = false;
  bool _isConversationComplete = false;

  // --- ADD STATE FOR VOICE RECORDING ---
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AssemblyAiService _assemblyAiService = AssemblyAiService();
  bool _isRecording = false;
  // --- END OF VOICE STATE ---

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  @override
  void dispose() {
    _textController.dispose();
    _chatFocusNode.dispose();
    _audioRecorder.dispose(); // <-- Don't forget to dispose
    super.dispose();
  }

  // --- Starts the chat (UNCHANGED) ---
  Future<void> _startConversation() async {
    setState(() { _isLoading = true; });
    final result = await _resumeService.startResume(widget.templateName);
    if (mounted) {
      if (result['success']) {
        setState(() {
          _resumeId = result['resumeId'];
          _messages.add(ChatMessage(text: result['question']!, isUser: false));
          _isLoading = false;
        });
        _chatFocusNode.requestFocus();
      } else {
        setState(() {
          _messages.add(ChatMessage(text: 'Error starting chat: ${result['message']}', isUser: false));
          _isLoading = false;
        });
      }
    }
  }

  // --- Sends answer to backend (UNCHANGED) ---
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
          _messages.add(ChatMessage(text: result['question']!, isUser: false));
          _isConversationComplete = result['isComplete'];
          _isLoading = false;
        });
        if (!_isConversationComplete) {
          _chatFocusNode.requestFocus();
        }
      } else {
        setState(() {
          _messages.add(ChatMessage(text: 'Error: ${result['message']}', isUser: false));
          _isLoading = false;
        });
      }
    }
  }
  
  // --- Calls backend to generate PDF (UNCHANGED) ---
  Future<void> _generatePdf() async {
    if (_resumeId == null) return;
    setState(() { _isGeneratingPdf = true; });
    final result = await _resumeService.generatePdf(_resumeId!);
    if (mounted) {
      setState(() { _isGeneratingPdf = false; });
      if (result['success']) {
        final String? pdfUrl = result['resume']?['pdfUrl'];
        if (pdfUrl != null) {
          final Uri url = Uri.parse(pdfUrl);
          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open PDF: $pdfUrl')));
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Error generating PDF'), backgroundColor: Colors.red));
      }
    }
  }

  // --- *** ADD VOICE FUNCTIONS *** ---

  Future<void> _startListening() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone permission is required.')));
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final audioPath = '${directory.path}/resume_answer.wav';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.pcm16bits), // Use pcm16bits
        path: audioPath,
      );

      setState(() { _isRecording = true; });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopAndTranscribe() async {
    try {
      final path = await _audioRecorder.stop();
      if (path == null) return;
      
      setState(() {
        _isRecording = false;
        _isLoading = true; // Show loading spinner in text field
      });

      // Transcribe the audio
      final String transcribedText = await _assemblyAiService.transcribe(path);
      
      // --- THIS IS THE KEY ---
      // Put the transcribed text into the chat box
      _textController.text = transcribedText;
      
      if(mounted) {
        setState(() { _isLoading = false; });
        _chatFocusNode.requestFocus(); // Focus the text field
      }

    } catch (e) {
      print('Error transcribing audio: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _textController.text = ''; // Clear text on error
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
  // --- *** END OF VOICE FUNCTIONS *** ---

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
              onPressed: _generatePdf,
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

  // --- *** MODIFIED CHAT INPUT *** ---
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
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: _isLoading ? "Thinking..." : (_isRecording ? "Listening..." : "Type or hold mic to talk..."),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: _isRecording ? Colors.blue.shade50 : Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              ),
              onSubmitted: (text) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8.0),
          
          // --- Voice Button ---
          GestureDetector(
            onLongPress: _startListening, // Hold to record
            onLongPressUp: _stopAndTranscribe, // Release to transcribe
            child: CircleAvatar(
              radius: 22,
              backgroundColor: _isRecording ? Colors.red : const Color(0xFF007BFF),
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(
                    _isRecording ? Icons.stop : Icons.mic, 
                    color: Colors.white
                  ),
            ),
          ),
          
          // --- Send Button ---
          const SizedBox(width: 8.0),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF007BFF)),
            onPressed: _isLoading ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
  // --- *** END OF MODIFIED CHAT INPUT *** ---


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
          boxShadow: isUser ? [] : [
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