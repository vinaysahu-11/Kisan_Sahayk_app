import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AiService {
  /// Get auth token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Get headers with auth
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Handle HTTP errors with detailed logging
  Exception _handleError(String operation, dynamic error, {http.Response? response}) {
    print('❌ AI Service Error [$operation]');
    print('Error: $error');
    
    if (response != null) {
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }

    if (error is SocketException) {
      return Exception('Network error: Cannot connect to server. Make sure backend is running on ${ApiConfig.baseUrl}');
    } else if (error is http.ClientException) {
      return Exception('Connection failed: ${error.message}. Check if backend server is running.');
    } else if (response != null && response.statusCode >= 400) {
      try {
        final errorData = jsonDecode(response.body);
        return Exception(errorData['message'] ?? 'Server error: ${response.statusCode}');
      } catch (_) {
        return Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    }
    
    return Exception('$operation failed: $error');
  }

  /// Send a chat message to AI
  Future<Map<String, dynamic>> sendChatMessage({
    required String message,
    String? conversationId,
    String language = 'en',
    Map<String, dynamic>? location,
  }) async {
    try {
      print('📤 Sending chat message to: ${ApiConfig.aiEndpoint}/chat');
      
      final headers = await _getHeaders();
      final body = jsonEncode({
        'message': message,
        if (conversationId != null) 'conversationId': conversationId,
        'language': language,
        if (location != null) 'location': location,
      });

      final response = await http
          .post(
            Uri.parse('${ApiConfig.aiEndpoint}/chat'),
            headers: headers,
            body: body,
          )
          .timeout(ApiConfig.timeout);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw _handleError('sendChatMessage', 'HTTP ${response.statusCode}', response: response);
      }
    } catch (e) {
      throw _handleError('sendChatMessage', e);
    }
  }

  /// Analyze soil data
  Future<Map<String, dynamic>> analyzeSoil({
    required double ph,
    required double nitrogen,
    required double phosphorus,
    required double potassium,
    String season = 'kharif',
    String language = 'en',
    Map<String, dynamic>? location,
  }) async {
    try {
      print('📤 Analyzing soil...');
      
      final headers = await _getHeaders();
      final body = jsonEncode({
        'ph': ph,
        'nitrogen': nitrogen,
        'phosphorus': phosphorus,
        'potassium': potassium,
        'season': season,
        'language': language,
        if (location != null) 'location': location,
      });

      final response = await http
          .post(
            Uri.parse('${ApiConfig.aiEndpoint}/soil-analysis'),
            headers: headers,
            body: body,
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw _handleError('analyzeSoil', 'HTTP ${response.statusCode}', response: response);
      }
    } catch (e) {
      throw _handleError('analyzeSoil', e);
    }
  }

  /// Scan disease from plant image
  Future<Map<String, dynamic>> scanDisease({
    required String imageBase64,
    String language = 'en',
    Map<String, dynamic>? location,
  }) async {
    try {
      print('📤 Scanning disease...');
      
      final headers = await _getHeaders();
      final body = jsonEncode({
        'image': imageBase64,
        'language': language,
        if (location != null) 'location': location,
      });

      final response = await http
          .post(
            Uri.parse('${ApiConfig.aiEndpoint}/disease-scan'),
            headers: headers,
            body: body,
          )
          .timeout(Duration(seconds: 60)); // Longer timeout for image processing

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw _handleError('scanDisease', 'HTTP ${response.statusCode}', response: response);
      }
    } catch (e) {
      throw _handleError('scanDisease', e);
    }
  }

  /// Process voice query
  Future<Map<String, dynamic>> processVoice({
    required String audioBase64,
    String language = 'auto',
    String? conversationId,
    bool enableTTS = true,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'audio': audioBase64,
        'language': language,
        if (conversationId != null) 'conversationId': conversationId,
        'enableTTS': enableTTS,
      });

      final response = await http
          .post(
            Uri.parse('${ApiConfig.aiEndpoint}/voice'),
            headers: headers,
            body: body,
          )
          .timeout(Duration(seconds: 60));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw _handleError('processVoice', 'HTTP ${response.statusCode}', response: response);
      }
    } catch (e) {
      throw _handleError('processVoice', e);
    }
  }

  /// Get history (chat, soil, disease, or voice)
  Future<Map<String, dynamic>> getHistory({
    String type = 'chat',
    int limit = 50,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.aiEndpoint}/history?type=$type&limit=$limit'),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw _handleError('getHistory', 'HTTP ${response.statusCode}', response: response);
      }
    } catch (e) {
      throw _handleError('getHistory', e);
    }
  }

  /// Get specific conversation
  Future<Map<String, dynamic>> getConversation(String conversationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.aiEndpoint}/conversation/$conversationId'),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw _handleError('getConversation', 'HTTP ${response.statusCode}', response: response);
      }
    } catch (e) {
      throw _handleError('getConversation', e);
    }
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.aiEndpoint}/conversation/$conversationId'),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode != 200) {
        throw _handleError('deleteConversation', 'HTTP ${response.statusCode}', response: response);
      }
    } catch (e) {
      throw _handleError('deleteConversation', e);
    }
  }
}
