const TransportBooking = require('../models/TransportBooking');
const User = require('../models/User');
const Rating = require('../models/Rating');
const { walletService } = require('../services/walletService');

// Vehicle types with base rates (per km)
const VEHICLE_TYPES = [
  { type: 'Tractor', capacity: '1-2 tons', baseRate: 15 },
  { type: 'Mini Truck', capacity: '2-3 tons', baseRate: 20 },
  { type: 'Small Truck', capacity: '3-5 tons', baseRate: 25 },
  { type: 'Medium Truck', capacity: '5-10 tons', baseRate: 35 },
  { type: 'Large Truck', capacity: '10+ tons', baseRate: 50 }
];

// @desc    Get vehicle types
// @route   GET /api/transport/vehicle-types
// @access  Public
exports.getVehicleTypes = async (req, res) => {
  try {
    res.json({ vehicleTypes: VEHICLE_TYPES });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch vehicle types', message: error.message });
  }
};

// @desc    Calculate fare
// @route   POST /api/transport/calculate-fare
// @access  Public
exports.calculateFare = async (req, res) => {
  try {
    const { vehicleType, distance, loadWeight } = req.body;

    const vehicle = VEHICLE_TYPES.find(v => v.type === vehicleType);
    if (!vehicle) {
      return res.status(400).json({ error: 'Invalid vehicle type' });
    }

    // Base fare
    let fare = vehicle.baseRate * Number(distance);

    // Weight surcharge (if load > 80% of capacity)
    const maxCapacity = parseInt(vehicle.capacity);
    if (loadWeight > maxCapacity * 0.8) {
      fare *= 1.2; // 20% surcharge
    }

    // Minimum fare
    fare = Math.max(fare, 200);

    // GST
    const gst = fare * 0.05; // 5% GST
    const total = fare + gst;

    res.json({
      vehicleType,
      distance: Number(distance),
      baseFare: Math.round(fare),
      gst: Math.round(gst),
      totalFare: Math.round(total)
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to calculate fare', message: error.message });
  }
};

// @desc    Create transport booking
// @route   POST /api/transport/bookings
// @access  Private
exports.createBooking = async (req, res) => {
  try {
    const {
      vehicleType,
      loadType,
      loadWeight,
      pickupLocation,
      dropLocation,
      distance,
      scheduledDate,
      fare,
      notes
    } = req.body;

    const vehicle = VEHICLE_TYPES.find(v => v.type === vehicleType);
    if (!vehicle) {
      return res.status(400).json({ error: 'Invalid vehicle type' });
    }

    const booking = new TransportBooking({
      user: req.user.userId,
      vehicleType,
      loadType,
      loadWeight,
      pickupLocation,
      dropLocation,
      distance,
      scheduledDate,
      fare: {
        baseFare: fare.baseFare,
        gst: fare.gst,
        total: fare.total
      },
      notes,
      status: 'pending'
    });

    await booking.save();

    // Process payment from wallet
    if (req.body.payNow) {
      await walletService.processOrderPayment(
        req.user.userId,
        booking._id,
        fare.total
      );

      booking.payment.status = 'paid';
      booking.payment.method = 'wallet';
      booking.payment.paidAt = new Date();
      await booking.save();
    }

    res.status(201).json({
      message: 'Transport booking created successfully',
      booking
    });
  } catch (error) {
    console.error('Create transport booking error:', error);
    res.status(500).json({ error: 'Failed to create booking', message: error.message });
  }
};

// @desc    Get user's bookings
// @route   GET /api/transport/bookings
// @access  Private
exports.getBookings = async (req, res) => {
  try {
    const { page = 1, limit = 20, status } = req.query;

    const query = { user: req.user.userId };
    if (status) query.status = status;

    const bookings = await TransportBooking.find(query)
      .populate('assignedPartner', 'name phone')
      .sort({ scheduledDate: -1 })
      .limit(Number(limit))
      .skip((Number(page) - 1) * Number(limit));

    const total = await TransportBooking.countDocuments(query);

    res.json({
      bookings,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch bookings', message: error.message });
  }
};

// @desc    Get booking details
// @route   GET /api/transport/bookings/:id
// @access  Private
exports.getBookingById = async (req, res) => {
  try {
    const booking = await TransportBooking.findOne({
      _id: req.params.id,
      user: req.user.userId
    })
      .populate('assignedPartner', 'name phone email rating')
      .populate('user', 'name phone');

    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    res.json({ booking });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch booking', message: error.message });
  }
};

// @desc    Cancel booking
// @route   PUT /api/transport/bookings/:id/cancel
// @access  Private
exports.cancelBooking = async (req, res) => {
  try {
    const { reason } = req.body;
    
    const booking = await TransportBooking.findOne({
      _id: req.params.id,
      user: req.user.userId
    });

    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    if (!['pending', 'confirmed'].includes(booking.status)) {
      return res.status(400).json({ 
        error: 'Cannot cancel booking in current status' 
      });
    }

    booking.status = 'cancelled';
    booking.cancellationReason = reason;
    await booking.save();

    // Refund if payment was made
    if (booking.payment && booking.payment.status === 'paid') {
      await walletService.processRefund(
        req.user.userId,
        booking._id,
        booking.fare.total
      );
    }

    res.json({
      message: 'Booking cancelled successfully',
      booking
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to cancel booking', message: error.message });
  }
};

// @desc    Rate transport partner
// @route   POST /api/transport/bookings/:id/rate
// @access  Private
exports.ratePartner = async (req, res) => {
  try {
    const { rating, review } = req.body;
    
    const booking = await TransportBooking.findOne({
      _id: req.params.id,
      user: req.user.userId,
      status: 'completed'
    });

    if (!booking) {
      return res.status(404).json({ 
        error: 'Booking not found or not completed' 
      });
    }

    if (!booking.assignedPartner) {
      return res.status(400).json({ error: 'No partner assigned to rate' });
    }

    // Check if already rated
    const existingRating = await Rating.findOne({
      ratedBy: req.user.userId,
      ratedEntity: booking.assignedPartner,
      referenceType: 'transport_booking',
      reference: booking._id
    });

    if (existingRating) {
      return res.status(400).json({ error: 'Already rated this booking' });
    }

    // Create rating
    const newRating = new Rating({
      ratedBy: req.user.userId,
      ratedEntity: booking.assignedPartner,
      ratedEntityType: 'User',
      referenceType: 'transport_booking',
      reference: booking._id,
      rating: Number(rating),
      review
    });

    await newRating.save();

    // Update partner's average rating
    const partner = await User.findById(booking.assignedPartner);
    const allRatings = await Rating.find({ ratedEntity: booking.assignedPartner });
    const avgRating = allRatings.reduce((sum, r) => sum + r.rating, 0) / allRatings.length;
    
    partner.rating.average = avgRating;
    partner.rating.count = allRatings.length;
    await partner.save();

    res.status(201).json({
      message: 'Rating submitted successfully',
      rating: newRating
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to submit rating', message: error.message });
  }
};

// @desc    Update booking status (Partner side)
// @route   PUT /api/transport/bookings/:id/status
// @access  Private (Transport partners only)
exports.updateStatus = async (req, res) => {
  try {
    const { status } = req.body;
    
    const validStatuses = ['assigned', 'accepted', 'in_progress', 'completed'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const booking = await TransportBooking.findOne({
      _id: req.params.id,
      assignedPartner: req.user.userId
    });

    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    // Status flow validation
    const statusFlow = {
      'pending': ['assigned'],
      'assigned': ['accepted', 'cancelled'],
      'accepted': ['in_progress', 'cancelled'],
      'in_progress': ['completed', 'cancelled'],
      'completed': [],
      'cancelled': []
    };

    if (!statusFlow[booking.status].includes(status)) {
      return res.status(400).json({ 
        error: `Cannot change status from ${booking.status} to ${status}` 
      });
    }

    booking.status = status;
    
    // Set timestamps
    if (status === 'accepted') booking.acceptedAt = new Date();
    if (status === 'in_progress') booking.startedAt = new Date();
    if (status === 'completed') {
      booking.completedAt = new Date();
      
      // Process commission and wallet credit
      const commissionRate = 10; // 10% commission
      const commission = (booking.fare.total * commissionRate) / 100;
      const partnerEarnings = booking.fare.total - commission;

      // Credit partner wallet
      await walletService.creditWallet(
        req.user.userId,
        partnerEarnings,
        'transport_earnings',
        booking._id,
        `Earnings from transport booking #${booking._id}`
      );

      // Record commission
      await walletService.creditWallet(
        'platform',
        commission,
        'commission',
        booking._id,
        `Commission from transport booking #${booking._id}`
      );
    }

    await booking.save();

    res.json({
      message: 'Status updated successfully',
      booking
    });
  } catch (error) {
    console.error('Update status error:', error);
    res.status(500).json({ error: 'Failed to update status', message: error.message });
  }
};

// @desc    Get available transport partners
// @route   GET /api/transport/partners/available
// @access  Private
exports.getAvailablePartners = async (req, res) => {
  try {
    const { vehicleType, page = 1, limit = 20 } = req.query;

    const query = { 
      role: 'transport_partner',
      isActive: true,
      'transportDetails.isApproved': true,
      'transportDetails.isAvailable': true
    };

    if (vehicleType) {
      query['transportDetails.vehicleType'] = vehicleType;
    }

    const partners = await User.find(query)
      .select('name phone rating transportDetails')
      .sort({ 'rating.average': -1 })
      .limit(Number(limit))
      .skip((Number(page) - 1) * Number(limit));

    const total = await User.countDocuments(query);

    res.json({
      partners,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch partners', message: error.message });
  }
};

module.exports = exports;
