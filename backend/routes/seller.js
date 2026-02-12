const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { authMiddleware, authorize } = require('../middleware/auth');
const sellerController = require('../controllers/sellerController');

// @route   POST /api/seller/register
// @desc    Register as seller
// @access  Private
router.post('/register', [
  authMiddleware,
  body('businessName').trim().notEmpty().withMessage('Business name is required'),
  body('businessAddress').trim().notEmpty().withMessage('Business address is required'),
  body('gstNumber').optional().trim(),
  body('panNumber').optional().trim(),
  body('bankDetails.accountNumber').trim().notEmpty(),
  body('bankDetails.ifscCode').trim().notEmpty(),
  body('bankDetails.accountHolderName').trim().notEmpty()
], sellerController.registerSeller);

// @route   GET /api/seller/profile
// @desc    Get seller profile
// @access  Private
router.get('/profile', authMiddleware, authorize('seller'), sellerController.getProfile);

// @route   POST /api/seller/products
// @desc    Add new product
// @access  Private (Sellers only)
router.post('/products', [
  authMiddleware,
  authorize('seller'),
  body('name').trim().notEmpty().withMessage('Product name is required'),
  body('category').notEmpty().withMessage('Category is required'),
  body('price').isFloat({ min: 0 }).withMessage('Valid price is required'),
  body('unit').trim().notEmpty().withMessage('Unit is required'),
  body('stock').isInt({ min: 0 }).withMessage('Valid stock is required'),
  body('moq').optional().isInt({ min: 1 })
], sellerController.addProduct);

// @route   GET /api/seller/products
// @desc    Get seller's products
// @access  Private (Sellers only)
router.get('/products', authMiddleware, authorize('seller'), sellerController.getProducts);

// @route   PUT /api/seller/products/:id
// @desc    Update product
// @access  Private (Sellers only)
router.put('/products/:id', [
  authMiddleware,
  authorize('seller'),
  body('name').optional().trim(),
  body('price').optional().isFloat({ min: 0 }),
  body('stock').optional().isInt({ min: 0 })
], sellerController.updateProduct);

// @route   DELETE /api/seller/products/:id
// @desc    Delete product
// @access  Private (Sellers only)
router.delete('/products/:id', authMiddleware, authorize('seller'), sellerController.deleteProduct);

// @route   GET /api/seller/orders
// @desc    Get seller's orders
// @access  Private (Sellers only)
router.get('/orders', authMiddleware, authorize('seller'), sellerController.getOrders);

// @route   PUT /api/seller/orders/:id/status
// @desc    Update order status
// @access  Private (Sellers only)
router.put('/orders/:id/status', [
  authMiddleware,
  authorize('seller'),
  body('status').isIn(['processing', 'confirmed', 'packed', 'shipped']).withMessage('Invalid status')
], sellerController.updateOrderStatus);

// @route   GET /api/seller/wallet
// @desc    Get seller wallet
// @access  Private (Sellers only)
router.get('/wallet', authMiddleware, authorize('seller'), sellerController.getWallet);

// @route   GET /api/seller/wallet/transactions
// @desc    Get wallet transactions
// @access  Private (Sellers only)
router.get('/wallet/transactions', authMiddleware, authorize('seller'), sellerController.getWalletTransactions);

// @route   GET /api/seller/analytics
// @desc    Get seller analytics
// @access  Private (Sellers only)
router.get('/analytics', authMiddleware, authorize('seller'), sellerController.getAnalytics);

module.exports = router;
