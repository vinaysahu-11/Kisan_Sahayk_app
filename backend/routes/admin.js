const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { authMiddleware, authorize } = require('../middleware/auth');
const adminController = require('../controllers/adminController');

// @route   PUT /api/admin/sellers/:id/approve
// @desc    Approve/reject seller
// @access  Admin only
router.put('/sellers/:id/approve', [
  authMiddleware,
  authorize('admin'),
  body('approved').isBoolean().withMessage('Approved status is required'),
  body('rejectionReason').optional().trim()
], adminController.approveSeller);

// @route   PUT /api/admin/partners/:id/approve
// @desc    Approve/reject partner
// @access  Admin only
router.put('/partners/:id/approve', [
  authMiddleware,
  authorize('admin'),
  body('approved').isBoolean().withMessage('Approved status is required'),
  body('rejectionReason').optional().trim()
], adminController.approvePartner);

// @route   PUT /api/admin/commission/:category
// @desc    Set commission rate
// @access  Admin only
router.put('/commission/:category', [
  authMiddleware,
  authorize('admin'),
  body('commissionPercentage').isFloat({ min: 0, max: 100 }).withMessage('Valid commission percentage required'),
  body('commissionType').isIn(['percentage', 'fixed']).withMessage('Commission type must be percentage or fixed')
], adminController.setCommissionRate);

// @route   POST /api/admin/wallet/adjust
// @desc    Adjust user wallet balance
// @access  Admin only
router.post('/wallet/adjust', [
  authMiddleware,
  authorize('admin'),
  body('userId').trim().notEmpty().withMessage('User ID is required'),
  body('amount').isFloat({ min: 0 }).withMessage('Valid amount is required'),
  body('type').isIn(['credit', 'debit']).withMessage('Type must be credit or debit'),
  body('description').trim().notEmpty().withMessage('Description is required')
], adminController.adjustWallet);

// @route   GET /api/admin/analytics
// @desc    Get admin analytics
// @access  Admin only
router.get('/analytics', authMiddleware, authorize('admin'), adminController.getAnalytics);

// @route   POST /api/admin/categories
// @desc    Create category
// @access  Admin only
router.post('/categories', [
  authMiddleware,
  authorize('admin'),
  body('name').trim().notEmpty().withMessage('Category name is required'),
  body('nameHi').trim().notEmpty(),
  body('nameHne').trim().notEmpty()
], adminController.createCategory);

// @route   PUT /api/admin/categories/:id
// @desc    Update category
// @access  Admin only
router.put('/categories/:id', [
  authMiddleware,
  authorize('admin'),
  body('name').optional().trim(),
  body('nameHi').optional().trim(),
  body('nameHne').optional().trim()
], adminController.updateCategory);

// @route   DELETE /api/admin/categories/:id
// @desc    Delete category
// @access  Admin only
router.delete('/categories/:id', authMiddleware, authorize('admin'), adminController.deleteCategory);

// @route   GET /api/admin/orders
// @desc    View all orders
// @access  Admin only
router.get('/orders', authMiddleware, authorize('admin'), adminController.viewAllOrders);

// @route   GET /api/admin/users
// @desc    View all users
// @access  Admin only
router.get('/users', authMiddleware, authorize('admin'), adminController.viewAllUsers);

// @route   PUT /api/admin/users/:id/toggle-status
// @desc    Toggle user active status
// @access  Admin only
router.put('/users/:id/toggle-status', authMiddleware, authorize('admin'), adminController.toggleUserStatus);

module.exports = router;
