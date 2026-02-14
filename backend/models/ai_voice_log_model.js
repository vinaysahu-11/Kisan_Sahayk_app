const mongoose = require('mongoose');

const voiceLogSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  audioUrl: {
    type: String,
    required: true,
  },
  transcribedText: {
    type: String,
  },
  language: {
    type: String,
    enum: ['en', 'hi', 'cg', 'hinglish'],
    default: 'en',
  },
  aiResponseText: {
    type: String,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('AIVoiceLog', voiceLogSchema);
