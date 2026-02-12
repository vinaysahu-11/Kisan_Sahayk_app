const DeliveryOrder = require('../models/DeliveryOrder');
const Order = require('../models/Order');
const User = require('../models/User');
const { walletService } = require('../services/walletService');
const { commissionService } = require('../services/commissionService');

// @desc    Register delivery partner
// @route   POST /api/delivery/register
// @access  Private
exports.registerPartner = async (req, res) => {
  try {
    const { vehicleType, vehicleNumber, licenseNumber, aadhar } = req.body;

    // Check if already registered as delivery partner
    const user = await User.findById(req.user.userId);
    if (user.role === 'delivery_partner') {
      return res.status(400).json({ error: 'Already registered as delivery partner' });
    }

    // Update user role and add delivery details
    user.role = 'delivery_partner';
    user.deliveryDetails = {
      vehicleType,
      vehicleNumber,
      licenseNumber,
      aadhar,
      isVerified: false,
      isApproved: false
    };

    await user.save();

    res.status(201).json({
      message: 'Delivery partner registration submitted. Awaiting admin approval.',
      user: {
        id: user._id,
        name: user.name,
        role: user.role,
        deliveryDetails: user.deliveryDetails
      }
    });
  } catch (error) {
    console.error('Delivery partner registration error:', error);
    res.status(500).json({ error: 'Failed to register', message: error.message });
  }
};

// @desc    Get assigned delivery orders
// @route   GET /api/delivery/orders
// @access  Private (delivery partners only)
exports.getAssignedOrders = async (req, res) => {
  try {
    const { page = 1, limit = 20, status } = req.query;

    // Check if user is delivery partner
    const user = await User.findById(req.user.userId);
    if (user.role !== 'delivery_partner') {
      return res.status(403).json({ error: 'Not authorized as delivery partner' });
    }

    const query = { assignedPartner: req.user.userId };
    if (status) query.status = status;

    const orders = await DeliveryOrder.find(query)
      .populate('order')
      .populate('buyer', 'name phone address')
      .sort({ assignedAt: -1 })
      .limit(Number(limit))
      .skip((Number(page) - 1) * Number(limit));

    const total = await DeliveryOrder.countDocuments(query);

    res.json({
      orders,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch orders', message: error.message });
  }
};

// @desc    Accept delivery order
// @route   PUT /api/delivery/orders/:id/accept
// @access  Private
exports.acceptOrder = async (req, res) => {
  try {
    const deliveryOrder = await DeliveryOrder.findOne({
      _id: req.params.id,
      assignedPartner: req.user.userId,
      status: 'assigned'
    });

    if (!deliveryOrder) {
      return res.status(404).json({ error: 'Order not found or already accepted' });
    }

    deliveryOrder.status = 'picked_up';
    deliveryOrder.pickedUpAt = new Date();
    await deliveryOrder.save();

    // Update main order status
    const order = await Order.findById(deliveryOrder.order);
    order.status = 'out_for_delivery';
    order.statusHistory.push({
      status: 'out_for_delivery',
      timestamp: new Date()
    });
    await order.save();

    res.json({
      message: 'Order accepted and picked up',
      deliveryOrder
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to accept order', message: error.message });
  }
};

// @desc    Complete delivery with OTP verification
// @route   PUT /api/delivery/orders/:id/complete
// @access  Private
exports.completeDelivery = async (req, res) => {
  try {
    const { otp, codAmount } = req.body;

    const deliveryOrder = await DeliveryOrder.findOne({
      _id: req.params.id,
      assignedPartner: req.user.userId,
      status: 'picked_up'
    }).populate('order');

    if (!deliveryOrder) {
      return res.status(404).json({ error: 'Order not found or not ready for completion' });
    }

    // Verify OTP
    if (deliveryOrder.otp !== otp) {
      return res.status(400).json({ error: 'Invalid OTP' });
    }

    // Handle COD
    if (deliveryOrder.order.paymentMethod === 'cod') {
      if (!codAmount || Number(codAmount) !== deliveryOrder.order.payment.total) {
        return res.status(400).json({ error: 'COD amount mismatch' });
      }
      deliveryOrder.codCollected = Number(codAmount);
    }

    // Update delivery order
    deliveryOrder.status = 'delivered';
    deliveryOrder.deliveredAt = new Date();
    await deliveryOrder.save();

    // Update main order
    const order = deliveryOrder.order;
    order.status = 'delivered';
    order.deliveryDate = new Date();
    order.statusHistory.push({
      status: 'delivered',
      timestamp: new Date()
    });
    await order.save();

    // Credit delivery fee to partner wallet
    await walletService.creditWallet(
      req.user.userId,
      deliveryOrder.deliveryFee,
      'delivery_fee',
      deliveryOrder._id
    );

    res.json({
      message: 'Delivery completed successfully',
      deliveryOrder,
      earnings: deliveryOrder.deliveryFee
    });
  } catch (error) {
    console.error('Complete delivery error:', error);
    res.status(500).json({ error: 'Failed to complete delivery', message: error.message });
  }
};

// @desc    Get delivery earnings
// @route   GET /api/delivery/earnings
// @access  Private
exports.getEarnings = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    const query = {
      assignedPartner: req.user.userId,
      status: 'delivered'
    };

    if (startDate || endDate) {
      query.deliveredAt = {};
      if (startDate) query.deliveredAt.$gte = new Date(startDate);
      if (endDate) query.deliveredAt.$lte = new Date(endDate);
    }

    const deliveries = await DeliveryOrder.find(query);

    const totalEarnings = deliveries.reduce((sum, d) => sum + d.deliveryFee, 0);
    const totalDeliveries = deliveries.length;
    const codCollected = deliveries.reduce((sum, d) => sum + (d.codCollected || 0), 0);

    const walletBalance = await walletService.getBalance(req.user.userId);

    res.json({
      totalEarnings,
      totalDeliveries,
      codCollected,
      walletBalance,
      averagePerDelivery: totalDeliveries > 0 ? totalEarnings / totalDeliveries : 0,
      deliveries: deliveries.slice(0, 10) // Recent 10
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch earnings', message: error.message });
  }
};

// @desc    Get delivery performance metrics
// @route   GET /api/delivery/performance
// @access  Private
exports.getPerformance = async (req, res) => {
  try {
    const totalDeliveries = await DeliveryOrder.countDocuments({
      assignedPartner: req.user.userId,
      status: 'delivered'
    });

    const onTimeDeliveries = await DeliveryOrder.countDocuments({
      assignedPartner: req.user.userId,
      status: 'delivered',
      deliveredAt: { $lte: '$expectedDeliveryDate' }
    });

    const user = await User.findById(req.user.userId);

    res.json({
      totalDeliveries,
      onTimeDeliveries,
      onTimePercentage: totalDeliveries > 0 ? (onTimeDeliveries / totalDeliveries * 100).toFixed(2) : 0,
      rating: user.rating.average || 0,
      totalRatings: user.rating.count || 0
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch performance', message: error.message });
  }
};

// @desc    Settle COD amount
// @route   POST /api/delivery/cod-settlement
// @access  Private
exports.settleCOD = async (req, res) => {
  try {
    const { orderIds, amount } = req.body;

    // Find all COD deliveries by partner
    const deliveries = await DeliveryOrder.find({
      _id: { $in: orderIds },
      assignedPartner: req.user.userId,
      status: 'delivered',
      codCollected: { $gt: 0 },
      codSettled: false
    });

    if (deliveries.length === 0) {
      return res.status(404).json({ error: 'No COD orders found for settlement' });
    }

    const totalCOD = deliveries.reduce((sum, d) => sum + d.codCollected, 0);

    if (Number(amount) !== totalCOD) {
      return res.status(400).json({ 
        error: 'Settlement amount mismatch',
        expected: totalCOD,
        provided: Number(amount)
      });
    }

    // Mark all as settled
    await DeliveryOrder.updateMany(
      { _id: { $in: orderIds } },
      { codSettled: true, codSettledAt: new Date() }
    );

    res.json({
      message: 'COD settlement completed',
      ordersSettled: deliveries.length,
      totalAmount: totalCOD
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to settle COD', message: error.message });
  }
};

module.exports = exports;
