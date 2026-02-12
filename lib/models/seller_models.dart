// Agriculture Seller Module Models

// Enums
enum SellerType { farmer, shop, mill, individual }

enum SellerLevel { basic, bigSeller }

enum KYCStatus { pending, approved, rejected, notSubmitted }

enum SubscriptionType { monthly, quarterly, yearly }

enum SubscriptionStatus { active, expired, cancelled }

enum PaymentMode { online, cod, wallet }

enum OrderStatus {
  placed,
  accepted,
  packed,
  shipped,
  delivered,
  completed,
  cancelled,
  rejected
}

enum ProductCondition { new_, used, refurbished }

// Seller Model
class Seller {
  final String id;
  final String name;
  final String mobile;
  final SellerType type;
  final String location;
  final String? profilePhoto;
  final SellerLevel level;
  final double commissionRate;
  final double walletBalance;
  final double pendingSettlement;
  final KYCStatus kycStatus;
  final DateTime registeredDate;
  final bool isActive;
  final SubscriptionStatus? subscriptionStatus;
  final DateTime? subscriptionExpiry;

  Seller({
    required this.id,
    required this.name,
    required this.mobile,
    required this.type,
    required this.location,
    this.profilePhoto,
    required this.level,
    required this.commissionRate,
    required this.walletBalance,
    required this.pendingSettlement,
    required this.kycStatus,
    required this.registeredDate,
    required this.isActive,
    this.subscriptionStatus,
    this.subscriptionExpiry,
  });

  Seller copyWith({
    String? id,
    String? name,
    String? mobile,
    SellerType? type,
    String? location,
    String? profilePhoto,
    SellerLevel? level,
    double? commissionRate,
    double? walletBalance,
    double? pendingSettlement,
    KYCStatus? kycStatus,
    DateTime? registeredDate,
    bool? isActive,
    SubscriptionStatus? subscriptionStatus,
    DateTime? subscriptionExpiry,
  }) {
    return Seller(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      type: type ?? this.type,
      location: location ?? this.location,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      level: level ?? this.level,
      commissionRate: commissionRate ?? this.commissionRate,
      walletBalance: walletBalance ?? this.walletBalance,
      pendingSettlement: pendingSettlement ?? this.pendingSettlement,
      kycStatus: kycStatus ?? this.kycStatus,
      registeredDate: registeredDate ?? this.registeredDate,
      isActive: isActive ?? this.isActive,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
    );
  }
}

// KYC Document Model
class KYCDocument {
  final String sellerId;
  final String? aadhaarNumber;
  final String? panNumber;
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? aadhaarPhoto;
  final String? panPhoto;
  final String? bankProof;
  final DateTime submittedDate;
  final KYCStatus status;
  final String? rejectionReason;

  KYCDocument({
    required this.sellerId,
    this.aadhaarNumber,
    this.panNumber,
    this.bankAccountNumber,
    this.ifscCode,
    this.aadhaarPhoto,
    this.panPhoto,
    this.bankProof,
    required this.submittedDate,
    required this.status,
    this.rejectionReason,
  });
}

// Category Model (Unlimited Nesting)
class AgriCategory {
  final String id;
  final String name;
  final String? parentId;
  final double commissionPercent;
  final bool isEnabled;
  final List<String> subcategoryIds;
  final Map<String, List<String>>? dynamicFields; // Field groups for this category

  AgriCategory({
    required this.id,
    required this.name,
    this.parentId,
    required this.commissionPercent,
    required this.isEnabled,
    this.subcategoryIds = const [],
    this.dynamicFields,
  });

  AgriCategory copyWith({
    String? id,
    String? name,
    String? parentId,
    double? commissionPercent,
    bool? isEnabled,
    List<String>? subcategoryIds,
    Map<String, List<String>>? dynamicFields,
  }) {
    return AgriCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      commissionPercent: commissionPercent ?? this.commissionPercent,
      isEnabled: isEnabled ?? this.isEnabled,
      subcategoryIds: subcategoryIds ?? this.subcategoryIds,
      dynamicFields: dynamicFields ?? this.dynamicFields,
    );
  }
}

// Product Model
class AgriProduct {
  final String id;
  final String sellerId;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String unit; // kg, ton, piece, liter, etc.
  final int moq; // Minimum Order Quantity
  final List<String> images;
  final String location;
  final bool codEnabled;
  final bool selfPickup;
  final bool sellerDelivery;
  final Map<String, dynamic> dynamicFields; // Category specific fields
  final DateTime listedDate;
  final bool isActive;
  final int viewCount;
  final int orderCount;

  AgriProduct({
    required this.id,
    required this.sellerId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.unit,
    required this.moq,
    required this.images,
    required this.location,
    required this.codEnabled,
    required this.selfPickup,
    required this.sellerDelivery,
    required this.dynamicFields,
    required this.listedDate,
    required this.isActive,
    this.viewCount = 0,
    this.orderCount = 0,
  });

  AgriProduct copyWith({
    String? id,
    String? sellerId,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? unit,
    int? moq,
    List<String>? images,
    String? location,
    bool? codEnabled,
    bool? selfPickup,
    bool? sellerDelivery,
    Map<String, dynamic>? dynamicFields,
    DateTime? listedDate,
    bool? isActive,
    int? viewCount,
    int? orderCount,
  }) {
    return AgriProduct(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      moq: moq ?? this.moq,
      images: images ?? this.images,
      location: location ?? this.location,
      codEnabled: codEnabled ?? this.codEnabled,
      selfPickup: selfPickup ?? this.selfPickup,
      sellerDelivery: sellerDelivery ?? this.sellerDelivery,
      dynamicFields: dynamicFields ?? this.dynamicFields,
      listedDate: listedDate ?? this.listedDate,
      isActive: isActive ?? this.isActive,
      viewCount: viewCount ?? this.viewCount,
      orderCount: orderCount ?? this.orderCount,
    );
  }
}

// Order Model
class SellerOrder {
  final String id;
  final String productId;
  final String sellerId;
  final String buyerId;
  final int quantity;
  final double totalAmount;
  final double commission;
  final double netEarnings;
  final PaymentMode paymentMode;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime? acceptedDate;
  final DateTime? shippedDate;
  final DateTime? deliveredDate;
  final bool codCollected;
  final String? cancellationReason;

  SellerOrder({
    required this.id,
    required this.productId,
    required this.sellerId,
    required this.buyerId,
    required this.quantity,
    required this.totalAmount,
    required this.commission,
    required this.netEarnings,
    required this.paymentMode,
    required this.status,
    required this.orderDate,
    this.acceptedDate,
    this.shippedDate,
    this.deliveredDate,
    this.codCollected = false,
    this.cancellationReason,
  });

  SellerOrder copyWith({
    String? id,
    String? productId,
    String? sellerId,
    String? buyerId,
    int? quantity,
    double? totalAmount,
    double? commission,
    double? netEarnings,
    PaymentMode? paymentMode,
    OrderStatus? status,
    DateTime? orderDate,
    DateTime? acceptedDate,
    DateTime? shippedDate,
    DateTime? deliveredDate,
    bool? codCollected,
    String? cancellationReason,
  }) {
    return SellerOrder(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      sellerId: sellerId ?? this.sellerId,
      buyerId: buyerId ?? this.buyerId,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
      commission: commission ?? this.commission,
      netEarnings: netEarnings ?? this.netEarnings,
      paymentMode: paymentMode ?? this.paymentMode,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      acceptedDate: acceptedDate ?? this.acceptedDate,
      shippedDate: shippedDate ?? this.shippedDate,
      deliveredDate: deliveredDate ?? this.deliveredDate,
      codCollected: codCollected ?? this.codCollected,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}

// Wallet Transaction Model
class SellerWalletTransaction {
  final String id;
  final String sellerId;
  final double amount;
  final String type; // credit, debit, commission, settlement, withdrawal
  final String description;
  final DateTime date;
  final String? orderId;

  SellerWalletTransaction({
    required this.id,
    required this.sellerId,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    this.orderId,
  });
}

// Subscription Plan Model
class SubscriptionPlan {
  final String id;
  final String name;
  final SubscriptionType type;
  final double price;
  final int durationDays;
  final double commissionRate;
  final List<String> benefits;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.durationDays,
    required this.commissionRate,
    required this.benefits,
  });
}

// Seller Analytics Model
class SellerAnalytics {
  final String sellerId;
  final double totalRevenue;
  final int totalOrders;
  final int activeListings;
  final int outOfStockItems;
  final int lowStockItems;
  final double commissionPaid;
  final Map<String, double> monthlySales; // Month -> Revenue
  final Map<String, int> topProducts; // ProductId -> Order count
  final Map<String, double> categoryPerformance; // CategoryId -> Revenue

  SellerAnalytics({
    required this.sellerId,
    required this.totalRevenue,
    required this.totalOrders,
    required this.activeListings,
    required this.outOfStockItems,
    required this.lowStockItems,
    required this.commissionPaid,
    required this.monthlySales,
    required this.topProducts,
    required this.categoryPerformance,
  });
}

// Notification Model
class SellerNotification {
  final String id;
  final String sellerId;
  final String title;
  final String message;
  final String type; // order, subscription, kyc, stock
  final DateTime date;
  final bool isRead;
  final String? orderId;

  SellerNotification({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.message,
    required this.type,
    required this.date,
    required this.isRead,
    this.orderId,
  });

  SellerNotification copyWith({
    String? id,
    String? sellerId,
    String? title,
    String? message,
    String? type,
    DateTime? date,
    bool? isRead,
    String? orderId,
  }) {
    return SellerNotification(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
      orderId: orderId ?? this.orderId,
    );
  }
}
