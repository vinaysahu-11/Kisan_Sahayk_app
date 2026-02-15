// Voice Assistant Overlay - Floating UI for voice control
// Shows conversation, waveform, and controls

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/voice_global_controller.dart';
import 'learning_mode_tutorial.dart';
import 'dart:math' as math;

class VoiceAssistantOverlay extends StatefulWidget {
  const VoiceAssistantOverlay({super.key});

  @override
  State<VoiceAssistantOverlay> createState() => _VoiceAssistantOverlayState();
}

class _VoiceAssistantOverlayState extends State<VoiceAssistantOverlay>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceGlobalController>(
      builder: (context, controller, child) {
        if (!controller.isActive) return const SizedBox.shrink();

        return Material(
          color: Colors.black.withOpacity(0.7),
          child: SafeArea(
            child: Stack(
              children: [
                // Main content
                Column(
                  children: [
                    // Header
                    _buildHeader(context, controller),
                    
                    // Waveform animation
                    if (controller.isRecording)
                      _buildWaveform(),
                    
                    // Conversation area
                    Expanded(
                      child: _buildConversation(controller),
                    ),
                    
                    // Input area
                    _buildInputArea(context, controller),
                  ],
                ),
                
                // Close button
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      controller.deactivate();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, VoiceGlobalController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade500],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.mic, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Voice Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (controller.currentScreen != null)
                  Text(
                    'Screen: ${controller.currentScreen}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          // Help button - opens tutorial
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            tooltip: 'Tutorial',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LearningModeTutorial(),
                ),
              );
            },
          ),
          // Learning mode toggle
          IconButton(
            icon: Icon(
              controller.learningMode ? Icons.school : Icons.school_outlined,
              color: Colors.white,
            ),
            tooltip: 'Learning Mode',
            onPressed: () {
              controller.toggleLearningMode();
            },
          ),
          // Clear button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Clear',
            onPressed: () {
              controller.clearConversation();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return SizedBox(
      height: 80,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return CustomPaint(
            painter: WaveformPainter(_waveController.value),
            size: const Size(double.infinity, 80),
          );
        },
      ),
    );
  }

  Widget _buildConversation(VoiceGlobalController controller) {
    if (controller.conversation.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic_none,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Mic button dabao aur bolo',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ya niche text type karo',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: controller.conversation.length,
      itemBuilder: (context, index) {
        final message = controller.conversation[index];
        final isUser = message['role'] == 'user';
        
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser 
                  ? Colors.green.shade600 
                  : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message['content'] ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea(BuildContext context, VoiceGlobalController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border(
          top: BorderSide(color: Colors.grey.shade700),
        ),
      ),
      child: Row(
        children: [
          // Text input
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type command...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.grey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  controller.processTextCommand(context, text.trim());
                  _textController.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          if (_textController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.send, color: Colors.green),
              onPressed: () {
                final text = _textController.text.trim();
                if (text.isNotEmpty) {
                  controller.processTextCommand(context, text);
                  _textController.clear();
                }
              },
            ),
          // Mic button
          GestureDetector(
            onTap: () async {
              if (controller.isRecording) {
                await controller.stopListening(context);
              } else {
                await controller.startListening(context);
              }
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: controller.isRecording 
                    ? Colors.red 
                    : Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (controller.isRecording ? Colors.red : Colors.green)
                        .withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                controller.isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Waveform painter
class WaveformPainter extends CustomPainter {
  final double animationValue;

  WaveformPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final waveCount = 3;
    final waveHeight = 30.0;

    for (var i = 0; i < waveCount; i++) {
      path.reset();
      final offset = (animationValue + i / waveCount) * 2 * math.pi;
      
      for (var x = 0.0; x < size.width; x += 5) {
        final y = size.height / 2 + 
            math.sin((x / size.width) * 4 * math.pi + offset) * 
            waveHeight * (1 - i * 0.3);
        
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
