const express = require('express');
const router = express.Router();
const aiController = require('../controllers/ai_controller');
const { authMiddleware } = require('../middleware/auth');

// Optional auth middleware - adds userId if token present, but doesn't block
const optionalAuth = async (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  if (token) {
    try {
      const jwt = require('jsonwebtoken');
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.userId = decoded.userId;
    } catch (err) {
      // Token invalid but continue anyway
    }
  }
  next();
};

// Use optional auth - AI works without login, but uses userId if available
router.use(optionalAuth);

// Chat endpoint
router.post('/chat', aiController.handleChat);

// Soil analysis endpoint
router.post('/soil-analysis', aiController.analyzeSoil);

// Disease detection endpoint
router.post('/disease-scan', aiController.scanDisease);

// Voice query endpoint
router.post('/voice', aiController.handleVoice);

// Get history (supports query param ?type=chat|soil|disease|voice)
router.get('/history', aiController.getHistory);

// Get specific conversation
router.get('/conversation/:id', aiController.getConversation);

// Delete a conversation
router.delete('/conversation/:id', aiController.deleteConversation);

module.exports = router;
