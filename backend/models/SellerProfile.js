const mongoose = require('mongoose');

const sellerProfileSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  businessName: {
    type: String,
    required: true,
    trim: true
  },
  businessType: {
    type: String,
    enum: ['individual', 'company', 'cooperative'],
    default: 'individual'
  },
  gstNumber: String,
  panNumber: String,
  bankAccount: {
    accountNumber: String,
    ifscCode: String,
    accountHolderName: String,
    bankName: String
  },
  address: {
    street: String,
    city: String,
    state: String,
    pincode: String,
    landmark: String
  },
  kycStatus: {
    type: String,
    enum: ['pending', 'under_review', 'approved', 'rejected'],
    default: 'pending'
  },
  kycDocuments: [{
    type: { type: String },
    url: String,
    uploadedAt: { type: Date, default: Date.now }
  }],
  approvalStatus: {
    type: String,
    enum: ['pending', 'approved', 'rejected', 'suspended'],
    default: 'pending'
  },
  approvedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  approvedAt: Date,
  rejectionReason: String,
  commissionRate: {
    type: Number,
    default: 10, // 10% default
    min: 0,
    max: 100
  },
  rating: {
    average: { type: Number, default: 0, min: 0, max: 5 },
    count: { type: Number, default: 0 }
  },
  totalOrders: {
    type: Number,
    default: 0
  },
  totalRevenue: {
    type: Number,
    default: 0
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// user already has unique index from unique: true
sellerProfileSchema.index({ approvalStatus: 1 });
sellerProfileSchema.index({ kycStatus: 1 });

module.exports = mongoose.model('SellerProfile', sellerProfileSchema);
