const Product = require('../models/Product');
const Cart = require('../models/Cart');
const Order = require('../models/Order');
const Rating = require('../models/Rating');
const Return = require('../models/Return');
const orderService = require('../services/orderService');
const walletService = require('../services/walletService');

/**
 * Get all products with filters
 */
exports.getProducts = async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 20, 
      category, 
      search, 
      minPrice, 
      maxPrice,
      sortBy = 'createdAt',
      sortOrder = 'desc'
    } = req.query;

    const skip = (page - 1) * limit;
    const query = { isActive: true, stock: { $gt: 0 } };

    // Filter by category
    if (category) {
      query.category = category;
    }

    // Search
    if (search) {
      query.$text = { $search: search };
    }

    // Price range
    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = parseFloat(minPrice);
      if (maxPrice) query.price.$lte = parseFloat(maxPrice);
    }

    const products = await Product.find(query)
      .populate('category', 'name')
      .populate('sellerId', 'name rating')
      .sort({ [sortBy]: sortOrder === 'desc' ? -1 : 1 })
      .skip(skip)
      .limit(parseInt(limit))
      .lean();

    const total = await Product.countDocuments(query);

    res.json({
      success: true,
      products,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to fetch products', 
      error: error.message 
    });
  }
};

/**
 * Get product by ID
 */
exports.getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id)
      .populate('category', 'name')
      .populate('sellerId', 'name phone rating');

    if (!product) {
      return res.status(404).json({ 
        success: false, 
        message: 'Product not found' 
      });
    }

    // Increment views
    product.views += 1;
    await product.save();

    // Get ratings
    const ratings = await Rating.find({ 
      entityType: 'product', 
      entityId: product._id,
      isVisible: true
    })
    .populate('ratedBy', 'name profileImage')
    .sort({ createdAt: -1 })
    .limit(10)
    .lean();

    res.json({
      success: true,
      product,
      ratings
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to fetch product', 
      error: error.message 
    });
  }
};

/**
 * Get cart
 */
exports.getCart = async (req, res) => {
  try {
    let cart = await Cart.findOne({ user: req.user.id })
      .populate('items.product', 'name price images stock')
      .populate('items.seller', 'name');

    if (!cart) {
      cart = await Cart.create({ user: req.user.id, items: [] });
    }

    res.json({
      success: true,
      cart
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to fetch cart', 
      error: error.message 
    });
  }
};

/**
 * Add to cart
 */
exports.addToCart = async (req, res) => {
  try {
    const { productId, quantity } = req.body;

    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({ 
        success: false, 
        message: 'Product not found' 
      });
    }

    if (product.stock < quantity) {
      return res.status(400).json({ 
        success: false, 
        message: 'Insufficient stock' 
      });
    }

    let cart = await Cart.findOne({ user: req.user.id });
    if (!cart) {
      cart = await Cart.create({ user: req.user.id, items: [] });
    }

    // Check if product already in cart
    const existingItem = cart.items.find(item => 
      item.product.toString() === productId
    );

    if (existingItem) {
      existingItem.quantity += quantity;
    } else {
      cart.items.push({
        product: productId,
        quantity,
        price: product.price,
        seller: product.sellerId
      });
    }

    cart.calculateTotal();
    await cart.save();

    cart = await cart.populate('items.product', 'name price images stock');
    cart = await cart.populate('items.seller', 'name');

    res.json({
      success: true,
      message: 'Product added to cart',
      cart
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to add to cart', 
      error: error.message 
    });
  }
};

/**
 * Update cart item
 */
exports.updateCartItem = async (req, res) => {
  try {
    const { itemId } = req.params;
    const { quantity } = req.body;

    const cart = await Cart.findOne({ user: req.user.id });
    if (!cart) {
      return res.status(404).json({ 
        success: false, 
        message: 'Cart not found' 
      });
    }

    const item = cart.items.id(itemId);
    if (!item) {
      return res.status(404).json({ 
        success: false, 
        message: 'Item not found in cart' 
      });
    }

    item.quantity = quantity;
    cart.calculateTotal();
    await cart.save();

    await cart.populate('items.product', 'name price images stock');
    await cart.populate('items.seller', 'name');

    res.json({
      success: true,
      message: 'Cart updated',
      cart
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to update cart', 
      error: error.message 
    });
  }
};

/**
 * Remove from cart
 */
exports.removeFromCart = async (req, res) => {
  try {
    const { itemId } = req.params;

    const cart = await Cart.findOne({ user: req.user.id });
    if (!cart) {
      return res.status(404).json({ 
        success: false, 
        message: 'Cart not found' 
      });
    }

    cart.items.pull(itemId);
    cart.calculateTotal();
    await cart.save();

    await cart.populate('items.product', 'name price images stock');

    res.json({
      success: true,
      message: 'Item removed from cart',
      cart
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to remove item', 
      error: error.message 
    });
  }
};

/**
 * Checkout and create order
 */
exports.checkout = async (req, res) => {
  try {
    const { addressId, paymentMethod } = req.body;

    const cart = await Cart.findOne({ user: req.user.id })
      .populate('items.product');

    if (!cart || cart.items.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'Cart is empty' 
      });
    }

    // Get address
    const User = require('../models/User');
    const user = await User.findById(req.user.id);
    const address = user.addresses.id(addressId);

    if (!address) {
      return res.status(404).json({ 
        success: false, 
        message: 'Address not found' 
      });
    }

    // Prepare order items
    const items = cart.items.map(item => ({
      productId: item.product._id,
      name: item.product.name,
      sellerId: item.seller,
      quantity: item.quantity,
      price: item.price,
      unit: item.product.unit,
      image: item.product.images[0]
    }));

    // Calculate pricing
    const subtotal = cart.totalAmount;
    const deliveryFee = 40; // Flat delivery fee
    const tax = subtotal * 0.05; // 5% tax
    const total = subtotal + deliveryFee + tax;

    const pricingDetails = {
      subtotal,
      deliveryFee,
      tax,
      discount: 0,
      total
    };

    // Create order
    const order = await orderService.createOrder(
      req.user.id,
      items,
      address.toObject(),
      paymentMethod,
      pricingDetails
    );

    // Clear cart
    cart.items = [];
    cart.totalAmount = 0;
    cart.totalItems = 0;
    await cart.save();

    const populatedOrder = await Order.findById(order._id)
      .populate('items.product', 'name images')
      .populate('items.seller', 'name phone');

    res.json({
      success: true,
      message: 'Order placed successfully',
      order: populatedOrder
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Checkout failed', 
      error: error.message 
    });
  }
};

/**
 * Get all orders
 */
exports.getOrders = async (req, res) => {
  try {
    const { page = 1, limit = 20, status } = req.query;

    const result = await orderService.getBuyerOrders(
      req.user.id,
      parseInt(page),
      parseInt(limit),
      status
    );

    res.json({
      success: true,
      ...result
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to fetch orders', 
      error: error.message 
    });
  }
};

/**
 * Get order by ID
 */
exports.getOrderById = async (req, res) => {
  try {
    const order = await Order.findOne({ 
      _id: req.params.id, 
      buyer: req.user.id 
    })
    .populate('items.product', 'name images')
    .populate('items.seller', 'name phone')
    .populate('delivery.partner', 'name phone');

    if (!order) {
      return res.status(404).json({ 
        success: false, 
        message: 'Order not found' 
      });
    }

    res.json({
      success: true,
      order
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to fetch order', 
      error: error.message 
    });
  }
};

/**
 * Cancel order
 */
exports.cancelOrder = async (req, res) => {
  try {
    const { reason } = req.body;

    const order = await orderService.cancelOrder(
      req.params.id,
      req.user.id,
      reason
    );

    res.json({
      success: true,
      message: 'Order cancelled successfully',
      order
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to cancel order', 
      error: error.message 
    });
  }
};

/**
 * Submit rating
 */
exports.submitRating = async (req, res) => {
  try {
    const { orderId, itemId, rating, review, images } = req.body;

    const order = await Order.findOne({ 
      _id: orderId, 
      buyer: req.user.id 
    });

    if (!order) {
      return res.status(404).json({ 
        success: false, 
        message: 'Order not found' 
      });
    }

    if (order.status !== 'delivered') {
      return res.status(400).json({ 
        success: false, 
        message: 'Can only rate delivered orders' 
      });
    }

    const item = order.items.id(itemId);
    if (!item) {
      return res.status(404).json({ 
        success: false, 
        message: 'Order item not found' 
      });
    }

    const ratingDoc = await Rating.create({
      ratedBy: req.user.id,
      ratedTo: item.seller,
      entityType: 'product',
      entityId: item.product,
      rating,
      review,
      images,
      reference: {
        orderId: order._id
      }
    });

    // Update product rating
    const Product = require('../models/Product');
    const product = await Product.findById(item.product);
    const newCount = product.rating.count + 1;
    const newAverage = ((product.rating.average * product.rating.count) + rating) / newCount;
    product.rating.average = newAverage;
    product.rating.count = newCount;
    await product.save();

    res.json({
      success: true,
      message: 'Rating submitted successfully',
      rating: ratingDoc
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to submit rating', 
      error: error.message 
    });
  }
};

/**
 * Request return
 */
exports.requestReturn = async (req, res) => {
  try {
    const { orderId, itemId, reason, description, images } = req.body;

    const order = await Order.findOne({ 
      _id: orderId, 
      buyer: req.user.id 
    });

    if (!order) {
      return res.status(404).json({ 
        success: false, 
        message: 'Order not found' 
      });
    }

    const item = order.items.id(itemId);
    if (!item) {
      return res.status(404).json({ 
        success: false, 
        message: 'Order item not found' 
      });
    }

    const returnRequest = await Return.create({
      order: orderId,
      orderItem: {
        product: item.product,
        quantity: item.quantity
      },
      user: req.user.id,
      seller: item.seller,
      reason,
      description,
      images,
      refundAmount: item.totalPrice
    });

    res.json({
      success: true,
      message: 'Return request submitted successfully',
      return: returnRequest
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to request return', 
      error: error.message 
    });
  }
};

/**
 * Get wallet info
 */
exports.getWallet = async (req, res) => {
  try {
    const balance = await walletService.getBalance(req.user.id);
    const transactions = await walletService.getTransactions(req.user.id, 1, 10);

    res.json({
      success: true,
      wallet: {
        balance,
        recentTransactions: transactions.transactions
      }
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to fetch wallet', 
      error: error.message 
    });
  }
};

/**
 * Get wallet transactions
 */
exports.getWalletTransactions = async (req, res) => {
  try {
    const { page = 1, limit = 20, category } = req.query;

    const result = await walletService.getTransactions(
      req.user.id,
      parseInt(page),
      parseInt(limit),
      category
    );

    res.json({
      success: true,
      ...result
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Failed to fetch transactions', 
      error: error.message 
    });
  }
};
