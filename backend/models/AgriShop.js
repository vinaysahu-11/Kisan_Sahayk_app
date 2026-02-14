const mongoose = require('mongoose');

const agriShopSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  owner: {
    type: String,
    required: true,
  },
  phone: {
    type: String,
    required: true,
  },
  address: {
    type: String,
    required: true,
  },
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point',
    },
    coordinates: {
      type: [Number],
      required: true,
      index: '2dsphere', // Geospatial index for location-based queries
    },
  },
  inventory: [
    {
      productName: String,
      category: {
        type: String,
        enum: ['fertilizer', 'pesticide', 'medicine', 'seeds', 'equipment', 'other'],
      },
      inStock: {
        type: Boolean,
        default: true,
      },
      price: Number,
    },
  ],
  rating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5,
  },
  verified: {
    type: Boolean,
    default: false,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// Create geospatial index
agriShopSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('AgriShop', agriShopSchema);
