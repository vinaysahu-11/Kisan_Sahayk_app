const express = require('express');
const mongoose = require('mongoose');

const labourBookingSchema = new mongoose.Schema({
  farmerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  labourId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  workType: {
    type: String,
    required: true,
    enum: ['Harvesting', 'Planting', 'Ploughing', 'Irrigation', 'Pesticide', 'Other']
  },
  duration: {
    type: Number, // in hours
    required: true
  },
  wage: {
    type: Number,
    required: true
  },
  workDate: {
    type: Date,
    required: true
  },
  location: {
    address: String,
    latitude: Number,
    longitude: Number
  },
  status: {
    type: String,
    enum: ['pending', 'accepted', 'ongoing', 'completed', 'cancelled'],
    default: 'pending'
  },
  rating: {
    type: Number,
    min: 1,
    max: 5
  },
  review: String,
  paymentStatus: {
    type: String,
    enum: ['pending', 'paid'],
    default: 'pending'
  },
  statusHistory: [{
    status: String,
    timestamp: {
      type: Date,
      default: Date.now
    }
  }]
}, { timestamps: true });

const LabourBooking = mongoose.model('LabourBooking', labourBookingSchema);

const router = express.Router();
const { authMiddleware, authorize } = require('../middleware/auth');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');

// Get available labour workers
router.get('/workers', authMiddleware, async (req, res) => {
  try {
    const { workType, location, page = 1, limit = 20 } = req.query;

    let query = { role: 'labour' };

    // Filter by work type if provided
    if (workType) {
      query.workType = workType;
    }

    const workers = await User.find(query)
      .select('fullName phoneNumber addresses rating')
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const count = await User.countDocuments(query);

    res.json({
      workers,
      totalPages: Math.ceil(count / limit),
      currentPage: page,
      total: count
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get worker details
router.get('/workers/:id', authMiddleware, async (req, res) => {
  try {
    const worker = await User.findOne({
      _id: req.params.id,
      role: 'labour'
    }).select('fullName phoneNumber addresses rating');

    if (!worker) {
      return res.status(404).json({ error: 'Worker not found' });
    }

    // Get completed bookings count
    const completedBookings = await LabourBooking.countDocuments({
      labourId: req.params.id,
      status: 'completed'
    });

    res.json({ 
      worker, 
      completedBookings 
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Book labour
router.post('/bookings', [
  authMiddleware,
  body('labourId').notEmpty(),
  body('workType').isIn(['Harvesting', 'Planting', 'Ploughing', 'Irrigation', 'Pesticide', 'Other']),
  body('duration').isInt({ min: 1 }),
  body('wage').isFloat({ min: 0 }),
  body('workDate').isISO8601(),
  body('location.address').trim().notEmpty()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { labourId, workType, duration, wage, workDate, location } = req.body;

    // Verify labour exists
    const labour = await User.findOne({ _id: labourId, role: 'labour' });
    if (!labour) {
      return res.status(404).json({ error: 'Labour worker not found' });
    }

    const booking = new LabourBooking({
      farmerId: req.user.userId,
      labourId,
      workType,
      duration,
      wage,
      workDate: new Date(workDate),
      location,
      statusHistory: [{
        status: 'pending',
        timestamp: new Date()
      }]
    });

    await booking.save();

    res.status(201).json({ 
      message: 'Labour booking created successfully', 
      booking 
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get farmer's bookings
router.get('/bookings', authMiddleware, async (req, res) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;

    let query = { farmerId: req.user.userId };
    if (status) {
      query.status = status;
    }

    const bookings = await LabourBooking.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('labourId', 'fullName phoneNumber');

    const count = await LabourBooking.countDocuments(query);

    res.json({
      bookings,
      totalPages: Math.ceil(count / limit),
      currentPage: page,
      total: count
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get labour worker's bookings
router.get('/my-bookings', authMiddleware, authorize('labour'), async (req, res) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;

    let query = { labourId: req.user.userId };
    if (status) {
      query.status = status;
    }

    const bookings = await LabourBooking.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('farmerId', 'fullName phoneNumber addresses');

    const count = await LabourBooking.countDocuments(query);

    res.json({
      bookings,
      totalPages: Math.ceil(count / limit),
      currentPage: page,
      total: count
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get booking details
router.get('/bookings/:id', authMiddleware, async (req, res) => {
  try {
    const booking = await LabourBooking.findOne({
      _id: req.params.id,
      $or: [
        { farmerId: req.user.userId },
        { labourId: req.user.userId }
      ]
    })
      .populate('farmerId', 'fullName phoneNumber addresses')
      .populate('labourId', 'fullName phoneNumber');

    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    res.json(booking);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Accept booking (by labour)
router.put('/bookings/:id/accept', authMiddleware, authorize('labour'), async (req, res) => {
  try {
    const booking = await LabourBooking.findOne({
      _id: req.params.id,
      labourId: req.user.userId
    });

    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    if (booking.status !== 'pending') {
      return res.status(400).json({ 
        error: 'Booking can only be accepted when status is pending' 
      });
    }

    booking.status = 'accepted';
    booking.statusHistory.push({
      status: 'accepted',
      timestamp: new Date()
    });

    await booking.save();

    res.json({ message: 'Booking accepted successfully', booking });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Start work (by labour)
router.put('/bookings/:id/start', authMiddleware, authorize('labour'), async (req, res) => {
  try {
    const booking = await LabourBooking.findOne({
      _id: req.params.id,
      labourId: req.user.userId
    });

    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    if (booking.status !== 'accepted') {
      return res.status(400).json({ 
        error: 'Booking must be accepted before starting work' 
      });
    }

    booking.status = 'ongoing';
    booking.statusHistory.push({
      status: 'ongoing',
      timestamp: new Date()
    });

    await booking.save();

    res.json({ message: 'Work started successfully', booking });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Complete work (by labour)
router.put('/bookings/:id/complete', authMiddleware, authorize('labour'), async (req, res) => {
  try {
    const booking = await LabourBooking.findOne({
      _id: req.params.id,
      labourId: req.user.userId
    });

    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    if (booking.status !== 'ongoing') {
      return res.status(400).json({ 
        error: 'Work must be ongoing before completing' 
      });
    }

    booking.status = 'completed';
    booking.statusHistory.push({
      status: 'completed',
      timestamp: new Date()
    });

    await booking.save();

    res.json({ message: 'Work completed successfully', booking });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Cancel booking
router.put('/bookings/:id/cancel', authMiddleware, async (req, res) => {
  try {
    const booking = await LabourBooking.findOne({
      _id: req.params.id,
      $or: [
        { farmerId: req.user.userId },
        { labourId: req.user.userId }
      ]
    });

    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    if (!['pending', 'accepted'].includes(booking.status)) {
      return res.status(400).json({ 
        error: 'Booking cannot be cancelled at this stage' 
      });
    }

    booking.status = 'cancelled';
    booking.statusHistory.push({
      status: 'cancelled',
      timestamp: new Date()
    });

    await booking.save();

    res.json({ message: 'Booking cancelled successfully', booking });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Rate labour worker (by farmer)
router.post('/bookings/:id/rate', [
  authMiddleware,
  body('rating').isInt({ min: 1, max: 5 }),
  body('review').optional().trim()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const booking = await LabourBooking.findOne({
      _id: req.params.id,
      farmerId: req.user.userId
    });

    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    if (booking.status !== 'completed') {
      return res.status(400).json({ 
        error: 'Can only rate completed bookings' 
      });
    }

    if (booking.rating) {
      return res.status(400).json({ error: 'Booking already rated' });
    }

    booking.rating = req.body.rating;
    booking.review = req.body.review;
    await booking.save();

    // Update labour worker's average rating
    const ratings = await LabourBooking.find({
      labourId: booking.labourId,
      rating: { $exists: true, $ne: null }
    }).select('rating');

    if (ratings.length > 0) {
      const avgRating = ratings.reduce((sum, b) => sum + b.rating, 0) / ratings.length;
      await User.findByIdAndUpdate(booking.labourId, { 
        rating: avgRating 
      });
    }

    res.json({ message: 'Rating submitted successfully', booking });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
