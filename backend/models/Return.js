const mongoose = require('mongoose');

const returnSchema = new mongoose.Schema({
  returnNumber: {
    type: String,
    required: true,
    unique: true
  },
  order: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Order',
    required: true
  },
  orderItem: {
    product: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
    quantity: Number
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  seller: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  reason: {
    type: String,
    required: true,
    enum: [
      'defective',
      'wrong_item',
      'not_as_described',
      'damaged',
      'quality_issue',
      'expired',
      'other'
    ]
  },
  description: String,
  images: [String],
  status: {
    type: String,
    enum: ['requested', 'approved', 'rejected', 'picked_up', 'refunded', 'cancelled'],
    default: 'requested'
  },
  refundAmount: {
    type: Number,
    required: true
  },
  refundMethod: {
    type: String,
    enum: ['wallet', 'original_payment_method'],
    default: 'wallet'
  },
  pickup: {
    scheduled: Boolean,
    scheduledDate: Date,
    assignedPartner: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    pickedUpAt: Date,
    status: {
      type: String,
      enum: ['pending', 'scheduled', 'picked_up', 'cancelled']
    }
  },
  approval: {
    approvedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    approvedAt: Date,
    rejectionReason: String
  },
  refund: {
    processedAt: Date,
    transactionId: String,
    status: { type: String, enum: ['pending', 'processed', 'failed'] }
  }
}, {
  timestamps: true
});

// returnNumber already has unique index from unique: true
returnSchema.index({ order: 1 });
returnSchema.index({ user: 1 });
returnSchema.index({ seller: 1 });
returnSchema.index({ status: 1 });

// Generate return number
returnSchema.pre('save', async function(next) {
  if (this.isNew && !this.returnNumber) {
    const count = await mongoose.model('Return').countDocuments();
    this.returnNumber = `RET${Date.now()}${count + 1}`;
  }
  next();
});

module.exports = mongoose.model('Return', returnSchema);
