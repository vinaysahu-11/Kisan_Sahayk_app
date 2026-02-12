import 'dart:async';
import 'dart:math';
import '../models/transport_models.dart';

class TransportBookingService {
  static final TransportBookingService _instance =
      TransportBookingService._internal();
  factory TransportBookingService() => _instance;
  TransportBookingService._internal();

  // Platform configuration
  static const double platformFeePercent = 5.0;
  static const double gstPercent = 0.0; // Enable if applicable
  static const double partnerCommissionPercent = 10.0;
  static const double searchRadiusKm = 10.0;

  // Simulated database
  final List<TransportBooking> _bookings = [];
  final List<TransportPartner> _partners = _getDummyPartners();
  
  // Streams for real-time updates
  final StreamController<TransportBooking> _bookingUpdatesController =
      StreamController<TransportBooking>.broadcast();
  
  Stream<TransportBooking> get bookingUpdates =>
      _bookingUpdatesController.stream;

  // Calculate distance between two locations (Haversine formula)
  double calculateDistance(Location from, Location to) {
    const earthRadiusKm = 6371;

    final dLat = _toRadians(to.latitude - from.latitude);
    final dLon = _toRadians(to.longitude - from.longitude);

    final lat1 = _toRadians(from.latitude);
    final lat2 = _toRadians(to.latitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Calculate fare breakdown
  FareBreakdown calculateFare({
    required double distance,
    required double ratePerKm,
    required double minimumFare,
  }) {
    final baseFare = distance * ratePerKm;
    final actualFare = baseFare < minimumFare ? minimumFare : baseFare;
    final platformFee = (actualFare * platformFeePercent) / 100;
    final gst = (actualFare * gstPercent) / 100;
    final totalFare = actualFare + platformFee + gst;

    return FareBreakdown(
      distance: distance,
      ratePerKm: ratePerKm,
      baseFare: baseFare,
      minimumFare: minimumFare,
      actualFare: actualFare,
      platformFee: platformFee,
      gst: gst,
      totalFare: totalFare,
    );
  }

  // Find available partners
  Future<List<TransportPartner>> findAvailablePartners({
    required Location pickupLocation,
    required VehicleType vehicleType,
    required double loadWeightTon,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Filter partners
    final availablePartners = _partners.where((partner) {
      // Check if partner is online and verified
      if (!partner.isOnline || !partner.isVerified) return false;

      // Check vehicle type match
      if (partner.vehicleType != vehicleType) return false;

      // Check capacity
      if (partner.capacityTon < loadWeightTon) return false;

      // Check distance
      if (partner.currentLocation == null) return false;
      final distance =
          calculateDistance(pickupLocation, partner.currentLocation!);
      if (distance > searchRadiusKm) return false;

      return true;
    }).toList();

    // Calculate distance and ETA for each partner
    final partnersWithDistance = availablePartners.map((partner) {
      final distance =
          calculateDistance(pickupLocation, partner.currentLocation!);
      final etaMinutes = (distance / 0.5).ceil(); // Assuming 30km/h avg speed

      return TransportPartner(
        id: partner.id,
        name: partner.name,
        phone: partner.phone,
        vehicleType: partner.vehicleType,
        vehicleNumber: partner.vehicleNumber,
        capacityTon: partner.capacityTon,
        ratePerKm: partner.ratePerKm,
        minimumFare: partner.minimumFare,
        rating: partner.rating,
        totalTrips: partner.totalTrips,
        isOnline: partner.isOnline,
        isVerified: partner.isVerified,
        currentLocation: partner.currentLocation,
        distanceFromPickup: distance,
        etaMinutes: etaMinutes,
      );
    }).toList();

    // Sort by distance and rating
    partnersWithDistance.sort((a, b) {
      final distanceCompare =
          (a.distanceFromPickup ?? 0).compareTo(b.distanceFromPickup ?? 0);
      if (distanceCompare != 0) return distanceCompare;
      return b.rating.compareTo(a.rating);
    });

    return partnersWithDistance;
  }

  // Create booking
  Future<TransportBooking> createBooking({
    required String userId,
    required String userName,
    required String userPhone,
    required Location pickupLocation,
    required Location dropLocation,
    required VehicleType vehicleType,
    required LoadType loadType,
    required double loadWeightTon,
    String? loadNotes,
    required BookingType bookingType,
    DateTime? scheduledTime,
  }) async {
    // Calculate distance
    final distance = calculateDistance(pickupLocation, dropLocation);

    // Get vehicle info
    final vehicleInfo = VehicleInfo.getAvailableVehicles()
        .firstWhere((v) => v.type == vehicleType);

    // Calculate fare
    final fareBreakdown = calculateFare(
      distance: distance,
      ratePerKm: vehicleInfo.ratePerKm,
      minimumFare: vehicleInfo.minimumFare,
    );

    // Generate booking ID
    final bookingId = 'BK${DateTime.now().millisecondsSinceEpoch}';

    // Create booking
    final booking = TransportBooking(
      bookingId: bookingId,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      pickupLocation: pickupLocation,
      dropLocation: dropLocation,
      distance: distance,
      vehicleType: vehicleType,
      loadType: loadType,
      loadWeightTon: loadWeightTon,
      loadNotes: loadNotes,
      bookingType: bookingType,
      scheduledTime: scheduledTime,
      status: BookingStatus.searching,
      fareBreakdown: fareBreakdown,
      createdAt: DateTime.now(),
      paymentStatus: PaymentStatus.pending,
    );

    _bookings.add(booking);
    _bookingUpdatesController.add(booking);

    // Start driver matching process
    _matchDriver(booking);

    return booking;
  }

  // Match driver to booking
  Future<void> _matchDriver(TransportBooking booking) async {
    try {
      // Find available partners
      final partners = await findAvailablePartners(
        pickupLocation: booking.pickupLocation,
        vehicleType: booking.vehicleType,
        loadWeightTon: booking.loadWeightTon,
      );

      if (partners.isEmpty) {
        // No drivers available
        await Future.delayed(const Duration(seconds: 2));
        updateBookingStatus(booking.bookingId, BookingStatus.cancelled);
        return;
      }

      // Simulate sequential request or broadcast
      // For now, auto-assign first available
      await Future.delayed(const Duration(seconds: 2));
      
      final assignedPartner = partners.first;
      final updatedBooking = booking.copyWith(
        status: BookingStatus.driverAssigned,
        assignedPartner: assignedPartner,
      );

      final index =
          _bookings.indexWhere((b) => b.bookingId == booking.bookingId);
      if (index != -1) {
        _bookings[index] = updatedBooking;
        _bookingUpdatesController.add(updatedBooking);
      }

      // Simulate driver arriving
      await Future.delayed(const Duration(seconds: 3));
      updateBookingStatus(booking.bookingId, BookingStatus.driverArriving);
    } catch (e) {
      // Log error (use a logging framework in production)
    }
  }

  // Update booking status
  void updateBookingStatus(String bookingId, BookingStatus newStatus) {
    final index = _bookings.indexWhere((b) => b.bookingId == bookingId);
    if (index != -1) {
      final updatedBooking = _bookings[index].copyWith(
        status: newStatus,
        completedAt: newStatus == BookingStatus.completed
            ? DateTime.now()
            : _bookings[index].completedAt,
      );
      _bookings[index] = updatedBooking;
      _bookingUpdatesController.add(updatedBooking);
    }
  }

  // Complete payment
  void completePayment(
    String bookingId,
    PaymentMethod method,
    PaymentStatus status,
  ) {
    final index = _bookings.indexWhere((b) => b.bookingId == bookingId);
    if (index != -1) {
      final updatedBooking = _bookings[index].copyWith(
        paymentMethod: method,
        paymentStatus: status,
      );
      _bookings[index] = updatedBooking;
      _bookingUpdatesController.add(updatedBooking);
    }
  }

  // Submit rating
  void submitRating(String bookingId, double rating, String review) {
    final index = _bookings.indexWhere((b) => b.bookingId == bookingId);
    if (index != -1) {
      final updatedBooking = _bookings[index].copyWith(
        rating: rating,
        review: review,
      );
      _bookings[index] = updatedBooking;
      _bookingUpdatesController.add(updatedBooking);
    }
  }

  // Get user bookings
  List<TransportBooking> getUserBookings(String userId) {
    return _bookings
        .where((b) => b.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get active booking
  TransportBooking? getActiveBooking(String userId) {
    try {
      return _bookings.firstWhere(
        (b) =>
            b.userId == userId &&
            (b.status != BookingStatus.completed &&
                b.status != BookingStatus.cancelled),
      );
    } catch (e) {
      return null;
    }
  }

  // Get booking by ID
  TransportBooking? getBookingById(String bookingId) {
    try {
      return _bookings.firstWhere((b) => b.bookingId == bookingId);
    } catch (e) {
      return null;
    }
  }

  // Calculate partner earnings
  double calculatePartnerEarning(double totalFare) {
    return totalFare * (100 - partnerCommissionPercent) / 100;
  }

  // Get partner earnings
  PartnerEarnings getPartnerEarnings(String partnerId) {
    final partnerBookings = _bookings.where(
      (b) =>
          b.assignedPartner?.id == partnerId &&
          b.status == BookingStatus.completed,
    );

    final totalEarnings = partnerBookings.fold<double>(
      0,
      (sum, b) => sum + calculatePartnerEarning(b.fareBreakdown.totalFare),
    );

    final today = DateTime.now();
    final todayBookings = partnerBookings.where((b) =>
        b.completedAt != null &&
        b.completedAt!.year == today.year &&
        b.completedAt!.month == today.month &&
        b.completedAt!.day == today.day);

    final todayEarnings = todayBookings.fold<double>(
      0,
      (sum, b) => sum + calculatePartnerEarning(b.fareBreakdown.totalFare),
    );

    return PartnerEarnings(
      partnerId: partnerId,
      totalEarnings: totalEarnings,
      todayEarnings: todayEarnings,
      withdrawableBalance: totalEarnings * 0.9, // 90% withdrawable
      platformCommission: partnerCommissionPercent,
      totalTrips: partnerBookings.length,
      todayTrips: todayBookings.length,
    );
  }

  void dispose() {
    _bookingUpdatesController.close();
  }

  // Dummy data for testing
  static List<TransportPartner> _getDummyPartners() {
    return [
      TransportPartner(
        id: 'TP001',
        name: 'Ramesh Yadav',
        phone: '9876543210',
        vehicleType: VehicleType.miniTruck,
        vehicleNumber: 'CG04AB1234',
        capacityTon: 5.0,
        ratePerKm: 35.0,
        minimumFare: 600.0,
        rating: 4.6,
        totalTrips: 243,
        isOnline: true,
        isVerified: true,
        currentLocation: Location(
          latitude: 21.2514,
          longitude: 81.6296,
          address: 'Raipur, Chhattisgarh',
        ),
      ),
      TransportPartner(
        id: 'TP002',
        name: 'Suresh Kumar',
        phone: '9876543211',
        vehicleType: VehicleType.tractor,
        vehicleNumber: 'CG04CD5678',
        capacityTon: 2.0,
        ratePerKm: 25.0,
        minimumFare: 300.0,
        rating: 4.8,
        totalTrips: 312,
        isOnline: true,
        isVerified: true,
        currentLocation: Location(
          latitude: 21.2612,
          longitude: 81.6384,
          address: 'Bilaspur Road, Raipur',
        ),
      ),
      TransportPartner(
        id: 'TP003',
        name: 'Mahesh Singh',
        phone: '9876543212',
        vehicleType: VehicleType.largeTruck,
        vehicleNumber: 'CG04EF9012',
        capacityTon: 10.0,
        ratePerKm: 50.0,
        minimumFare: 1000.0,
        rating: 4.5,
        totalTrips: 156,
        isOnline: true,
        isVerified: true,
        currentLocation: Location(
          latitude: 21.2420,
          longitude: 81.6203,
          address: 'Dhamtari Road, Raipur',
        ),
      ),
      TransportPartner(
        id: 'TP004',
        name: 'Rajesh Patel',
        phone: '9876543213',
        vehicleType: VehicleType.pickup,
        vehicleNumber: 'CG04GH3456',
        capacityTon: 1.5,
        ratePerKm: 20.0,
        minimumFare: 250.0,
        rating: 4.7,
        totalTrips: 428,
        isOnline: true,
        isVerified: true,
        currentLocation: Location(
          latitude: 21.2560,
          longitude: 81.6350,
          address: 'Tatibandh, Raipur',
        ),
      ),
      TransportPartner(
        id: 'TP005',
        name: 'Dinesh Verma',
        phone: '9876543214',
        vehicleType: VehicleType.tractor,
        vehicleNumber: 'CG04IJ7890',
        capacityTon: 2.0,
        ratePerKm: 25.0,
        minimumFare: 300.0,
        rating: 4.4,
        totalTrips: 189,
        isOnline: false,
        isVerified: true,
        currentLocation: Location(
          latitude: 21.2480,
          longitude: 81.6410,
          address: 'Mana Camp, Raipur',
        ),
      ),
    ];
  }
}
