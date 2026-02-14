// API Config - Backend endpoints
// Web: localhost:3000, Android Emulator: 10.0.2.2:3000

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

/// API Configuration Class
/// Provides centralized access to all backend endpoints
class ApiConfig {
  // === Base URL Configuration ===
  /// Returns appropriate backend URL based on platform
  static String get baseUrl {
    if (kIsWeb) {
      // Web: Direct localhost connection
      return 'http://localhost:3000/api';
    } else if (Platform.isAndroid) {
      // Android Emulator: Special IP that routes to host machine
      // Use 10.0.2.2 for emulator, or actual IP for physical device
      return 'http://10.0.2.2:3000/api';
    } else {
      // iOS Simulator/Physical Device: localhost or actual server IP
      return 'http://localhost:3000/api';
    }
  }

  // === API Endpoint Getters ===
  // All endpoints are dynamically generated based on baseUrl
  
  /// Authentication endpoints (login, signup, logout)
  static String get authEndpoint => '$baseUrl/auth';
  static String get buyerEndpoint => '$baseUrl/buyer';
  static String get sellerEndpoint => '$baseUrl/seller';
  static String get labourEndpoint => '$baseUrl/labour';
  static String get transportEndpoint => '$baseUrl/transport';
  static String get weatherEndpoint => '$baseUrl/weather';
  static String get aiEndpoint => '$baseUrl/ai';
  
  static const Duration timeout = Duration(seconds: 30);
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> headersWithToken(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };

  static void printConfig() {
    if (kDebugMode) {
      print('═══════════════════════════════════');
      print('API Configuration');
      print('═══════════════════════════════════');
      print('Platform: ${kIsWeb ? "Web" : (Platform.isAndroid ? "Android" : "iOS")}');
      print('Base URL: $baseUrl');
      print('AI Endpoint: $aiEndpoint');
      print('═══════════════════════════════════');
    }
  }
}
