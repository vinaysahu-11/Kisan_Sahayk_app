const mongoose = require('mongoose');

const deliveryOrderSchema = new mongoose.Schema({
  deliveryNumber: {
    type: String,
    required: true,
    unique: true
  },
  order: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Order',
    required: true
  },
  assignedPartner: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  pickupLocation: {
    sellerLocation: String,
    coordinates: {
      latitude: Number,
      longitude: Number
    }
  },
  deliveryLocation: {
    address: String,
    coordinates: {
      latitude: Number,
      longitude: Number
    }
  },
  distance: Number, // in km
  status: {
    type: String,
    enum: ['pending', 'assigned', 'accepted', 'picked_up', 'in_transit', 'delivered', 'failed', 'cancelled'],
    default: 'pending'
  },
  acceptedAt: Date,
  pickedUpAt: Date,
  deliveredAt: Date,
  deliveryOTP: {
    type: String
  },
  isOtpVerified: {
    type: Boolean,
    default: false
  },
  isCOD: {
    type: Boolean,
    default: false
  },
  codAmount: Number,
  codCollected: {
    type: Boolean,
    default: false
  },
  deliveryFee: {
    type: Number,
    required: true
  },
  partnerEarning: {
    type: Number
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
  proof: {
    image: String,
    signature: String,
    notes: String
  },
  failureReason: String,
  cancellationReason: String
}, {
  timestamps: true
});

// deliveryNumber already has unique index from unique: true
deliveryOrderSchema.index({ order: 1 });
deliveryOrderSchema.index({ assignedPartner: 1 });
deliveryOrderSchema.index({ status: 1 });

// Generate delivery number
deliveryOrderSchema.pre('save', async function(next) {
  if (this.isNew && !this.deliveryNumber) {
    const count = await mongoose.model('DeliveryOrder').countDocuments();
    this.deliveryNumber = `DL${Date.now()}${count + 1}`;
  }
  // Generate OTP for COD orders
  if (this.isNew && this.isCOD && !this.deliveryOTP) {
    this.deliveryOTP = Math.floor(100000 + Math.random() * 900000).toString();
  }
  next();
});

module.exports = mongoose.model('DeliveryOrder', deliveryOrderSchema);
