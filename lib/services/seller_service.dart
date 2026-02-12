import 'dart:async';
import '../models/seller_models.dart';

class SellerService {
  static final SellerService _instance = SellerService._internal();
  factory SellerService() => _instance;
  SellerService._internal() {
    _initializeData();
  }

  // Storage
  final Map<String, Seller> _sellers = {};
  final Map<String, AgriProduct> _products = {};
  final Map<String, SellerOrder> _orders = {};
  final Map<String, AgriCategory> _categories = {};
  final Map<String, KYCDocument> _kycDocuments = {};
  final Map<String, SubscriptionPlan> _subscriptionPlans = {};
  final List<SellerWalletTransaction> _transactions = [];
  final List<SellerNotification> _notifications = [];

  // Current logged in seller
  String? _currentSellerId;

  // Stream controllers
  final _sellerUpdateController = StreamController<Seller>.broadcast();
  final _orderUpdateController = StreamController<SellerOrder>.broadcast();
  final _notificationController = StreamController<SellerNotification>.broadcast();

  Stream<Seller> get sellerUpdates => _sellerUpdateController.stream;
  Stream<SellerOrder> get orderUpdates => _orderUpdateController.stream;
  Stream<SellerNotification> get notificationUpdates => _notificationController.stream;

  void _initializeData() {
    // Initialize default categories
    _initializeCategories();
    // Initialize subscription plans
    _initializeSubscriptionPlans();
    // Initialize demo seller
    _initializeDemoSeller();
    // Initialize demo products
    _initializeDemoProducts();
    // Initialize demo orders
    _initializeDemoOrders();
  }

  void _initializeCategories() {
    final defaultCategories = [
      AgriCategory(
        id: 'CAT001',
        name: 'Crops',
        commissionPercent: 2.5,
        isEnabled: true,
        dynamicFields: {
          'details': ['Grade', 'Moisture %', 'Harvest Date']
        },
      ),
      AgriCategory(
        id: 'CAT002',
        name: 'Fruits',
        commissionPercent: 3.0,
        isEnabled: true,
        dynamicFields: {
          'details': ['Variety', 'Ripeness', 'Origin']
        },
      ),
      AgriCategory(
        id: 'CAT003',
        name: 'Vegetables',
        commissionPercent: 3.0,
        isEnabled: true,
        dynamicFields: {
          'details': ['Freshness', 'Organic', 'Harvest Date']
        },
      ),
      AgriCategory(
        id: 'CAT004',
        name: 'Seeds',
        commissionPercent: 2.0,
        isEnabled: true,
        dynamicFields: {
          'details': ['Variety', 'Germination %', 'Certification']
        },
      ),
      AgriCategory(
        id: 'CAT005',
        name: 'Fertilizers',
        commissionPercent: 2.5,
        isEnabled: true,
        dynamicFields: {
          'details': ['Type', 'NPK Ratio', 'Weight per bag']
        },
      ),
      AgriCategory(
        id: 'CAT006',
        name: 'Pesticides',
        commissionPercent: 2.5,
        isEnabled: true,
        dynamicFields: {
          'details': ['Type', 'Active Ingredient', 'Dosage']
        },
      ),
      AgriCategory(
        id: 'CAT007',
        name: 'Equipment',
        commissionPercent: 3.5,
        isEnabled: true,
        dynamicFields: {
          'details': ['Condition', 'Brand', 'Year', 'Warranty']
        },
      ),
      AgriCategory(
        id: 'CAT008',
        name: 'Livestock',
        commissionPercent: 4.0,
        isEnabled: true,
        dynamicFields: {
          'details': ['Age', 'Weight', 'Breed', 'Health Certificate']
        },
      ),
      AgriCategory(
        id: 'CAT009',
        name: 'Dairy',
        commissionPercent: 3.0,
        isEnabled: true,
        dynamicFields: {
          'details': ['Type', 'Fat %', 'Expiry Date']
        },
      ),
      AgriCategory(
        id: 'CAT010',
        name: 'Processed Goods',
        commissionPercent: 3.5,
        isEnabled: true,
        dynamicFields: {
          'details': ['Processing Type', 'Packaging', 'Shelf Life']
        },
      ),
      AgriCategory(
        id: 'CAT011',
        name: 'Organic Products',
        commissionPercent: 2.0,
        isEnabled: true,
        dynamicFields: {
          'details': ['Certification', 'Organic Grade']
        },
      ),
      AgriCategory(
        id: 'CAT012',
        name: 'Tools',
        commissionPercent: 3.0,
        isEnabled: true,
        dynamicFields: {
          'details': ['Type', 'Material', 'Condition']
        },
      ),
      AgriCategory(
        id: 'CAT013',
        name: 'Irrigation Systems',
        commissionPercent: 3.5,
        isEnabled: true,
        dynamicFields: {
          'details': ['Type', 'Coverage Area', 'Power Source']
        },
      ),
      AgriCategory(
        id: 'CAT014',
        name: 'Agro Chemicals',
        commissionPercent: 2.5,
        isEnabled: true,
        dynamicFields: {
          'details': ['Chemical Type', 'Concentration', 'Safety Rating']
        },
      ),
      AgriCategory(
        id: 'CAT015',
        name: 'Feed & Fodder',
        commissionPercent: 2.5,
        isEnabled: true,
        dynamicFields: {
          'details': ['Animal Type', 'Nutritional Value', 'Moisture']
        },
      ),
    ];

    for (var category in defaultCategories) {
      _categories[category.id] = category;
    }
  }

  void _initializeSubscriptionPlans() {
    _subscriptionPlans['SUB001'] = SubscriptionPlan(
      id: 'SUB001',
      name: 'Big Seller Monthly',
      type: SubscriptionType.monthly,
      price: 499,
      durationDays: 30,
      commissionRate: 1.5,
      benefits: [
        'Lower commission (1.5%)',
        'Priority listing',
        'Advanced analytics',
        'Verified badge',
        'Featured products',
      ],
    );

    _subscriptionPlans['SUB002'] = SubscriptionPlan(
      id: 'SUB002',
      name: 'Big Seller Quarterly',
      type: SubscriptionType.quarterly,
      price: 1299,
      durationDays: 90,
      commissionRate: 1.0,
      benefits: [
        'Lowest commission (1%)',
        'Top priority listing',
        'Advanced analytics',
        'Verified badge',
        'Featured products',
        '3 months validity',
        'Save ₹198',
      ],
    );

    _subscriptionPlans['SUB003'] = SubscriptionPlan(
      id: 'SUB003',
      name: 'Big Seller Yearly',
      type: SubscriptionType.yearly,
      price: 4999,
      durationDays: 365,
      commissionRate: 1.0,
      benefits: [
        'Lowest commission (1%)',
        'Top priority listing',
        'Advanced analytics',
        'Verified badge',
        'Featured products',
        '12 months validity',
        'Save ₹989',
        'Dedicated support',
      ],
    );
  }

  void _initializeDemoSeller() {
    final demoSeller = Seller(
      id: 'S1001',
      name: 'Ramesh Traders',
      mobile: '9876543210',
      type: SellerType.shop,
      location: 'Indore, Madhya Pradesh',
      level: SellerLevel.basic,
      commissionRate: 3.0,
      walletBalance: 15000,
      pendingSettlement: 2500,
      kycStatus: KYCStatus.approved,
      registeredDate: DateTime.now().subtract(const Duration(days: 90)),
      isActive: true,
    );
    _sellers[demoSeller.id] = demoSeller;
    _currentSellerId = demoSeller.id;
  }

  void _initializeDemoProducts() {
    final products = [
      AgriProduct(
        id: 'P501',
        sellerId: 'S1001',
        categoryId: 'CAT004',
        name: 'Hybrid Paddy Seed',
        description: 'High yield hybrid paddy seeds with 85% germination rate. Suitable for Kharif season in all soil types.',
        price: 2200,
        stock: 100,
        unit: 'kg',
        moq: 5,
        images: ['seed1.jpg'],
        location: 'Indore, MP',
        codEnabled: true,
        selfPickup: true,
        sellerDelivery: true,
        dynamicFields: {
          'Variety': 'IR64',
          'Germination %': '85',
          'Certification': 'Yes'
        },
        listedDate: DateTime.now().subtract(const Duration(days: 10)),
        isActive: true,
        viewCount: 145,
        orderCount: 28,
      ),
      AgriProduct(
        id: 'P502',
        sellerId: 'S1001',
        categoryId: 'CAT005',
        name: 'Organic Fertilizer',
        description: 'Premium quality organic fertilizer for all crops. Rich in NPK and micronutrients.',
        price: 850,
        stock: 200,
        unit: 'kg',
        moq: 10,
        images: ['fertilizer1.jpg'],
        location: 'Indore, MP',
        codEnabled: true,
        selfPickup: true,
        sellerDelivery: false,
        dynamicFields: {
          'Type': 'Organic',
          'NPK Ratio': '10:26:26',
          'Weight per bag': '50 kg'
        },
        listedDate: DateTime.now().subtract(const Duration(days: 5)),
        isActive: true,
        viewCount: 230,
        orderCount: 42,
      ),
      AgriProduct(
        id: 'P503',
        sellerId: 'S1001',
        categoryId: 'CAT001',
        name: 'Premium Basmati Rice',
        description: 'Grade-A Basmati rice, extra long grain. Exported quality, freshly harvested.',
        price: 3500,
        stock: 500,
        unit: 'quintal',
        moq: 1,
        images: [],
        location: 'Indore, MP',
        codEnabled: true,
        selfPickup: true,
        sellerDelivery: true,
        dynamicFields: {'Grade': 'A', 'Moisture %': '12', 'Harvest Date': '2026-01'},
        listedDate: DateTime.now().subtract(const Duration(days: 3)),
        isActive: true,
        viewCount: 320,
        orderCount: 15,
      ),
      AgriProduct(
        id: 'P504',
        sellerId: 'S1001',
        categoryId: 'CAT002',
        name: 'Fresh Alphonso Mango',
        description: 'Premium Alphonso mangoes from Ratnagiri orchards. Chemical free, naturally ripened.',
        price: 600,
        stock: 50,
        unit: 'kg',
        moq: 5,
        images: [],
        location: 'Ratnagiri, MH',
        codEnabled: true,
        selfPickup: false,
        sellerDelivery: true,
        dynamicFields: {'Variety': 'Alphonso', 'Ripeness': 'Ready to eat', 'Origin': 'Ratnagiri'},
        listedDate: DateTime.now().subtract(const Duration(days: 1)),
        isActive: true,
        viewCount: 480,
        orderCount: 35,
      ),
      AgriProduct(
        id: 'P505',
        sellerId: 'S1001',
        categoryId: 'CAT003',
        name: 'Organic Tomatoes',
        description: 'Farm-fresh organic tomatoes. No pesticide used. Rich red colour and firm texture.',
        price: 45,
        stock: 300,
        unit: 'kg',
        moq: 5,
        images: [],
        location: 'Indore, MP',
        codEnabled: true,
        selfPickup: true,
        sellerDelivery: true,
        dynamicFields: {'Freshness': 'Same Day', 'Organic': 'Yes', 'Harvest Date': '2026-02'},
        listedDate: DateTime.now().subtract(const Duration(hours: 12)),
        isActive: true,
        viewCount: 190,
        orderCount: 55,
      ),
      AgriProduct(
        id: 'P506',
        sellerId: 'S1001',
        categoryId: 'CAT006',
        name: 'Neem Oil Pesticide',
        description: 'Pure cold-pressed neem oil. Natural pest repellent safe for organic farming.',
        price: 350,
        stock: 150,
        unit: 'liter',
        moq: 1,
        images: [],
        location: 'Indore, MP',
        codEnabled: true,
        selfPickup: true,
        sellerDelivery: true,
        dynamicFields: {'Type': 'Organic', 'Active Ingredient': 'Azadirachtin', 'Dosage': '5ml/liter'},
        listedDate: DateTime.now().subtract(const Duration(days: 7)),
        isActive: true,
        viewCount: 88,
        orderCount: 18,
      ),
      AgriProduct(
        id: 'P507',
        sellerId: 'S1001',
        categoryId: 'CAT007',
        name: 'Power Tiller',
        description: 'Heavy duty 12HP diesel power tiller. Ideal for small to medium farms.',
        price: 85000,
        stock: 5,
        unit: 'piece',
        moq: 1,
        images: [],
        location: 'Indore, MP',
        codEnabled: false,
        selfPickup: true,
        sellerDelivery: false,
        dynamicFields: {'Condition': 'New', 'Brand': 'VST Shakti', 'Warranty': '2 Years'},
        listedDate: DateTime.now().subtract(const Duration(days: 14)),
        isActive: true,
        viewCount: 65,
        orderCount: 2,
      ),
      AgriProduct(
        id: 'P508',
        sellerId: 'S1001',
        categoryId: 'CAT009',
        name: 'Fresh Cow Milk',
        description: 'Pure A2 cow milk from country breed cows. Daily delivery available.',
        price: 60,
        stock: 100,
        unit: 'liter',
        moq: 2,
        images: [],
        location: 'Indore, MP',
        codEnabled: true,
        selfPickup: true,
        sellerDelivery: true,
        dynamicFields: {'Type': 'A2 Cow', 'Fat %': '4.5', 'Expiry Date': 'Same Day'},
        listedDate: DateTime.now().subtract(const Duration(hours: 4)),
        isActive: true,
        viewCount: 340,
        orderCount: 120,
      ),
      AgriProduct(
        id: 'P509',
        sellerId: 'S1001',
        categoryId: 'CAT011',
        name: 'Organic Turmeric Powder',
        description: 'Certified organic turmeric powder. High curcumin content. Lab tested.',
        price: 280,
        stock: 80,
        unit: 'kg',
        moq: 1,
        images: [],
        location: 'Indore, MP',
        codEnabled: true,
        selfPickup: true,
        sellerDelivery: true,
        dynamicFields: {'Certification': 'NPOP Certified', 'Organic Grade': 'Premium'},
        listedDate: DateTime.now().subtract(const Duration(days: 6)),
        isActive: true,
        viewCount: 200,
        orderCount: 30,
      ),
      AgriProduct(
        id: 'P510',
        sellerId: 'S1001',
        categoryId: 'CAT015',
        name: 'Cattle Feed Premium',
        description: 'Balanced nutrition cattle feed. Increases milk yield by 15-20%.',
        price: 1200,
        stock: 400,
        unit: 'bag',
        moq: 5,
        images: [],
        location: 'Indore, MP',
        codEnabled: true,
        selfPickup: true,
        sellerDelivery: true,
        dynamicFields: {'Animal Type': 'Cattle', 'Nutritional Value': 'High Protein', 'Moisture': '10%'},
        listedDate: DateTime.now().subtract(const Duration(days: 4)),
        isActive: true,
        viewCount: 95,
        orderCount: 22,
      ),
    ];

    for (var product in products) {
      _products[product.id] = product;
    }
  }

  void _initializeDemoOrders() {
    final orders = [
      SellerOrder(
        id: 'O8901',
        productId: 'P501',
        sellerId: 'S1001',
        buyerId: 'B101',
        quantity: 10,
        totalAmount: 22000,
        commission: 660,
        netEarnings: 21340,
        paymentMode: PaymentMode.cod,
        status: OrderStatus.delivered,
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        deliveredDate: DateTime.now().subtract(const Duration(hours: 6)),
        codCollected: true,
      ),
      SellerOrder(
        id: 'O8902',
        productId: 'P502',
        sellerId: 'S1001',
        buyerId: 'B102',
        quantity: 20,
        totalAmount: 17000,
        commission: 510,
        netEarnings: 16490,
        paymentMode: PaymentMode.online,
        status: OrderStatus.shipped,
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        shippedDate: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      SellerOrder(
        id: 'O8903',
        productId: 'P501',
        sellerId: 'S1001',
        buyerId: 'B103',
        quantity: 5,
        totalAmount: 11000,
        commission: 330,
        netEarnings: 10670,
        paymentMode: PaymentMode.cod,
        status: OrderStatus.placed,
        orderDate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    for (var order in orders) {
      _orders[order.id] = order;
    }
  }

  // ============ AUTH & REGISTRATION ============

  Future<bool> verifyOTP(String mobile, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    return otp == '123456'; // Demo OTP
  }

  Future<Seller> registerSeller({
    required String mobile,
    required String name,
    required SellerType type,
    required String location,
    String? profilePhoto,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final sellerId = 'S${DateTime.now().millisecondsSinceEpoch}';
    final seller = Seller(
      id: sellerId,
      name: name,
      mobile: mobile,
      type: type,
      location: location,
      profilePhoto: profilePhoto,
      level: SellerLevel.basic,
      commissionRate: 3.0,
      walletBalance: 0,
      pendingSettlement: 0,
      kycStatus: KYCStatus.notSubmitted,
      registeredDate: DateTime.now(),
      isActive: true,
    );

    _sellers[sellerId] = seller;
    _currentSellerId = sellerId;
    _sellerUpdateController.add(seller);

    return seller;
  }

  Seller? getCurrentSeller() {
    if (_currentSellerId == null) return null;
    return _sellers[_currentSellerId];
  }

  void setCurrentSeller(String sellerId) {
    _currentSellerId = sellerId;
  }

  // ============ CATEGORY MANAGEMENT ============

  List<AgriCategory> getAllCategories() {
    return _categories.values.where((c) => c.isEnabled).toList();
  }

  List<AgriCategory> getRootCategories() {
    return _categories.values
        .where((c) => c.parentId == null && c.isEnabled)
        .toList();
  }

  List<AgriCategory> getSubcategories(String parentId) {
    return _categories.values
        .where((c) => c.parentId == parentId && c.isEnabled)
        .toList();
  }

  AgriCategory? getCategory(String id) {
    return _categories[id];
  }

  void addCategory(AgriCategory category) {
    _categories[category.id] = category;
  }

  void updateCategory(AgriCategory category) {
    _categories[category.id] = category;
  }

  void deleteCategory(String id) {
    _categories.remove(id);
  }

  // ============ PRODUCT MANAGEMENT ============

  List<AgriProduct> getAllActiveProducts() {
    return _products.values
        .where((p) => p.isActive && p.stock > 0)
        .toList()
      ..sort((a, b) => b.listedDate.compareTo(a.listedDate));
  }

  List<AgriProduct> getProductsByCategory(String categoryId) {
    return _products.values
        .where((p) => p.categoryId == categoryId && p.isActive && p.stock > 0)
        .toList();
  }

  Seller? getSellerById(String sellerId) {
    return _sellers[sellerId];
  }

  Future<AgriProduct> addProduct(AgriProduct product) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _products[product.id] = product;
    
    _addNotification(
      sellerId: product.sellerId,
      title: 'Product Listed',
      message: '${product.name} is now live!',
      type: 'product',
    );

    return product;
  }

  List<AgriProduct> getSellerProducts(String sellerId) {
    return _products.values.where((p) => p.sellerId == sellerId).toList()
      ..sort((a, b) => b.listedDate.compareTo(a.listedDate));
  }

  AgriProduct? getProduct(String id) {
    return _products[id];
  }

  void updateProduct(AgriProduct product) {
    _products[product.id] = product;
  }

  void updateProductStock(String productId, int newStock) {
    final product = _products[productId];
    if (product != null) {
      _products[productId] = product.copyWith(stock: newStock);
      
      if (newStock == 0) {
        _addNotification(
          sellerId: product.sellerId,
          title: 'Out of Stock',
          message: '${product.name} is now out of stock',
          type: 'stock',
        );
      }
    }
  }

  List<AgriProduct> getLowStockProducts(String sellerId, int threshold) {
    return _products.values
        .where((p) => p.sellerId == sellerId && p.stock > 0 && p.stock <= threshold)
        .toList();
  }

  List<AgriProduct> getOutOfStockProducts(String sellerId) {
    return _products.values
        .where((p) => p.sellerId == sellerId && p.stock == 0)
        .toList();
  }

  // ============ ORDER MANAGEMENT ============

  void addOrder(SellerOrder order) {
    _orders[order.id] = order;
    _addNotification(
      sellerId: order.sellerId,
      title: 'New Order Received',
      message: 'Order #${order.id} for ₹${order.totalAmount.toInt()}',
      type: 'order',
      orderId: order.id,
    );
    _orderUpdateController.add(order);
  }

  List<SellerOrder> getSellerOrders(String sellerId, {OrderStatus? status}) {
    var orders = _orders.values.where((o) => o.sellerId == sellerId);
    if (status != null) {
      orders = orders.where((o) => o.status == status);
    }
    return orders.toList()..sort((a, b) => b.orderDate.compareTo(a.orderDate));
  }

  SellerOrder? getOrder(String id) {
    return _orders[id];
  }

  Future<void> acceptOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final order = _orders[orderId];
    if (order != null) {
      _orders[orderId] = order.copyWith(
        status: OrderStatus.accepted,
        acceptedDate: DateTime.now(),
      );
      _orderUpdateController.add(_orders[orderId]!);
      
      _addNotification(
        sellerId: order.sellerId,
        title: 'Order Accepted',
        message: 'Order ${order.id} has been accepted',
        type: 'order',
        orderId: orderId,
      );
    }
  }

  Future<void> rejectOrder(String orderId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final order = _orders[orderId];
    if (order != null) {
      _orders[orderId] = order.copyWith(
        status: OrderStatus.rejected,
        cancellationReason: reason,
      );
      _orderUpdateController.add(_orders[orderId]!);
    }
  }

  Future<void> markOrderPacked(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final order = _orders[orderId];
    if (order != null) {
      _orders[orderId] = order.copyWith(status: OrderStatus.packed);
      _orderUpdateController.add(_orders[orderId]!);
    }
  }

  Future<void> markOrderShipped(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final order = _orders[orderId];
    if (order != null) {
      _orders[orderId] = order.copyWith(
        status: OrderStatus.shipped,
        shippedDate: DateTime.now(),
      );
      _orderUpdateController.add(_orders[orderId]!);
    }
  }

  Future<void> markOrderDelivered(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final order = _orders[orderId];
    if (order != null) {
      final updatedOrder = order.copyWith(
        status: OrderStatus.delivered,
        deliveredDate: DateTime.now(),
      );
      _orders[orderId] = updatedOrder;
      _orderUpdateController.add(updatedOrder);
      
      // Update product stock
      final product = _products[order.productId];
      if (product != null) {
        updateProductStock(order.productId, product.stock - order.quantity);
      }

      // If COD, mark for settlement
      if (order.paymentMode == PaymentMode.cod) {
        _orders[orderId] = updatedOrder.copyWith(codCollected: true);
        final seller = _sellers[order.sellerId];
        if (seller != null) {
          _sellers[order.sellerId] = seller.copyWith(
            pendingSettlement: seller.pendingSettlement + order.netEarnings,
          );
        }
      } else {
        // Credit wallet immediately for online payments
        _creditWallet(order.sellerId, order.netEarnings, 'Order ${order.id}', orderId);
      }
    }
  }

  // ============ WALLET MANAGEMENT ============

  void _creditWallet(String sellerId, double amount, String description, String? orderId) {
    final seller = _sellers[sellerId];
    if (seller != null) {
      _sellers[sellerId] = seller.copyWith(
        walletBalance: seller.walletBalance + amount,
      );
      
      _transactions.add(SellerWalletTransaction(
        id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        sellerId: sellerId,
        amount: amount,
        type: 'credit',
        description: description,
        date: DateTime.now(),
        orderId: orderId,
      ));

      _sellerUpdateController.add(_sellers[sellerId]!);
    }
  }

  Future<bool> withdrawFunds(String sellerId, double amount) async {
    await Future.delayed(const Duration(seconds: 1));
    final seller = _sellers[sellerId];
    if (seller == null || seller.walletBalance < amount || amount < 500) {
      return false;
    }

    _sellers[sellerId] = seller.copyWith(
      walletBalance: seller.walletBalance - amount,
    );

    _transactions.add(SellerWalletTransaction(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      sellerId: sellerId,
      amount: amount,
      type: 'debit',
      description: 'Withdrawal to bank',
      date: DateTime.now(),
    ));

    _sellerUpdateController.add(_sellers[sellerId]!);
    
    _addNotification(
      sellerId: sellerId,
      title: 'Withdrawal Successful',
      message: '₹${amount.toInt()} withdrawn to your bank account',
      type: 'wallet',
    );

    return true;
  }

  List<SellerWalletTransaction> getTransactions(String sellerId) {
    return _transactions.where((t) => t.sellerId == sellerId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ============ KYC MANAGEMENT ============

  Future<void> submitKYC(KYCDocument document) async {
    await Future.delayed(const Duration(seconds: 1));
    _kycDocuments[document.sellerId] = document;
    
    final seller = _sellers[document.sellerId];
    if (seller != null) {
      _sellers[document.sellerId] = seller.copyWith(
        kycStatus: KYCStatus.pending,
      );
      _sellerUpdateController.add(_sellers[document.sellerId]!);
    }

    _addNotification(
      sellerId: document.sellerId,
      title: 'KYC Submitted',
      message: 'Your KYC documents are under review',
      type: 'kyc',
    );
  }

  Future<void> approveKYC(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final seller = _sellers[sellerId];
    if (seller != null) {
      _sellers[sellerId] = seller.copyWith(kycStatus: KYCStatus.approved);
      _sellerUpdateController.add(_sellers[sellerId]!);
      
      _addNotification(
        sellerId: sellerId,
        title: 'KYC Approved',
        message: 'Your KYC has been approved. You can now upgrade to Big Seller',
        type: 'kyc',
      );
    }
  }

  // ============ SUBSCRIPTION MANAGEMENT ============

  List<SubscriptionPlan> getSubscriptionPlans() {
    return _subscriptionPlans.values.toList();
  }

  Future<bool> upgradeToBigSeller(String sellerId, String planId) async {
    await Future.delayed(const Duration(seconds: 1));
    final seller = _sellers[sellerId];
    final plan = _subscriptionPlans[planId];
    
    if (seller == null || plan == null || seller.kycStatus != KYCStatus.approved) {
      return false;
    }

    final expiryDate = DateTime.now().add(Duration(days: plan.durationDays));
    
    _sellers[sellerId] = seller.copyWith(
      level: SellerLevel.bigSeller,
      commissionRate: plan.commissionRate,
      subscriptionStatus: SubscriptionStatus.active,
      subscriptionExpiry: expiryDate,
    );

    _sellerUpdateController.add(_sellers[sellerId]!);
    
    _addNotification(
      sellerId: sellerId,
      title: 'Upgrade Successful',
      message: 'You are now a Big Seller! Enjoy lower commission rates',
      type: 'subscription',
    );

    return true;
  }

  // ============ ANALYTICS ============

  SellerAnalytics getAnalytics(String sellerId) {
    final orders = getSellerOrders(sellerId);
    final products = getSellerProducts(sellerId);
    
    double totalRevenue = 0;
    double commissionPaid = 0;
    Map<String, double> monthlySales = {};
    Map<String, int> topProducts = {};
    Map<String, double> categoryPerformance = {};

    for (var order in orders) {
      if (order.status == OrderStatus.delivered || order.status == OrderStatus.completed) {
        totalRevenue += order.netEarnings;
        commissionPaid += order.commission;

        final month = '${order.orderDate.year}-${order.orderDate.month}';
        monthlySales[month] = (monthlySales[month] ?? 0) + order.netEarnings;

        topProducts[order.productId] = (topProducts[order.productId] ?? 0) + 1;

        final product = _products[order.productId];
        if (product != null) {
          categoryPerformance[product.categoryId] = 
              (categoryPerformance[product.categoryId] ?? 0) + order.netEarnings;
        }
      }
    }

    return SellerAnalytics(
      sellerId: sellerId,
      totalRevenue: totalRevenue,
      totalOrders: orders.where((o) => 
          o.status == OrderStatus.delivered || o.status == OrderStatus.completed).length,
      activeListings: products.where((p) => p.isActive && p.stock > 0).length,
      outOfStockItems: products.where((p) => p.stock == 0).length,
      lowStockItems: products.where((p) => p.stock > 0 && p.stock <= 10).length,
      commissionPaid: commissionPaid,
      monthlySales: monthlySales,
      topProducts: topProducts,
      categoryPerformance: categoryPerformance,
    );
  }

  // ============ NOTIFICATIONS ============

  void _addNotification({
    required String sellerId,
    required String title,
    required String message,
    required String type,
    String? orderId,
  }) {
    final notification = SellerNotification(
      id: 'N${DateTime.now().millisecondsSinceEpoch}',
      sellerId: sellerId,
      title: title,
      message: message,
      type: type,
      date: DateTime.now(),
      isRead: false,
      orderId: orderId,
    );
    _notifications.add(notification);
    _notificationController.add(notification);
  }

  List<SellerNotification> getNotifications(String sellerId) {
    return _notifications.where((n) => n.sellerId == sellerId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void markNotificationRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  int getUnreadNotificationCount(String sellerId) {
    return _notifications
        .where((n) => n.sellerId == sellerId && !n.isRead)
        .length;
  }

  // ============ ADMIN FUNCTIONS ============

  List<Seller> getAllSellers() {
    return _sellers.values.toList();
  }

  void updateSellerStatus(String sellerId, bool isActive) {
    final seller = _sellers[sellerId];
    if (seller != null) {
      _sellers[sellerId] = seller.copyWith(isActive: isActive);
    }
  }

  void updateSellerLevel(String sellerId, SellerLevel level, double commission) {
    final seller = _sellers[sellerId];
    if (seller != null) {
      _sellers[sellerId] = seller.copyWith(
        level: level,
        commissionRate: commission,
      );
    }
  }

  void dispose() {
    _sellerUpdateController.close();
    _orderUpdateController.close();
    _notificationController.close();
  }
}
