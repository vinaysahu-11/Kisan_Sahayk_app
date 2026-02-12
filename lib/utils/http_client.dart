import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_storage.dart';

class HttpClient {
  // GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final token = await TokenStorage.getToken();
      final headers = token != null 
          ? ApiConfig.headersWithToken(token)
          : ApiConfig.headers;

      print('📤 GET: $endpoint');
      
      final response = await http
          .get(Uri.parse(endpoint), headers: headers)
          .timeout(ApiConfig.timeout);

      print('📥 Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ GET Error: $e');
      rethrow;
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await TokenStorage.getToken();
      final headers = token != null 
          ? ApiConfig.headersWithToken(token)
          : ApiConfig.headers;

      print('📤 POST: $endpoint');
      print('📦 Body: $body');
      
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      print('📥 Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ POST Error: $e');
      rethrow;
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await TokenStorage.getToken();
      final headers = token != null 
          ? ApiConfig.headersWithToken(token)
          : ApiConfig.headers;

      print('📤 PUT: $endpoint');
      print('📦 Body: $body');
      
      final response = await http
          .put(
            Uri.parse(endpoint),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      print('📥 Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ PUT Error: $e');
      rethrow;
    }
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final token = await TokenStorage.getToken();
      final headers = token != null 
          ? ApiConfig.headersWithToken(token)
          : ApiConfig.headers;

      print('📤 DELETE: $endpoint');
      
      final response = await http
          .delete(Uri.parse(endpoint), headers: headers)
          .timeout(ApiConfig.timeout);

      print('📥 Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ DELETE Error: $e');
      rethrow;
    }
  }

  // Handle response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    print('📥 Response: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired - logout
      TokenStorage.clearAll();
      throw Exception('Session expired. Please login again.');
    } else if (response.statusCode == 400) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? error['message'] ?? 'Bad request');
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found');
    } else if (response.statusCode == 500) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Server error');
    } else {
      throw Exception('Request failed with status ${response.statusCode}');
    }
  }
}
