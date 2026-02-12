const mongoose = require('mongoose');

const labourBookingSchema = new mongoose.Schema({
  bookingNumber: {
    type: String,
    required: true,
    unique: true
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  skill: {
    type: String,
    required: true,
    enum: ['ploughing', 'harvesting', 'sowing', 'weeding', 'irrigation', 'pesticide_spray', 'general_farm_work']
  },
  numberOfWorkers: {
    type: Number,
    required: true,
    min: 1
  },
  duration: {
    hours: Number,
    days: Number
  },
  date: {
    type: Date,
    required: true
  },
  location: {
    address: String,
    city: String,
    state: String,
    pincode: String,
    coordinates: {
      latitude: Number,
      longitude: Number
    }
  },
  assignedPartner: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  status: {
    type: String,
    enum: ['pending', 'assigned', 'confirmed', 'in_progress', 'completed', 'cancelled'],
    default: 'pending'
  },
  pricing: {
    basePrice: Number,
    perWorkerRate: Number,
    totalAmount: Number,
    advanceAmount: Number,
    remainingAmount: Number
  },
  payment: {
    method: { type: String, enum: ['cash', 'online', 'wallet'] },
    status: { type: String, enum: ['pending', 'advance_paid', 'completed'], default: 'pending' },
    paidAmount: { type: Number, default: 0 },
    transactionId: String,
    paidAt: Date
  },
  rating: {
    rating: { type: Number, min: 1, max: 5 },
    review: String,
    ratedAt: Date
  },
  cancellation: {
    cancelledBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    reason: String,
    cancelledAt: Date
  },
  completedAt: Date
}, {
  timestamps: true
});

// bookingNumber already has unique index from unique: true
labourBookingSchema.index({ user: 1 });
labourBookingSchema.index({ assignedPartner: 1 });
labourBookingSchema.index({ status: 1 });
labourBookingSchema.index({ date: 1 });

// Generate booking number
labourBookingSchema.pre('save', async function(next) {
  if (this.isNew && !this.bookingNumber) {
    const count = await mongoose.model('LabourBooking').countDocuments();
    this.bookingNumber = `LB${Date.now()}${count + 1}`;
  }
  next();
});

module.exports = mongoose.model('LabourBooking', labourBookingSchema);
