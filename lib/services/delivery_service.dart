import '../models/delivery_models.dart';

class DeliveryService {
  static final DeliveryService _instance = DeliveryService._internal();
  factory DeliveryService() => _instance;

  // Storage
  final Map<String, DeliveryPartner> _partners = {};
  final Map<String, DeliveryOrder> _orders = {};
  final List<DeliveryWalletTransaction> _transactions = [];
  final List<DeliveryIncentive> _incentives = [];
  final List<DeliveryNotification> _notifications = [];
  final Map<String, CODSettlement> _codSettlements = {};

  // Current partner
  String? _currentPartnerId;

  // Commission & pricing config (Admin controlled)
  double _commissionPercent = 15.0; // Platform takes 15%
  double _baseFee = 50.0;
  double _distanceBonusPerKM = 8.0;
  final double _codFeePercent = 2.0; // 2% of COD amount
  double _surgeMultiplier = 1.0; // 1.0 = no surge, 1.5 = 50% surge
  int _dailyTargetDeliveries = 20;
  double _dailyTargetBonus = 500.0;

  DeliveryService._internal() {
    _initializeDemoData();
  }

  void _initializeDemoData() {
    // Demo delivery partner (approved)
    _partners['DP201'] = DeliveryPartner(
      id: 'DP201',
      name: 'Amit Kumar',
      mobile: '9876543210',
      email: 'amit@delivery.com',
      aadhaar: '1234-5678-9012',
      drivingLicense: 'DL1234567890',
      policeVerified: true,
      bankAccount: '123456789012',
      ifscCode: 'SBIN0001234',
      emergencyContact: '9876543211',
      emergencyName: 'Rajesh Kumar',
      serviceRadius: 15.0,
      vehicleType: VehicleType.bike,
      vehicleNumber: 'MP09XX1234',
      status: DeliveryPartnerStatus.active,
      rating: 4.7,
      totalDeliveries: 348,
      acceptanceRate: 92,
      onTimeRate: 95,
      cancellationRate: 3,
      isOnline: true,
      activeOrders: 2,
      todayEarnings: 850.0,
      monthEarnings: 24500.0,
      registeredDate: DateTime.now().subtract(const Duration(days: 90)),
      approvedDate: DateTime.now().subtract(const Duration(days: 88)),
    );

    // Demo partner (pending approval)
    _partners['DP202'] = DeliveryPartner(
      id: 'DP202',
      name: 'Rahul Verma',
      mobile: '9876543212',
      email: 'rahul@delivery.com',
      aadhaar: '2345-6789-0123',
      drivingLicense: 'DL2345678901',
      policeVerified: false,
      bankAccount: '234567890123',
      ifscCode: 'HDFC0001234',
      emergencyContact: '9876543213',
      emergencyName: 'Suresh Verma',
      serviceRadius: 10.0,
      vehicleType: VehicleType.scooter,
      vehicleNumber: 'MP09YY5678',
      status: DeliveryPartnerStatus.underReview,
      registeredDate: DateTime.now().subtract(const Duration(days: 2)),
    );

    // Demo delivery orders
    _orders['DEL9001'] = DeliveryOrder(
      id: 'DEL9001',
      buyerOrderId: 'BO9001',
      partnerId: 'DP201',
      pickupLocation: 'Farm Fresh Indore',
      pickupAddress: '123, Vijay Nagar, Indore',
      pickupPhone: '9876543214',
      dropLocation: 'Buyer Home',
      dropAddress: '456, Sudama Nagar, Indore',
      dropPhone: '9876543215',
      distance: 8.5,
      isCOD: true,
      codAmount: 450.0,
      paymentMode: 'COD',
      status: DeliveryStatus.reachedCustomer,
      baseFee: 50.0,
      distanceBonus: 68.0,
      codFee: 9.0,
      surgeBonus: 15.0,
      totalEarning: 142.0,
      commission: 21.3,
      netEarning: 120.7,
      assignedAt: DateTime.now().subtract(const Duration(hours: 2)),
      acceptedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
      pickedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 20)),
      pickupOTP: '1234',
      deliveryOTP: '5678',
      pickupOTPVerified: true,
    );

    _orders['DEL9002'] = DeliveryOrder(
      id: 'DEL9002',
      buyerOrderId: 'BO9002',
      partnerId: 'DP201',
      pickupLocation: 'Organic Store Mhow',
      pickupAddress: '789, Main Road, Mhow',
      pickupPhone: '9876543216',
      dropLocation: 'Customer Address',
      dropAddress: '101, Palasia, Indore',
      dropPhone: '9876543217',
      distance: 12.0,
      isCOD: false,
      paymentMode: 'Online',
      status: DeliveryStatus.pickedUp,
      baseFee: 50.0,
      distanceBonus: 96.0,
      surgeBonus: 0.0,
      totalEarning: 146.0,
      commission: 21.9,
      netEarning: 124.1,
      assignedAt: DateTime.now().subtract(const Duration(hours: 1)),
      acceptedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      pickedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      pickupOTP: '2468',
      deliveryOTP: '1357',
      pickupOTPVerified: true,
    );

    // Demo wallet transactions
    _transactions.add(DeliveryWalletTransaction(
      id: 'DWT001',
      partnerId: 'DP201',
      amount: 120.7,
      type: 'earning',
      description: 'Delivery earning for order DEL9001',
      date: DateTime.now().subtract(const Duration(hours: 1)),
      orderId: 'DEL9001',
    ));

    _transactions.add(DeliveryWalletTransaction(
      id: 'DWT002',
      partnerId: 'DP201',
      amount: 450.0,
      type: 'cod_collected',
      description: 'COD collected for order DEL9001',
      date: DateTime.now().subtract(const Duration(hours: 1)),
      orderId: 'DEL9001',
    ));

    _transactions.add(DeliveryWalletTransaction(
      id: 'DWT003',
      partnerId: 'DP201',
      amount: 500.0,
      type: 'incentive',
      description: 'Daily target bonus - 20 deliveries',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ));

    // Demo incentive
    _incentives.add(DeliveryIncentive(
      id: 'INC001',
      partnerId: 'DP201',
      type: 'daily_target',
      amount: 500.0,
      description: 'Completed 20 deliveries today',
      earnedDate: DateTime.now().subtract(const Duration(days: 1)),
      claimed: true,
    ));

    // Demo COD settlement
    _codSettlements['COD001'] = CODSettlement(
      id: 'COD001',
      partnerId: 'DP201',
      totalCollected: 1250.0,
      pending: 1250.0,
      collectionDate: DateTime.now(),
      status: 'pending',
      orderIds: ['DEL9001'],
    );

    // Demo notification
    _notifications.add(DeliveryNotification(
      id: 'DN001',
      partnerId: 'DP201',
      title: 'New Delivery Assigned',
      message: 'You have a new delivery from Vijay Nagar to Sudama Nagar',
      type: 'new_order',
      date: DateTime.now().subtract(const Duration(minutes: 30)),
      orderId: 'DEL9001',
    ));
  }

  // ============ AUTHENTICATION ============

  Future<DeliveryPartner?> login(String mobile, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final partner = _partners.values.where((p) => p.mobile == mobile).firstOrNull;
    if (partner != null) {
      _currentPartnerId = partner.id;
    }
    return partner;
  }

  Future<bool> register(DeliveryPartner partner) async {
    await Future.delayed(const Duration(seconds: 1));
    _partners[partner.id] = partner;
    _currentPartnerId = partner.id;
    _addNotification(
      partner.id,
      'Registration Successful',
      'Your application is under review. We will notify you once approved.',
      'subscription',
    );
    return true;
  }

  DeliveryPartner? getCurrentPartner() {
    return _currentPartnerId != null ? _partners[_currentPartnerId] : null;
  }

  void logout() => _currentPartnerId = null;

  // ============ PARTNER MANAGEMENT ============

  List<DeliveryPartner> getAllPartners() => _partners.values.toList();

  DeliveryPartner? getPartner(String id) => _partners[id];

  void updatePartner(DeliveryPartner partner) {
    _partners[partner.id] = partner;
  }

  void toggleOnlineStatus(String partnerId) {
    final partner = _partners[partnerId];
    if (partner != null) {
      _partners[partnerId] = partner.copyWith(isOnline: !partner.isOnline);
    }
  }

  // ============ ADMIN - APPROVAL ============

  Future<bool> approvePartner(String partnerId) async {
    await Future.delayed(const Duration(seconds: 1));
    final partner = _partners[partnerId];
    if (partner == null) return false;

    _partners[partnerId] = partner.copyWith(
      status: DeliveryPartnerStatus.approved,
      approvedDate: DateTime.now(),
    );

    _addNotification(
      partnerId,
      'Application Approved!',
      'Congratulations! Your delivery partner application has been approved. You can now start accepting deliveries.',
      'subscription',
    );
    return true;
  }

  Future<bool> rejectPartner(String partnerId, String reason) async {
    await Future.delayed(const Duration(seconds: 1));
    final partner = _partners[partnerId];
    if (partner == null) return false;

    _partners[partnerId] = partner.copyWith(
      status: DeliveryPartnerStatus.rejected,
      rejectionReason: reason,
    );

    _addNotification(
      partnerId,
      'Application Rejected',
      'Your application has been rejected. Reason: $reason',
      'subscription',
    );
    return true;
  }

  void blockPartner(String partnerId) {
    final partner = _partners[partnerId];
    if (partner != null) {
      _partners[partnerId] = partner.copyWith(status: DeliveryPartnerStatus.blocked);
    }
  }

  // ============ ORDER MANAGEMENT ============

  List<DeliveryOrder> getPartnerOrders(String partnerId, {DeliveryStatus? status}) {
    var orders = _orders.values.where((o) => o.partnerId == partnerId);
    if (status != null) orders = orders.where((o) => o.status == status);
    return orders.toList()..sort((a, b) => b.assignedAt.compareTo(a.assignedAt));
  }

  List<DeliveryOrder> getActiveOrders(String partnerId) {
    return _orders.values.where((o) =>
      o.partnerId == partnerId &&
      o.status != DeliveryStatus.completed &&
      o.status != DeliveryStatus.rejected &&
      o.status != DeliveryStatus.cancelled
    ).toList();
  }

  List<DeliveryOrder> getCompletedOrders(String partnerId) {
    return _orders.values.where((o) =>
      o.partnerId == partnerId && o.status == DeliveryStatus.completed
    ).toList();
  }

  DeliveryOrder? getOrder(String orderId) => _orders[orderId];

  // ============ ORDER ASSIGNMENT (Auto) ============

  String? assignDelivery({
    required String buyerOrderId,
    required String pickupLocation,
    required String pickupAddress,
    required String pickupPhone,
    required String dropLocation,
    required String dropAddress,
    required String dropPhone,
    required double distance,
    required bool isCOD,
    required double codAmount,
    required String paymentMode,
  }) {
    // Find nearest available partner
   final availablePartners = _partners.values.where((p) =>
      p.status == DeliveryPartnerStatus.active &&
      p.isOnline &&
      p.activeOrders < 10 && // Max capacity
      p.rating >= 4.0 && // Min rating
      p.acceptanceRate >= 70 // Min acceptance rate
    ).toList();

    if (availablePartners.isEmpty) return null;

    // Sort by rating and distance (simulated)
    availablePartners.sort((a, b) => b.rating.compareTo(a.rating));
    final partner = availablePartners.first;

    // Calculate earnings
    final baseFee = _baseFee;
    final distanceBonus = distance * _distanceBonusPerKM;
    final codFee = isCOD ? (codAmount * _codFeePercent / 100) : 0.0;
    final surgeBonus = _surgeMultiplier > 1.0 ? ((baseFee + distanceBonus) * (_surgeMultiplier - 1.0)) : 0.0;
    final totalEarning = baseFee + distanceBonus + codFee + surgeBonus;
    final commission = totalEarning * _commissionPercent / 100;
    final netEarning = totalEarning - commission;

    final orderId = 'DEL${DateTime.now().millisecondsSinceEpoch}';
    final order = DeliveryOrder(
      id: orderId,
      buyerOrderId: buyerOrderId,
      partnerId: partner.id,
      pickupLocation: pickupLocation,
      pickupAddress: pickupAddress,
      pickupPhone: pickupPhone,
      dropLocation: dropLocation,
      dropAddress: dropAddress,
      dropPhone: dropPhone,
      distance: distance,
      isCOD: isCOD,
      codAmount: codAmount,
      paymentMode: paymentMode,
      baseFee: baseFee,
      distanceBonus: distanceBonus,
      codFee: codFee,
      surgeBonus: surgeBonus,
      totalEarning: totalEarning,
      commission: commission,
      netEarning: netEarning,
      assignedAt: DateTime.now(),
      pickupOTP: _generateOTP(),
      deliveryOTP: _generateOTP(),
    );

    _orders[orderId] = order;
    _partners[partner.id] = partner.copyWith(activeOrders: partner.activeOrders + 1);

    _addNotification(
      partner.id,
      'New Delivery Assigned',
      'Pickup: $pickupLocation → Drop: $dropLocation. Earn ₹${netEarning.toInt()}',
      'new_order',
      orderId: orderId,
    );

    return orderId;
  }

  // ============ ORDER ACTIONS ============

  Future<bool> acceptOrder(String orderId) async {
    await Future.delayed(const Duration(seconds: 1));
    final order = _orders[orderId];
    if (order == null) return false;

    _orders[orderId] = order.copyWith(
      status: DeliveryStatus.accepted,
      acceptedAt: DateTime.now(),
    );

    final partner = _partners[order.partnerId];
    if (partner != null) {
      final newAcceptanceRate = ((partner.acceptanceRate * partner.totalDeliveries) + 100) ~/ (partner.totalDeliveries + 1);
      _partners[order.partnerId] = partner.copyWith(acceptanceRate: newAcceptanceRate);
    }

    return true;
  }

  Future<bool> rejectOrder(String orderId, String reason) async {
    await Future.delayed(const Duration(seconds: 1));
    final order = _orders[orderId];
    if (order == null) return false;

    _orders[orderId] = order.copyWith(
      status: DeliveryStatus.rejected,
      rejectionReason: reason,
    );

    final partner = _partners[order.partnerId];
    if (partner != null) {
      final newAcceptanceRate = ((partner.acceptanceRate * partner.totalDeliveries)) ~/ (partner.totalDeliveries + 1);
      final newCancellationRate = ((partner.cancellationRate * partner.totalDeliveries) + 100) ~/ (partner.totalDeliveries + 1);
      _partners[order.partnerId] = partner.copyWith(
        activeOrders: partner.activeOrders - 1,
        acceptanceRate: newAcceptanceRate,
        cancellationRate: newCancellationRate,
      );
    }

    // Try to reassign
    // (In production, this would trigger auto-assignment to next partner)

    return true;
  }

  Future<bool> updateOrderStatus(String orderId, DeliveryStatus newStatus, {String? otp}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final order = _orders[orderId];
    if (order == null) return false;

    // OTP verification for pickup/delivery
    if (newStatus == DeliveryStatus.pickedUp) {
      if (otp != order.pickupOTP) return false;
      _orders[orderId] = order.copyWith(
        status: newStatus,
        pickedAt: DateTime.now(),
        pickupOTPVerified: true,
      );
    } else if (newStatus == DeliveryStatus.delivered) {
      if (otp != order.deliveryOTP) return false;
      _orders[orderId] = order.copyWith(
        status: newStatus,
        deliveredAt: DateTime.now(),
        deliveryOTPVerified: true,
      );
      _completeDelivery(orderId);
    } else {
      _orders[orderId] = order.copyWith(status: newStatus);
    }

    return true;
  }

  void _completeDelivery(String orderId) {
    final order = _orders[orderId];
    if (order == null) return;

    _orders[orderId] = order.copyWith(
      status: DeliveryStatus.completed,
      completedAt: DateTime.now(),
    );

    final partner = _partners[order.partnerId];
    if (partner == null) return;

    // Update partner stats
    final newTotalDeliveries = partner.totalDeliveries + 1;
    final newOnTimeRate = 95; // Simulated
    _partners[order.partnerId] = partner.copyWith(
      totalDeliveries: newTotalDeliveries,
      onTimeRate: newOnTimeRate,
      activeOrders: partner.activeOrders - 1,
      todayEarnings: partner.todayEarnings + order.netEarning,
      monthEarnings: partner.monthEarnings + order.netEarning,
    );

    // Add wallet transaction
    _transactions.add(DeliveryWalletTransaction(
      id: 'DWT${DateTime.now().millisecondsSinceEpoch}',
      partnerId: order.partnerId,
      amount: order.netEarning,
      type: 'earning',
      description: 'Delivery earning for order ${order.id}',
      date: DateTime.now(),
      orderId: order.id,
    ));

    // COD handling
    if (order.isCOD) {
      _transactions.add(DeliveryWalletTransaction(
        id: 'DWT${DateTime.now().millisecondsSinceEpoch}_COD',
        partnerId: order.partnerId,
        amount: order.codAmount,
        type: 'cod_collected',
        description: 'COD collected for order ${order.id}',
        date: DateTime.now(),
        orderId: order.id,
      ));
    }

    // Check daily target incentive
    final todayDeliveries = getCompletedOrders(order.partnerId).where((o) {
      final deliveredDate = o.deliveredAt ?? o.completedAt;
      return deliveredDate != null && 
             deliveredDate.year == DateTime.now().year &&
             deliveredDate.month == DateTime.now().month &&
             deliveredDate.day == DateTime.now().day;
    }).length;

    if (todayDeliveries == _dailyTargetDeliveries) {
      _incentives.add(DeliveryIncentive(
        id: 'INC${DateTime.now().millisecondsSinceEpoch}',
        partnerId: order.partnerId,
        type: 'daily_target',
        amount: _dailyTargetBonus,
        description: 'Completed $_dailyTargetDeliveries deliveries today',
        earnedDate: DateTime.now(),
      ));

      _addNotification(
        order.partnerId,
        'Target Achieved! 🎉',
        'Congratulations! You earned ₹$_dailyTargetBonus daily target bonus',
        'target_achieved',
      );
    }

    _addNotification(
      order.partnerId,
      'Delivery Completed',
      'You earned ₹${order.netEarning.toInt()} for order ${order.id}',
      'new_order',
      orderId: order.id,
    );
  }

  // ============ WALLET & EARNINGS ============

  List<DeliveryWalletTransaction> getWalletTransactions(String partnerId) {
    return _transactions.where((t) => t.partnerId == partnerId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double getWalletBalance(String partnerId) {
    return _transactions.where((t) => t.partnerId == partnerId).fold(0.0, (sum, t) {
      if (t.type == 'earning' || t.type == 'incentive') return sum + t.amount;
      if (t.type == 'withdrawal' || t.type == 'commission') return sum - t.amount;
      return sum;
    });
  }

  double getCODPending(String partnerId) {
    return _transactions.where((t) => t.partnerId == partnerId && t.type == 'cod_collected').fold(0.0, (sum, t) => sum + t.amount) -
           _transactions.where((t) => t.partnerId == partnerId && t.type == 'cod_settled').fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<bool> withdrawBalance(String partnerId, double amount) async {
    await Future.delayed(const Duration(seconds: 1));
    final balance = getWalletBalance(partnerId);
    if (amount > balance) return false;

    _transactions.add(DeliveryWalletTransaction(
      id: 'DWT${DateTime.now().millisecondsSinceEpoch}',
      partnerId: partnerId,
      amount: amount,
      type: 'withdrawal',
      description: 'Withdrawal to bank account',
      date: DateTime.now(),
    ));

    return true;
  }

  // ============ INCENTIVES ============

  List<DeliveryIncentive> getIncentives(String partnerId) {
    return _incentives.where((i) => i.partnerId == partnerId).toList()
      ..sort((a, b) => b.earnedDate.compareTo(a.earnedDate));
  }

  double getTotalIncentivesEarned(String partnerId) {
    return _incentives.where((i) => i.partnerId == partnerId).fold(0.0, (sum, i) => sum + i.amount);
  }

  // ============ NOTIFICATIONS ============

  List<DeliveryNotification> getNotifications(String partnerId) {
    return _notifications.where((n) => n.partnerId == partnerId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  int getUnreadCount(String partnerId) {
    return _notifications.where((n) => n.partnerId == partnerId && !n.isRead).length;
  }

  void markNotificationRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  void markAllRead(String partnerId) {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].partnerId == partnerId && !_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
  }

  void _addNotification(String partnerId, String title, String message, String type, {String? orderId}) {
    _notifications.add(DeliveryNotification(
      id: 'DN${DateTime.now().millisecondsSinceEpoch}',
      partnerId: partnerId,
      title: title,
      message: message,
      type: type,
      date: DateTime.now(),
      orderId: orderId,
    ));
  }

  // ============ ANALYTICS ============

  Map<String, dynamic> getPartnerAnalytics(String partnerId, {DateTime? startDate, DateTime? endDate}) {
    final orders = getCompletedOrders(partnerId);
    final filteredOrders = orders.where((o) {
      final date = o.deliveredAt ?? o.completedAt;
      if (date == null) return false;
      if (startDate != null && date.isBefore(startDate)) return false;
      if (endDate != null && date.isAfter(endDate)) return false;
      return true;
    }).toList();

    final totalEarnings = filteredOrders.fold(0.0, (sum, o) => sum + o.netEarning);
    final avgEarning = filteredOrders.isNotEmpty ? totalEarnings / filteredOrders.length : 0.0;
    final avgDistance = filteredOrders.isNotEmpty
        ? filteredOrders.fold(0.0, (sum, o) => sum + o.distance) / filteredOrders.length
        : 0.0;

    return {
      'totalDeliveries': filteredOrders.length,
      'totalEarnings': totalEarnings,
      'avgEarning': avgEarning,
      'avgDistance': avgDistance,
      'codOrders': filteredOrders.where((o) => o.isCOD).length,
      'onlineOrders': filteredOrders.where((o) => !o.isCOD).length,
    };
  }

  // ============ ADMIN - SETTINGS ============

  void updateCommissionPercent(double percent) => _commissionPercent = percent;
  void updateBaseFee(double fee) => _baseFee = fee;
  void updateDistanceBonus(double bonus) => _distanceBonusPerKM = bonus;
  void updateSurgeMultiplier(double multiplier) => _surgeMultiplier = multiplier;
  void updateDailyTarget(int target, double bonus) {
    _dailyTargetDeliveries = target;
    _dailyTargetBonus = bonus;
  }

  double get commissionPercent => _commissionPercent;
  double get baseFee => _baseFee;
  double get surgeMultiplier => _surgeMultiplier;
  int get dailyTargetDeliveries => _dailyTargetDeliveries;
  double get dailyTargetBonus => _dailyTargetBonus;

  // ============ HELPER ============

  String _generateOTP() {
    return (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
  }
}
