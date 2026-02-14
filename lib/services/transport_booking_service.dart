import 'dart:math';
import '../utils/http_client.dart';
import '../config/api_config.dart';

class TransportBookingService {
  static final TransportBookingService _instance =
      TransportBookingService._internal();
  factory TransportBookingService() => _instance;
  TransportBookingService._internal();

  // Get vehicle types from backend
  Future<List<Map<String, dynamic>>> getVehicleTypes() async {
    try {
      final data = await HttpClient.get(
        '${ApiConfig.transportEndpoint}/vehicle-types',
      );

      return List<Map<String, dynamic>>.from(data['vehicleTypes']);
    } catch (e) {
      print('Get vehicle types error: $e');
      rethrow;
    }
  }

  // Calculate fare from backend
  Future<Map<String, dynamic>> calculateFare({
    required String vehicleType,
    required double distance,
    double? loadWeight,
  }) async {
    try {
      final data = await HttpClient.post(
        '${ApiConfig.transportEndpoint}/calculate-fare',
        {
          'vehicleType': vehicleType,
          'distance': distance,
          'loadWeight': loadWeight,
        },
      );

      return {
        'vehicleType': data['vehicleType'],
        'distance': data['distance'],
        'baseFare': data['baseFare'],
        'gst': data['gst'],
        'totalFare': data['totalFare'],
      };
    } catch (e) {
      print('Calculate fare error: $e');
      rethrow;
    }
  }

  // Create transport booking
  Future<Map<String, dynamic>> createBooking({
    required String vehicleType,
    required String loadType,
    required double loadWeight,
    required Map<String, dynamic> pickupLocation,
    required Map<String, dynamic> dropLocation,
    required double distance,
    required String scheduledDate,
    required Map<String, dynamic> fare,
    String? notes,
    bool payNow = false,
  }) async {
    try {
      final data = await HttpClient.post(
        '${ApiConfig.transportEndpoint}/bookings',
        {
          'vehicleType': vehicleType,
          'loadType': loadType,
          'loadWeight': loadWeight,
          'pickupLocation': pickupLocation,
          'dropLocation': dropLocation,
          'distance': distance,
          'scheduledDate': scheduledDate,
          'fare': fare,
          'notes': notes,
          'payNow': payNow,
        },
      );

      return {
        'message': data['message'],
        'booking': data['booking'],
      };
    } catch (e) {
      print('Create booking error: $e');
      rethrow;
    }
  }

  // Get user's bookings
  Future<Map<String, dynamic>> getBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      String url = '${ApiConfig.transportEndpoint}/bookings?page=$page&limit=$limit';
      if (status != null) {
        url += '&status=$status';
      }

      final data = await HttpClient.get(url);

      return {
        'bookings': data['bookings'],
        'pagination': data['pagination'],
      };
    } catch (e) {
      print('Get bookings error: $e');
      rethrow;
    }
  }

  // Get booking details
  Future<Map<String, dynamic>> getBookingById(String bookingId) async {
    try {
      final data = await HttpClient.get(
        '${ApiConfig.transportEndpoint}/bookings/$bookingId',
      );

      return {'booking': data['booking']};
    } catch (e) {
      print('Get booking details error: $e');
      rethrow;
    }
  }

  // Cancel booking
  Future<Map<String, dynamic>> cancelBooking(
    String bookingId,
    String reason,
  ) async {
    try {
      final data = await HttpClient.put(
        '${ApiConfig.transportEndpoint}/bookings/$bookingId/cancel',
        {'reason': reason},
      );

      return {
        'message': data['message'],
        'booking': data['booking'],
      };
    } catch (e) {
      print('Cancel booking error: $e');
      rethrow;
    }
  }

  // Rate transport partner
  Future<Map<String, dynamic>> ratePartner({
    required String bookingId,
    required int rating,
    String? review,
  }) async {
    try {
      final data = await HttpClient.post(
        '${ApiConfig.transportEndpoint}/bookings/$bookingId/rate',
        {
          'rating': rating,
          'review': review,
        },
      );

      return {
        'message': data['message'],
        'rating': data['rating'],
      };
    } catch (e) {
      print('Rate partner error: $e');
      rethrow;
    }
  }

  // Update booking status (Partner side)
  Future<Map<String, dynamic>> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    try {
      final data = await HttpClient.put(
        '${ApiConfig.transportEndpoint}/bookings/$bookingId/status',
        {'status': status},
      );

      return {
        'message': data['message'],
        'booking': data['booking'],
      };
    } catch (e) {
      print('Update status error: $e');
      rethrow;
    }
  }

  // Get available transport partners
  Future<Map<String, dynamic>> getAvailablePartners({
    String? vehicleType,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      String url = '${ApiConfig.transportEndpoint}/partners/available?page=$page&limit=$limit';
      if (vehicleType != null) {
        url += '&vehicleType=$vehicleType';
      }

      final data = await HttpClient.get(url);

      return {
        'partners': data['partners'],
        'pagination': data['pagination'],
      };
    } catch (e) {
      print('Get available partners error: $e');
      rethrow;
    }
  }

  // Calculate distance between two locations (Haversine formula)
  // This can be used on frontend for display purposes
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}
