const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  sellerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  name: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    trim: true
  },
  category: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
    required: true
  },
  subcategory: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category'
  },
  price: {
    type: Number,
    required: true,
    min: 0
  },
  mrp: {
    type: Number
  },
  discount: {
    type: Number,
    default: 0,
    min: 0,
    max: 100
  },
  unit: {
    type: String,
    required: true,
    enum: ['kg', 'quintal', 'ton', 'piece', 'liter', 'bag', 'gram']
  },
  stock: {
    type: Number,
    required: true,
    min: 0
  },
  moq: {
    type: Number,
    default: 1,
    min: 1
  },
  images: [String],
  specifications: [{
    key: String,
    value: String
  }],
  certifications: [String],
  codEnabled: {
    type: Boolean,
    default: false
  },
  deliveryTime: {
    type: String,
    default: '3-5 days'
  },
  returnPolicy: {
    enabled: { type: Boolean, default: true },
    days: { type: Number, default: 7 }
  },
  rating: {
    average: {
      type: Number,
      default: 0,
      min: 0,
      max: 5
    },
    count: {
      type: Number,
      default: 0
    }
  },
  totalSales: {
    type: Number,
    default: 0
  },
  views: {
    type: Number,
    default: 0
  },
  isActive: {
    type: Boolean,
    default: true
  },
  isFeatured: {
    type: Boolean,
    default: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, { timestamps: true });

// Indexes for faster queries
productSchema.index({ sellerId: 1, isActive: 1 });
productSchema.index({ category: 1, isActive: 1 });
productSchema.index({ name: 'text', description: 'text' });
productSchema.index({ 'rating.average': -1 });
productSchema.index({ totalSales: -1 });
productSchema.index({ price: 1 });

module.exports = mongoose.model('Product', productSchema);
