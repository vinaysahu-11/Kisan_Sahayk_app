const express = require('express');
const router = express.Router();
const aiController = require('../controllers/ai_controller');
const { authMiddleware } = require('../middleware/auth');

// Protect all AI routes
router.use(authMiddleware);

// Chat endpoint
router.post('/chat', aiController.handleChat);

// Soil analysis endpoint
router.post('/soil-analysis', aiController.analyzeSoil);

// Disease detection endpoint
router.post('/disease-scan', aiController.scanDisease);

// Voice query endpoint
router.post('/voice', aiController.handleVoice);

// Get conversation history
router.get('/history', aiController.getHistory);

// Delete a conversation
router.delete('/conversation/:id', aiController.deleteConversation);

module.exports = router;
