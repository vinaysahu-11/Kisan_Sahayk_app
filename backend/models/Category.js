const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
    unique: true
  },
  nameHi: {
    type: String,
    trim: true
  },
  nameCg: {
    type: String,
    trim: true
  },
  description: String,
  icon: String,
  image: String,
  parentCategory: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
    default: null
  },
  isActive: {
    type: Boolean,
    default: true
  },
  order: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true
});

// name already has unique index from unique: true
categorySchema.index({ parentCategory: 1 });

module.exports = mongoose.model('Category', categorySchema);
