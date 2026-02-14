const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  phone: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  password: {
    type: String
  },
  role: {
    type: String,
    enum: ['buyer', 'seller', 'labour_partner', 'transport_partner', 'delivery_partner', 'admin'],
    default: 'buyer'
  },
  email: {
    type: String,
    trim: true,
    lowercase: true
  },
  profileImage: String,
  addresses: [{
    name: String,
    mobile: String,
    addressLine: String,
    city: String,
    state: String,
    pincode: String,
    landmark: String,
    coordinates: {
      latitude: Number,
      longitude: Number
    },
    isDefault: { type: Boolean, default: false }
  }],
  wallet: {
    balance: { 
      type: Number, 
      default: 0,
      min: 0
    },
    lastUpdated: {
      type: Date,
      default: Date.now
    }
  },
  otp: {
    code: String,
    expiresAt: Date
  },
  preferences: {
    language: {
      type: String,
      enum: ['en', 'hi', 'cg'],
      default: 'hi'
    },
    darkMode: {
      type: Boolean,
      default: false
    },
    notifications: {
      orders: { type: Boolean, default: true },
      bookings: { type: Boolean, default: true },
      wallet: { type: Boolean, default: true },
      promotions: { type: Boolean, default: true }
    }
  },
  isActive: {
    type: Boolean,
    default: true
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  lastLogin: Date,
  fcmToken: String,
  rating: {
    average: { type: Number, default: 0, min: 0, max: 5 },
    count: { type: Number, default: 0 }
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, { timestamps: true });

// Only create indexes that aren't already defined by unique constraint
// phone already has unique index from unique: true
userSchema.index({ email: 1 });
userSchema.index({ role: 1 });
userSchema.index({ isActive: 1 });

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (this.isModified('password') && this.password) {
    this.password = await bcrypt.hash(this.password, 10);
  }
  if (this.isModified('otp.code') && this.otp && this.otp.code) {
    this.otp.code = await bcrypt.hash(this.otp.code, 10);
  }
  next();
});

// Compare password method
userSchema.methods.comparePassword = async function(candidatePassword) {
  if (!this.password) return false;
  return await bcrypt.compare(candidatePassword, this.password);
};

// Compare OTP
userSchema.methods.compareOTP = async function(candidateOTP) {
  if (!this.otp || !this.otp.code) return false;
  return await bcrypt.compare(candidateOTP, this.otp.code);
};

module.exports = mongoose.model('User', userSchema);
