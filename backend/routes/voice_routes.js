const express = require('express');
const router = express.Router();
const voiceController = require('../controllers/voice_controller');
const multer = require('multer');

// Configure multer for audio upload
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max
  },
  fileFilter: (req, file, cb) => {
    // Accept audio files
    if (file.mimetype.startsWith('audio/') || file.originalname.match(/\.(webm|ogg|mp3|wav|m4a)$/)) {
      cb(null, true);
    } else {
      cb(new Error('Only audio files are allowed'));
    }
  },
});

// Optional auth middleware (same as AI routes)
const optionalAuth = async (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  if (token) {
    try {
      const jwt = require('jsonwebtoken');
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.userId = decoded.userId;
      req.user = { id: decoded.userId };
    } catch (err) {
      // Token invalid but continue anyway
    }
  }
  next();
};

router.use(optionalAuth);

// Process voice command with audio upload
router.post('/process', upload.single('audio'), voiceController.processVoice);

// Process text command (fallback for testing)
router.post('/process-text', voiceController.processText);

// Get voice session history
router.get('/history', voiceController.getHistory);

// Get specific session
router.get('/session/:sessionId', voiceController.getSession);

// End session
router.post('/session/:sessionId/end', voiceController.endSession);

// Text-to-speech
router.post('/tts', voiceController.textToSpeech);

module.exports = router;
