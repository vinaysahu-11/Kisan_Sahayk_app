const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { authMiddleware, authorize } = require('../middleware/auth');
const deliveryController = require('../controllers/deliveryController');

// @route   POST /api/delivery/register
// @desc    Register as delivery partner
// @access  Private
router.post('/register', [
  authMiddleware,
  body('vehicleType').trim().notEmpty().withMessage('Vehicle type is required'),
  body('vehicleNumber').trim().notEmpty().withMessage('Vehicle number is required'),
  body('licenseNumber').trim().notEmpty().withMessage('License number is required'),
  body('aadhar').trim().notEmpty().withMessage('Aadhar number is required')
], deliveryController.registerPartner);

// @route   GET /api/delivery/orders
// @desc    Get assigned delivery orders
// @access  Private (Delivery partners only)
router.get('/orders', authMiddleware, authorize('delivery_partner'), deliveryController.getAssignedOrders);

// @route   PUT /api/delivery/orders/:id/accept
// @desc    Accept delivery order
// @access  Private (Delivery partners only)
router.put('/orders/:id/accept', authMiddleware, authorize('delivery_partner'), deliveryController.acceptOrder);

// @route   PUT /api/delivery/orders/:id/complete
// @desc    Complete delivery with OTP verification
// @access  Private (Delivery partners only)
router.put('/orders/:id/complete', [
  authMiddleware,
  authorize('delivery_partner'),
  body('otp').trim().notEmpty().withMessage('OTP is required'),
  body('codAmount').optional().isFloat({ min: 0 })
], deliveryController.completeDelivery);

// @route   GET /api/delivery/earnings
// @desc    Get delivery earnings
// @access  Private (Delivery partners only)
router.get('/earnings', authMiddleware, authorize('delivery_partner'), deliveryController.getEarnings);

// @route   GET /api/delivery/performance
// @desc    Get delivery performance metrics
// @access  Private (Delivery partners only)
router.get('/performance', authMiddleware, authorize('delivery_partner'), deliveryController.getPerformance);

// @route   POST /api/delivery/cod-settlement
// @desc    Settle COD amount
// @access  Private (Delivery partners only)
router.post('/cod-settlement', [
  authMiddleware,
  authorize('delivery_partner'),
  body('orderIds').isArray().withMessage('Order IDs array is required'),
  body('amount').isFloat({ min: 0 }).withMessage('Valid amount is required')
], deliveryController.settleCOD);

module.exports = router;
