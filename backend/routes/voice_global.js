// Voice Global Routes - API endpoints for voice-guided navigation

const express = require('express');
const router = express.Router();
const voiceGlobalController = require('../controllers/voice_global_controller');

// Process global voice command
router.post('/process-global', voiceGlobalController.processGlobalCommand);

// Get voice shortcuts
router.get('/shortcuts', voiceGlobalController.getVoiceShortcuts);

// Get conversation history
router.get('/history/:sessionId', voiceGlobalController.getConversationHistory);

// Save voice context
router.post('/context', voiceGlobalController.saveVoiceContext);

module.exports = router;
