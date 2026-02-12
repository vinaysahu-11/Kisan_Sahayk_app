const Product = require('../models/Product');
const SellerProfile = require('../models/SellerProfile');
const Order = require('../models/Order');
const User = require('../models/User');
const Category = require('../models/Category');
const { walletService } = require('../services/walletService');
const { commissionService } = require('../services/commissionService');

// @desc    Register as seller (create seller profile)
// @route   POST /api/seller/register
// @access  Private (authenticated users with seller role)
exports.registerSeller = async (req, res) => {
  try {
    const { businessName, gst, address, bankDetails } = req.body;
    
    // Check if seller profile already exists
    const existingProfile = await SellerProfile.findOne({ user: req.user.userId });
    if (existingProfile) {
      return res.status(400).json({ error: 'Seller profile already exists' });
    }

    const sellerProfile = new SellerProfile({
      user: req.user.userId,
      businessName,
      gst,
      address,
      bankDetails,
      approvalStatus: 'pending',
      kycStatus: 'pending'
    });

    await sellerProfile.save();

    res.status(201).json({
      message: 'Seller registration submitted. Awaiting admin approval.',
      profile: sellerProfile
    });
  } catch (error) {
    console.error('Seller registration error:', error);
    res.status(500).json({ error: 'Registration failed', message: error.message });
  }
};

// @desc    Get seller profile
// @route   GET /api/seller/profile
// @access  Private (seller)
exports.getProfile = async (req, res) => {
  try {
    const profile = await SellerProfile.findOne({ user: req.user.userId })
      .populate('user', 'name phone email');
    
    if (!profile) {
      return res.status(404).json({ error: 'Seller profile not found' });
    }

    res.json({ profile });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch profile', message: error.message });
  }
};

// @desc    Add new product
// @route   POST /api/seller/products
// @access  Private (seller)
exports.addProduct = async (req, res) => {
  try {
    const sellerProfile = await SellerProfile.findOne({ user: req.user.userId });
    
    if (!sellerProfile) {
      return res.status(404).json({ error: 'Seller profile not found. Register first.' });
    }

    if (sellerProfile.approvalStatus !== 'approved') {
      return res.status(403).json({ error: 'Seller account not approved yet' });
    }

    const {
      name, description, category, price, unit, stock,
      minOrder, discount, specifications, images
    } = req.body;

    const product = new Product({
      seller: req.user.userId,
      name,
      description,
      category,
      price,
      unit,
      stock,
      minOrder,
      discount,
      specifications,
      images,
      isActive: true
    });

    await product.save();

    res.status(201).json({
      message: 'Product added successfully',
      product
    });
  } catch (error) {
    console.error('Add product error:', error);
    res.status(500).json({ error: 'Failed to add product', message: error.message });
  }
};

// @desc    Get seller's products
// @route   GET /api/seller/products
// @access  Private (seller)
exports.getProducts = async (req, res) => {
  try {
    const { page = 1, limit = 20, search, category, isActive } = req.query;

    const query = { seller: req.user.userId };
    
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } }
      ];
    }
    
    if (category) query.category = category;
    if (isActive !== undefined) query.isActive = isActive === 'true';

    const products = await Product.find(query)
      .populate('category', 'name')
      .sort({ createdAt: -1 })
      .limit(Number(limit))
      .skip((Number(page) - 1) * Number(limit));

    const total = await Product.countDocuments(query);

    res.json({
      products,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch products', message: error.message });
  }
};

// @desc    Update product
// @route   PUT /api/seller/products/:id
// @access  Private (seller)
exports.updateProduct = async (req, res) => {
  try {
    const product = await Product.findOne({
      _id: req.params.id,
      seller: req.user.userId
    });

    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }

    const allowedUpdates = ['name', 'description', 'price', 'stock', 'discount', 
      'specifications', 'images', 'isActive', 'minOrder', 'unit'];
    
    allowedUpdates.forEach(field => {
      if (req.body[field] !== undefined) {
        product[field] = req.body[field];
      }
    });

    await product.save();

    res.json({
      message: 'Product updated successfully',
      product
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update product', message: error.message });
  }
};

// @desc    Delete product
// @route   DELETE /api/seller/products/:id
// @access  Private (seller)
exports.deleteProduct = async (req, res) => {
  try {
    const product = await Product.findOneAndDelete({
      _id: req.params.id,
      seller: req.user.userId
    });

    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }

    res.json({ message: 'Product deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete product', message: error.message });
  }
};

// @desc    Get seller's orders
// @route   GET /api/seller/orders
// @access  Private (seller)
exports.getOrders = async (req, res) => {
  try {
    const { page = 1, limit = 20, status } = req.query;

    const query = { 'items.seller': req.user.userId };
    if (status) query.status = status;

    const orders = await Order.find(query)
      .populate('buyer', 'name phone')
      .populate('items.product', 'name')
      .sort({ orderDate: -1 })
      .limit(Number(limit))
      .skip((Number(page) - 1) * Number(limit));

    const total = await Order.countDocuments(query);

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

// @desc    Update order status
// @route   PUT /api/seller/orders/:id/status
// @access  Private (seller)
exports.updateOrderStatus = async (req, res) => {
  try {
    const { status, note } = req.body;
    const orderId = req.params.id;

    const order = await Order.findOne({
      _id: orderId,
      'items.seller': req.user.userId
    });

    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    const validStatuses = ['processing', 'confirmed', 'packed', 'shipped'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    order.status = status;
    order.statusHistory.push({
      status,
      note: note || `Status updated by seller`,
      updatedBy: req.user.userId
    });

    if (status === 'confirmed') order.confirmedDate = new Date();
    if (status === 'packed') order.packedDate = new Date();
    if (status === 'shipped') order.shippedDate = new Date();

    await order.save();

    res.json({
      message: 'Order status updated successfully',
      order
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update status', message: error.message });
  }
};

// @desc    Get wallet info
// @route   GET /api/seller/wallet
// @access  Private (seller)
exports.getWallet = async (req, res) => {
  try {
    const user = await User.findById(req.user.userId);
    const balance = await walletService.getBalance(req.user.userId);
    
    const recentTransactions = await walletService.getTransactions(
      req.user.userId, 1, 10
    );

    res.json({
      balance,
      lastUpdated: user.wallet.lastUpdated,
      recentTransactions
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch wallet', message: error.message });
  }
};

// @desc    Get wallet transactions
// @route   GET /api/seller/wallet/transactions
// @access  Private (seller)
exports.getWalletTransactions = async (req, res) => {
  try {
    const { page = 1, limit = 20, category } = req.query;

    const transactions = await walletService.getTransactions(
      req.user.userId,
      Number(page),
      Number(limit),
      category
    );

    res.json(transactions);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch transactions', message: error.message });
  }
};

// @desc    Get analytics/dashboard
// @route   GET /api/seller/analytics
// @access  Private (seller)
exports.getAnalytics = async (req, res) => {
  try {
    // Total products
    const totalProducts = await Product.countDocuments({ seller: req.user.userId });
    const activeProducts = await Product.countDocuments({ 
      seller: req.user.userId, 
      isActive: true 
    });

    // Total orders
    const totalOrders = await Order.countDocuments({ 'items.seller': req.user.userId });
    const pendingOrders = await Order.countDocuments({ 
      'items.seller': req.user.userId,
      status: { $in: ['placed', 'processing', 'confirmed'] }
    });
    const completedOrders = await Order.countDocuments({ 
      'items.seller': req.user.userId,
      status: 'completed'
    });

    // Total earnings (from completed orders)
    const completedOrdersData = await Order.find({
      'items.seller': req.user.userId,
      status: 'completed',
      'commission.deducted': true
    });

    let totalEarnings = 0;
    let totalCommission = 0;
    
    completedOrdersData.forEach(order => {
      order.items.forEach(item => {
        if (item.seller.toString() === req.user.userId.toString()) {
          const itemTotal = item.price * item.quantity;
          totalEarnings += itemTotal;
          if (order.commission) {
            totalCommission += order.commission.amount;
          }
        }
      });
    });

    const netEarnings = totalEarnings - totalCommission;

    // Wallet balance
    const walletBalance = await walletService.getBalance(req.user.userId);

    // Recent orders
    const recentOrders = await Order.find({ 'items.seller': req.user.userId })
      .populate('buyer', 'name phone')
      .sort({ orderDate: -1 })
      .limit(5);

    res.json({
      products: {
        total: totalProducts,
        active: activeProducts,
        inactive: totalProducts - activeProducts
      },
      orders: {
        total: totalOrders,
        pending: pendingOrders,
        completed: completedOrders
      },
      earnings: {
        total: totalEarnings,
        commission: totalCommission,
        net: netEarnings,
        walletBalance
      },
      recentOrders
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch analytics', message: error.message });
  }
};

module.exports = exports;
