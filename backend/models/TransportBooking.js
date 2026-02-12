const mongoose = require('mongoose');

const transportBookingSchema = new mongoose.Schema({
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
  vehicleType: {
    type: String,
    required: true,
    enum: ['mini_truck', 'pickup', 'tractor', 'tempo', 'large_truck']
  },
  loadDetails: {
    type: { type: String, enum: ['crop', 'equipment', 'fertilizer', 'other'] },
    weight: Number,
    description: String
  },
  pickupLocation: {
    address: String,
    city: String,
    state: String,
    pincode: String,
    coordinates: {
      latitude: Number,
      longitude: Number
    }
  },
  dropLocation: {
    address: String,
    city: String,
    state: String,
    pincode: String,
    coordinates: {
      latitude: Number,
      longitude: Number
    }
  },
  distance: {
    type: Number // in km
  },
  scheduledDate: {
    type: Date,
    required: true
  },
  assignedPartner: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  vehicleDetails: {
    registrationNumber: String,
    driverName: String,
    driverPhone: String
  },
  status: {
    type: String,
    enum: ['pending', 'assigned', 'confirmed', 'picked_up', 'in_transit', 'delivered', 'cancelled'],
    default: 'pending'
  },
  pricing: {
    baseFare: Number,
    perKmRate: Number,
    loadingCharges: Number,
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
  tracking: {
    currentLocation: {
      latitude: Number,
      longitude: Number,
      updatedAt: Date
    },
    estimatedArrival: Date
  },
  cancellation: {
    cancelledBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    reason: String,
    cancelledAt: Date
  },
  deliveredAt: Date
}, {
  timestamps: true
});

// bookingNumber already has unique index from unique: true
transportBookingSchema.index({ user: 1 });
transportBookingSchema.index({ assignedPartner: 1 });
transportBookingSchema.index({ status: 1 });
transportBookingSchema.index({ scheduledDate: 1 });

// Generate booking number
transportBookingSchema.pre('save', async function(next) {
  if (this.isNew && !this.bookingNumber) {
    const count = await mongoose.model('TransportBooking').countDocuments();
    this.bookingNumber = `TB${Date.now()}${count + 1}`;
  }
  next();
});

module.exports = mongoose.model('TransportBooking', transportBookingSchema);
