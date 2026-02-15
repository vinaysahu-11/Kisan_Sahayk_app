// API Config - Centralized Backend Configuration
// Supports: Web (localhost), Android Emulator, Real Device (ngrok)

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

/// API Configuration Class
/// Provides centralized access to all backend endpoints
/// 
/// NGROK SETUP:
/// 1. Start backend: cd backend && node server.js
/// 2. Start ngrok: ngrok http 5000
/// 3. Copy HTTPS URL (e.g., https://abc123.ngrok.io)
/// 4. Paste below in ngrokUrl variable
/// 5. Set useNgrok = true
/// 6. Rebuild APK: flutter build apk
class ApiConfig {
  // ========================================
  // 🔧 NGROK CONFIGURATION
  // ========================================
  
  /// Set this to your ngrok HTTPS URL when using real device
  /// Example: 'https://abc123.ngrok.io'
  static const String ngrokUrl = 'REPLACE_WITH_NGROK_URL';
  
  /// Set to true when testing on real Android device
  /// Set to false for emulator/web development
  static const bool useNgrok = false;
  
  // ========================================
  // 🌐 BASE URL LOGIC
  // ========================================
  
  /// Returns appropriate backend URL based on platform and configuration
  static String get baseUrl {
    // Production: Use ngrok URL for real device testing
    if (useNgrok && ngrokUrl != 'REPLACE_WITH_NGROK_URL') {
      if (kDebugMode) {
        print('🔗 Using Ngrok URL: $ngrokUrl');
      }
      return '$ngrokUrl/api';
    }
    
    // Development: Platform-specific URLs
    if (kIsWeb) {
      // Web: Direct localhost connection
      return 'http://localhost:5000/api';
    } else if (Platform.isAndroid) {
      // Android Emulator: Special IP that routes to host machine
      return 'http://10.0.2.2:5000/api';
    } else if (Platform.isIOS) {
      // iOS Simulator: localhost
      return 'http://localhost:5000/api';
    } else {
      // Fallback
      return 'http://localhost:5000/api';
    }
  }
  
  // ========================================
  // 📍 API ENDPOINT GETTERS
  // ========================================
  
  /// Authentication endpoints
  static String get authEndpoint => '$baseUrl/auth';
  
  /// Buyer/Shopping endpoints
  static String get buyerEndpoint => '$baseUrl/buyer';
  
  /// Seller endpoints
  static String get sellerEndpoint => '$baseUrl/seller';
  
  /// Labour/Workers endpoints
  static String get labourEndpoint => '$baseUrl/labour';
  
  /// Transport booking endpoints
  static String get transportEndpoint => '$baseUrl/transport';
  
  /// Weather forecast endpoints
  static String get weatherEndpoint => '$baseUrl/weather';
  
  /// AI Assistant endpoints
  static String get aiEndpoint => '$baseUrl/ai';
  
  /// Voice commands endpoints
  static String get voiceEndpoint => '$baseUrl/voice';
  
  /// Delivery partner endpoints
  static String get deliveryEndpoint => '$baseUrl/delivery';
  
  /// Admin endpoints
  static String get adminEndpoint => '$baseUrl/admin';
  
  // ========================================
  // ⚙️ HTTP CONFIGURATION
  // ========================================
  
  /// Default timeout for API requests
  static const Duration timeout = Duration(seconds: 30);
  
  /// Connect timeout
  static const Duration connectTimeout = Duration(seconds: 15);
  
  /// Default headers for all requests
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'KisanSahayak-Flutter',
  };
  
  /// Headers with authentication token
  static Map<String, String> headersWithToken(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
  
  // ========================================
  // 🐛 DEBUG UTILITIES
  // ========================================
  
  /// Print current configuration (debug only)
  static void printConfig() {
    if (kDebugMode) {
      print('═══════════════════════════════════════');
      print('📡 API Configuration');
      print('═══════════════════════════════════════');
      print('Platform: ${kIsWeb ? 'Web' : Platform.operatingSystem}');
      print('Using Ngrok: $useNgrok');
      print('Base URL: $baseUrl');
      print('Timeout: ${timeout.inSeconds}s');
      print('═══════════════════════════════════════');
    }
  }
  
  /// Validate configuration
  static bool isConfigValid() {
    if (useNgrok) {
      if (ngrokUrl == 'REPLACE_WITH_NGROK_URL') {
        if (kDebugMode) {
          print('❌ ERROR: useNgrok is true but ngrokUrl not set!');
          print('   Please set your ngrok URL in api_config.dart');
        }
        return false;
      }
      if (!ngrokUrl.startsWith('https://') && !ngrokUrl.startsWith('http://')) {
        if (kDebugMode) {
          print('❌ ERROR: Invalid ngrok URL format!');
          print('   URL should start with https:// or http://');
        }
        return false;
      }
    }
    return true;
  }
}
