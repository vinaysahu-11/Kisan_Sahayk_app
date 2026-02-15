import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'token_storage.dart';

class HttpClient {
  // GET request with better error handling
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final token = await TokenStorage.getToken();
      final headers = token != null 
          ? ApiConfig.headersWithToken(token)
          : ApiConfig.headers;

      if (kDebugMode) {
        print('🌐 GET: $endpoint');
      }
      
      final response = await http
          .get(Uri.parse(endpoint), headers: headers)
          .timeout(ApiConfig.timeout);

      return _handleResponse(response, 'GET', endpoint);
    } on TimeoutException {
      return _handleTimeout(endpoint);
    } on SocketException {
      return _handleConnectionError(endpoint);
    } catch (e) {
      return _handleUnknownError(e, endpoint);
    }
  }

  // POST request with better error handling
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await TokenStorage.getToken();
      final headers = token != null 
          ? ApiConfig.headersWithToken(token)
          : ApiConfig.headers;

      if (kDebugMode) {
        print('🌐 POST: $endpoint');
        final bodyStr = jsonEncode(body);
        final preview = bodyStr.length > 200 ? '${bodyStr.substring(0, 200)}...' : bodyStr;
        print('   Body: $preview');
      }
      
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response, 'POST', endpoint);
    } on TimeoutException {
      return _handleTimeout(endpoint);
    } on SocketException {
      return _handleConnectionError(endpoint);
    } catch (e) {
      return _handleUnknownError(e, endpoint);
    }
  }

  // PUT request with better error handling
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await TokenStorage.getToken();
      final headers = token != null 
          ? ApiConfig.headersWithToken(token)
          : ApiConfig.headers;

      if (kDebugMode) {
        print('🌐 PUT: $endpoint');
        print('   Body: ${jsonEncode(body)}');
      }
      
      final response = await http
          .put(
            Uri.parse(endpoint),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response, 'PUT', endpoint);
    } on TimeoutException {
      return _handleTimeout(endpoint);
    } on SocketException {
      return _handleConnectionError(endpoint);
    } catch (e) {
      return _handleUnknownError(e, endpoint);
    }
  }

  // DELETE request with better error handling
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final token = await TokenStorage.getToken();
      final headers = token != null 
          ? ApiConfig.headersWithToken(token)
          : ApiConfig.headers;

      if (kDebugMode) {
        print('🌐 DELETE: $endpoint');
      }
      
      final response = await http
          .delete(Uri.parse(endpoint), headers: headers)
          .timeout(ApiConfig.timeout);

      return _handleResponse(response, 'DELETE', endpoint);
    } on TimeoutException {
      return _handleTimeout(endpoint);
    } on SocketException {
      return _handleConnectionError(endpoint);
    } catch (e) {
      return _handleUnknownError(e, endpoint);
    }
  }

  // Handle response with detailed logging
  static Map<String, dynamic> _handleResponse(
    http.Response response,
    String method,
    String endpoint,
  ) {
    if (kDebugMode) {
      final status = response.statusCode;
      final icon = status >= 200 && status < 300 ? '✅' : '❌';
      print('$icon Response $status from $method');
      
      if (response.body.length < 500) {
        print('   Body: ${response.body}');
      } else {
        print('   Body: ${response.body.substring(0, 200)}... (${response.body.length} bytes)');
      }
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        return {
          'success': false,
          'error': 'Invalid JSON response',
          'message': 'Server returned invalid data',
        };
      }
    } else {
      return _handleErrorResponse(response, endpoint);
    }
  }

  static Map<String, dynamic> _handleErrorResponse(
    http.Response response,
    String endpoint,
  ) {
    String errorMessage;
    
    try {
      final errorData = jsonDecode(response.body);
      errorMessage = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
    } catch (e) {
      errorMessage = 'Server error: ${response.statusCode}';
    }

    if (kDebugMode) {
      print('❌ HTTP ${response.statusCode}: $errorMessage');
      print('   Response: ${response.body}');
    }

    // Handle auth errors
    if (response.statusCode == 401) {
      TokenStorage.clearAll();
    }

    return {
      'success': false,
      'error': errorMessage,
      'statusCode': response.statusCode,
      'message': _getUserFriendlyErrorMessage(response.statusCode, errorMessage),
    };
  }

  static Map<String, dynamic> _handleTimeout(String endpoint) {
    if (kDebugMode) {
      print('⏱️  Request timeout: $endpoint');
    }
    return {
      'success': false,
      'error': 'timeout',
      'message': 'Request timed out. Please check your connection.',
    };
  }

  static Map<String, dynamic> _handleConnectionError(String endpoint) {
    if (kDebugMode) {
      print('🔌 Connection error: $endpoint');
      print('   ⚠️  Cannot connect to backend!');
      print('   ');
      print('   📝 Checklist:');
      print('   ✓ Backend running? (cd backend && node server.js)');
      print('   ✓ Ngrok running? (ngrok http 5000)');
      print('   ✓ Ngrok URL updated in ApiConfig?');
      print('   ✓ useNgrok = true in ApiConfig?');
      print('   ✓ Internet connection active?');
    }
    return {
      'success': false,
      'error': 'connection_failed',
      'message': 'Cannot connect to server.\n\n'
          'Please check:\n'
          '• Backend is running (node server.js)\n'
          '• Ngrok is running (ngrok http 5000)\n'
          '• Ngrok URL updated in ApiConfig\n'
          '• Internet connection is active',
    };
  }

  static Map<String, dynamic> _handleUnknownError(dynamic error, String endpoint) {
    if (kDebugMode) {
      print('💥 Unknown error: $error');
      print('   Endpoint: $endpoint');
    }
    return {
      'success': false,
      'error': 'unknown_error',
      'message': 'Something went wrong: ${error.toString()}',
    };
  }

  static String _getUserFriendlyErrorMessage(int statusCode, String originalMessage) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'Access denied. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 408:
        return 'Request timeout. Please try again.';
      case 429:
        return 'Too many requests. Please wait a moment.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Server temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. Server not responding.';
      default:
        return originalMessage;
    }
  }
}
