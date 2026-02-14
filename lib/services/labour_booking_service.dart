import '../utils/http_client.dart';
import '../config/api_config.dart';
import '../models/labour_models.dart';

class LabourBookingService {
  static final LabourBookingService _instance =
      LabourBookingService._internal();
  factory LabourBookingService() => _instance;
  LabourBookingService._internal();

  // Calculate cost breakdown for a booking
  LabourCostBreakdown calculateCost({
    required int workersCount,
    required double wagePerWorker,
    required WorkDuration duration,
  }) {
    final subtotal = workersCount * wagePerWorker * (duration == WorkDuration.fullDay ? 1 : 0.5);
    final platformFee = subtotal * 0.05;
    final gst = subtotal * 0.18;
    final totalCost = subtotal + platformFee + gst;
    return LabourCostBreakdown(
      workersCount: workersCount,
      wagePerWorker: wagePerWorker,
      duration: duration,
      subtotal: subtotal,
      platformFee: platformFee,
      gst: gst,
      totalCost: totalCost,
      advanceAmount: null,
      remainingAmount: null,
    );
  }

  // Find available labour partners
  Future<List<LabourPartner>> findAvailableLabour({
    required LabourSkillType skillType,
    required Location workLocation,
    required DateTime workDate,
    required int workersRequired,
  }) async {
    try {
      final response = await HttpClient.get(
        '${ApiConfig.labourEndpoint}/partners?skill=${skillType.name}&lat=${workLocation.latitude}&lng=${workLocation.longitude}&date=${workDate.toIso8601String()}&count=$workersRequired',
      );
      final partners = (response['partners'] as List)
          .map((p) => LabourPartner.fromJson(p))
          .toList();
      return partners;
    } catch (e) {
      print('Find available labour error: $e');
      rethrow;
    }
  }

  // Update payment status
  Future<Map<String, dynamic>> updatePaymentStatus(
    String bookingId,
    PaymentStatus status,
  ) async {
    try {
      final response = await HttpClient.put(
        '${ApiConfig.labourEndpoint}/bookings/$bookingId/payment',
        {'status': status.name},
      );
      return response;
    } catch (e) {
      print('Update payment status error: $e');
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
      final response = await HttpClient.post(
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
      return response;
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

        final response = await HttpClient.get(url);

      return response;
    } catch (e) {
      print('Get bookings error: $e');
      rethrow;
    }
  }

  // Get booking details
  Future<Map<String, dynamic>> getBookingById(String bookingId) async {
    try {
        final response = await HttpClient.get(
        '${ApiConfig.labourEndpoint}/bookings/$bookingId',
      );

      return response;
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
        final response = await HttpClient.put(
        '${ApiConfig.labourEndpoint}/bookings/$bookingId/cancel',
        {'reason': reason},
      );

      return response;
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
        final response = await HttpClient.post(
        '${ApiConfig.labourEndpoint}/bookings/$bookingId/rate',
        {
          'rating': rating,
          'review': review,
        },
      );

      return response;
    } catch (e) {
      print('Rate partner error: $e');
      rethrow;
    }
  }

  // Alias for submitRating (used in screens)
  Future<Map<String, dynamic>> submitRating({
    required String bookingId,
    required int rating,
    String? review,
  }) async {
    return await ratePartner(
      bookingId: bookingId,
      rating: rating,
      review: review,
    );
  }

  // Update booking status (Partner side)
  Future<Map<String, dynamic>> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    try {
        final response = await HttpClient.put(
        '${ApiConfig.labourEndpoint}/bookings/$bookingId/status',
        {'status': status},
      );

      return response;
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

      final response = await HttpClient.get(url);
      return response;
    } catch (e) {
      print('Get available partners error: $e');
      rethrow;
    }
  }
}
