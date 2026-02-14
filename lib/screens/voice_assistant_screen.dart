// Voice Assistant - Voice/Text commands ka chat interface
// Commands: "Transport chahiye", "Mausam dikhao", "Beej kharidna hai" etc.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../services/voice_service.dart';
import '../services/voice_navigation_service.dart';
import '../providers/language_provider.dart';

/// Voice Assistant Screen Widget
/// Provides conversational interface for voice/text commands
class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  // Voice processing service
  final VoiceService _voiceService = VoiceService();
  
  // Navigation service for intent-based routing
  late VoiceNavigationService _navigationService;
  
  // Text input controller (for web platform)
  final TextEditingController _textController = TextEditingController();
  
  // Conversation messages list
  final List<Map<String, dynamic>> _messages = [];
  
  // State flags
  bool _isRecording = false; // Recording in progress
  bool _isProcessing = false; // Processing command
  
  // Animation controller for visual effects
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _navigationService = VoiceNavigationService(Navigator.of(context).widget.key as GlobalKey<NavigatorState>);
    
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Add greeting message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addGreeting();
    });
  }

  void _addGreeting() {
    final lang = Provider.of<LanguageProvider>(context, listen: false).locale.languageCode;
    final greetings = {
      'en': kIsWeb 
          ? 'Hello! Type your command below or ask me anything!'
          : 'Hello! What would you like to do today?',
      'hi': kIsWeb 
          ? 'नमस्ते! नीचे अपना आदेश टाइप करें या मुझसे कुछ भी पूछें!'
          : 'नमस्ते! आप क्या करना चाहते हैं?',
      'cg': kIsWeb 
          ? 'नमस्कार! नीचे अपन आदेश लिखव या मोला कुछ भी पूछव!'
          : 'नमस्कार! तुमन का करे चाहत हव?',
    };
    
    setState(() {
      _messages.add({
        'role': 'assistant',
        'content': greetings[lang] ?? greetings['hi']!,
        'timestamp': DateTime.now(),
      });
    });

    // Don't speak greeting automatically on web - browsers block TTS without user interaction
    // User can tap mic button to start interaction
  }

  Future<void> _processTextInput() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isProcessing = true;
      // Add user message immediately
      _messages.add({
        'role': 'user',
        'content': text,
        'timestamp': DateTime.now(),
      });
    });

    _textController.clear();

    final lang = Provider.of<LanguageProvider>(context, listen: false).locale.languageCode;
    final result = await _voiceService.processText(text: text, language: lang);

    setState(() => _isProcessing = false);

    if (result != null && result['success'] == true) {
      // Add assistant response
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': result['message'],
          'timestamp': DateTime.now(),
        });
      });

      // Navigate if action is complete
      if (result['complete'] == true && result['action'] != null) {
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          await _navigationService.navigateByIntent(
            context: context,
            intent: result['intent'],
            entities: result['entities'] ?? {},
          );
        }
      }
    } else {
      _showError('Failed to process command');
    }
  }

  Future<void> _toggleRecording() async {
    // On web, show info about text input
    if (kIsWeb) {
      _showError('Please use text input below to send commands');
      return;
    }

    if (_isRecording) {
      // Stop recording
      setState(() => _isProcessing = true);
      
      final lang = Provider.of<LanguageProvider>(context, listen: false).locale.languageCode;
      final result = await _voiceService.stopRecordingAndProcess(language: lang);
      
      setState(() {
        _isRecording = false;
        _isProcessing = false;
      });

      if (result != null && result['success'] == true) {
        // Add user message
        setState(() {
          _messages.add({
            'role': 'user',
            'content': result['transcription'],
            'timestamp': DateTime.now(),
          });
        });

        // Add assistant response
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': result['message'],
            'timestamp': DateTime.now(),
          });
        });

        // Navigate if action is complete
        if (result['complete'] == true && result['action'] != null) {
          await Future.delayed(const Duration(seconds: 2));
          
          if (mounted) {
            await _navigationService.navigateByIntent(
              context: context,
              intent: result['intent'],
              entities: result['entities'] ?? {},
            );
          }
        }
      } else {
        _showError('Failed to process voice command');
      }
    } else {
      await _voiceService.startRecording();
      setState(() => _isRecording = true);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant'),
        backgroundColor: const Color(0xFF2E6B3F),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
                _voiceService.startNewSession();
              });
              _addGreeting();
            },
            tooltip: 'New Session',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
            tooltip: 'History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Waveform animation
          if (_isRecording)
            Container(
              height: 80,
              color: const Color(0xFF2E6B3F).withOpacity(0.1),
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: WaveformPainter(_waveController.value),
                    size: Size.infinite,
                  );
                },
              ),
            ),

          // Status indicator
          if (_isProcessing)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.orange[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Processing...',
                    style: TextStyle(color: Colors.orange[900]),
                  ),
                ],
              ),
            ),

          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mic_none,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap the mic button to start',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['role'] == 'user';

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? const Color(0xFF2E6B3F)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message['content'],
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Recording button and text input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text input for web
                  if (kIsWeb)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              decoration: InputDecoration(
                                hintText: 'Type your command...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (_) => _processTextInput(),
                              enabled: !_isProcessing,
                            ),
                          ),
                          const SizedBox(width: 12),
                          FloatingActionButton(
                            onPressed: _isProcessing ? null : _processTextInput,
                            backgroundColor: const Color(0xFF2E6B3F),
                            child: _isProcessing
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ),

                  // Mic button row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Stop speaking button
                      if (!_isRecording)
                        IconButton(
                          icon: const Icon(Icons.volume_off),
                          iconSize: 32,
                          color: Colors.grey,
                          onPressed: () => _voiceService.stopSpeaking(),
                          tooltip: 'Stop Speaking',
                        ),
                      
                      const SizedBox(width: 20),

                      // Main mic button
                      GestureDetector(
                        onTap: _isProcessing ? null : _toggleRecording,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kIsWeb 
                                ? Colors.grey 
                                : (_isRecording
                                    ? Colors.red
                                    : const Color(0xFF2E6B3F)),
                            boxShadow: [
                              BoxShadow(
                                color: (kIsWeb 
                                    ? Colors.grey 
                                    : (_isRecording ? Colors.red : const Color(0xFF2E6B3F)))
                                    .withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            kIsWeb 
                                ? Icons.mic_off 
                                : (_isRecording ? Icons.stop : Icons.mic),
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // End session button
                      if (!_isRecording)
                        IconButton(
                          icon: const Icon(Icons.close),
                          iconSize: 32,
                          color: Colors.grey,
                          onPressed: () async {
                            await _voiceService.endSession();
                            if (mounted) Navigator.of(context).pop();
                          },
                          tooltip: 'End Session',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showHistory() async {
    final history = await _voiceService.getVoiceHistory();
    
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Voice History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: history.isEmpty
                    ? const Center(child: Text('No history yet'))
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final session = history[index];
                          return ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(session['preview'] ?? 'Session'),
                            subtitle: Text(session['createdAt'] ?? ''),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pop(context);
                              // Load session
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _textController.dispose();
    _voiceService.dispose();
    super.dispose();
  }
}

// Waveform painter
class WaveformPainter extends CustomPainter {
  final double animationValue;

  WaveformPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E6B3F)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final centerY = height / 2;

    for (double x = 0; x < width; x++) {
      final y = centerY +
          (30 * (animationValue + 0.5)) *
              (0.5 + 0.5 * (x / width)) *
              (x % 20 < 10 ? 1 : -1);
      
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}
