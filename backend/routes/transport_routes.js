const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { authMiddleware, authorize } = require('../middleware/auth');
const transportController = require('../controllers/transportController');

// @route   GET /api/transport/vehicle-types
// @desc    Get vehicle types
// @access  Public
router.get('/vehicle-types', transportController.getVehicleTypes);

// @route   POST /api/transport/calculate-fare
// @desc    Calculate fare
// @access  Public
router.post('/calculate-fare', [
  body('vehicleType').trim().notEmpty().withMessage('Vehicle type is required'),
  body('distance').isFloat({ min: 0 }).withMessage('Valid distance is required'),
  body('loadWeight').optional().isFloat({ min: 0 })
], transportController.calculateFare);

// @route   POST /api/transport/bookings
// @desc    Create transport booking
// @access  Private
router.post('/bookings', [
  authMiddleware,
  body('vehicleType').trim().notEmpty().withMessage('Vehicle type is required'),
  body('loadType').trim().notEmpty().withMessage('Load type is required'),
  body('loadWeight').isFloat({ min: 0 }).withMessage('Valid load weight is required'),
  body('pickupLocation').notEmpty().withMessage('Pickup location is required'),
  body('dropLocation').notEmpty().withMessage('Drop location is required'),
  body('distance').isFloat({ min: 0 }).withMessage('Valid distance is required'),
  body('scheduledDate').isISO8601().withMessage('Valid date is required'),
  body('fare').notEmpty().withMessage('Fare details are required')
], transportController.createBooking);

// @route   GET /api/transport/bookings
// @desc    Get user's bookings
// @access  Private
router.get('/bookings', authMiddleware, transportController.getBookings);

// @route   GET /api/transport/bookings/:id
// @desc    Get booking details
// @access  Private
router.get('/bookings/:id', authMiddleware, transportController.getBookingById);

// @route   PUT /api/transport/bookings/:id/cancel
// @desc    Cancel booking
// @access  Private
router.put('/bookings/:id/cancel', [
  authMiddleware,
  body('reason').optional().trim()
], transportController.cancelBooking);

// @route   POST /api/transport/bookings/:id/rate
// @desc    Rate transport partner
// @access  Private
router.post('/bookings/:id/rate', [
  authMiddleware,
  body('rating').isInt({ min: 1, max: 5 }).withMessage('Rating must be between 1-5'),
  body('review').optional().trim()
], transportController.ratePartner);

// @route   PUT /api/transport/bookings/:id/status
// @desc    Update booking status (Partner side)
// @access  Private (Transport partners only)
router.put('/bookings/:id/status', [
  authMiddleware,
  authorize('transport_partner'),
  body('status').isIn(['assigned', 'accepted', 'in_progress', 'completed']).withMessage('Invalid status')
], transportController.updateStatus);

// @route   GET /api/transport/partners/available
// @desc    Get available transport partners
// @access  Private
router.get('/partners/available', authMiddleware, transportController.getAvailablePartners);

module.exports = router;
