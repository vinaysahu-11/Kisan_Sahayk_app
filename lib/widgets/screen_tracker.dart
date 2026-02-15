// Screen Tracker - Reports current screen to voice controller

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/voice_global_controller.dart';

class ScreenTracker extends StatefulWidget {
  final Widget child;
  final String screenName;

  const ScreenTracker({
    super.key,
    required this.child,
    required this.screenName,
  });

  @override
  State<ScreenTracker> createState() => _ScreenTrackerState();
}

class _ScreenTrackerState extends State<ScreenTracker> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final voiceController = Provider.of<VoiceGlobalController>(context, listen: false);
      voiceController.setCurrentScreen(widget.screenName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
