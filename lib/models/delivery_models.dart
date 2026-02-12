// ============ DELIVERY PARTNER MODELS ============

enum DeliveryPartnerStatus { submitted, underReview, approved, active, blocked, rejected }
enum VehicleType { bike, scooter, cycle, van }
enum DeliveryStatus { assigned, accepted, reachedPickup, pickedUp, reachedCustomer, delivered, completed, rejected, cancelled }

// ============ DELIVERY PARTNER ============

class DeliveryPartner {
  final String id;
  final String name;
  final String mobile;
  final String email;
  final String aadhaar;
  final String? drivingLicense;
  final bool policeVerified;
  final String bankAccount;
  final String ifscCode;
  final String emergencyContact;
  final String emergencyName;
  final double serviceRadius; // in KM
  final String workingHoursStart;
  final String workingHoursEnd;
  final VehicleType vehicleType;
  final String vehicleNumber;
  final DeliveryPartnerStatus status;
  final double rating;
  final int totalDeliveries;
  final int acceptanceRate; // percentage
  final int onTimeRate; // percentage
  final int cancellationRate; // percentage
  final bool isOnline;
  final int activeOrders;
  final double todayEarnings;
  final double monthEarnings;
  final String? rejectionReason;
  final DateTime registeredDate;
  final DateTime? approvedDate;

  DeliveryPartner({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.aadhaar,
    this.drivingLicense,
    this.policeVerified = false,
    required this.bankAccount,
    required this.ifscCode,
    required this.emergencyContact,
    required this.emergencyName,
    this.serviceRadius = 10.0,
    this.workingHoursStart = '09:00',
    this.workingHoursEnd = '21:00',
    required this.vehicleType,
    required this.vehicleNumber,
    this.status = DeliveryPartnerStatus.submitted,
    this.rating = 0.0,
    this.totalDeliveries = 0,
    this.acceptanceRate = 100,
    this.onTimeRate = 100,
    this.cancellationRate = 0,
    this.isOnline = false,
    this.activeOrders = 0,
    this.todayEarnings = 0.0,
    this.monthEarnings = 0.0,
    this.rejectionReason,
    required this.registeredDate,
    this.approvedDate,
  });

  DeliveryPartner copyWith({
    String? id, String? name, String? mobile, String? email, String? aadhaar, String? drivingLicense,
    bool? policeVerified, String? bankAccount, String? ifscCode, String? emergencyContact, String? emergencyName,
    double? serviceRadius, String? workingHoursStart, String? workingHoursEnd, VehicleType? vehicleType,
    String? vehicleNumber, DeliveryPartnerStatus? status, double? rating, int? totalDeliveries,
    int? acceptanceRate, int? onTimeRate, int? cancellationRate, bool? isOnline, int? activeOrders,
    double? todayEarnings, double? monthEarnings, String? rejectionReason, DateTime? registeredDate, DateTime? approvedDate,
  }) {
    return DeliveryPartner(
      id: id ?? this.id, name: name ?? this.name, mobile: mobile ?? this.mobile, email: email ?? this.email,
      aadhaar: aadhaar ?? this.aadhaar, drivingLicense: drivingLicense ?? this.drivingLicense,
      policeVerified: policeVerified ?? this.policeVerified, bankAccount: bankAccount ?? this.bankAccount,
      ifscCode: ifscCode ?? this.ifscCode, emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyName: emergencyName ?? this.emergencyName, serviceRadius: serviceRadius ?? this.serviceRadius,
      workingHoursStart: workingHoursStart ?? this.workingHoursStart, workingHoursEnd: workingHoursEnd ?? this.workingHoursEnd,
      vehicleType: vehicleType ?? this.vehicleType, vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      status: status ?? this.status, rating: rating ?? this.rating, totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      acceptanceRate: acceptanceRate ?? this.acceptanceRate, onTimeRate: onTimeRate ?? this.onTimeRate,
      cancellationRate: cancellationRate ?? this.cancellationRate, isOnline: isOnline ?? this.isOnline,
      activeOrders: activeOrders ?? this.activeOrders, todayEarnings: todayEarnings ?? this.todayEarnings,
      monthEarnings: monthEarnings ?? this.monthEarnings, rejectionReason: rejectionReason ?? this.rejectionReason,
      registeredDate: registeredDate ?? this.registeredDate, approvedDate: approvedDate ?? this.approvedDate,
    );
  }
}

// ============ DELIVERY ORDER ============

class DeliveryOrder {
  final String id;
  final String buyerOrderId; // Link to buyer order
  final String partnerId;
  final String pickupLocation;
  final String pickupAddress;
  final String pickupPhone;
  final String dropLocation;
  final String dropAddress;
  final String dropPhone;
  final double distance; // KM
  final bool isCOD;
  final double codAmount;
  final String paymentMode;
  final DeliveryStatus status;
  final double baseFee;
  final double distanceBonus;
  final double heavyItemBonus;
  final double codFee;
  final double surgeBonus;
  final double totalEarning;
  final double commission; // Platform cut
  final double netEarning;
  final DateTime assignedAt;
  final DateTime? acceptedAt;
  final DateTime? pickedAt;
  final DateTime? deliveredAt;
  final DateTime? completedAt;
  final String? pickupOTP;
  final String? deliveryOTP;
  final bool pickupOTPVerified;
  final bool deliveryOTPVerified;
  final String? rejectionReason;
  final String? cancellationReason;
  final int? rating;
  final String? feedback;

  DeliveryOrder({
    required this.id,
    required this.buyerOrderId,
    required this.partnerId,
    required this.pickupLocation,
    required this.pickupAddress,
    required this.pickupPhone,
    required this.dropLocation,
    required this.dropAddress,
    required this.dropPhone,
    required this.distance,
    this.isCOD = false,
    this.codAmount = 0.0,
    required this.paymentMode,
    this.status = DeliveryStatus.assigned,
    required this.baseFee,
    this.distanceBonus = 0.0,
    this.heavyItemBonus = 0.0,
    this.codFee = 0.0,
    this.surgeBonus = 0.0,
    required this.totalEarning,
    required this.commission,
    required this.netEarning,
    required this.assignedAt,
    this.acceptedAt,
    this.pickedAt,
    this.deliveredAt,
    this.completedAt,
    this.pickupOTP,
    this.deliveryOTP,
    this.pickupOTPVerified = false,
    this.deliveryOTPVerified = false,
    this.rejectionReason,
    this.cancellationReason,
    this.rating,
    this.feedback,
  });

  DeliveryOrder copyWith({
    String? id, String? buyerOrderId, String? partnerId, String? pickupLocation, String? pickupAddress,
    String? pickupPhone, String? dropLocation, String? dropAddress, String? dropPhone, double? distance,
    bool? isCOD, double? codAmount, String? paymentMode, DeliveryStatus? status, double? baseFee,
    double? distanceBonus, double? heavyItemBonus, double? codFee, double? surgeBonus, double? totalEarning,
    double? commission, double? netEarning, DateTime? assignedAt, DateTime? acceptedAt, DateTime? pickedAt,
    DateTime? deliveredAt, DateTime? completedAt, String? pickupOTP, String? deliveryOTP,
    bool? pickupOTPVerified, bool? deliveryOTPVerified, String? rejectionReason, String? cancellationReason,
    int? rating, String? feedback,
  }) {
    return DeliveryOrder(
      id: id ?? this.id, buyerOrderId: buyerOrderId ?? this.buyerOrderId, partnerId: partnerId ?? this.partnerId,
      pickupLocation: pickupLocation ?? this.pickupLocation, pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupPhone: pickupPhone ?? this.pickupPhone, dropLocation: dropLocation ?? this.dropLocation,
      dropAddress: dropAddress ?? this.dropAddress, dropPhone: dropPhone ?? this.dropPhone,
      distance: distance ?? this.distance, isCOD: isCOD ?? this.isCOD, codAmount: codAmount ?? this.codAmount,
      paymentMode: paymentMode ?? this.paymentMode, status: status ?? this.status, baseFee: baseFee ?? this.baseFee,
      distanceBonus: distanceBonus ?? this.distanceBonus, heavyItemBonus: heavyItemBonus ?? this.heavyItemBonus,
      codFee: codFee ?? this.codFee, surgeBonus: surgeBonus ?? this.surgeBonus, totalEarning: totalEarning ?? this.totalEarning,
      commission: commission ?? this.commission, netEarning: netEarning ?? this.netEarning,
      assignedAt: assignedAt ?? this.assignedAt, acceptedAt: acceptedAt ?? this.acceptedAt,
      pickedAt: pickedAt ?? this.pickedAt, deliveredAt: deliveredAt ?? this.deliveredAt,
      completedAt: completedAt ?? this.completedAt, pickupOTP: pickupOTP ?? this.pickupOTP,
      deliveryOTP: deliveryOTP ?? this.deliveryOTP, pickupOTPVerified: pickupOTPVerified ?? this.pickupOTPVerified,
      deliveryOTPVerified: deliveryOTPVerified ?? this.deliveryOTPVerified,
      rejectionReason: rejectionReason ?? this.rejectionReason, cancellationReason: cancellationReason ?? this.cancellationReason,
      rating: rating ?? this.rating, feedback: feedback ?? this.feedback,
    );
  }
}

// ============ DELIVERY WALLET ============

class DeliveryWalletTransaction {
  final String id;
  final String partnerId;
  final double amount;
  final String type; // 'earning', 'cod_collected', 'cod_settled', 'incentive', 'withdrawal', 'commission'
  final String description;
  final DateTime date;
  final String? orderId;

  DeliveryWalletTransaction({
    required this.id,
    required this.partnerId,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    this.orderId,
  });
}

// ============ DELIVERY INCENTIVE ============

class DeliveryIncentive {
  final String id;
  final String partnerId;
  final String type; // 'daily_target', 'weekly_bonus', 'ontime_reward', 'rating_reward'
  final double amount;
  final String description;
  final DateTime earnedDate;
  final bool claimed;

  DeliveryIncentive({
    required this.id,
    required this.partnerId,
    required this.type,
    required this.amount,
    required this.description,
    required this.earnedDate,
    this.claimed = false,
  });
}

// ============ DELIVERY NOTIFICATION ============

class DeliveryNotification {
  final String id;
  final String partnerId;
  final String title;
  final String message;
  final String type; // 'new_order', 'surge_alert', 'target_achieved', 'rating_drop', 'subscription'
  final DateTime date;
  final bool isRead;
  final String? orderId;

  DeliveryNotification({
    required this.id,
    required this.partnerId,
    required this.title,
    required this.message,
    required this.type,
    required this.date,
    this.isRead = false,
    this.orderId,
  });

  DeliveryNotification copyWith({bool? isRead}) {
    return DeliveryNotification(
      id: id, partnerId: partnerId, title: title, message: message, type: type,
      date: date, isRead: isRead ?? this.isRead, orderId: orderId,
    );
  }
}

// ============ COD SETTLEMENT ============

class CODSettlement {
  final String id;
  final String partnerId;
  final double totalCollected;
  final double settled;
  final double pending;
  final DateTime collectionDate;
  final DateTime? settlementDate;
  final String status; // 'pending', 'approved', 'settled'
  final List<String> orderIds;

  CODSettlement({
    required this.id,
    required this.partnerId,
    required this.totalCollected,
    this.settled = 0.0,
    required this.pending,
    required this.collectionDate,
    this.settlementDate,
    this.status = 'pending',
    required this.orderIds,
  });
}
