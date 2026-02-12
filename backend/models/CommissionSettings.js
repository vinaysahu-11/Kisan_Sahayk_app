const mongoose = require('mongoose');

const commissionSettingsSchema = new mongoose.Schema({
  category: {
    type: String,
    required: true,
    unique: true,
    enum: ['seller_product', 'labour_booking', 'transport_booking']
  },
  rate: {
    type: Number,
    required: true,
    min: 0,
    max: 100 // percentage
  },
  isActive: {
    type: Boolean,
    default: true
  },
  description: String,
  updatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }
}, {
  timestamps: true
});

// category already has unique index from unique: true

module.exports = mongoose.model('CommissionSettings', commissionSettingsSchema);
