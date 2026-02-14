import 'package:flutter/material.dart';

class VoiceNavigationService {
  final GlobalKey<NavigatorState> navigatorKey;

  VoiceNavigationService(this.navigatorKey);

  /// Navigate based on intent and entities
  Future<void> navigateByIntent({
    required BuildContext context,
    required String intent,
    required Map<String, dynamic> entities,
  }) async {
    print('🚀 Navigating: intent=$intent, entities=$entities');

    try {
      switch (intent) {
        case 'book_transport':
          await _navigateToTransportBooking(context, entities);
          break;

        case 'book_labour':
          await _navigateToLabourBooking(context, entities);
          break;

        case 'buy_product':
          await _navigateToBuyerDashboard(context, entities);
          break;

        case 'sell_product':
          await _navigateToSellerDashboard(context, entities);
          break;

        case 'weather_query':
          await _navigateToWeather(context, entities);
          break;

        case 'soil_analysis':
          await _navigateToSoilAnalysis(context, entities);
          break;

        case 'disease_scan':
          await _navigateToDiseaseScanner(context, entities);
          break;

        case 'general_query':
          // Stay on voice assistant screen
          break;

        default:
          print('⚠️ Unknown intent: $intent');
      }
    } catch (e) {
      print('❌ Navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigation failed: $e')),
      );
    }
  }

  Future<void> _navigateToTransportBooking(
    BuildContext context,
    Map<String, dynamic> entities,
  ) async {
    // Close voice assistant first
    Navigator.of(context).pop();

    // Navigate to transport booking with pre-filled data
    Navigator.of(context).pushNamed(
      '/transport/booking',
      arguments: {
        'pickup': entities['pickup'],
        'drop': entities['drop'],
        'load': entities['load'],
        'vehicle': entities['vehicle'],
        'date': entities['date'],
      },
    );
  }

  Future<void> _navigateToLabourBooking(
    BuildContext context,
    Map<String, dynamic> entities,
  ) async {
    Navigator.of(context).pop();
    
    Navigator.of(context).pushNamed(
      '/labour/booking',
      arguments: {
        'workers': entities['workers'],
        'duration': entities['duration'],
        'task': entities['task'],
        'location': entities['location'],
        'date': entities['date'],
      },
    );
  }

  Future<void> _navigateToBuyerDashboard(
    BuildContext context,
    Map<String, dynamic> entities,
  ) async {
    Navigator.of(context).pop();
    
    Navigator.of(context).pushNamed(
      '/buyer/dashboard',
      arguments: {
        'searchQuery': entities['product'],
        'category': entities['category'],
      },
    );
  }

  Future<void> _navigateToSellerDashboard(
    BuildContext context,
    Map<String, dynamic> entities,
  ) async {
    Navigator.of(context).pop();
    
    Navigator.of(context).pushNamed(
      '/seller/dashboard',
      arguments: {
        'product': entities['product'],
        'quantity': entities['quantity'],
        'price': entities['price'],
      },
    );
  }

  Future<void> _navigateToWeather(
    BuildContext context,
    Map<String, dynamic> entities,
  ) async {
    Navigator.of(context).pop();
    
    Navigator.of(context).pushNamed(
      '/weather',
      arguments: {
        'location': entities['location'],
      },
    );
  }

  Future<void> _navigateToSoilAnalysis(
    BuildContext context,
    Map<String, dynamic> entities,
  ) async {
    Navigator.of(context).pop();
    
    // Navigate to AI Assistant with soil analysis pre-selected
    Navigator.of(context).pushNamed(
      '/ai-assistant',
      arguments: {
        'tab': 'soil',
        'data': entities,
      },
    );
  }

  Future<void> _navigateToDiseaseScanner(
    BuildContext context,
    Map<String, dynamic> entities,
  ) async {
    Navigator.of(context).pop();
    
    // Navigate to AI Assistant with disease scanner pre-selected
    Navigator.of(context).pushNamed(
      '/ai-assistant',
      arguments: {
        'tab': 'disease',
        'data': entities,
      },
    );
  }

  /// Show confirmation dialog before navigation
  Future<bool> confirmNavigation(BuildContext context, String destination) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Navigation'),
        content: Text('Navigate to $destination?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Go'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
