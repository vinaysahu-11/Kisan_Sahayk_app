import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';

class AuthService {
  /// Register new user
  /// Sends POST request to /api/auth/register
  /// Returns: {token, user, message}
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    String? role,
  }) async {
    try {
      print('📤 Signup Request - Name: $name, Phone: $phone, Role: ${role ?? 'buyer'}');
      
      final url = Uri.parse('${ApiConfig.authEndpoint}/register');
      print('URL: $url');

      final body = jsonEncode({
        'name': name,
        'phone': phone,
        'password': password,
        'role': role ?? 'buyer',
      });

      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: body,
      ).timeout(ApiConfig.timeout);

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Save token and user data
        await TokenStorage.saveToken(
          data['token'],
          userId: data['user']['id'],
          role: data['user']['role'],
          name: data['user']['name'],
          phone: data['user']['phone'],
        );
        
        print('Signup Successful! Token saved.');
        return data;
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        final errorMsg = error['error'] ?? error['errors']?[0]?['msg'] ?? 'Validation failed';
        throw Exception(errorMsg);
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  /// Login with phone and OTP
  Future<Map<String, dynamic>> login({
    required String phone,
    required String otp,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.authEndpoint}/login');
      
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({'phone': phone, 'otp': otp}),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Save token and user data
        await TokenStorage.saveToken(
          data['token'],
          userId: data['user']['id'],
          role: data['user']['role'],
          name: data['user']['name'],
          phone: data['user']['phone'],
        );
        
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('Phone number not registered');
      } else if (response.statusCode == 401) {
        throw Exception('Invalid OTP');
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  /// Send OTP
  Future<Map<String, dynamic>> sendOTP({required String phone}) async {
    try {
      final url = Uri.parse('${ApiConfig.authEndpoint}/send-otp');
      
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({'phone': phone}),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send OTP');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    await TokenStorage.clearAll();
  }

  /// Update user preferences (language, darkMode, notifications)
  Future<Map<String, dynamic>> updatePreferences({
    String? language,
    bool? darkMode,
    Map<String, dynamic>? notifications,
  }) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final url = Uri.parse('${ApiConfig.authEndpoint}/preferences');
      
      final body = <String, dynamic>{};
      if (language != null) body['language'] = language;
      if (darkMode != null) body['darkMode'] = darkMode;
      if (notifications != null) body['notifications'] = notifications;

      final response = await http.put(
        url,
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update preferences');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  /// Get user preferences
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final url = Uri.parse('${ApiConfig.authEndpoint}/preferences');
      
      final response = await http.get(
        url,
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get preferences');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }
}
