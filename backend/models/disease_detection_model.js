const mongoose = require('mongoose');

const diseaseDetectionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  imageUrl: {
    type: String,
    required: true,
  },
  plantType: String,
  disease: String,
  confidence: Number,
  recommendations: {
    medicines: [String],
    dosages: [String],
    organicAlternatives: [String],
    preventiveSteps: [String],
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('DiseaseDetection', diseaseDetectionSchema);
