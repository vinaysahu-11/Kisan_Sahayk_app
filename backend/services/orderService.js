const Order = require('../models/Order');
const DeliveryOrder = require('../models/DeliveryOrder');
const Product = require('../models/Product');
const User = require('../models/User');
const walletService = require('./walletService');
const commissionService = require('./commissionService');

class OrderService {
  /**
   * Create order from cart
   */
  async createOrder(buyerId, items, deliveryAddress, paymentMethod, pricingDetails) {
    // Create order
    const order = await Order.create({
      buyer: buyerId,
      items: items.map(item => ({
        product: item.productId,
        productName: item.name,
        seller: item.sellerId,
        quantity: item.quantity,
        unit: item.unit,
        pricePerUnit: item.price,
        totalPrice: item.price * item.quantity,
        image: item.image,
        status: 'pending'
      })),
      deliveryAddress,
      pricing: pricingDetails,
      payment: {
        method: paymentMethod,
        status: paymentMethod === 'wallet' ? 'completed' : 'pending'
      },
      status: 'placed',
      statusHistory: [{
        status: 'placed',
        timestamp: new Date(),
        note: 'Order placed successfully'
      }]
    });

    // Process wallet payment if applicable
    if (paymentMethod === 'wallet') {
      await walletService.processOrderPayment(buyerId, order._id, pricingDetails.total);
      order.payment.paidAt = new Date();
      await order.save();
    }

    // Update product stock
    for (const item of items) {
      await Product.findByIdAndUpdate(item.productId, {
        $inc: { stock: -item.quantity, totalSales: item.quantity }
      });
    }

    return order;
  }

  /**
   * Update order status
   */
  async updateOrderStatus(orderId, newStatus, note = '', updatedBy = null) {
    const order = await Order.findById(orderId);
    if (!order) throw new Error('Order not found');

    order.status = newStatus;
    order.statusHistory.push({
      status: newStatus,
      timestamp: new Date(),
      note,
      updatedBy
    });

    // Handle specific status transitions
    if (newStatus === 'delivered') {
      order.delivery.deliveredAt = new Date();
      // Mark payment as completed for COD
      if (order.payment.method === 'cod') {
        order.payment.status = 'completed';
        order.payment.paidAt = new Date();
      }
    }

    if (newStatus === 'completed') {
      // Process seller earnings with commission deduction
      await this.processSellerEarnings(order);
      // Process delivery partner earnings
      if (order.delivery.partner) {
        await this.processDeliveryEarnings(order);
      }
    }

    await order.save();
    return order;
  }

  /**
   * Process seller earnings after order completion
   */
  async processSellerEarnings(order) {
    // Group items by seller
    const sellerItems = {};
    for (const item of order.items) {
      const sellerId = item.seller.toString();
      if (!sellerItems[sellerId]) {
        sellerItems[sellerId] = [];
      }
      sellerItems[sellerId].push(item);
    }

    // Process earnings for each seller
    for (const [sellerId, items] of Object.entries(sellerItems)) {
      const totalAmount = items.reduce((sum, item) => sum + item.totalPrice, 0);
      
      // Calculate commission
      const earnings = await commissionService.calculateSellerEarnings(sellerId, totalAmount);

      // Credit to seller wallet
      await walletService.processSellerEarning(
        sellerId,
        order._id,
        earnings.grossAmount,
        earnings.commissionAmount,
        earnings.commissionRate
      );

      // Update seller profile
      await User.findByIdAndUpdate(sellerId, {
        $inc: { 
          'rating.count': 1 
        }
      });
    }

    // Mark commission as deducted
    order.commission.deducted = true;
    await order.save();
  }

  /**
   * Process delivery partner earnings
   */
  async processDeliveryEarnings(order) {
    const deliveryOrder = await DeliveryOrder.findOne({ order: order._id });
    if (!deliveryOrder) return;

    const deliveryFee = deliveryOrder.deliveryFee || 0;
    const partnerEarning = deliveryOrder.partnerEarning || deliveryFee * 0.8; // 80% to partner

    // For COD orders, deduct collected amount
    if (deliveryOrder.isCOD && deliveryOrder.codCollected) {
      await walletService.processDeliveryEarning(
        deliveryOrder.assignedPartner,
        deliveryOrder._id,
        partnerEarning,
        deliveryOrder.codAmount
      );
      // Deduct COD amount from partner wallet
      await walletService.processCODSettlement(
        deliveryOrder.assignedPartner,
        deliveryOrder._id,
        deliveryOrder.codAmount
      );
    } else {
      await walletService.processDeliveryEarning(
        deliveryOrder.assignedPartner,
        deliveryOrder._id,
        partnerEarning,
        0
      );
    }
  }

  /**
   * Assign delivery partner
   */
  async assignDeliveryPartner(orderId, partnerId) {
    const order = await Order.findById(orderId);
    if (!order) throw new Error('Order not found');

    // Generate OTP for delivery
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    order.delivery.partner = partnerId;
    order.delivery.assignedAt = new Date();
    order.delivery.otp = otp;

    await order.save();

    // Create delivery order
    const deliveryOrder = await DeliveryOrder.create({
      order: orderId,
      assignedPartner: partnerId,
      deliveryLocation: order.deliveryAddress,
      isCOD: order.payment.method === 'cod',
      codAmount: order.payment.method === 'cod' ? order.pricing.total : 0,
      deliveryFee: order.pricing.deliveryFee,
      deliveryOTP: otp,
      status: 'assigned'
    });

    return { order, deliveryOrder };
  }

  /**
   * Cancel order
   */
  async cancelOrder(orderId, cancelledBy, reason) {
    const order = await Order.findById(orderId);
    if (!order) throw new Error('Order not found');

    if (['delivered', 'completed', 'cancelled'].includes(order.status)) {
      throw new Error('Order cannot be cancelled');
    }

    order.status = 'cancelled';
    order.cancellation = {
      cancelledBy,
      reason,
      cancelledAt: new Date()
    };
    order.statusHistory.push({
      status: 'cancelled',
      timestamp: new Date(),
      note: `Cancelled: ${reason}`,
      updatedBy: cancelledBy
    });

    // Process refund if payment was made
    if (order.payment.status === 'completed') {
      await walletService.processRefund(order.buyer, order._id, order.pricing.total);
      order.payment.status = 'refunded';
      order.payment.refundAmount = order.pricing.total;
    }

    // Restore product stock
    for (const item of order.items) {
      await Product.findByIdAndUpdate(item.product, {
        $inc: { stock: item.quantity, totalSales: -item.quantity }
      });
    }

    await order.save();
    return order;
  }

  /**
   * Get orders for buyer
   */
  async getBuyerOrders(buyerId, page = 1, limit = 20, status = null) {
    const skip = (page - 1) * limit;
    const query = { buyer: buyerId };
    
    if (status) {
      query.status = status;
    }

    const orders = await Order.find(query)
      .populate('items.product', 'name images')
      .populate('items.seller', 'name phone')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .lean();

    const total = await Order.countDocuments(query);

    return {
      orders,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    };
  }

  /**
   * Get orders for seller
   */
  async getSellerOrders(sellerId, page = 1, limit = 20, status = null) {
    const skip = (page - 1) * limit;
    const query = { 'items.seller': sellerId };
    
    if (status) {
      query.status = status;
    }

    const orders = await Order.find(query)
      .populate('buyer', 'name phone')
      .populate('items.product', 'name images')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .lean();

    const total = await Order.countDocuments(query);

    return {
      orders,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    };
  }
}

module.exports = new OrderService();
