const aiService = require('../services/ai_service');

// Main chat handler
exports.handleChat = async (req, res) => {
  try {
    const { message, context } = req.body;
    const userId = req.user.id;
    const response = await aiService.getChatResponse(message, userId, context);
    res.json(response);
  } catch (error) {
    res.status(500).json({ message: 'Error processing chat request', error: error.message });
  }
};

// Soil analysis handler
exports.analyzeSoil = async (req, res) => {
  try {
    const soilData = req.body;
    const userId = req.user.id;
    const analysis = await aiService.getSoilAnalysis(soilData, userId);
    res.json(analysis);
  } catch (error) {
    res.status(500).json({ message: 'Error analyzing soil data', error: error.message });
  }
};

// Disease scan handler
exports.scanDisease = async (req, res) => {
  try {
    // Assuming image is sent as base64 or via a file upload service
    const { image } = req.body;
    const userId = req.user.id;
    const result = await aiService.getDiseaseDiagnosis(image, userId);
    res.json(result);
  } catch (error) {
    res.status(500).json({ message: 'Error scanning disease', error: error.message });
  }
};

// Voice handler
exports.handleVoice = async (req, res) => {
  try {
    // Assuming audio is sent as base64 or via a file upload service
    const { audio } = req.body;
    const userId = req.user.id;
    const response = await aiService.processVoiceQuery(audio, userId);
    res.json(response);
  } catch (error) {
    res.status(500).json({ message: 'Error processing voice request', error: error.message });
  }
};

// Get conversation history
exports.getHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const history = await aiService.getConversationHistory(userId);
    res.json(history);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching history', error: error.message });
  }
};

// Delete a specific conversation
exports.deleteConversation = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    await aiService.deleteConversation(id, userId);
    res.status(200).json({ message: 'Conversation deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting conversation', error: error.message });
  }
};
