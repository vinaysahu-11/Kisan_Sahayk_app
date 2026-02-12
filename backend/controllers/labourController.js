const LabourBooking = require('../models/LabourBooking');
const User = require('../models/User');
const Rating = require('../models/Rating');
const { walletService } = require('../services/walletService');
const { commissionService } = require('../services/commissionService');

// Available skills list
const SKILLS = [
  'Harvesting', 'Ploughing', 'Weeding', 'Planting', 'Irrigation',
  'Pesticide Spraying', 'Fertilizer Application', 'Farm Cleaning',
  'Machinery Operation', 'General Farm Work'
];

// @desc    Get available skills
// @route   GET /api/labour/skills
// @access  Public
exports.getSkills = async (req, res) => {
  try {
    res.json({ skills: SKILLS });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch skills', message: error.message });
  }
};

// @desc    Create labour booking
// @route   POST /api/labour/bookings
// @access  Private
exports.createBooking = async (req, res) => {
  try {
    const {
      skill,
      workType,
      labourRequired,
      date,
      duration,
      description,
      location,
      budget
    } = req.body;

    if (!SKILLS.includes(skill)) {
      return res.status(400).json({ error: 'Invalid skill selected' });
    }

    const booking = new LabourBooking({
      user: req.user.userId,
      skill,
      workType,
      labourRequired,
      date,
      duration,
      description,
      location,
      budget,
      status: 'pending'
    });

    await booking.save();

    res.status(201).json({
      message: 'Labour booking created successfully',
      booking
    });
  } catch (error) {
    console.error('Create labour booking error:', error);
    res.status(500).json({ error: 'Failed to create booking', message: error.message });
  }
};

// @desc    Get user's bookings
// @route   GET /api/labour/bookings
// @access  Private
exports.getBookings = async (req, res) => {
  try {
    const { page = 1, limit = 20, status } = req.query;

    const query = { user: req.user.userId };
    if (status) query.status = status;

    const bookings = await LabourBooking.find(query)
      .populate('assignedPartner', 'name phone')
      .sort({ date: -1 })
      .limit(Number(limit))
      .skip((Number(page) - 1) * Number(limit));

    const total = await LabourBooking.countDocuments(query);

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
// @route   GET /api/labour/bookings/:id
// @access  Private
exports.getBookingById = async (req, res) => {
  try {
    const booking = await LabourBooking.findOne({
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
// @route   PUT /api/labour/bookings/:id/cancel
// @access  Private
exports.cancelBooking = async (req, res) => {
  try {
    const { reason } = req.body;
    
    const booking = await LabourBooking.findOne({
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
        booking.payment.amount
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

// @desc    Submit rating for labour partner
// @route   POST /api/labour/bookings/:id/rate
// @access  Private
exports.ratePartner = async (req, res) => {
  try {
    const { rating, review } = req.body;
    
    const booking = await LabourBooking.findOne({
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
      referenceType: 'labour_booking',
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
      referenceType: 'labour_booking',
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

// @desc    Get available labour partners
// @route   GET /api/labour/partners
// @access  Private
exports.getPartners = async (req, res) => {
  try {
    const { skill, page = 1, limit = 20 } = req.query;

    const query = { 
      role: 'labour_partner',
      isActive: true
    };

    const partners = await User.find(query)
      .select('name phone rating')
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

// @desc    Update booking status (Partner side)
// @route   PUT /api/labour/bookings/:id/status
// @access  Private (Labour partners only)
exports.updateStatus = async (req, res) => {
  try {
    const { status } = req.body;
    
    const validStatuses = ['assigned', 'accepted', 'work_started', 'completed'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const booking = await LabourBooking.findOne({
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
      'accepted': ['work_started', 'cancelled'],
      'work_started': ['completed', 'cancelled'],
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
    if (status === 'work_started') booking.startedAt = new Date();
    if (status === 'completed') {
      booking.completedAt = new Date();
      
      // Calculate total payment
      const totalAmount = booking.duration * booking.budget; // budget acts as rate per hour
      
      // Process commission and wallet credit
      const commissionRate = 10; // 10% commission
      const commission = (totalAmount * commissionRate) / 100;
      const partnerEarnings = totalAmount - commission;

      // Credit partner wallet
      await walletService.creditWallet(
        req.user.userId,
        partnerEarnings,
        'labour_earnings',
        booking._id,
        `Earnings from labour booking #${booking._id}`
      );

      // Record commission
      await walletService.creditWallet(
        'platform',
        commission,
        'commission',
        booking._id,
        `Commission from labour booking #${booking._id}`
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

module.exports = exports;
