const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  product: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true
  },
  productName: String,
  seller: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  quantity: {
    type: Number,
    required: true,
    min: 1
  },
  unit: String,
  pricePerUnit: {
    type: Number,
    required: true
  },
  totalPrice: {
    type: Number,
    required: true
  },
  image: String,
  status: {
    type: String,
    enum: ['pending', 'accepted', 'packed', 'shipped', 'delivered', 'cancelled', 'returned'],
    default: 'pending'
  }
}, { _id: true });

const orderSchema = new mongoose.Schema({
  orderNumber: {
    type: String,
    required: true,
    unique: true
  },
  buyer: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  items: [orderItemSchema],
  deliveryAddress: {
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
    }
  },
  pricing: {
    subtotal: { type: Number, required: true },
    deliveryFee: { type: Number, default: 0 },
    tax: { type: Number, default: 0 },
    discount: { type: Number, default: 0 },
    total: { type: Number, required: true }
  },
  payment: {
    method: {
      type: String,
      enum: ['cod', 'online', 'wallet'],
      required: true
    },
    status: {
      type: String,
      enum: ['pending', 'completed', 'failed', 'refunded', 'partially_refunded'],
      default: 'pending'
    },
    transactionId: String,
    paidAt: Date,
    refundAmount: { type: Number, default: 0 }
  },
  status: {
    type: String,
    enum: ['placed', 'processing', 'confirmed', 'packed', 'shipped', 'out_for_delivery', 'delivered', 'completed', 'cancelled', 'returned'],
    default: 'placed'
  },
  statusHistory: [{
    status: String,
    timestamp: { type: Date, default: Date.now },
    note: String,
    updatedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
  }],
  delivery: {
    partner: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    assignedAt: Date,
    pickedUpAt: Date,
    deliveredAt: Date,
    trackingId: String,
    otp: String,
    otpVerified: { type: Boolean, default: false }
  },
  commission: {
    rate: { type: Number, default: 10 },
    amount: { type: Number, default: 0 },
    deducted: { type: Boolean, default: false }
  },
  cancellation: {
    cancelledBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    reason: String,
    cancelledAt: Date
  },
  estimatedDelivery: Date,
  specialInstructions: String,
  orderDate: {
    type: Date,
    default: Date.now
  }
}, { timestamps: true });

// Indexes for efficient queries
// orderNumber already has unique index from unique: true
orderSchema.index({ buyer: 1, status: 1 });
orderSchema.index({ 'items.seller': 1, status: 1 });
orderSchema.index({ 'delivery.partner': 1, status: 1 });
orderSchema.index({ orderDate: -1 });
orderSchema.index({ status: 1 });

// Generate order number
orderSchema.pre('save', async function(next) {
  if (this.isNew && !this.orderNumber) {
    const count = await mongoose.model('Order').countDocuments();
    this.orderNumber = `ORD${Date.now()}${count + 1}`;
  }
  next();
});

module.exports = mongoose.model('Order', orderSchema);
