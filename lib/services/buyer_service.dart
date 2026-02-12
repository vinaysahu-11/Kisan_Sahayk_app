import 'dart:async';
import '../models/buyer_models.dart';
import '../models/seller_models.dart';
import 'seller_service.dart';

class BuyerService {
  static final BuyerService _instance = BuyerService._internal();
  factory BuyerService() => _instance;
  BuyerService._internal() {
    _initializeDemoData();
  }

  final SellerService _sellerService = SellerService();

  // Storage
  final String _buyerId = 'B100';
  final List<CartItem> _cart = [];
  final Map<String, BuyerOrder> _orders = {};
  final Map<String, BuyerAddress> _addresses = {};
  final Map<String, ProductRating> _ratings = {};
  final Map<String, ReturnRequest> _returns = {};
  final List<BuyerWalletTransaction> _walletTxns = [];
  final List<BuyerNotification> _notifications = [];
  final Map<String, EscrowTransaction> _escrow = {};
  double _walletBalance = 500; // Demo starting balance
  final Map<String, double> _sellerRatings = {}; // sellerId -> avg rating

  String get buyerId => _buyerId;
  double get walletBalance => _walletBalance;

  // ============ INIT DEMO DATA ============

  void _initializeDemoData() {
    // Demo addresses
    _addresses['ADDR1'] = BuyerAddress(
      id: 'ADDR1',
      name: 'Rakesh Kumar',
      mobile: '9876543210',
      addressLine: '45, MG Road, Near Railway Station',
      city: 'Indore',
      state: 'Madhya Pradesh',
      pincode: '452001',
      isDefault: true,
    );
    _addresses['ADDR2'] = BuyerAddress(
      id: 'ADDR2',
      name: 'Rakesh Kumar',
      mobile: '9876543210',
      addressLine: '12, Farm House, Village Mhow',
      city: 'Mhow',
      state: 'Madhya Pradesh',
      pincode: '453441',
    );

    // Demo completed order
    _orders['BO9001'] = BuyerOrder(
      id: 'BO9001',
      buyerId: _buyerId,
      sellerId: 'S1001',
      productId: 'P501',
      productName: 'Hybrid Paddy Seed',
      sellerName: 'Ramesh Traders',
      quantity: 10,
      productPrice: 2200,
      subtotal: 22000,
      deliveryFee: 100,
      totalAmount: 22100,
      paymentMode: 'online',
      status: BuyerOrderStatus.delivered,
      addressId: 'ADDR1',
      orderDate: DateTime.now().subtract(const Duration(days: 7)),
      acceptedDate: DateTime.now().subtract(const Duration(days: 6)),
      packedDate: DateTime.now().subtract(const Duration(days: 5)),
      shippedDate: DateTime.now().subtract(const Duration(days: 4)),
      deliveredDate: DateTime.now().subtract(const Duration(days: 2)),
      escrowId: 'ESC001',
      escrowReleased: true,
    );

    _orders['BO9002'] = BuyerOrder(
      id: 'BO9002',
      buyerId: _buyerId,
      sellerId: 'S1001',
      productId: 'P505',
      productName: 'Organic Tomatoes',
      sellerName: 'Ramesh Traders',
      quantity: 20,
      productPrice: 45,
      subtotal: 900,
      deliveryFee: 40,
      codCharge: 25,
      totalAmount: 965,
      paymentMode: 'cod',
      status: BuyerOrderStatus.shipped,
      addressId: 'ADDR1',
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      acceptedDate: DateTime.now().subtract(const Duration(days: 1)),
      shippedDate: DateTime.now().subtract(const Duration(hours: 8)),
    );

    _orders['BO9003'] = BuyerOrder(
      id: 'BO9003',
      buyerId: _buyerId,
      sellerId: 'S1001',
      productId: 'P509',
      productName: 'Organic Turmeric Powder',
      sellerName: 'Ramesh Traders',
      quantity: 5,
      productPrice: 280,
      subtotal: 1400,
      deliveryFee: 60,
      totalAmount: 1460,
      paymentMode: 'online',
      status: BuyerOrderStatus.placed,
      addressId: 'ADDR2',
      orderDate: DateTime.now().subtract(const Duration(hours: 3)),
      escrowId: 'ESC003',
    );

    // Demo escrow
    _escrow['ESC001'] = EscrowTransaction(
      id: 'ESC001',
      orderId: 'BO9001',
      amount: 22100,
      status: 'released',
      createdDate: DateTime.now().subtract(const Duration(days: 7)),
      releasedDate: DateTime.now().subtract(const Duration(days: 2)),
    );
    _escrow['ESC003'] = EscrowTransaction(
      id: 'ESC003',
      orderId: 'BO9003',
      amount: 1460,
      status: 'held',
      createdDate: DateTime.now().subtract(const Duration(hours: 3)),
    );

    // Demo wallet transactions
    _walletTxns.add(BuyerWalletTransaction(
      id: 'BWT001',
      buyerId: _buyerId,
      amount: 500,
      type: 'cashback',
      description: 'Welcome cashback bonus',
      date: DateTime.now().subtract(const Duration(days: 30)),
    ));

    // Demo notification
    _addNotification('Order Shipped', 'Your order BO9002 has been shipped!', 'delivery', orderId: 'BO9002');

    // Seller ratings
    _sellerRatings['S1001'] = 4.3;
  }

  // ============ PRODUCTS (from SellerService) ============

  List<AgriProduct> getAllProducts() => _sellerService.getAllActiveProducts();

  List<AgriProduct> getProductsByCategory(String categoryId) =>
      _sellerService.getProductsByCategory(categoryId);

  AgriProduct? getProduct(String id) => _sellerService.getProduct(id);

  List<AgriCategory> getRootCategories() => _sellerService.getRootCategories();

  List<AgriCategory> getAllCategories() => _sellerService.getAllCategories();

  List<AgriCategory> getSubcategories(String parentId) =>
      _sellerService.getSubcategories(parentId);

  AgriCategory? getCategory(String id) => _sellerService.getCategory(id);

  Seller? getSeller(String id) => _sellerService.getSellerById(id);

  double getSellerRating(String sellerId) => _sellerRatings[sellerId] ?? 0;

  // ============ SEARCH & FILTER ============

  List<AgriProduct> searchProducts(String query) {
    final q = query.toLowerCase();
    return getAllProducts()
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.location.toLowerCase().contains(q))
        .toList();
  }

  List<AgriProduct> filterProducts({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? codOnly,
    String? sortBy,
  }) {
    var products = categoryId != null
        ? getProductsByCategory(categoryId)
        : getAllProducts();

    if (minPrice != null) products = products.where((p) => p.price >= minPrice).toList();
    if (maxPrice != null) products = products.where((p) => p.price <= maxPrice).toList();
    if (codOnly == true) products = products.where((p) => p.codEnabled).toList();

    switch (sortBy) {
      case 'price_low':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'newest':
        products.sort((a, b) => b.listedDate.compareTo(a.listedDate));
        break;
      case 'popular':
        products.sort((a, b) => b.orderCount.compareTo(a.orderCount));
        break;
    }
    return products;
  }

  // ============ CART ============

  List<CartItem> getCart() => _cart;
  List<CartItem> get cartItems => _cart;

  int get cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  void addToCart(String productId, int quantity) {
    final existing = _cart.where((c) => c.productId == productId).toList();
    if (existing.isNotEmpty) {
      existing.first.quantity += quantity;
    } else {
      _cart.add(CartItem(productId: productId, quantity: quantity));
    }
  }

  void updateCartQuantity(String productId, int quantity) {
    final item = _cart.where((c) => c.productId == productId).toList();
    if (item.isNotEmpty) {
      if (quantity <= 0) {
        _cart.removeWhere((c) => c.productId == productId);
      } else {
        item.first.quantity = quantity;
      }
    }
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((c) => c.productId == productId);
  }

  void clearCart() => _cart.clear();

  double getCartSubtotal() {
    double total = 0;
    for (var item in _cart) {
      final product = getProduct(item.productId);
      if (product != null) total += product.price * item.quantity;
    }
    return total;
  }

  double getDeliveryFee() {
    final subtotal = getCartSubtotal();
    if (subtotal >= 5000) return 0; // Free delivery above 5000
    if (subtotal >= 1000) return 50;
    return 80;
  }

  double getCODCharge() => 25;

  double getPlatformFee() {
    final subtotal = getCartSubtotal();
    return subtotal * 0.02; // 2% platform fee
  }

  // ============ ADDRESS ============

  List<BuyerAddress> getAddresses() => _addresses.values.toList();

  BuyerAddress? getDefaultAddress() {
    final defaults = _addresses.values.where((a) => a.isDefault).toList();
    return defaults.isNotEmpty ? defaults.first : _addresses.values.isNotEmpty ? _addresses.values.first : null;
  }

  void addAddress(BuyerAddress address) {
    if (address.isDefault) {
      for (var key in _addresses.keys) {
        _addresses[key] = _addresses[key]!.copyWith(isDefault: false);
      }
    }
    _addresses[address.id] = address;
  }

  void updateAddress(BuyerAddress address) {
    if (address.isDefault) {
      for (var key in _addresses.keys) {
        _addresses[key] = _addresses[key]!.copyWith(isDefault: false);
      }
    }
    _addresses[address.id] = address;
  }

  void deleteAddress(String id) => _addresses.remove(id);

  void setDefaultAddress(String id) {
    for (var key in _addresses.keys) {
      _addresses[key] = _addresses[key]!.copyWith(isDefault: key == id);
    }
  }

  void addAddressFromFields({
    required String name,
    required String mobile,
    required String addressLine,
    required String city,
    required String state,
    required String pincode,
  }) {
    final id = 'ADDR${DateTime.now().millisecondsSinceEpoch}';
    _addresses[id] = BuyerAddress(
      id: id,
      name: name,
      mobile: mobile,
      addressLine: addressLine,
      city: city,
      state: state,
      pincode: pincode,
      isDefault: _addresses.isEmpty,
    );
  }

  BuyerAddress? getAddress(String id) => _addresses[id];

  // ============ ORDER PLACEMENT ============

  Future<List<BuyerOrder>> placeOrder({
    required String addressId,
    required String paymentMode,
    double walletUsed = 0,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final deliveryFee = getDeliveryFee();
    final codCharge = paymentMode == 'cod' ? getCODCharge() : 0.0;
    final platformFee = getPlatformFee();

    // Group cart items (for simplicity, one order per cart item)
    final List<BuyerOrder> createdOrders = [];

    for (var item in List<CartItem>.from(_cart)) {
      final product = getProduct(item.productId);
      if (product == null) continue;
      final seller = getSeller(product.sellerId);

      final orderId = 'BO${DateTime.now().millisecondsSinceEpoch}${createdOrders.length}';
      final itemSubtotal = product.price * item.quantity;
      final itemDeliveryFee = deliveryFee / _cart.length;
      final itemCodCharge = codCharge / _cart.length;
      final itemTotal = itemSubtotal + itemDeliveryFee + itemCodCharge;

      String? escrowId;
      if (paymentMode == 'online') {
        escrowId = 'ESC${DateTime.now().millisecondsSinceEpoch}${createdOrders.length}';
        _escrow[escrowId] = EscrowTransaction(
          id: escrowId,
          orderId: orderId,
          amount: itemTotal,
          status: 'held',
          createdDate: DateTime.now(),
        );
      }

      final buyerOrder = BuyerOrder(
        id: orderId,
        buyerId: _buyerId,
        sellerId: product.sellerId,
        productId: product.id,
        productName: product.name,
        sellerName: seller?.name ?? 'Unknown Seller',
        quantity: item.quantity,
        productPrice: product.price,
        subtotal: itemSubtotal,
        deliveryFee: itemDeliveryFee,
        codCharge: itemCodCharge,
        platformFee: platformFee / _cart.length,
        walletUsed: walletUsed / _cart.length,
        totalAmount: itemTotal,
        paymentMode: paymentMode,
        status: BuyerOrderStatus.placed,
        addressId: addressId,
        orderDate: DateTime.now(),
        escrowId: escrowId,
      );

      _orders[orderId] = buyerOrder;
      createdOrders.add(buyerOrder);

      // Create corresponding seller order
      final category = getCategory(product.categoryId);
      final commission = itemSubtotal * (category?.commissionPercent ?? 3.0) / 100;

      _sellerService.addOrder(SellerOrder(
        id: orderId,
        productId: product.id,
        sellerId: product.sellerId,
        buyerId: _buyerId,
        quantity: item.quantity,
        totalAmount: itemSubtotal,
        commission: commission,
        netEarnings: itemSubtotal - commission,
        paymentMode: paymentMode == 'cod' ? PaymentMode.cod : PaymentMode.online,
        status: OrderStatus.placed,
        orderDate: DateTime.now(),
      ));

      _addNotification(
        'Order Placed',
        'Your order #$orderId for ${product.name} is confirmed!',
        'order',
        orderId: orderId,
      );
    }

    // Deduct wallet if used
    if (walletUsed > 0) {
      _walletBalance -= walletUsed;
      _walletTxns.add(BuyerWalletTransaction(
        id: 'BWT${DateTime.now().millisecondsSinceEpoch}',
        buyerId: _buyerId,
        amount: walletUsed,
        type: 'used',
        description: 'Used for order payment',
        date: DateTime.now(),
      ));
    }

    clearCart();
    return createdOrders;
  }

  // ============ ORDER MANAGEMENT ============

  List<BuyerOrder> getOrders({BuyerOrderStatus? status}) {
    var orders = _orders.values.where((o) => o.buyerId == _buyerId);
    if (status != null) orders = orders.where((o) => o.status == status);
    return orders.toList()..sort((a, b) => b.orderDate.compareTo(a.orderDate));
  }

  List<BuyerOrder> getActiveOrders() {
    return _orders.values
        .where((o) =>
            o.buyerId == _buyerId &&
            o.status != BuyerOrderStatus.delivered &&
            o.status != BuyerOrderStatus.completed &&
            o.status != BuyerOrderStatus.cancelled &&
            o.status != BuyerOrderStatus.returned)
        .toList()
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
  }

  List<BuyerOrder> getCompletedOrders() {
    return _orders.values
        .where((o) =>
            o.buyerId == _buyerId &&
            (o.status == BuyerOrderStatus.delivered || o.status == BuyerOrderStatus.completed))
        .toList()
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
  }

  BuyerOrder? getOrder(String id) => _orders[id];

  Future<void> cancelOrder(String orderId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final order = _orders[orderId];
    if (order == null) return;

    _orders[orderId] = order.copyWith(
      status: BuyerOrderStatus.cancelled,
      cancelledDate: DateTime.now(),
      cancellationReason: reason,
    );

    // Refund for online payment
    if (order.paymentMode == 'online') {
      final escrow = _escrow[order.escrowId];
      if (escrow != null) {
        _escrow[order.escrowId!] = EscrowTransaction(
          id: escrow.id,
          orderId: escrow.orderId,
          amount: escrow.amount,
          status: 'refunded',
          createdDate: escrow.createdDate,
          releasedDate: DateTime.now(),
        );
      }
      _walletBalance += order.totalAmount;
      _walletTxns.add(BuyerWalletTransaction(
        id: 'BWT${DateTime.now().millisecondsSinceEpoch}',
        buyerId: _buyerId,
        amount: order.totalAmount,
        type: 'refund',
        description: 'Refund for cancelled order #$orderId',
        date: DateTime.now(),
        orderId: orderId,
      ));
      _addNotification(
        'Refund Processed',
        '₹${order.totalAmount.toInt()} refunded to wallet for order #$orderId',
        'refund',
        orderId: orderId,
      );
    }

    _addNotification(
      'Order Cancelled',
      'Order #$orderId has been cancelled. ${order.paymentMode == 'online' ? 'Refund processed to wallet.' : ''}',
      'order',
      orderId: orderId,
    );
  }

  // Simulate seller accepting/shipping/delivering (for demo)
  void simulateOrderProgress(String orderId) {
    final order = _orders[orderId];
    if (order == null) return;

    switch (order.status) {
      case BuyerOrderStatus.placed:
        _orders[orderId] = order.copyWith(
          status: BuyerOrderStatus.accepted,
          acceptedDate: DateTime.now(),
        );
        _addNotification('Order Accepted', 'Seller accepted order #$orderId', 'order', orderId: orderId);
        break;
      case BuyerOrderStatus.accepted:
        _orders[orderId] = order.copyWith(
          status: BuyerOrderStatus.packed,
          packedDate: DateTime.now(),
        );
        _addNotification('Order Packed', 'Order #$orderId is packed and ready', 'order', orderId: orderId);
        break;
      case BuyerOrderStatus.packed:
        _orders[orderId] = order.copyWith(
          status: BuyerOrderStatus.shipped,
          shippedDate: DateTime.now(),
        );
        _addNotification('Order Shipped', 'Order #$orderId has been shipped!', 'delivery', orderId: orderId);
        break;
      case BuyerOrderStatus.shipped:
        _orders[orderId] = order.copyWith(
          status: BuyerOrderStatus.delivered,
          deliveredDate: DateTime.now(),
        );
        // Release escrow for online payments
        if (order.paymentMode == 'online' && order.escrowId != null) {
          final escrow = _escrow[order.escrowId];
          if (escrow != null) {
            _escrow[order.escrowId!] = EscrowTransaction(
              id: escrow.id,
              orderId: escrow.orderId,
              amount: escrow.amount,
              status: 'released',
              createdDate: escrow.createdDate,
              releasedDate: DateTime.now(),
            );
          }
          _orders[orderId] = _orders[orderId]!.copyWith(escrowReleased: true);
        }
        _addNotification('Order Delivered', 'Order #$orderId delivered successfully!', 'delivery', orderId: orderId);
        break;
      default:
        break;
    }
  }

  // ============ RATING ============

  void submitRating({
    required String orderId,
    required String productId,
    required String sellerId,
    required int productRating,
    required int sellerRating,
    String? review,
  }) {
    final rating = ProductRating(
      id: 'R${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      productId: productId,
      sellerId: sellerId,
      buyerId: _buyerId,
      productRating: productRating,
      sellerRating: sellerRating,
      review: review,
      date: DateTime.now(),
    );
    _ratings[rating.id] = rating;

    // Update seller avg rating
    final sellerRatings = _ratings.values.where((r) => r.sellerId == sellerId).toList();
    final avg = sellerRatings.fold<double>(0, (s, r) => s + r.sellerRating) / sellerRatings.length;
    _sellerRatings[sellerId] = avg;

    // Mark order as rated
    final order = _orders[orderId];
    if (order != null) {
      _orders[orderId] = order.copyWith(isRated: true);
    }
  }

  List<ProductRating> getProductRatings(String productId) {
    return _ratings.values.where((r) => r.productId == productId).toList();
  }

  bool isOrderRated(String orderId) {
    return _ratings.values.any((r) => r.orderId == orderId);
  }

  // ============ RETURN / DISPUTE ============

  void raiseReturn({
    required String orderId,
    required String reason,
    String? details,
  }) {
    final ret = ReturnRequest(
      id: 'RET${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      buyerId: _buyerId,
      reason: reason,
      details: details,
      status: DisputeStatus.raised,
      raisedDate: DateTime.now(),
    );
    _returns[ret.id] = ret;

    _orders[orderId] = _orders[orderId]!.copyWith(status: BuyerOrderStatus.returned);

    _addNotification(
      'Return Requested',
      'Return request for order #$orderId has been raised',
      'order',
      orderId: orderId,
    );
  }

  List<ReturnRequest> getReturns() {
    return _returns.values.where((r) => r.buyerId == _buyerId).toList()
      ..sort((a, b) => b.raisedDate.compareTo(a.raisedDate));
  }

  ReturnRequest? getReturn(String orderId) {
    final rets = _returns.values.where((r) => r.orderId == orderId).toList();
    return rets.isNotEmpty ? rets.first : null;
  }

  void resolveReturn(String returnId, String resolution) {
    final ret = _returns[returnId];
    if (ret == null) return;
    _returns[returnId] = ret.copyWith(
      status: DisputeStatus.resolved,
      resolvedDate: DateTime.now(),
      resolution: resolution,
    );

    final order = _orders[ret.orderId];
    if (order != null && order.paymentMode == 'online') {
      _walletBalance += order.totalAmount;
      _walletTxns.add(BuyerWalletTransaction(
        id: 'BWT${DateTime.now().millisecondsSinceEpoch}',
        buyerId: _buyerId,
        amount: order.totalAmount,
        type: 'refund',
        description: 'Return refund for order #${ret.orderId}',
        date: DateTime.now(),
        orderId: ret.orderId,
      ));
    }

    _addNotification(
      'Return Resolved',
      'Your return for order #${ret.orderId} has been resolved',
      'refund',
      orderId: ret.orderId,
    );
  }

  // ============ WALLET ============

  List<BuyerWalletTransaction> getWalletTransactions() {
    return _walletTxns.where((t) => t.buyerId == _buyerId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ============ NOTIFICATIONS ============

  void _addNotification(String title, String message, String type, {String? orderId}) {
    _notifications.add(BuyerNotification(
      id: 'BN${DateTime.now().millisecondsSinceEpoch}${_notifications.length}',
      buyerId: _buyerId,
      title: title,
      message: message,
      type: type,
      date: DateTime.now(),
      orderId: orderId,
    ));
  }

  List<BuyerNotification> getNotifications() {
    return _notifications.where((n) => n.buyerId == _buyerId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  int getUnreadCount() {
    return _notifications.where((n) => n.buyerId == _buyerId && !n.isRead).length;
  }

  void markNotificationRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) _notifications[idx] = _notifications[idx].copyWith(isRead: true);
  }

  void markAllRead() {
    for (var i = 0; i < _notifications.length; i++) {
      if (_notifications[i].buyerId == _buyerId && !_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
  }
}
