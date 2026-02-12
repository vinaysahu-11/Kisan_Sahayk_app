const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const { authMiddleware, authorize } = require('../middleware/auth');
const Product = require('../models/Product');
const Order = require('../models/Order');

// Get seller's products
router.get('/products', authMiddleware, authorize('seller'), async (req, res) => {
  try {
    const { page = 1, limit = 20, search, category } = req.query;

    let query = { sellerId: req.user.userId };
    
    if (search) {
      query.$text = { $search: search };
    }
    
    if (category) {
      query.category = category;
    }

    const products = await Product.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const count = await Product.countDocuments(query);

    res.json({
      products,
      totalPages: Math.ceil(count / limit),
      currentPage: page,
      total: count
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Add new product
router.post('/products', [
  authMiddleware,
  authorize('seller'),
  body('name').trim().notEmpty(),
  body('category').trim().notEmpty(),
  body('price').isFloat({ min: 0 }),
  body('unit').trim().notEmpty(),
  body('stock').isInt({ min: 0 }),
  body('moq').optional().isInt({ min: 1 }),
  body('description').optional().trim(),
  body('images').optional().isArray(),
  body('codEnabled').optional().isBoolean()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const product = new Product({
      ...req.body,
      sellerId: req.user.userId
    });

    await product.save();

    res.status(201).json({ 
      message: 'Product added successfully', 
      product 
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update product
router.put('/products/:id', [
  authMiddleware,
  authorize('seller'),
  body('name').optional().trim().notEmpty(),
  body('price').optional().isFloat({ min: 0 }),
  body('stock').optional().isInt({ min: 0 }),
  body('moq').optional().isInt({ min: 1 }),
  body('description').optional().trim(),
  body('images').optional().isArray(),
  body('codEnabled').optional().isBoolean()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const product = await Product.findOne({
      _id: req.params.id,
      sellerId: req.user.userId
    });

    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }

    Object.assign(product, req.body);
    await product.save();

    res.json({ message: 'Product updated successfully', product });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete product
router.delete('/products/:id', authMiddleware, authorize('seller'), async (req, res) => {
  try {
    const product = await Product.findOneAndDelete({
      _id: req.params.id,
      sellerId: req.user.userId
    });

    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }

    res.json({ message: 'Product deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get seller's orders
router.get('/orders', authMiddleware, authorize('seller'), async (req, res) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;

    // Find orders that contain products from this seller
    let query = { 'items.sellerId': req.user.userId };
    
    if (status) {
      query.status = status;
    }

    const orders = await Order.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('buyerId', 'fullName phoneNumber')
      .populate('items.productId', 'name images');

    const count = await Order.countDocuments(query);

    res.json({
      orders,
      totalPages: Math.ceil(count / limit),
      currentPage: page,
      total: count
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get single order details
router.get('/orders/:id', authMiddleware, authorize('seller'), async (req, res) => {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      'items.sellerId': req.user.userId
    })
      .populate('buyerId', 'fullName phoneNumber')
      .populate('items.productId', 'name images');

    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Accept order
router.put('/orders/:id/accept', authMiddleware, authorize('seller'), async (req, res) => {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      'items.sellerId': req.user.userId
    });

    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    if (order.status !== 'placed') {
      return res.status(400).json({ 
        error: 'Order can only be accepted when status is "placed"' 
      });
    }

    order.status = 'accepted';
    order.statusHistory.push({
      status: 'accepted',
      timestamp: new Date()
    });

    await order.save();

    res.json({ message: 'Order accepted successfully', order });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Mark order as packed
router.put('/orders/:id/pack', authMiddleware, authorize('seller'), async (req, res) => {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      'items.sellerId': req.user.userId
    });

    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    if (order.status !== 'accepted') {
      return res.status(400).json({ 
        error: 'Order must be accepted before packing' 
      });
    }

    order.status = 'packed';
    order.statusHistory.push({
      status: 'packed',
      timestamp: new Date()
    });

    await order.save();

    res.json({ message: 'Order marked as packed', order });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Mark order as shipped
router.put('/orders/:id/ship', [
  authMiddleware,
  authorize('seller'),
  body('trackingNumber').optional().trim()
], async (req, res) => {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      'items.sellerId': req.user.userId
    });

    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    if (order.status !== 'packed') {
      return res.status(400).json({ 
        error: 'Order must be packed before shipping' 
      });
    }

    order.status = 'shipped';
    order.statusHistory.push({
      status: 'shipped',
      timestamp: new Date()
    });

    if (req.body.trackingNumber) {
      order.trackingNumber = req.body.trackingNumber;
    }

    await order.save();

    res.json({ message: 'Order marked as shipped', order });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Sales analytics
router.get('/analytics', authMiddleware, authorize('seller'), async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    let dateFilter = {};
    if (startDate || endDate) {
      dateFilter.createdAt = {};
      if (startDate) dateFilter.createdAt.$gte = new Date(startDate);
      if (endDate) dateFilter.createdAt.$lte = new Date(endDate);
    }

    // Total products
    const totalProducts = await Product.countDocuments({ 
      sellerId: req.user.userId 
    });

    // Total orders
    const totalOrders = await Order.countDocuments({
      'items.sellerId': req.user.userId,
      ...dateFilter
    });

    // Revenue calculation
    const orders = await Order.find({
      'items.sellerId': req.user.userId,
      status: { $in: ['delivered', 'completed'] },
      ...dateFilter
    });

    let totalRevenue = 0;
    orders.forEach(order => {
      order.items.forEach(item => {
        if (item.sellerId.toString() === req.user.userId) {
          totalRevenue += item.totalPrice;
        }
      });
    });

    // Order status breakdown
    const statusBreakdown = await Order.aggregate([
      { 
        $match: { 
          'items.sellerId': req.user.userId,
          ...dateFilter
        } 
      },
      { 
        $group: { 
          _id: '$status', 
          count: { $sum: 1 } 
        } 
      }
    ]);

    res.json({
      totalProducts,
      totalOrders,
      totalRevenue,
      statusBreakdown
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
