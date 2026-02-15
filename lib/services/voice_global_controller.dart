// Global Voice Controller - AI-powered app navigation system
// Controls entire app via voice across all screens

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import '../config/api_config.dart';
import '../providers/language_provider.dart';
import 'screen_registry.dart';
import 'learning_mode_helper.dart';
import 'form_fill_handler.dart';

class VoiceGlobalController extends ChangeNotifier {
  static final VoiceGlobalController _instance = VoiceGlobalController._internal();
  factory VoiceGlobalController() => _instance;
  VoiceGlobalController._internal();

  final AudioRecorder _recorder = AudioRecorder();
  final FlutterTts _tts = FlutterTts();
  final ScreenRegistry _screenRegistry = ScreenRegistry();
  
  bool _isActive = false;
  bool _isRecording = false;
  bool _learningMode = false;
  String? _currentScreen;
  String? _sessionId;
  String? _languageCode;
  List<Map<String, dynamic>> _conversation = [];
  Map<String, dynamic>? _context;

  bool get isActive => _isActive;
  bool get isRecording => _isRecording;
  bool get learningMode => _learningMode;
  String? get currentScreen => _currentScreen;
  List<Map<String, dynamic>> get conversation => _conversation;

  Future<void> initialize() async {
    await _tts.setLanguage('hi-IN');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  void toggleLearningMode() {
    _learningMode = !_learningMode;
    notifyListeners();
  }

  void setCurrentScreen(String screenName) {
    _currentScreen = screenName;
    
    // If learning mode is active and screen changes, provide introduction
    if (_learningMode && screenName.isNotEmpty) {
      final introduction = LearningModeHelper.getScreenIntroduction(
        screenName, 
        _languageCode ?? 'hi'
      );
      
      // Add introduction to conversation
      _conversation.add({
        'role': 'assistant',
        'content': introduction,
        'timestamp': DateTime.now(),
        'type': 'screen_intro',
      });
      
      // Speak introduction (async, non-blocking)
      Future.microtask(() => speak(introduction));
    }
    
    notifyListeners();
  }

  void activate() {
    _isActive = true;
    notifyListeners();
  }

  void deactivate() {
    _isActive = false;
    _isRecording = false;
    notifyListeners();
  }

  Future<void> startListening(BuildContext context) async {
    if (_isRecording) return;

    try {
      _isRecording = true;
      notifyListeners();

      if (kIsWeb) {
        // Web: Show text input
        return;
      }

      if (await _recorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );
      }
    } catch (e) {
      print('Start listening error: $e');
      _isRecording = false;
      notifyListeners();
    }
  }

  Future<void> stopListening(BuildContext context) async {
    if (!_isRecording) return;

    try {
      final path = await _recorder.stop();
      _isRecording = false;
      notifyListeners();

      if (path != null) {
        await _processVoiceCommand(context, audioPath: path);
      }
    } catch (e) {
      print('Stop listening error: $e');
      _isRecording = false;
      notifyListeners();
    }
  }

  Future<void> processTextCommand(BuildContext context, String text) async {
    await _processVoiceCommand(context, text: text);
  }

  Future<void> _processVoiceCommand(BuildContext context, {String? text, String? audioPath}) async {
    try {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      final language = languageProvider.locale.languageCode;
      _languageCode = language; // Store for later use

      // Add user message to conversation
      _conversation.add({
        'role': 'user',
        'content': text ?? 'Voice input',
        'timestamp': DateTime.now(),
      });
      notifyListeners();

      // Send to backend for processing
      final result = await _sendToBackend(
        text: text,
        audioPath: audioPath,
        language: language,
        context: context,
      );

      if (result['success']) {
        // Add assistant response
        _conversation.add({
          'role': 'assistant',
          'content': result['message'],
          'timestamp': DateTime.now(),
        });
        notifyListeners();

        // Speak response
        await speak(result['message']);

        // Execute action if any
        if (result['action'] != null) {
          await _executeAction(context, result['action'], result);
        }

        // Update context
        if (result['context'] != null) {
          _context = result['context'];
        }
      }
    } catch (e) {
      print('Process voice command error: $e');
      _conversation.add({
        'role': 'assistant',
        'content': 'Maaf kijiye, kuch galat ho gaya. Phir se try karein.',
        'timestamp': DateTime.now(),
      });
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _sendToBackend({
    String? text,
    String? audioPath,
    required String language,
    required BuildContext context,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}/voice/process-global';
      
      final requestData = {
        'text': text,
        'language': language,
        'sessionId': _sessionId,
        'currentScreen': _currentScreen,
        'learningMode': _learningMode,
        'availableActions': _screenRegistry.getScreenActions(_currentScreen ?? ''),
        'context': _context,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error',
        };
      }
    } catch (e) {
      print('Backend error: $e');
      return {
        'success': false,
        'message': 'Connection error',
      };
    }
  }

  Future<void> _executeAction(BuildContext context, Map<String, dynamic> action, Map<String, dynamic> result) async {
    final actionType = action['type'];
    final navigator = Navigator.of(context);

    switch (actionType) {
      case 'navigate':
        final route = action['route'];
        if (route != null) {
          // Speak before navigation
          if (_learningMode && action['explanation'] != null) {
            await speak(action['explanation']);
            await Future.delayed(const Duration(milliseconds: 500));
          }
          
          navigator.pushNamed(route, arguments: action['arguments']);
        }
        break;

      case 'fill_form':
        final fields = action['fields'] as Map<String, dynamic>?;
        if (fields != null && _currentScreen != null) {
          final success = FormFillHandler.fillForm(_currentScreen!, fields);
          
          if (success) {
            final message = _learningMode 
                ? 'Form fill kar diya gaya hai. Values check kar lein.'
                : 'Form filled!';
            await speak(message);
          } else {
            await speak('Form fill nahi ho paya. Manually bharein.');
          }
          
          notifyListeners();
        }
        break;

      case 'confirm':
        // Show confirmation dialog
        final confirmed = await _showConfirmationDialog(context, action);
        if (confirmed) {
          // Execute confirmed action
          if (action['confirmedAction'] != null) {
            await _executeAction(context, action['confirmedAction'], result);
          }
        }
        break;

      case 'select':
        // Highlight and select UI element
        // TODO: Implement UI highlighting
        break;

      case 'back':
        navigator.pop();
        break;

      default:
        print('Unknown action type: $actionType');
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context, Map<String, dynamic> action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Karo'),
        content: Text(action['confirmMessage'] ?? 'Aap confirm karte hain?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Nahi'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Haan'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (e) {
      print('TTS error: $e');
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (e) {
      print('Stop TTS error: $e');
    }
  }

  void clearConversation() {
    _conversation.clear();
    _context = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _tts.stop();
    super.dispose();
  }
}
