import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Base URL configuration
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    } else {
      return 'http://localhost:3000/api';
    }
  }

  // API Endpoints
  static String get authEndpoint => '$baseUrl/auth';
  static String get buyerEndpoint => '$baseUrl/buyer';
  static String get sellerEndpoint => '$baseUrl/seller';
  static String get labourEndpoint => '$baseUrl/labour';
  static String get transportEndpoint => '$baseUrl/transport';
  static String get weatherEndpoint => '$baseUrl/weather';
  
  // Request timeout
  static const Duration timeout = Duration(seconds: 30);
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> headersWithToken(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
}
