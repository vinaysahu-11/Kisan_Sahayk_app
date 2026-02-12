// Agriculture Buyer Module Models

// ============ BUYER ============

class BuyerAddress {
  final String id;
  final String name;
  final String mobile;
  final String addressLine;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  BuyerAddress({
    required this.id,
    required this.name,
    required this.mobile,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  BuyerAddress copyWith({
    String? id,
    String? name,
    String? mobile,
    String? addressLine,
    String? city,
    String? state,
    String? pincode,
    bool? isDefault,
  }) {
    return BuyerAddress(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get fullAddress => '$addressLine, $city, $state - $pincode';
}

// ============ CART ============

class CartItem {
  final String productId;
  int quantity;

  CartItem({required this.productId, required this.quantity});
}

// ============ BUYER ORDER ============

enum BuyerOrderStatus {
  placed,
  accepted,
  packed,
  shipped,
  outForDelivery,
  delivered,
  completed, // after COD cash paid
  cancelled,
  returned,
}

class BuyerOrder {
  final String id;
  final String buyerId;
  final String sellerId;
  final String productId;
  final String productName;
  final String sellerName;
  final int quantity;
  final double productPrice;
  final double subtotal;
  final double deliveryFee;
  final double codCharge;
  final double platformFee;
  final double walletUsed;
  final double totalAmount;
  final String paymentMode; // 'online' or 'cod'
  final BuyerOrderStatus status;
  final String? addressId;
  final DateTime orderDate;
  final DateTime? acceptedDate;
  final DateTime? packedDate;
  final DateTime? shippedDate;
  final DateTime? deliveredDate;
  final DateTime? cancelledDate;
  final String? cancellationReason;
  final bool isRated;
  final String? escrowId;
  final bool escrowReleased;

  BuyerOrder({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required this.productName,
    required this.sellerName,
    required this.quantity,
    required this.productPrice,
    required this.subtotal,
    this.deliveryFee = 0,
    this.codCharge = 0,
    this.platformFee = 0,
    this.walletUsed = 0,
    required this.totalAmount,
    required this.paymentMode,
    required this.status,
    this.addressId,
    required this.orderDate,
    this.acceptedDate,
    this.packedDate,
    this.shippedDate,
    this.deliveredDate,
    this.cancelledDate,
    this.cancellationReason,
    this.isRated = false,
    this.escrowId,
    this.escrowReleased = false,
  });

  BuyerOrder copyWith({
    String? id,
    String? buyerId,
    String? sellerId,
    String? productId,
    String? productName,
    String? sellerName,
    int? quantity,
    double? productPrice,
    double? subtotal,
    double? deliveryFee,
    double? codCharge,
    double? platformFee,
    double? walletUsed,
    double? totalAmount,
    String? paymentMode,
    BuyerOrderStatus? status,
    String? addressId,
    DateTime? orderDate,
    DateTime? acceptedDate,
    DateTime? packedDate,
    DateTime? shippedDate,
    DateTime? deliveredDate,
    DateTime? cancelledDate,
    String? cancellationReason,
    bool? isRated,
    String? escrowId,
    bool? escrowReleased,
  }) {
    return BuyerOrder(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sellerName: sellerName ?? this.sellerName,
      quantity: quantity ?? this.quantity,
      productPrice: productPrice ?? this.productPrice,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      codCharge: codCharge ?? this.codCharge,
      platformFee: platformFee ?? this.platformFee,
      walletUsed: walletUsed ?? this.walletUsed,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      status: status ?? this.status,
      addressId: addressId ?? this.addressId,
      orderDate: orderDate ?? this.orderDate,
      acceptedDate: acceptedDate ?? this.acceptedDate,
      packedDate: packedDate ?? this.packedDate,
      shippedDate: shippedDate ?? this.shippedDate,
      deliveredDate: deliveredDate ?? this.deliveredDate,
      cancelledDate: cancelledDate ?? this.cancelledDate,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      isRated: isRated ?? this.isRated,
      escrowId: escrowId ?? this.escrowId,
      escrowReleased: escrowReleased ?? this.escrowReleased,
    );
  }
}

// ============ RATING ============

class ProductRating {
  final String id;
  final String orderId;
  final String productId;
  final String sellerId;
  final String buyerId;
  final int productRating; // 1-5
  final int sellerRating; // 1-5
  final String? review;
  final DateTime date;

  ProductRating({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.sellerId,
    required this.buyerId,
    required this.productRating,
    required this.sellerRating,
    this.review,
    required this.date,
  });
}

// ============ RETURN / DISPUTE ============

enum DisputeStatus { raised, underReview, resolved, rejected }

class ReturnRequest {
  final String id;
  final String orderId;
  final String buyerId;
  final String reason;
  final String? details;
  final DisputeStatus status;
  final DateTime raisedDate;
  final DateTime? resolvedDate;
  final String? resolution;

  ReturnRequest({
    required this.id,
    required this.orderId,
    required this.buyerId,
    required this.reason,
    this.details,
    required this.status,
    required this.raisedDate,
    this.resolvedDate,
    this.resolution,
  });

  ReturnRequest copyWith({
    String? id,
    String? orderId,
    String? buyerId,
    String? reason,
    String? details,
    DisputeStatus? status,
    DateTime? raisedDate,
    DateTime? resolvedDate,
    String? resolution,
  }) {
    return ReturnRequest(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      buyerId: buyerId ?? this.buyerId,
      reason: reason ?? this.reason,
      details: details ?? this.details,
      status: status ?? this.status,
      raisedDate: raisedDate ?? this.raisedDate,
      resolvedDate: resolvedDate ?? this.resolvedDate,
      resolution: resolution ?? this.resolution,
    );
  }
}

// ============ BUYER WALLET ============

class BuyerWalletTransaction {
  final String id;
  final String buyerId;
  final double amount;
  final String type; // 'refund', 'cashback', 'used', 'credit'
  final String description;
  final DateTime date;
  final String? orderId;

  BuyerWalletTransaction({
    required this.id,
    required this.buyerId,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    this.orderId,
  });
}

// ============ BUYER NOTIFICATION ============

class BuyerNotification {
  final String id;
  final String buyerId;
  final String title;
  final String message;
  final String type; // 'order', 'refund', 'promo', 'delivery'
  final DateTime date;
  final bool isRead;
  final String? orderId;

  BuyerNotification({
    required this.id,
    required this.buyerId,
    required this.title,
    required this.message,
    required this.type,
    required this.date,
    this.isRead = false,
    this.orderId,
  });

  BuyerNotification copyWith({bool? isRead}) {
    return BuyerNotification(
      id: id,
      buyerId: buyerId,
      title: title,
      message: message,
      type: type,
      date: date,
      isRead: isRead ?? this.isRead,
      orderId: orderId,
    );
  }
}

// ============ ESCROW ============

class EscrowTransaction {
  final String id;
  final String orderId;
  final double amount;
  final String status; // 'held', 'released', 'refunded'
  final DateTime createdDate;
  final DateTime? releasedDate;

  EscrowTransaction({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.createdDate,
    this.releasedDate,
  });
}
