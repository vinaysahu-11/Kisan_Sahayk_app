const mongoose = require('mongoose');

const soilAnalysisSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  ph: Number,
  nitrogen: Number,
  phosphorus: Number,
  potassium: Number,
  season: String,
  location: {
    type: { type: String, default: 'Point' },
    coordinates: [Number],
  },
  recommendations: {
    crops: [String],
    fertilizers: [String],
    organicSolutions: [String],
    irrigation: String,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('SoilAnalysis', soilAnalysisSchema);
