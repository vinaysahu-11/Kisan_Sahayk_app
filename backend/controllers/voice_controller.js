const voiceService = require('../services/voice_service');
const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 10 * 1024 * 1024 } }); // 10MB

/**
 * Process voice command
 */
exports.processVoice = async (req, res) => {
  try {
    const userId = req.user?.id || req.userId || null;
    const { sessionId, language = 'hi' } = req.body;
    
    if (!req.file) {
      return res.status(400).json({ error: 'Audio file is required' });
    }

    const audioBuffer = req.file.buffer;

    const result = await voiceService.processVoiceCommand(
      audioBuffer,
      userId,
      sessionId,
      language
    );

    res.json(result);
  } catch (error) {
    console.error('Voice processing error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to process voice command',
    });
  }
};

/**
 * Get voice session history
 */
exports.getHistory = async (req, res) => {
  try {
    const userId = req.user?.id || req.userId || null;
    const { limit = 10 } = req.query;

    const history = await voiceService.getVoiceHistory(userId, parseInt(limit));
    res.json({ sessions: history });
  } catch (error) {
    console.error('Voice history error:', error);
    res.status(500).json({
      error: error.message || 'Failed to get voice history',
    });
  }
};

/**
 * Get specific voice session
 */
exports.getSession = async (req, res) => {
  try {
    const userId = req.user?.id || req.userId || null;
    const { sessionId } = req.params;

    const session = await voiceService.getVoiceSession(sessionId, userId);
    res.json(session);
  } catch (error) {
    console.error('Get session error:', error);
    res.status(404).json({
      error: error.message || 'Session not found',
    });
  }
};

/**
 * End/clear voice session
 */
exports.endSession = async (req, res) => {
  try {
    const userId = req.user?.id || req.userId || null;
    const { sessionId } = req.params;

    const result = await voiceService.endVoiceSession(sessionId, userId);
    res.json(result);
  } catch (error) {
    console.error('End session error:', error);
    res.status(500).json({
      error: error.message || 'Failed to end session',
    });
  }
};

/**
 * Process text command (fallback for testing without audio)
 */
exports.processText = async (req, res) => {
  try {
    const userId = req.user?.id || req.userId || null;
    const { text, sessionId, language = 'hi' } = req.body;
    
    if (!text) {
      return res.status(400).json({ error: 'Text is required' });
    }

    const result = await voiceService.processTextCommand(
      text,
      userId,
      sessionId,
      language
    );

    res.json(result);
  } catch (error) {
    console.error('Text processing error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to process text command',
    });
  }
};

/**
 * Text-to-speech endpoint
 */
exports.textToSpeech = async (req, res) => {
  try {
    const { text, language = 'hi' } = req.body;

    if (!text) {
      return res.status(400).json({ error: 'Text is required' });
    }

    const result = await voiceService.textToSpeech(text, language);
    res.json(result);
  } catch (error) {
    console.error('TTS error:', error);
    res.status(500).json({
      error: error.message || 'Failed to convert text to speech',
    });
  }
};

module.exports = exports;
