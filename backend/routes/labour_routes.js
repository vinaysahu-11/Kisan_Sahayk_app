const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { authMiddleware, authorize } = require('../middleware/auth');
const labourController = require('../controllers/labourController');

// @route   GET /api/labour/skills
// @desc    Get available skills
// @access  Public
router.get('/skills', labourController.getSkills);

// @route   POST /api/labour/bookings
// @desc    Create labour booking
// @access  Private
router.post('/bookings', [
  authMiddleware,
  body('skill').trim().notEmpty().withMessage('Skill is required'),
  body('workType').trim().notEmpty().withMessage('Work type is required'),
  body('labourRequired').isInt({ min: 1 }).withMessage('At least 1 labour required'),
  body('date').isISO8601().withMessage('Valid date is required'),
  body('duration').isFloat({ min: 0.5 }).withMessage('Valid duration is required'),
  body('budget').isFloat({ min: 0 }).withMessage('Valid budget is required')
], labourController.createBooking);

// @route   GET /api/labour/bookings
// @desc    Get user's bookings
// @access  Private
router.get('/bookings', authMiddleware, labourController.getBookings);

// @route   GET /api/labour/bookings/:id
// @desc    Get booking details
// @access  Private
router.get('/bookings/:id', authMiddleware, labourController.getBookingById);

// @route   PUT /api/labour/bookings/:id/cancel
// @desc    Cancel booking
// @access  Private
router.put('/bookings/:id/cancel', [
  authMiddleware,
  body('reason').optional().trim()
], labourController.cancelBooking);

// @route   POST /api/labour/bookings/:id/rate
// @desc    Rate labour partner
// @access  Private
router.post('/bookings/:id/rate', [
  authMiddleware,
  body('rating').isInt({ min: 1, max: 5 }).withMessage('Rating must be between 1-5'),
  body('review').optional().trim()
], labourController.ratePartner);

// @route   GET /api/labour/partners
// @desc    Get available labour partners
// @access  Private
router.get('/partners', authMiddleware, labourController.getPartners);

// @route   PUT /api/labour/bookings/:id/status
// @desc    Update booking status (Partner side)
// @access  Private (Labour partners only)
router.put('/bookings/:id/status', [
  authMiddleware,
  authorize('labour_partner'),
  body('status').isIn(['assigned', 'accepted', 'work_started', 'completed']).withMessage('Invalid status')
], labourController.updateStatus);

module.exports = router;
