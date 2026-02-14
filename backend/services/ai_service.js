const axios = require('axios');
const dotenv = require('dotenv');

dotenv.config();

const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
const AI_API_URL = 'https://api.openai.com/v1/chat/completions';

const AIConversation = require('../models/ai_conversation_model');

/**
 * Get a chat response from the AI.
 */
exports.getChatResponse = async (message, userId, context) => {
  const { conversationId } = context;

  // This is a placeholder for the actual OpenAI API call
  const aiResponseMessage = `This is a dummy AI response to: "${message}"`;

  let conversation;
  if (conversationId) {
    conversation = await AIConversation.findById(conversationId);
  } else {
    conversation = new AIConversation({ userId, title: message.substring(0, 30) });
  }

  conversation.messages.push({ role: 'user', content: message });
  conversation.messages.push({ role: 'assistant', content: aiResponseMessage });
  
  await conversation.save();

  return {
    conversationId: conversation._id,
    message: aiResponseMessage,
  };
};

const SoilAnalysis = require('../models/soil_analysis_model');

/**
 * Get soil analysis from the AI.
 */
exports.getSoilAnalysis = async (soilData, userId) => {
  const { ph, nitrogen, phosphorus, potassium, season, location } = soilData;

  const prompt = `
    Analyze the following soil data for a farmer in India and provide recommendations.
    - pH: ${ph}
    - Nitrogen (N): ${nitrogen} kg/ha
    - Phosphorus (P): ${phosphorus} kg/ha
    - Potassium (K): ${potassium} kg/ha
    - Current Season: ${season}
    - Location: ${location.coordinates.join(', ')}

    Provide a structured JSON response with:
    1. A summary message for the farmer.
    2. A list of 3-4 suitable crops.
    3. Recommended fertilizers and dosages.
    4. Organic farming alternatives.
    5. A suggested irrigation method.
    6. Warnings for any extreme values.
  `;

  // This is a placeholder for the actual OpenAI API call
  const aiResponse = {
    message: 'Your soil is slightly acidic. It is suitable for crops like potatoes and strawberries. We recommend adding lime to balance the pH.',
    crops: ['Potato', 'Strawberry', 'Radish', 'Carrot'],
    fertilizers: ['DAP: 50kg/acre', 'MOP: 25kg/acre'],
    organicSolutions: ['Compost: 2 tons/acre', 'Vermicompost'],
    irrigation: 'Drip irrigation is highly recommended to save water.',
    warnings: ['Your soil pH is lower than ideal for most cereal crops.'],
  };

  // Save the analysis to the database
  const newAnalysis = new SoilAnalysis({
    userId,
    ...soilData,
    recommendations: {
      crops: aiResponse.crops,
      fertilizers: aiResponse.fertilizers,
      organicSolutions: aiResponse.organicSolutions,
      irrigation: aiResponse.irrigation,
    },
  });
  await newAnalysis.save();

  return aiResponse;
};

const DiseaseDetection = require('../models/disease_detection_model');

/**
 * Get disease diagnosis from an image.
 */
exports.getDiseaseDiagnosis = async (imageBase64, userId) => {
  // In a real scenario, you would upload the image to a service like S3
  // and get a URL, or send the base64 data directly if the API supports it.
  const imageUrl = 'placeholder_image_url'; // Dummy URL

  const prompt = `
    Analyze the attached image of a plant leaf.
    Provide a structured JSON response with:
    1. The detected plant disease.
    2. A confidence score (0 to 1).
    3. Recommended chemical medicines and dosages.
    4. Recommended organic alternatives.
    5. Preventive steps to avoid future infection.
  `;

  // Placeholder for the actual OpenAI Vision API call
  const aiResponse = {
    plantType: 'Tomato',
    disease: 'Late Blight',
    confidence: 0.95,
    medicines: ['Mancozeb: 2.5g/litre water', 'Chlorothalonil: 1g/litre water'],
    organicAlternatives: ['Neem oil spray (10ml/litre)', 'Baking soda solution'],
    preventiveSteps: ['Ensure proper spacing between plants for air circulation.', 'Water at the base of the plant, not on the leaves.'],
  };

  // Save the detection to the database
  const newDetection = new DiseaseDetection({
    userId,
    imageUrl,
    plantType: aiResponse.plantType,
    disease: aiResponse.disease,
    confidence: aiResponse.confidence,
    recommendations: {
      medicines: aiResponse.medicines,
      organicAlternatives: aiResponse.organicAlternatives,
      preventiveSteps: aiResponse.preventiveSteps,
    },
  });
  await newDetection.save();

  return aiResponse;
};

const AIVoiceLog = require('../models/ai_voice_log_model');

/**
 * Process a voice query.
 */
exports.processVoiceQuery = async (audioBase64, userId) => {
  // In a real scenario, you would upload the audio to a service like S3
  // and get a URL, or send the base64 data directly.
  const audioUrl = 'placeholder_audio_url'; // Dummy URL

  // 1. Transcribe audio to text (e.g., using OpenAI Whisper)
  const transcribedText = 'dummy transcription: how to improve soil health for wheat crop';

  // 2. Get chat response for the transcribed text
  const aiChatResponse = await exports.getChatResponse(transcribedText, userId, {});

  // 3. (Optional) Convert the text response back to speech (TTS)
  // This would typically be handled on the client-side to play the audio.

  // 4. Log the voice interaction
  const newLog = new AIVoiceLog({
    userId,
    audioUrl,
    transcribedText,
    aiResponseText: aiChatResponse.message,
    language: 'hinglish', // This could be detected or passed from the client
  });
  await newLog.save();

  return {
    transcribedText,
    aiResponse: aiChatResponse,
  };
};

/**
 * Fetch conversation history from the database.
 */
exports.getConversationHistory = async (userId) => {
  const history = await AIConversation.find({ userId }).sort({ createdAt: -1 });
  return history.map(conv => ({ id: conv._id, title: conv.title }));
};

/**
 * Delete a conversation from the database.
 */
exports.deleteConversation = async (conversationId, userId) => {
  const result = await AIConversation.findOneAndDelete({ _id: conversationId, userId });
  if (!result) {
    throw new Error('Conversation not found or user not authorized to delete.');
  }
  return { status: 'success', message: 'Conversation deleted.' };
};
