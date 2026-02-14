const aiService = require('../services/ai_service');

// Main chat handler
exports.handleChat = async (req, res) => {
  try {
    const { message, conversationId, language, location } = req.body;
    const userId = req.user?.id || req.userId || null;
    
    if (!message || message.trim() === '') {
      return res.status(400).json({ message: 'Message is required' });
    }

    const context = {
      conversationId,
      language: language || 'en',
      location,
    };

    const response = await aiService.getChatResponse(message, userId, context);
    res.json(response);
  } catch (error) {
    console.error('Chat Error:', error);
    res.status(500).json({ 
      message: 'Error processing chat request', 
      error: error.message 
    });
  }
};

// Soil analysis handler
exports.analyzeSoil = async (req, res) => {
  try {
    const { ph, nitrogen, phosphorus, potassium, season, location, language } = req.body;
    const userId = req.user?.id || req.userId || null;

    // Validate required fields
    if (!ph || !nitrogen || !phosphorus || !potassium || !season) {
      return res.status(400).json({ 
        message: 'Missing required fields: ph, nitrogen, phosphorus, potassium, season' 
      });
    }

    const soilData = {
      ph: parseFloat(ph),
      nitrogen: parseFloat(nitrogen),
      phosphorus: parseFloat(phosphorus),
      potassium: parseFloat(potassium),
      season,
      location,
      language: language || 'en',
    };

    const analysis = await aiService.getSoilAnalysis(soilData, userId);
    res.json(analysis);
  } catch (error) {
    console.error('Soil Analysis Error:', error);
    res.status(500).json({ 
      message: 'Error analyzing soil data', 
      error: error.message 
    });
  }
};

// Disease scan handler
exports.scanDisease = async (req, res) => {
  try {
    const { image, language, location } = req.body;
    const userId = req.user?.id || req.userId || null;

    if (!image) {
      return res.status(400).json({ message: 'Image is required' });
    }

    const context = {
      language: language || 'en',
      location,
    };

    const result = await aiService.getDiseaseDiagnosis(image, userId, context);
    res.json(result);
  } catch (error) {
    console.error('Disease Scan Error:', error);
    res.status(500).json({ 
      message: 'Error scanning disease', 
      error: error.message 
    });
  }
};

// Voice handler
exports.handleVoice = async (req, res) => {
  try {
    const { audio, language, conversationId, enableTTS } = req.body;
    const userId = req.user?.id || req.userId || null;

    if (!audio) {
      return res.status(400).json({ message: 'Audio data is required' });
    }

    const context = {
      language: language || 'auto',
      conversationId,
      enableTTS: enableTTS !== false, // default true
    };

    const response = await aiService.processVoiceQuery(audio, userId, context);
    res.json(response);
  } catch (error) {
    console.error('Voice Processing Error:', error);
    res.status(500).json({ 
      message: 'Error processing voice request', 
      error: error.message 
    });
  }
};

// Get conversation history
exports.getHistory = async (req, res) => {
  try {
    const userId = req.user?.id || req.userId || null;
    const { type = 'chat', limit = 50 } = req.query;

    let history;
    switch (type) {
      case 'soil':
        history = await aiService.getSoilHistory(userId, parseInt(limit));
        break;
      case 'disease':
        history = await aiService.getDiseaseHistory(userId, parseInt(limit));
        break;
      case 'voice':
        history = await aiService.getVoiceHistory(userId, parseInt(limit));
        break;
      case 'chat':
      default:
        history = await aiService.getConversationHistory(userId, parseInt(limit));
        break;
    }

    res.json({ type, history });
  } catch (error) {
    console.error('History Fetch Error:', error);
    res.status(500).json({ 
      message: 'Error fetching history', 
      error: error.message 
    });
  }
};

// Get specific conversation
exports.getConversation = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user?.id || req.userId || null;
    
    const conversation = await aiService.getConversation(id, userId);
    res.json(conversation);
  } catch (error) {
    console.error('Get Conversation Error:', error);
    res.status(404).json({ 
      message: 'Conversation not found', 
      error: error.message 
    });
  }
};

// Delete a specific conversation
exports.deleteConversation = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user?.id || req.userId || null;
    
    await aiService.deleteConversation(id, userId);
    res.status(200).json({ message: 'Conversation deleted successfully' });
  } catch (error) {
    console.error('Delete Conversation Error:', error);
    res.status(500).json({ 
      message: 'Error deleting conversation', 
      error: error.message 
    });
  }
};

module.exports = exports;
