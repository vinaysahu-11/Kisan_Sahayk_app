// Labour Booking System Models

enum LabourSkillType {
  harvesting,
  loadingUnloading,
  fieldWorker,
  irrigation,
  constructionHelper,
  generalFarm,
}

enum WorkDuration {
  halfDay,
  fullDay,
}

enum LabourBookingStatus {
  searching,
  labourAssigned,
  workConfirmed,
  workStarted,
  workCompleted,
  paymentReleased,
  cancelled,
}

enum PaymentOption {
  payAfterWork,
  partialAdvance,
}

enum PaymentMethod {
  upi,
  card,
  wallet,
  cash,
}

enum PaymentStatus {
  pending,
  advancePaid,
  completed,
  refunded,
  failed,
}

class Location {
  final double latitude;
  final double longitude;
  final String address;

  Location({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      };

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        latitude: json['latitude'],
        longitude: json['longitude'],
        address: json['address'],
      );
}

class LabourSkillInfo {
  final LabourSkillType type;
  final String name;
  final String description;
  final String icon;
  final double avgWageMin;
  final double avgWageMax;
  final int availableWorkers;
  final double avgRating;

  LabourSkillInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.avgWageMin,
    required this.avgWageMax,
    required this.availableWorkers,
    required this.avgRating,
  });

  // Getters for compatibility
  LabourSkillType get skillType => type;
  double get minWagePerDay => avgWageMin;
  double get maxWagePerDay => avgWageMax;
  double get averageRating => avgRating;

  static List<LabourSkillInfo> getAvailableSkills() {
    return [
      LabourSkillInfo(
        type: LabourSkillType.harvesting,
        name: 'Harvesting Worker',
        description: 'Crop harvesting & collection',
        icon: '🌾',
        avgWageMin: 400,
        avgWageMax: 600,
        availableWorkers: 15,
        avgRating: 4.5,
      ),
      LabourSkillInfo(
        type: LabourSkillType.loadingUnloading,
        name: 'Loading / Unloading',
        description: 'Load & transport goods',
        icon: '📦',
        avgWageMin: 350,
        avgWageMax: 500,
        availableWorkers: 12,
        avgRating: 4.3,
      ),
      LabourSkillInfo(
        type: LabourSkillType.fieldWorker,
        name: 'Field Worker',
        description: 'Ploughing, sowing, weeding',
        icon: '👨‍🌾',
        avgWageMin: 350,
        avgWageMax: 550,
        availableWorkers: 18,
        avgRating: 4.4,
      ),
      LabourSkillInfo(
        type: LabourSkillType.irrigation,
        name: 'Irrigation Worker',
        description: 'Water management & irrigation',
        icon: '💧',
        avgWageMin: 300,
        avgWageMax: 450,
        availableWorkers: 8,
        avgRating: 4.2,
      ),
      LabourSkillInfo(
        type: LabourSkillType.constructionHelper,
        name: 'Construction Helper',
        description: 'Farm building & repairs',
        icon: '🔨',
        avgWageMin: 400,
        avgWageMax: 650,
        availableWorkers: 10,
        avgRating: 4.6,
      ),
      LabourSkillInfo(
        type: LabourSkillType.generalFarm,
        name: 'General Farm Labour',
        description: 'All-purpose farm work',
        icon: '🧑‍🌾',
        avgWageMin: 300,
        avgWageMax: 500,
        availableWorkers: 20,
        avgRating: 4.3,
      ),
    ];
  }
}

class LabourPartner {
  final String id;
  final String name;
  final String phone;
  final List<LabourSkillType> skills;
  final int experienceYears;
  final double dailyWageExpectation;
  final double rating;
  final int totalJobsCompleted;
  final bool isAvailable;
  final bool isVerified;
  final double serviceRadiusKm;
  final Location? currentLocation;
  final double? distanceFromWork;

  LabourPartner({
    required this.id,
    required this.name,
    required this.phone,
    required this.skills,
    required this.experienceYears,
    required this.dailyWageExpectation,
    required this.rating,
    required this.totalJobsCompleted,
    required this.isAvailable,
    required this.isVerified,
    required this.serviceRadiusKm,
    this.currentLocation,
    this.distanceFromWork,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'skills': skills.map((s) => s.name).toList(),
        'experienceYears': experienceYears,
        'dailyWageExpectation': dailyWageExpectation,
        'rating': rating,
        'totalJobsCompleted': totalJobsCompleted,
        'isAvailable': isAvailable,
        'isVerified': isVerified,
        'serviceRadiusKm': serviceRadiusKm,
        'currentLocation': currentLocation?.toJson(),
        'distanceFromWork': distanceFromWork,
      };

  factory LabourPartner.fromJson(Map<String, dynamic> json) => LabourPartner(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        skills: (json['skills'] as List)
            .map((s) => LabourSkillType.values.firstWhere((e) => e.name == s))
            .toList(),
        experienceYears: json['experienceYears'],
        dailyWageExpectation: json['dailyWageExpectation'],
        rating: json['rating'],
        totalJobsCompleted: json['totalJobsCompleted'],
        isAvailable: json['isAvailable'],
        isVerified: json['isVerified'],
        serviceRadiusKm: json['serviceRadiusKm'],
        currentLocation: json['currentLocation'] != null
            ? Location.fromJson(json['currentLocation'])
            : null,
        distanceFromWork: json['distanceFromWork'],
      );
}

class LabourCostBreakdown {
  final int workersCount;
  final double wagePerWorker;
  final WorkDuration duration;
  final double subtotal;
  final double platformFee;
  final double gst;
  final double totalCost;
  final double? advanceAmount;
  final double? remainingAmount;

  LabourCostBreakdown({
    required this.workersCount,
    required this.wagePerWorker,
    required this.duration,
    required this.subtotal,
    required this.platformFee,
    required this.gst,
    required this.totalCost,
    this.advanceAmount,
    this.remainingAmount,
  });

  Map<String, dynamic> toJson() => {
        'workersCount': workersCount,
        'wagePerWorker': wagePerWorker,
        'duration': duration.name,
        'subtotal': subtotal,
        'platformFee': platformFee,
        'gst': gst,
        'totalCost': totalCost,
        'advanceAmount': advanceAmount,
        'remainingAmount': remainingAmount,
      };

  factory LabourCostBreakdown.fromJson(Map<String, dynamic> json) =>
      LabourCostBreakdown(
        workersCount: json['workersCount'],
        wagePerWorker: json['wagePerWorker'],
        duration: WorkDuration.values
            .firstWhere((e) => e.name == json['duration']),
        subtotal: json['subtotal'],
        platformFee: json['platformFee'],
        gst: json['gst'],
        totalCost: json['totalCost'],
        advanceAmount: json['advanceAmount'],
        remainingAmount: json['remainingAmount'],
      );
}

class LabourBooking {
  final String bookingId;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final LabourSkillType labourType;
  final int workersRequired;
  final List<LabourPartner> assignedLabourers;
  final DateTime workDate;
  final WorkDuration duration;
  final double wagePerWorker;
  final Location workLocation;
  final String? workNotes;
  final LabourBookingStatus status;
  final LabourCostBreakdown costBreakdown;
  final PaymentOption paymentOption;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime? completedAt;
  final double? rating;
  final String? review;

  LabourBooking({
    required this.bookingId,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.labourType,
    required this.workersRequired,
    required this.assignedLabourers,
    required this.workDate,
    required this.duration,
    required this.wagePerWorker,
    required this.workLocation,
    this.workNotes,
    required this.status,
    required this.costBreakdown,
    required this.paymentOption,
    required this.paymentStatus,
    required this.createdAt,
    this.completedAt,
    this.rating,
    this.review,
  });

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'farmerId': farmerId,
        'farmerName': farmerName,
        'farmerPhone': farmerPhone,
        'labourType': labourType.name,
        'workersRequired': workersRequired,
        'assignedLabourers':
            assignedLabourers.map((l) => l.toJson()).toList(),
        'workDate': workDate.toIso8601String(),
        'duration': duration.name,
        'wagePerWorker': wagePerWorker,
        'workLocation': workLocation.toJson(),
        'workNotes': workNotes,
        'status': status.name,
        'costBreakdown': costBreakdown.toJson(),
        'paymentOption': paymentOption.name,
        'paymentStatus': paymentStatus.name,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'rating': rating,
        'review': review,
      };

  factory LabourBooking.fromJson(Map<String, dynamic> json) => LabourBooking(
        bookingId: json['bookingId'],
        farmerId: json['farmerId'],
        farmerName: json['farmerName'],
        farmerPhone: json['farmerPhone'],
        labourType: LabourSkillType.values
            .firstWhere((e) => e.name == json['labourType']),
        workersRequired: json['workersRequired'],
        assignedLabourers: (json['assignedLabourers'] as List)
            .map((l) => LabourPartner.fromJson(l))
            .toList(),
        workDate: DateTime.parse(json['workDate']),
        duration:
            WorkDuration.values.firstWhere((e) => e.name == json['duration']),
        wagePerWorker: json['wagePerWorker'],
        workLocation: Location.fromJson(json['workLocation']),
        workNotes: json['workNotes'],
        status: LabourBookingStatus.values
            .firstWhere((e) => e.name == json['status']),
        costBreakdown: LabourCostBreakdown.fromJson(json['costBreakdown']),
        paymentOption: PaymentOption.values
            .firstWhere((e) => e.name == json['paymentOption']),
        paymentStatus: PaymentStatus.values
            .firstWhere((e) => e.name == json['paymentStatus']),
        createdAt: DateTime.parse(json['createdAt']),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        rating: json['rating'],
        review: json['review'],
      );

  LabourBooking copyWith({
    LabourBookingStatus? status,
    List<LabourPartner>? assignedLabourers,
    DateTime? completedAt,
    PaymentStatus? paymentStatus,
    double? rating,
    String? review,
  }) {
    return LabourBooking(
      bookingId: bookingId,
      farmerId: farmerId,
      farmerName: farmerName,
      farmerPhone: farmerPhone,
      labourType: labourType,
      workersRequired: workersRequired,
      assignedLabourers: assignedLabourers ?? this.assignedLabourers,
      workDate: workDate,
      duration: duration,
      wagePerWorker: wagePerWorker,
      workLocation: workLocation,
      workNotes: workNotes,
      status: status ?? this.status,
      costBreakdown: costBreakdown,
      paymentOption: paymentOption,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      rating: rating ?? this.rating,
      review: review ?? this.review,
    );
  }
}

class LabourEarnings {
  final String labourId;
  final double todayEarnings;
  final double weeklyEarnings;
  final double totalEarnings;
  final double withdrawableBalance;
  final double platformCommission;
  final int completedJobs;
  final int upcomingBookings;

  LabourEarnings({
    required this.labourId,
    required this.todayEarnings,
    required this.weeklyEarnings,
    required this.totalEarnings,
    required this.withdrawableBalance,
    required this.platformCommission,
    required this.completedJobs,
    required this.upcomingBookings,
  });

  Map<String, dynamic> toJson() => {
        'labourId': labourId,
        'todayEarnings': todayEarnings,
        'weeklyEarnings': weeklyEarnings,
        'totalEarnings': totalEarnings,
        'withdrawableBalance': withdrawableBalance,
        'platformCommission': platformCommission,
        'completedJobs': completedJobs,
        'upcomingBookings': upcomingBookings,
      };

  factory LabourEarnings.fromJson(Map<String, dynamic> json) =>
      LabourEarnings(
        labourId: json['labourId'],
        todayEarnings: json['todayEarnings'],
        weeklyEarnings: json['weeklyEarnings'],
        totalEarnings: json['totalEarnings'],
        withdrawableBalance: json['withdrawableBalance'],
        platformCommission: json['platformCommission'],
        completedJobs: json['completedJobs'],
        upcomingBookings: json['upcomingBookings'],
      );
}
