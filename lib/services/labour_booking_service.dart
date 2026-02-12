import 'dart:convert';
import '../utils/http_client.dart';
import '../config/api_config.dart';

class LabourBookingService {
  static final LabourBookingService _instance =
      LabourBookingService._internal();
  factory LabourBookingService() => _instance;
  LabourBookingService._internal();

  final HttpClient _httpClient = HttpClient();

  // Get available skills from backend
  Future<List<String>> getSkills() async {
    try {
      final response = await _httpClient.get(
        '${ApiConfig.labourEndpoint}/skills',
      );

      final data = json.decode(response.body);
      return List<String>.from(data['skills']);
    } catch (e) {
      print('Get skills error: $e');
      rethrow;
    }
  }

  // Create labour booking
  Future<Map<String, dynamic>> createBooking({
    required String skill,
    required String workType,
    required int labourRequired,
    required String date,
    required double duration,
    required String description,
    required Map<String, dynamic> location,
    required double budget,
  }) async {
    try {
      final response = await _httpClient.post(
        '${ApiConfig.labourEndpoint}/bookings',
        {
          'skill': skill,
          'workType': workType,
          'labourRequired': labourRequired,
          'date': date,
          'duration': duration,
          'description': description,
          'location': location,
          'budget': budget,
        },
      );

      final data = json.decode(response.body);
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
      String url = '${ApiConfig.labourEndpoint}/bookings?page=$page&limit=$limit';
      if (status != null) {
        url += '&status=$status';
      }

      final response = await _httpClient.get(url);

      final data = json.decode(response.body);
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
      final response = await _httpClient.get(
        '${ApiConfig.labourEndpoint}/bookings/$bookingId',
      );

      final data = json.decode(response.body);
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
      final response = await _httpClient.put(
        '${ApiConfig.labourEndpoint}/bookings/$bookingId/cancel',
        {'reason': reason},
      );

      final data = json.decode(response.body);
      return {
        'message': data['message'],
        'booking': data['booking'],
      };
    } catch (e) {
      print('Cancel booking error: $e');
      rethrow;
    }
  }

  // Rate labour partner
  Future<Map<String, dynamic>> ratePartner({
    required String bookingId,
    required int rating,
    String? review,
  }) async {
    try {
      final response = await _httpClient.post(
        '${ApiConfig.labourEndpoint}/bookings/$bookingId/rate',
        {
          'rating': rating,
          'review': review,
        },
      );

      final data = json.decode(response.body);
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
      final response = await _httpClient.put(
        '${ApiConfig.labourEndpoint}/bookings/$bookingId/status',
        {'status': status},
      );

      final data = json.decode(response.body);
      return {
        'message': data['message'],
        'booking': data['booking'],
      };
    } catch (e) {
      print('Update status error: $e');
      rethrow;
    }
  }

  // Get available labour partners
  Future<Map<String, dynamic>> getAvailablePartners({
    String? skill,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      String url = '${ApiConfig.labourEndpoint}/partners?page=$page&limit=$limit';
      if (skill != null) {
        url += '&skill=$skill';
      }

      final response = await _httpClient.get(url);

      final data = json.decode(response.body);
      return {
        'partners': data['partners'],
        'pagination': data['pagination'],
      };
    } catch (e) {
      print('Get available partners error: $e');
      rethrow;
    }
  }
}
