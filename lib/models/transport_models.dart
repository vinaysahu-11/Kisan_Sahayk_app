// Transport Booking System Models

enum VehicleType {
  tractor,
  miniTruck,
  largeTruck,
  pickup,
}

enum LoadType {
  crop,
  fertilizer,
  equipment,
  other,
}

enum BookingType {
  instant,
  scheduled,
}

enum BookingStatus {
  searching,
  driverAssigned,
  driverArriving,
  loadStarted,
  inTransit,
  delivered,
  completed,
  cancelled,
}

enum PaymentMethod {
  upi,
  card,
  wallet,
  cash,
}

enum PaymentStatus {
  pending,
  held,
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

class VehicleInfo {
  final VehicleType type;
  final String name;
  final double capacityTon;
  final double ratePerKm;
  final double minimumFare;
  final String icon;
  final String description;

  VehicleInfo({
    required this.type,
    required this.name,
    required this.capacityTon,
    required this.ratePerKm,
    required this.minimumFare,
    required this.icon,
    required this.description,
  });

  static List<VehicleInfo> getAvailableVehicles() {
    return [
      VehicleInfo(
        type: VehicleType.tractor,
        name: 'Tractor',
        capacityTon: 2.0,
        ratePerKm: 25.0,
        minimumFare: 300.0,
        icon: '🚜',
        description: 'Best for farm loads',
      ),
      VehicleInfo(
        type: VehicleType.miniTruck,
        name: 'Mini Truck',
        capacityTon: 5.0,
        ratePerKm: 35.0,
        minimumFare: 600.0,
        icon: '🚚',
        description: 'Medium capacity',
      ),
      VehicleInfo(
        type: VehicleType.largeTruck,
        name: 'Large Truck',
        capacityTon: 10.0,
        ratePerKm: 50.0,
        minimumFare: 1000.0,
        icon: '🚛',
        description: 'High capacity loads',
      ),
      VehicleInfo(
        type: VehicleType.pickup,
        name: 'Pickup Van',
        capacityTon: 1.5,
        ratePerKm: 20.0,
        minimumFare: 250.0,
        icon: '🛻',
        description: 'Quick small loads',
      ),
    ];
  }
}

class TransportPartner {
  final String id;
  final String name;
  final String phone;
  final VehicleType vehicleType;
  final String vehicleNumber;
  final double capacityTon;
  final double ratePerKm;
  final double minimumFare;
  final double rating;
  final int totalTrips;
  final bool isOnline;
  final bool isVerified;
  final Location? currentLocation;
  final double? distanceFromPickup;
  final int? etaMinutes;

  TransportPartner({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.capacityTon,
    required this.ratePerKm,
    required this.minimumFare,
    required this.rating,
    required this.totalTrips,
    required this.isOnline,
    required this.isVerified,
    this.currentLocation,
    this.distanceFromPickup,
    this.etaMinutes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'vehicleType': vehicleType.name,
        'vehicleNumber': vehicleNumber,
        'capacityTon': capacityTon,
        'ratePerKm': ratePerKm,
        'minimumFare': minimumFare,
        'rating': rating,
        'totalTrips': totalTrips,
        'isOnline': isOnline,
        'isVerified': isVerified,
        'currentLocation': currentLocation?.toJson(),
        'distanceFromPickup': distanceFromPickup,
        'etaMinutes': etaMinutes,
      };

  factory TransportPartner.fromJson(Map<String, dynamic> json) =>
      TransportPartner(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        vehicleType: VehicleType.values
            .firstWhere((e) => e.name == json['vehicleType']),
        vehicleNumber: json['vehicleNumber'],
        capacityTon: json['capacityTon'],
        ratePerKm: json['ratePerKm'],
        minimumFare: json['minimumFare'],
        rating: json['rating'],
        totalTrips: json['totalTrips'],
        isOnline: json['isOnline'],
        isVerified: json['isVerified'],
        currentLocation: json['currentLocation'] != null
            ? Location.fromJson(json['currentLocation'])
            : null,
        distanceFromPickup: json['distanceFromPickup'],
        etaMinutes: json['etaMinutes'],
      );
}

class FareBreakdown {
  final double distance;
  final double ratePerKm;
  final double baseFare;
  final double minimumFare;
  final double actualFare;
  final double platformFee;
  final double gst;
  final double totalFare;

  FareBreakdown({
    required this.distance,
    required this.ratePerKm,
    required this.baseFare,
    required this.minimumFare,
    required this.actualFare,
    required this.platformFee,
    required this.gst,
    required this.totalFare,
  });

  Map<String, dynamic> toJson() => {
        'distance': distance,
        'ratePerKm': ratePerKm,
        'baseFare': baseFare,
        'minimumFare': minimumFare,
        'actualFare': actualFare,
        'platformFee': platformFee,
        'gst': gst,
        'totalFare': totalFare,
      };

  factory FareBreakdown.fromJson(Map<String, dynamic> json) => FareBreakdown(
        distance: json['distance'],
        ratePerKm: json['ratePerKm'],
        baseFare: json['baseFare'],
        minimumFare: json['minimumFare'],
        actualFare: json['actualFare'],
        platformFee: json['platformFee'],
        gst: json['gst'],
        totalFare: json['totalFare'],
      );
}

class TransportBooking {
  final String bookingId;
  final String userId;
  final String userName;
  final String userPhone;
  final Location pickupLocation;
  final Location dropLocation;
  final double distance;
  final VehicleType vehicleType;
  final LoadType loadType;
  final double loadWeightTon;
  final String? loadNotes;
  final BookingType bookingType;
  final DateTime? scheduledTime;
  final BookingStatus status;
  final TransportPartner? assignedPartner;
  final FareBreakdown fareBreakdown;
  final DateTime createdAt;
  final DateTime? completedAt;
  final PaymentMethod? paymentMethod;
  final PaymentStatus paymentStatus;
  final double? rating;
  final String? review;

  TransportBooking({
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.pickupLocation,
    required this.dropLocation,
    required this.distance,
    required this.vehicleType,
    required this.loadType,
    required this.loadWeightTon,
    this.loadNotes,
    required this.bookingType,
    this.scheduledTime,
    required this.status,
    this.assignedPartner,
    required this.fareBreakdown,
    required this.createdAt,
    this.completedAt,
    this.paymentMethod,
    required this.paymentStatus,
    this.rating,
    this.review,
  });

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'userId': userId,
        'userName': userName,
        'userPhone': userPhone,
        'pickupLocation': pickupLocation.toJson(),
        'dropLocation': dropLocation.toJson(),
        'distance': distance,
        'vehicleType': vehicleType.name,
        'loadType': loadType.name,
        'loadWeightTon': loadWeightTon,
        'loadNotes': loadNotes,
        'bookingType': bookingType.name,
        'scheduledTime': scheduledTime?.toIso8601String(),
        'status': status.name,
        'assignedPartner': assignedPartner?.toJson(),
        'fareBreakdown': fareBreakdown.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'paymentMethod': paymentMethod?.name,
        'paymentStatus': paymentStatus.name,
        'rating': rating,
        'review': review,
      };

  factory TransportBooking.fromJson(Map<String, dynamic> json) =>
      TransportBooking(
        bookingId: json['bookingId'],
        userId: json['userId'],
        userName: json['userName'],
        userPhone: json['userPhone'],
        pickupLocation: Location.fromJson(json['pickupLocation']),
        dropLocation: Location.fromJson(json['dropLocation']),
        distance: json['distance'],
        vehicleType:
            VehicleType.values.firstWhere((e) => e.name == json['vehicleType']),
        loadType:
            LoadType.values.firstWhere((e) => e.name == json['loadType']),
        loadWeightTon: json['loadWeightTon'],
        loadNotes: json['loadNotes'],
        bookingType: BookingType.values
            .firstWhere((e) => e.name == json['bookingType']),
        scheduledTime: json['scheduledTime'] != null
            ? DateTime.parse(json['scheduledTime'])
            : null,
        status: BookingStatus.values.firstWhere((e) => e.name == json['status']),
        assignedPartner: json['assignedPartner'] != null
            ? TransportPartner.fromJson(json['assignedPartner'])
            : null,
        fareBreakdown: FareBreakdown.fromJson(json['fareBreakdown']),
        createdAt: DateTime.parse(json['createdAt']),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        paymentMethod: json['paymentMethod'] != null
            ? PaymentMethod.values
                .firstWhere((e) => e.name == json['paymentMethod'])
            : null,
        paymentStatus: PaymentStatus.values
            .firstWhere((e) => e.name == json['paymentStatus']),
        rating: json['rating'],
        review: json['review'],
      );

  TransportBooking copyWith({
    BookingStatus? status,
    TransportPartner? assignedPartner,
    DateTime? completedAt,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    double? rating,
    String? review,
  }) {
    return TransportBooking(
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
      status: status ?? this.status,
      assignedPartner: assignedPartner ?? this.assignedPartner,
      fareBreakdown: fareBreakdown,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      rating: rating ?? this.rating,
      review: review ?? this.review,
    );
  }
}

class PartnerEarnings {
  final String partnerId;
  final double totalEarnings;
  final double todayEarnings;
  final double withdrawableBalance;
  final double platformCommission;
  final int totalTrips;
  final int todayTrips;

  PartnerEarnings({
    required this.partnerId,
    required this.totalEarnings,
    required this.todayEarnings,
    required this.withdrawableBalance,
    required this.platformCommission,
    required this.totalTrips,
    required this.todayTrips,
  });

  Map<String, dynamic> toJson() => {
        'partnerId': partnerId,
        'totalEarnings': totalEarnings,
        'todayEarnings': todayEarnings,
        'withdrawableBalance': withdrawableBalance,
        'platformCommission': platformCommission,
        'totalTrips': totalTrips,
        'todayTrips': todayTrips,
      };

  factory PartnerEarnings.fromJson(Map<String, dynamic> json) =>
      PartnerEarnings(
        partnerId: json['partnerId'],
        totalEarnings: json['totalEarnings'],
        todayEarnings: json['todayEarnings'],
        withdrawableBalance: json['withdrawableBalance'],
        platformCommission: json['platformCommission'],
        totalTrips: json['totalTrips'],
        todayTrips: json['todayTrips'],
      );
}
