const User = require('../models/User');
const SellerProfile = require('../models/SellerProfile');
const Product = require('../models/Product');
const Order = require('../models/Order');
const Category = require('../models/Category');
const CommissionSettings = require('../models/CommissionSettings');
const WalletTransaction = require('../models/WalletTransaction');
const { walletService } = require('../services/walletService');

// @desc    Approve seller
// @route   PUT /api/admin/sellers/:id/approve
// @access  Admin only
exports.approveSeller = async (req, res) => {
  try {
    const { approved, rejectionReason } = req.body;

    const seller = await SellerProfile.findById(req.params.id).populate('user');
    
    if (!seller) {
      return res.status(404).json({ error: 'Seller not found' });
    }

    seller.approvalStatus = approved ? 'approved' : 'rejected';
    if (approved) {
      seller.approvedAt = new Date();
      seller.approvedBy = req.user.userId;
    } else {
      seller.rejectionReason = rejectionReason;
    }

    await seller.save();

    res.json({
      message: `Seller ${approved ? 'approved' : 'rejected'} successfully`,
      seller
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update seller status', message: error.message });
  }
};

// @desc    Approve delivery/labour/transport partner
// @route   PUT /api/admin/partners/:id/approve
// @access  Admin only
exports.approvePartner = async (req, res) => {
  try {
    const { approved, rejectionReason } = req.body;

    const user = await User.findById(req.params.id);
    
    if (!user) {
      return res.status(404).json({ error: 'Partner not found' });
    }

    if (!['delivery_partner', 'labour_partner', 'transport_partner'].includes(user.role)) {
      return res.status(400).json({ error: 'User is not a partner' });
    }

    // Update approval status based on role
    if (user.role === 'delivery_partner') {
      user.deliveryDetails.isApproved = approved;
      if (!approved) user.deliveryDetails.rejectionReason = rejectionReason;
    } else if (user.role === 'labour_partner') {
      user.labourDetails.isApproved = approved;
      if (!approved) user.labourDetails.rejectionReason = rejectionReason;
    } else if (user.role === 'transport_partner') {
      user.transportDetails.isApproved = approved;
      if (!approved) user.transportDetails.rejectionReason = rejectionReason;
    }

    await user.save();

    res.json({
      message: `Partner ${approved ? 'approved' : 'rejected'} successfully`,
      user: {
        id: user._id,
        name: user.name,
        role: user.role,
        approved
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update partner status', message: error.message });
  }
};

// @desc    Set commission rate
// @route   PUT /api/admin/commission/:category
// @access  Admin only
exports.setCommissionRate = async (req, res) => {
  try {
    const { commissionPercentage, commissionType } = req.body;
    const { category } = req.params;

    const commission = await CommissionSettings.findOne({ category });

    if (commission) {
      commission.commissionPercentage = commissionPercentage;
      commission.commissionType = commissionType;
      await commission.save();
    } else {
      await CommissionSettings.create({
        category,
        commissionPercentage,
        commissionType
      });
    }

    res.json({
      message: 'Commission rate updated successfully',
      category,
      commissionPercentage,
      commissionType
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update commission', message: error.message });
  }
};

// @desc    Adjust user wallet
// @route   POST /api/admin/wallet/adjust
// @access  Admin only
exports.adjustWallet = async (req, res) => {
  try {
    const { userId, amount, type, description } = req.body;

    if (!['credit', 'debit'].includes(type)) {
      return res.status(400).json({ error: 'Invalid adjustment type' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (type === 'credit') {
      await walletService.creditWallet(
        userId,
        Number(amount),
        'admin_adjustment',
        null,
        description
      );
    } else {
      await walletService.debitWallet(
        userId,
        Number(amount),
        'admin_adjustment',
        null,
        description
      );
    }

    const newBalance = await walletService.getBalance(userId);

    res.json({
      message: 'Wallet adjusted successfully',
      userId,
      adjustment: {
        type,
        amount: Number(amount),
        description
      },
      newBalance
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to adjust wallet', message: error.message });
  }
};

// @desc    Get admin analytics
// @route   GET /api/admin/analytics
// @access  Admin only
exports.getAnalytics = async (req, res) => {
  try {
    // User statistics
    const totalUsers = await User.countDocuments({ isActive: true });
    const buyersCount = await User.countDocuments({ role: 'buyer', isActive: true });
    const sellersCount = await SellerProfile.countDocuments({ approvalStatus: 'approved' });
    const partnersCount = await User.countDocuments({ 
      role: { $in: ['delivery_partner', 'labour_partner', 'transport_partner'] },
      isActive: true
    });

    // Order statistics
    const totalOrders = await Order.countDocuments();
    const pendingOrders = await Order.countDocuments({ status: { $in: ['pending', 'confirmed'] } });
    const completedOrders = await Order.countDocuments({ status: 'delivered' });
    const cancelledOrders = await Order.countDocuments({ status: 'cancelled' });

    // Revenue statistics
    const orderRevenue = await Order.aggregate([
      { $match: { status: 'delivered' } },
      { $group: { _id: null, total: { $sum: '$payment.total' } } }
    ]);

    const commissionEarned = await WalletTransaction.aggregate([
      { $match: { type: 'commission' } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);

    // Product statistics
    const totalProducts = await Product.countDocuments({ isActive: true });
    const productsByCategory = await Product.aggregate([
      { $match: { isActive: true } },
      { $group: { _id: '$category', count: { $count: {} } } },
      { $lookup: { from: 'categories', localField: '_id', foreignField: '_id', as: 'category' } },
      { $unwind: '$category' },
      { $project: { categoryName: '$category.name', count: 1 } }
    ]);

    // Pending approvals
    const pendingSellers = await SellerProfile.countDocuments({ approvalStatus: 'pending' });
    const pendingPartners = await User.countDocuments({
      $or: [
        { role: 'delivery_partner', 'deliveryDetails.isApproved': false },
        { role: 'labour_partner', 'labourDetails.isApproved': false },
        { role: 'transport_partner', 'transportDetails.isApproved': false }
      ]
    });

    res.json({
      users: {
        total: totalUsers,
        buyers: buyersCount,
        sellers: sellersCount,
        partners: partnersCount
      },
      orders: {
        total: totalOrders,
        pending: pendingOrders,
        completed: completedOrders,
        cancelled: cancelledOrders
      },
      revenue: {
        totalOrderValue: orderRevenue[0]?.total || 0,
        commissionEarned: commissionEarned[0]?.total || 0
      },
      products: {
        total: totalProducts,
        byCategory: productsByCategory
      },
      pendingApprovals: {
        sellers: pendingSellers,
        partners: pendingPartners,
        total: pendingSellers + pendingPartners
      }
    });
  } catch (error) {
    console.error('Admin analytics error:', error);
    res.status(500).json({ error: 'Failed to fetch analytics', message: error.message });
  }
};

// @desc    Manage categories - Create
// @route   POST /api/admin/categories
// @access  Admin only
exports.createCategory = async (req, res) => {
  try {
    const { name, nameHi, nameHne, description, icon, isActive } = req.body;

    const existingCategory = await Category.findOne({ name });
    if (existingCategory) {
      return res.status(400).json({ error: 'Category already exists' });
    }

    const category = new Category({
      name,
      nameHi,
      nameHne,
      description,
      icon,
      isActive
    });

    await category.save();

    res.status(201).json({
      message: 'Category created successfully',
      category
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create category', message: error.message });
  }
};

// @desc    Update category
// @route   PUT /api/admin/categories/:id
// @access  Admin only
exports.updateCategory = async (req, res) => {
  try {
    const { name, nameHi, nameHne, description, icon, isActive } = req.body;

    const category = await Category.findByIdAndUpdate(
      req.params.id,
      { name, nameHi, nameHne, description, icon, isActive },
      { new: true, runValidators: true }
    );

    if (!category) {
      return res.status(404).json({ error: 'Category not found' });
    }

    res.json({
      message: 'Category updated successfully',
      category
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update category', message: error.message });
  }
};

// @desc    Delete category
// @route   DELETE /api/admin/categories/:id
// @access  Admin only
exports.deleteCategory = async (req, res) => {
  try {
    // Check if category has products
    const productsCount = await Product.countDocuments({ category: req.params.id });
    
    if (productsCount > 0) {
      return res.status(400).json({ 
        error: 'Cannot delete category with existing products',
        productsCount 
      });
    }

    const category = await Category.findByIdAndDelete(req.params.id);

    if (!category) {
      return res.status(404).json({ error: 'Category not found' });
    }

    res.json({
      message: 'Category deleted successfully',
      category
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete category', message: error.message });
  }
};

// @desc    View all orders
// @route   GET /api/admin/orders
// @access  Admin only
exports.viewAllOrders = async (req, res) => {
  try {
    const { page = 1, limit = 20, status, startDate, endDate } = req.query;

    const query = {};
    if (status) query.status = status;
    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = new Date(startDate);
      if (endDate) query.createdAt.$lte = new Date(endDate);
    }

    const orders = await Order.find(query)
      .populate('buyer', 'name phone')
      .populate('items.product', 'name')
      .populate('items.seller', 'businessName')
      .sort({ createdAt: -1 })
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

// @desc    View all users
// @route   GET /api/admin/users
// @access  Admin only
exports.viewAllUsers = async (req, res) => {
  try {
    const { page = 1, limit = 20, role, search } = req.query;

    const query = {};
    if (role) query.role = role;
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } }
      ];
    }

    const users = await User.find(query)
      .select('-password -otp')
      .sort({ createdAt: -1 })
      .limit(Number(limit))
      .skip((Number(page) - 1) * Number(limit));

    const total = await User.countDocuments(query);

    res.json({
      users,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch users', message: error.message });
  }
};

// @desc    Toggle user active status
// @route   PUT /api/admin/users/:id/toggle-status
// @access  Admin only
exports.toggleUserStatus = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (user.role === 'admin') {
      return res.status(400).json({ error: 'Cannot deactivate admin users' });
    }

    user.isActive = !user.isActive;
    await user.save();

    res.json({
      message: `User ${user.isActive ? 'activated' : 'deactivated'} successfully`,
      user: {
        id: user._id,
        name: user.name,
        isActive: user.isActive
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update user status', message: error.message });
  }
};

module.exports = exports;
