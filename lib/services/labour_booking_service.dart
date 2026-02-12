import 'dart:async';
import 'dart:math';
import '../models/labour_models.dart';

class LabourBookingService {
  static final LabourBookingService _instance =
      LabourBookingService._internal();
  factory LabourBookingService() => _instance;
  LabourBookingService._internal();

  // Platform configuration
  static const double platformFeePercent = 5.0;
  static const double gstPercent = 0.0; // Enable if applicable
  static const double labourCommissionPercent = 5.0;
  static const double advancePercent = 30.0;
  static const double searchRadiusKm = 20.0;

  // Simulated database
  final List<LabourBooking> _bookings = [];
  final List<LabourPartner> _labourPartners = _getDummyLabourPartners();
  
  // Streams for real-time updates
  final StreamController<LabourBooking> _bookingUpdatesController =
      StreamController<LabourBooking>.broadcast();
  
  Stream<LabourBooking> get bookingUpdates =>
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

  // Calculate cost breakdown
  LabourCostBreakdown calculateCost({
    required int workersCount,
    required double wagePerWorker,
    required WorkDuration duration,
    PaymentOption paymentOption = PaymentOption.payAfterWork,
  }) {
    final subtotal = workersCount * wagePerWorker;
    final platformFee = (subtotal * platformFeePercent) / 100;
    final gst = (subtotal * gstPercent) / 100;
    final totalCost = subtotal + platformFee + gst;

    double? advanceAmount;
    double? remainingAmount;

    if (paymentOption == PaymentOption.partialAdvance) {
      advanceAmount = (totalCost * advancePercent) / 100;
      remainingAmount = totalCost - advanceAmount;
    }

    return LabourCostBreakdown(
      workersCount: workersCount,
      wagePerWorker: wagePerWorker,
      duration: duration,
      subtotal: subtotal,
      platformFee: platformFee,
      gst: gst,
      totalCost: totalCost,
      advanceAmount: advanceAmount,
      remainingAmount: remainingAmount,
    );
  }

  // Find available labour partners
  Future<List<LabourPartner>> findAvailableLabour({
    required LabourSkillType skillType,
    required Location workLocation,
    required DateTime workDate,
    required int workersRequired,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Filter partners
    final availablePartners = _labourPartners.where((partner) {
      // Check if partner is available and verified
      if (!partner.isAvailable || !partner.isVerified) return false;

      // Check skill type match
      if (!partner.skills.contains(skillType)) return false;

      // Check location/service radius
      if (partner.currentLocation == null) return false;
      final distance =
          calculateDistance(workLocation, partner.currentLocation!);
      if (distance > partner.serviceRadiusKm) return false;

      return true;
    }).toList();

    // Calculate distance for each partner
    final partnersWithDistance = availablePartners.map((partner) {
      final distance =
          calculateDistance(workLocation, partner.currentLocation!);

      return LabourPartner(
        id: partner.id,
        name: partner.name,
        phone: partner.phone,
        skills: partner.skills,
        experienceYears: partner.experienceYears,
        dailyWageExpectation: partner.dailyWageExpectation,
        rating: partner.rating,
        totalJobsCompleted: partner.totalJobsCompleted,
        isAvailable: partner.isAvailable,
        isVerified: partner.isVerified,
        serviceRadiusKm: partner.serviceRadiusKm,
        currentLocation: partner.currentLocation,
        distanceFromWork: distance,
      );
    }).toList();

    // Sort by rating and distance
    partnersWithDistance.sort((a, b) {
      final ratingCompare = b.rating.compareTo(a.rating);
      if (ratingCompare != 0) return ratingCompare;
      return (a.distanceFromWork ?? 0).compareTo(b.distanceFromWork ?? 0);
    });

    return partnersWithDistance.take(workersRequired).toList();
  }

  // Create booking
  Future<LabourBooking> createBooking({
    required String farmerId,
    required String farmerName,
    required String farmerPhone,
    required LabourSkillType labourType,
    required int workersRequired,
    required DateTime workDate,
    required WorkDuration duration,
    required double wagePerWorker,
    required Location workLocation,
    String? workNotes,
    required PaymentOption paymentOption,
  }) async {
    // Calculate cost
    final costBreakdown = calculateCost(
      workersCount: workersRequired,
      wagePerWorker: wagePerWorker,
      duration: duration,
      paymentOption: paymentOption,
    );

    // Generate booking ID
    final bookingId = 'LBK${DateTime.now().millisecondsSinceEpoch}';

    // Create booking
    final booking = LabourBooking(
      bookingId: bookingId,
      farmerId: farmerId,
      farmerName: farmerName,
      farmerPhone: farmerPhone,
      labourType: labourType,
      workersRequired: workersRequired,
      assignedLabourers: [],
      workDate: workDate,
      duration: duration,
      wagePerWorker: wagePerWorker,
      workLocation: workLocation,
      workNotes: workNotes,
      status: LabourBookingStatus.searching,
      costBreakdown: costBreakdown,
      paymentOption: paymentOption,
      paymentStatus: PaymentStatus.pending,
      createdAt: DateTime.now(),
    );

    _bookings.add(booking);
    _bookingUpdatesController.add(booking);

    // Start labour matching process
    _matchLabour(booking);

    return booking;
  }

  // Match labour to booking
  Future<void> _matchLabour(LabourBooking booking) async {
    try {
      // Find available partners
      final partners = await findAvailableLabour(
        skillType: booking.labourType,
        workLocation: booking.workLocation,
        workDate: booking.workDate,
        workersRequired: booking.workersRequired,
      );

      if (partners.isEmpty) {
        // No labour available
        await Future.delayed(const Duration(seconds: 2));
        updateBookingStatus(booking.bookingId, LabourBookingStatus.cancelled);
        return;
      }

      // Simulate matching delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Assign labour partners
      final updatedBooking = booking.copyWith(
        status: LabourBookingStatus.labourAssigned,
        assignedLabourers: partners,
      );

      final index =
          _bookings.indexWhere((b) => b.bookingId == booking.bookingId);
      if (index != -1) {
        _bookings[index] = updatedBooking;
        _bookingUpdatesController.add(updatedBooking);
      }

      // Auto confirm after 1 second (simulate acceptance)
      await Future.delayed(const Duration(seconds: 1));
      updateBookingStatus(booking.bookingId, LabourBookingStatus.workConfirmed);
    } catch (e) {
      // Log error (use a logging framework in production)
    }
  }

  // Update booking status
  void updateBookingStatus(String bookingId, LabourBookingStatus newStatus) {
    final index = _bookings.indexWhere((b) => b.bookingId == bookingId);
    if (index != -1) {
      final updatedBooking = _bookings[index].copyWith(
        status: newStatus,
        completedAt: newStatus == LabourBookingStatus.workCompleted
            ? DateTime.now()
            : _bookings[index].completedAt,
      );
      _bookings[index] = updatedBooking;
      _bookingUpdatesController.add(updatedBooking);
    }
  }

  // Update payment status
  void updatePaymentStatus(String bookingId, PaymentStatus status) {
    final index = _bookings.indexWhere((b) => b.bookingId == bookingId);
    if (index != -1) {
      final updatedBooking = _bookings[index].copyWith(
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

  // Get farmer bookings
  List<LabourBooking> getFarmerBookings(String farmerId) {
    return _bookings
        .where((b) => b.farmerId == farmerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get active booking
  LabourBooking? getActiveBooking(String farmerId) {
    try {
      return _bookings.firstWhere(
        (b) =>
            b.farmerId == farmerId &&
            (b.status != LabourBookingStatus.workCompleted &&
                b.status != LabourBookingStatus.paymentReleased &&
                b.status != LabourBookingStatus.cancelled),
      );
    } catch (e) {
      return null;
    }
  }

  // Get booking by ID
  LabourBooking? getBookingById(String bookingId) {
    try {
      return _bookings.firstWhere((b) => b.bookingId == bookingId);
    } catch (e) {
      return null;
    }
  }

  // Calculate labour earning (after commission)
  double calculateLabourEarning(double totalAmount) {
    return totalAmount * (100 - labourCommissionPercent) / 100;
  }

  // Get labour earnings
  LabourEarnings getLabourEarnings(String labourId) {
    final labourBookings = _bookings.where(
      (b) =>
          b.assignedLabourers.any((l) => l.id == labourId) &&
          b.status == LabourBookingStatus.paymentReleased,
    );

    final totalEarnings = labourBookings.fold<double>(
      0,
      (sum, b) => sum + calculateLabourEarning(b.costBreakdown.totalCost) / b.assignedLabourers.length,
    );

    final today = DateTime.now();
    final todayBookings = labourBookings.where((b) =>
        b.completedAt != null &&
        b.completedAt!.year == today.year &&
        b.completedAt!.month == today.month &&
        b.completedAt!.day == today.day);

    final todayEarnings = todayBookings.fold<double>(
      0,
      (sum, b) => sum + calculateLabourEarning(b.costBreakdown.totalCost) / b.assignedLabourers.length,
    );

    // Calculate week start (Monday)
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekBookings = labourBookings.where((b) =>
        b.completedAt != null &&
        b.completedAt!.isAfter(weekStart));

    final weeklyEarnings = weekBookings.fold<double>(
      0,
      (sum, b) => sum + calculateLabourEarning(b.costBreakdown.totalCost) / b.assignedLabourers.length,
    );

    final upcomingBookings = _bookings.where(
      (b) =>
          b.assignedLabourers.any((l) => l.id == labourId) &&
          b.workDate.isAfter(DateTime.now()) &&
          (b.status == LabourBookingStatus.labourAssigned ||
              b.status == LabourBookingStatus.workConfirmed),
    ).length;

    return LabourEarnings(
      labourId: labourId,
      todayEarnings: todayEarnings,
      weeklyEarnings: weeklyEarnings,
      totalEarnings: totalEarnings,
      withdrawableBalance: totalEarnings * 0.9, // 90% withdrawable
      platformCommission: labourCommissionPercent,
      completedJobs: labourBookings.length,
      upcomingBookings: upcomingBookings,
    );
  }

  void dispose() {
    _bookingUpdatesController.close();
  }

  // Dummy data for testing
  static List<LabourPartner> _getDummyLabourPartners() {
    return [
      LabourPartner(
        id: 'LB001',
        name: 'Suresh Kumar',
        phone: '9876543210',
        skills: [LabourSkillType.harvesting, LabourSkillType.loadingUnloading],
        experienceYears: 5,
        dailyWageExpectation: 500,
        rating: 4.7,
        totalJobsCompleted: 128,
        isAvailable: true,
        isVerified: true,
        serviceRadiusKm: 15,
        currentLocation: Location(
          latitude: 21.2514,
          longitude: 81.6296,
          address: 'Raipur, Chhattisgarh',
        ),
      ),
      LabourPartner(
        id: 'LB002',
        name: 'Raju Yadav',
        phone: '9876543211',
        skills: [LabourSkillType.fieldWorker, LabourSkillType.generalFarm],
        experienceYears: 3,
        dailyWageExpectation: 450,
        rating: 4.5,
        totalJobsCompleted: 85,
        isAvailable: true,
        isVerified: true,
        serviceRadiusKm: 12,
        currentLocation: Location(
          latitude: 21.2612,
          longitude: 81.6384,
          address: 'Bilaspur Road, Raipur',
        ),
      ),
      LabourPartner(
        id: 'LB003',
        name: 'Mahesh Singh',
        phone: '9876543212',
        skills: [LabourSkillType.constructionHelper],
        experienceYears: 8,
        dailyWageExpectation: 600,
        rating: 4.8,
        totalJobsCompleted: 156,
        isAvailable: true,
        isVerified: true,
        serviceRadiusKm: 20,
        currentLocation: Location(
          latitude: 21.2420,
          longitude: 81.6203,
          address: 'Dhamtari Road, Raipur',
        ),
      ),
      LabourPartner(
        id: 'LB004',
        name: 'Ramesh Patel',
        phone: '9876543213',
        skills: [LabourSkillType.irrigation, LabourSkillType.fieldWorker],
        experienceYears: 4,
        dailyWageExpectation: 400,
        rating: 4.4,
        totalJobsCompleted: 92,
        isAvailable: true,
        isVerified: true,
        serviceRadiusKm: 10,
        currentLocation: Location(
          latitude: 21.2560,
          longitude: 81.6350,
          address: 'Tatibandh, Raipur',
        ),
      ),
      LabourPartner(
        id: 'LB005',
        name: 'Dinesh Verma',
        phone: '9876543214',
        skills: [LabourSkillType.harvesting, LabourSkillType.generalFarm],
        experienceYears: 6,
        dailyWageExpectation: 500,
        rating: 4.6,
        totalJobsCompleted: 142,
        isAvailable: true,
        isVerified: true,
        serviceRadiusKm: 18,
        currentLocation: Location(
          latitude: 21.2480,
          longitude: 81.6410,
          address: 'Mana Camp, Raipur',
        ),
      ),
      LabourPartner(
        id: 'LB006',
        name: 'Prakash Sahu',
        phone: '9876543215',
        skills: [LabourSkillType.loadingUnloading, LabourSkillType.generalFarm],
        experienceYears: 2,
        dailyWageExpectation: 400,
        rating: 4.3,
        totalJobsCompleted: 58,
        isAvailable: true,
        isVerified: true,
        serviceRadiusKm: 15,
        currentLocation: Location(
          latitude: 21.2590,
          longitude: 81.6450,
          address: 'Devendra Nagar, Raipur',
        ),
      ),
      // More workers for matching
      ...List.generate(15, (i) {
        final skills = [
          [LabourSkillType.harvesting, LabourSkillType.fieldWorker],
          [LabourSkillType.loadingUnloading, LabourSkillType.generalFarm],
          [LabourSkillType.irrigation, LabourSkillType.fieldWorker],
        ][i % 3];
        
        return LabourPartner(
          id: 'LB${(i + 7).toString().padLeft(3, '0')}',
          name: 'Worker ${i + 7}',
          phone: '987654${(3216 + i).toString()}',
          skills: skills,
          experienceYears: (i % 8) + 1,
          dailyWageExpectation: 350.0 + (i % 6) * 50,
          rating: 4.0 + (i % 10) * 0.08,
          totalJobsCompleted: (i + 1) * 15,
          isAvailable: true,
          isVerified: true,
          serviceRadiusKm: 10.0 + (i % 5) * 2,
          currentLocation: Location(
            latitude: 21.25 + (i % 10) * 0.01,
            longitude: 81.63 + (i % 10) * 0.01,
            address: 'Area ${i + 7}, Raipur',
          ),
        );
      }),
    ];
  }
}
