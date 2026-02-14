// Voice Service - Recording aur Text processing
// Mobile: Voice recording, Web: Text input only

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../config/api_config.dart';

class VoiceService {
  // Audio recorder (mobile only)
  final AudioRecorder _recorder = AudioRecorder();
  
  // Text-to-Speech engine
  final FlutterTts _tts = FlutterTts();
  
  // Current session ID for maintaining conversation context
  String? _currentSessionId;
  
  // Recording state flag
  bool _isRecording = false;

  // Initialize TTS
  Future<void> initTts({String language = 'hi'}) async {
    await _tts.setLanguage(language == 'hi' ? 'hi-IN' : 'en-IN');
    await _tts.setSpeechRate(0.45); // Slower for rural users
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> startRecording() async {
    try {
      if (kIsWeb) {
        _isRecording = true;
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
        
        _isRecording = true;
        return;
      }
    } catch (e) {
      print('Start recording error: $e');
    }
  }

  // Stop recording and process
  Future<Map<String, dynamic>?> stopRecordingAndProcess({
    required String language,
  }) async {
    try {
      if (!_isRecording) return null;

      // For web, we can't actually record, so return a message
      if (kIsWeb) {
        _isRecording = false;
        return {
          'success': false,
          'message': 'Please use text input on web browser',
          'isWeb': true,
        };
      }

      final path = await _recorder.stop();
      _isRecording = false;

      if (path == null) {
        throw Exception('Recording failed');
      }

      print('Audio file saved: $path');

      // Send to backend
      final result = await _sendVoiceToBackend(path, language);
      
      // Speak the response
      if (result != null && result['success'] == true) {
        await speak(result['message'], language);
      }

      return result;
    } catch (e) {
      print('Stop recording error: $e');
      return null;
    }
  }

  // Process text directly (for web and testing)
  Future<Map<String, dynamic>?> processText({
    required String text,
    required String language,
  }) async {
    try {
      print('📤 Sending text to backend...');

      final uri = Uri.parse('${ApiConfig.baseUrl}/voice/process-text');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'language': language,
          'sessionId': _currentSessionId,
        }),
      ).timeout(const Duration(seconds: 30));

      print('📥 Text response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Save session ID
        if (data['sessionId'] != null) {
          _currentSessionId = data['sessionId'];
        }

        // Speak the response
        if (data['success'] == true) {
          await speak(data['message'], language);
        }

        return data;
      } else {
        throw Exception('Failed to process text: ${response.body}');
      }
    } catch (e) {
      print('Process text error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Send voice file to backend
  Future<Map<String, dynamic>?> _sendVoiceToBackend(
    String audioPath,
    String language,
  ) async {
    try {
      print('📤 Sending voice to backend...');

      final uri = Uri.parse('${ApiConfig.baseUrl}/voice/process');
      final request = http.MultipartRequest('POST', uri);

      // Add audio file
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        audioPath,
        filename: 'voice.m4a',
      ));

      // Add fields
      request.fields['language'] = language;
      if (_currentSessionId != null) {
        request.fields['sessionId'] = _currentSessionId!;
      }

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Voice response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Save session ID
        if (data['sessionId'] != null) {
          _currentSessionId = data['sessionId'];
        }

        return data;
      } else {
        throw Exception('Failed to process voice: ${response.body}');
      }
    } catch (e) {
      print('Voice service error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Text-to-speech
  Future<void> speak(String text, String language) async {
    try {
      await initTts(language: language);
      await _tts.speak(text);
    } catch (e) {
      print('TTS error: $e');
      // Silently fail - TTS might not be available on web without user interaction
    }
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (e) {
      print('Stop TTS error: $e');
    }
  }

  bool get isRecording => _isRecording;

  String? get sessionId => _currentSessionId;

  void startNewSession() {
    _currentSessionId = null;
  }

  // Get voice history
  Future<List<Map<String, dynamic>>> getVoiceHistory({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/voice/history?limit=$limit'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['sessions'] ?? []);
      }
      return [];
    } catch (e) {
      print('Get voice history error: $e');
      return [];
    }
  }


  Future<Map<String, dynamic>?> getSession(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/voice/session/$sessionId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Get session error: $e');
      return null;
    }
  }

  // End session
  Future<void> endSession() async {
    if (_currentSessionId == null) return;

    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/voice/session/$_currentSessionId/end'),
      ).timeout(const Duration(seconds: 10));
      
      _currentSessionId = null;
    } catch (e) {
      print('End session error: $e');
    }
  }

  // Dispose
  Future<void> dispose() async {
    await _recorder.dispose();
    await _tts.stop();
  }
}
