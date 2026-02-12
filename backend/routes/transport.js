const express = require('express');
const mongoose = require('mongoose');

const transportBookingSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  driverId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  vehicleType: {
    type: String,
    required: true,
    enum: ['Truck', 'Tractor', 'Mini Truck', 'Tempo', 'Other']
  },
  loadType: {
    type: String,
    required: true
  },
  weight: {
    type: Number, // in KG
    required: true
  },
  pickupLocation: {
    address: {
      type: String,
      required: true
    },
    latitude: Number,
    longitude: Number
  },
  dropLocation: {
    address: {
      type: String,
      required: true
    },
    latitude: Number,
    longitude: Number
  },
  pickupDate: {
    type: Date,
    required: true
  },
  fare: {
    type: Number,
    required: true
  },
  distance: Number, // in KM
  estimatedTime: Number, // in minutes
  status: {
    type: String,
    enum: ['pending', 'accepted', 'picked', 'inTransit', 'delivered', 'completed', 'cancelled'],
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
  trackingNumber: String,
  statusHistory: [{
    status: String,
    timestamp: {
      type: Date,
      default: Date.now
    },
    location: {
      latitude: Number,
      longitude: Number
    }
  }]
}, { timestamps: true });

const TransportBooking = mongoose.model('TransportBooking', transportBookingSchema);

const router = express.Router();
const { authMiddleware, authorize } = require('../middleware/auth');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');

// Get available transport drivers
router.get('/drivers', authMiddleware, async (req, res) => {
  try {
    const { vehicleType, page = 1, limit = 20 } = req.query;

    let query = { role: 'transport' };

    if (vehicleType) {
      query.vehicleType = vehicleType;
    }

    const drivers = await User.find(query)
      .select('fullName phoneNumber addresses rating')
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const count = await User.countDocuments(query);

    res.json({
      drivers,
      totalPages: Math.ceil(count / limit),
      currentPage: page,
      total: count
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get driver details
router.get('/drivers/:id', authMiddleware, async (req, res) => {
  try {
    const driver = await User.findOne({
      _id: req.params.id,
      role: 'transport'
    }).select('fullName phoneNumber addresses rating');

    if (!driver) {
      return res.status(404).json({ error: 'Driver not found' });
    }

    // Get completed trips count
    const completedTrips = await TransportBooking.countDocuments({
      driverId: req.params.id,
      status: 'completed'
    });

    res.json({ 
      driver, 
      completedTrips 
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Book transport
router.post('/bookings', [
  authMiddleware,
  body('driverId').notEmpty(),
  body('vehicleType').isIn(['Truck', 'Tractor', 'Mini Truck', 'Tempo', 'Other']),
  body('loadType').trim().notEmpty(),
  body('weight').isFloat({ min: 0 }),
  body('pickupLocation.address').trim().notEmpty(),
  body('dropLocation.address').trim().notEmpty(),
  body('pickupDate').isISO8601(),
  body('fare').isFloat({ min: 0 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { 
      driverId, 
      vehicleType, 
      loadType, 
      weight, 
      pickupLocation, 
      dropLocation, 
      pickupDate, 
      fare,
      distance,
      estimatedTime
    } = req.body;

    // Verify driver exists
    const driver = await User.findOne({ _id: driverId, role: 'transport' });
    if (!driver) {
      return res.status(404).json({ error: 'Driver not found' });
    }

    const booking = new TransportBooking({
      userId: req.user.userId,
      driverId,
      vehicleType,
      loadType,
      weight,
      pickupLocation,
      dropLocation,
      pickupDate: new Date(pickupDate),
      fare,
      distance,
      estimatedTime,
      trackingNumber: `TRK${Date.now()}`,
      statusHistory: [{
        status: 'pending',
        timestamp: new Date()
      }]
    });

    await booking.save();

    res.status(201).json({ 
      message: 'Transport booking created successfully', 
      booking 
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get user's bookings
router.get('/bookings', authMiddleware, async (req, res) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;

    let query = { userId: req.user.userId };
    if (status) {
      query.status = status;
    }

    const bookings = await TransportBooking.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('driverId', 'fullName phoneNumber');

    const count = await TransportBooking.countDocuments(query);

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

// Get driver's bookings
router.get('/my-bookings', authMiddleware, authorize('transport'), async (req, res) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;

    let query = { driverId: req.user.userId };
    if (status) {
      query.status = status;
    }

    const bookings = await TransportBooking.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('userId', 'fullName phoneNumber');

    const count = await TransportBooking.countDocuments(query);

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
    const booking = await TransportBooking.findOne({
      _id: req.params.id,
      $or: [
        { userId: req.user.userId },
        { driverId: req.user.userId }
      ]
    })
      .populate('userId', 'fullName phoneNumber')
      .populate('driverId', 'fullName phoneNumber');

    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    res.json(booking);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Accept booking (by driver)
router.put('/bookings/:id/accept', authMiddleware, authorize('transport'), async (req, res) => {
  try {
    const booking = await TransportBooking.findOne({
      _id: req.params.id,
      driverId: req.user.userId
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

// Pickup load (by driver)
router.put('/bookings/:id/pickup', [
  authMiddleware,
  authorize('transport'),
  body('location.latitude').optional().isFloat(),
  body('location.longitude').optional().isFloat()
], async (req, res) => {
  try {
    const booking = await TransportBooking.findOne({
      _id: req.params.id,
      driverId: req.user.userId
    });

    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    if (booking.status !== 'accepted') {
      return res.status(400).json({ 
        error: 'Booking must be accepted before pickup' 
      });
    }

    booking.status = 'picked';
    booking.statusHistory.push({
      status: 'picked',
      timestamp: new Date(),
      location: req.body.location
    });

    await booking.save();

    res.json({ message: 'Load picked up successfully', booking });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Start transit (by driver)
router.put('/bookings/:id/transit', [
  authMiddleware,
  authorize('transport'),
  body('location.latitude').optional().isFloat(),
  body('location.longitude').optional().isFloat()
], async (req, res) => {
  try {
    const booking = await TransportBooking.findOne({
      _id: req.params.id,
      driverId: req.user.userId
    });

    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    if (booking.status !== 'picked') {
      return res.status(400).json({ 
        error: 'Load must be picked before transit' 
      });
    }

    booking.status = 'inTransit';
    booking.statusHistory.push({
      status: 'inTransit',
      timestamp: new Date(),
      location: req.body.location
    });

    await booking.save();

    res.json({ message: 'Transit started successfully', booking });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Deliver load (by driver)
router.put('/bookings/:id/deliver', [
  authMiddleware,
  authorize('transport'),
  body('location.latitude').optional().isFloat(),
  body('location.longitude').optional().isFloat()
], async (req, res) => {
  try {
    const booking = await TransportBooking.findOne({
      _id: req.params.id,
      driverId: req.user.userId
    });

    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    if (booking.status !== 'inTransit') {
      return res.status(400).json({ 
        error: 'Load must be in transit before delivery' 
      });
    }

    booking.status = 'delivered';
    booking.statusHistory.push({
      status: 'delivered',
      timestamp: new Date(),
      location: req.body.location
    });

    await booking.save();

    res.json({ message: 'Load delivered successfully', booking });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Complete booking (by user after delivery)
router.put('/bookings/:id/complete', authMiddleware, async (req, res) => {
  try {
    const booking = await TransportBooking.findOne({
      _id: req.params.id,
      userId: req.user.userId
    });

    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    if (booking.status !== 'delivered') {
      return res.status(400).json({ 
        error: 'Booking must be delivered before completion' 
      });
    }

    booking.status = 'completed';
    booking.statusHistory.push({
      status: 'completed',
      timestamp: new Date()
    });

    await booking.save();

    res.json({ message: 'Booking completed successfully', booking });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Cancel booking
router.put('/bookings/:id/cancel', authMiddleware, async (req, res) => {
  try {
    const booking = await TransportBooking.findOne({
      _id: req.params.id,
      $or: [
        { userId: req.user.userId },
        { driverId: req.user.userId }
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

// Rate driver (by user)
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

    const booking = await TransportBooking.findOne({
      _id: req.params.id,
      userId: req.user.userId
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

    // Update driver's average rating
    const ratings = await TransportBooking.find({
      driverId: booking.driverId,
      rating: { $exists: true, $ne: null }
    }).select('rating');

    if (ratings.length > 0) {
      const avgRating = ratings.reduce((sum, b) => sum + b.rating, 0) / ratings.length;
      await User.findByIdAndUpdate(booking.driverId, { 
        rating: avgRating 
      });
    }

    res.json({ message: 'Rating submitted successfully', booking });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Track booking location
router.get('/bookings/:id/track', authMiddleware, async (req, res) => {
  try {
    const booking = await TransportBooking.findOne({
      _id: req.params.id,
      $or: [
        { userId: req.user.userId },
        { driverId: req.user.userId }
      ]
    }).select('status statusHistory trackingNumber');

    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    res.json({
      trackingNumber: booking.trackingNumber,
      currentStatus: booking.status,
      history: booking.statusHistory
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
