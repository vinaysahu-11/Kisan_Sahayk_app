// Floating Voice Button - Global mic button accessible from anywhere

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/voice_global_controller.dart';

class FloatingVoiceButton extends StatelessWidget {
  const FloatingVoiceButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceGlobalController>(
      builder: (context, controller, child) {
        // Don't show if overlay is already active
        if (controller.isActive) {
          return const SizedBox.shrink();
        }

        return Positioned(
          right: 16,
          bottom: 80,
          child: GestureDetector(
            onTap: () {
              controller.activate();
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }
}
