const mongoose = require('mongoose');

const ratingSchema = new mongoose.Schema({
  ratedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  ratedTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  entityType: {
    type: String,
    enum: ['product', 'seller', 'labour_partner', 'transport_partner', 'delivery_partner'],
    required: true
  },
  entityId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true
  },
  rating: {
    type: Number,
    required: true,
    min: 1,
    max: 5
  },
  review: {
    type: String,
    trim: true
  },
  images: [String],
  reference: {
    orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order' },
    bookingId: mongoose.Schema.Types.ObjectId,
    deliveryId: { type: mongoose.Schema.Types.ObjectId, ref: 'DeliveryOrder' }
  },
  isVisible: {
    type: Boolean,
    default: true
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  helpfulCount: {
    type: Number,
    default: 0
  },
  response: {
    text: String,
    respondedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    respondedAt: Date
  }
}, {
  timestamps: true
});

ratingSchema.index({ entityType: 1, entityId: 1 });
ratingSchema.index({ ratedBy: 1 });
ratingSchema.index({ ratedTo: 1 });
ratingSchema.index({ rating: 1 });
ratingSchema.index({ 'reference.orderId': 1 });

module.exports = mongoose.model('Rating', ratingSchema);
