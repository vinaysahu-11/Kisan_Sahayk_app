const axios = require('axios');
const dotenv = require('dotenv');
const FormData = require('form-data');

dotenv.config();

// API Configuration - Use FREE Google Gemini or paid OpenAI
const USE_GEMINI = process.env.USE_GEMINI !== 'false'; // Default to free Gemini
const OPENAI_API_KEY = process.env.OPENAI_API_KEY || '';
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';

// OpenAI URLs
const AI_API_URL = 'https://api.openai.com/v1/chat/completions';
const VISION_API_URL = 'https://api.openai.com/v1/chat/completions';
const WHISPER_API_URL = 'https://api.openai.com/v1/audio/transcriptions';
const TTS_API_URL = 'https://api.openai.com/v1/audio/speech';

// Google Gemini URLs  
const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
const GEMINI_VISION_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

const AIConversation = require('../models/ai_conversation_model');
const AgriShop = require('../models/AgriShop');

// Language-specific system prompts
const getSystemPrompt = (language) => {
  const prompts = {
    en: 'You are an expert AI agricultural assistant for Indian farmers. Provide practical, actionable advice in simple English. Focus on Indian farming conditions, crops, seasons, and locally available resources.',
    hi: 'आप भारतीय किसानों के लिए एक विशेषज्ञ AI कृषि सहायक हैं। सरल हिंदी में व्यावहारिक सलाह दें। भारतीय खेती की परिस्थितियों, फसलों, मौसम और स्थानीय संसाधनों पर ध्यान केंद्रित करें।',
    cg: 'तुमन भारतीय किसान मन बर एक विशेषज्ञ AI खेती सहायक हव। सरल छत्तीसगढ़ी म व्यावहारिक सलाह देवव। भारतीय खेती के हालत, फसल, मौसम अउ स्थानीय संसाधन मन ऊपर ध्यान देवव।',
    hinglish: 'Aap Indian farmers ke liye ek expert AI krishi sahayak hain. Simple language mein practical advice dijiye. Indian farming conditions, crops, seasons aur locally available resources par focus kijiye.',
  };
  return prompts[language] || prompts.en;
};

/**
 * Call Google Gemini API (FREE)
 */
const callGemini = async (messages, temperature = 0.7) => {
  try {
    // Convert messages to Gemini format
    const prompt = messages
      .filter(m => m.role !== 'system')
      .map(m => m.content)
      .join('\n\n');
    
    const systemPrompt = messages.find(m => m.role === 'system')?.content || '';
    const fullPrompt = systemPrompt ? `${systemPrompt}\n\n${prompt}` : prompt;

    const response = await axios.post(
      `${GEMINI_API_URL}?key=${GEMINI_API_KEY}`,
      {
        contents: [{
          parts: [{ text: fullPrompt }]
        }],
        generationConfig: {
          temperature,
          maxOutputTokens: 2048,
        }
      },
      {
        headers: { 'Content-Type': 'application/json' },
      }
    );

    return response.data.candidates[0].content.parts[0].text;
  } catch (error) {
    console.error('Gemini API Error:', error.response?.data || error.message);
    throw new Error('Failed to get AI response from Gemini');
  }
};

/**
 * Make OpenAI API call (PAID)
 */
const callOpenAI = async (messages, model = 'gpt-4o', temperature = 0.7, maxTokens = 1000) => {
  try {
    const response = await axios.post(
      AI_API_URL,
      {
        model,
        messages,
        temperature,
        max_tokens: maxTokens,
      },
      {
        headers: {
          'Authorization': `Bearer ${OPENAI_API_KEY}`,
          'Content-Type': 'application/json',
        },
      }
    );
    return response.data.choices[0].message.content;
  } catch (error) {
    console.error('OpenAI API Error:', error.response?.data || error.message);
    throw new Error('Failed to get AI response');
  }
};

/**
 * Smart AI call - uses Gemini (free) or OpenAI (paid) based on config
 */
const callAI = async (messages, temperature = 0.7) => {
  if (USE_GEMINI && GEMINI_API_KEY) {
    return await callGemini(messages, temperature);
  } else if (OPENAI_API_KEY) {
    return await callOpenAI(messages, 'gpt-4o', temperature, 1500);
  } else {
    throw new Error('No AI API key configured. Set GEMINI_API_KEY or OPENAI_API_KEY in .env');
  }
};

/**
 * Get a chat response from the AI with context memory.
 */
exports.getChatResponse = async (message, userId, context) => {
  const { conversationId, language = 'en', location } = context;

  let conversation;
  if (conversationId) {
    conversation = await AIConversation.findById(conversationId);
    // Check ownership only if userId exists
    if (!conversation || (userId && conversation.userId && conversation.userId.toString() !== userId.toString())) {
      throw new Error('Conversation not found or unauthorized');
    }
  } else {
    conversation = new AIConversation({ 
      userId: userId || null, // Allow null for anonymous users
      title: message.substring(0, 50) 
    });
  }

  // Build message history for context
  const messages = [
    { role: 'system', content: getSystemPrompt(language) },
    ...conversation.messages.map(msg => ({ role: msg.role, content: msg.content })),
    { role: 'user', content: message }
  ];

  // Call AI (Gemini or OpenAI based on config)
  const aiResponseMessage = await callAI(messages);

  // Save to conversation
  conversation.messages.push({ role: 'user', content: message });
  conversation.messages.push({ role: 'assistant', content: aiResponseMessage });
  
  await conversation.save();

  return {
    conversationId: conversation._id,
    message: aiResponseMessage,
    metadata: {
      model: USE_GEMINI ? 'gemini-2.5-flash' : 'gpt-4o',
      language,
    },
  };
};

const SoilAnalysis = require('../models/soil_analysis_model');

/**
 * Find nearby agri shops with specific products
 */
const findNearbyShops = async (location, productCategory, maxDistance = 50000) => {
  if (!location || !location.coordinates || location.coordinates.length !== 2) {
    return [];
  }

  const shops = await AgriShop.find({
    location: {
      $near: {
        $geometry: {
          type: 'Point',
          coordinates: location.coordinates,
        },
        $maxDistance: maxDistance, // in meters (50km default)
      },
    },
    'inventory.category': productCategory,
    'inventory.inStock': true,
  }).limit(5);

  return shops.map(shop => ({
    name: shop.name,
    phone: shop.phone,
    address: shop.address,
    distance: calculateDistance(location.coordinates, shop.location.coordinates),
    rating: shop.rating,
    mapsUrl: `https://www.google.com/maps/search/?api=1&query=${shop.location.coordinates[1]},${shop.location.coordinates[0]}`,
  }));
};

/**
 * Calculate distance between two coordinates (in km)
 */
const calculateDistance = (coords1, coords2) => {
  const [lon1, lat1] = coords1;
  const [lon2, lat2] = coords2;
  const R = 6371; // Radius of Earth in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return (R * c).toFixed(2);
};

/**
 * Get soil analysis from the AI with structured recommendations.
 */
exports.getSoilAnalysis = async (soilData, userId) => {
  const { ph, nitrogen, phosphorus, potassium, season, location, language = 'en' } = soilData;

  const prompt = `
Analyze the following soil data for a farmer in India and provide detailed recommendations:
- pH: ${ph}
- Nitrogen (N): ${nitrogen} kg/ha
- Phosphorus (P): ${phosphorus} kg/ha  
- Potassium (K): ${potassium} kg/ha
- Current Season: ${season}
- Location: ${location?.name || 'Not provided'}

Provide a structured JSON response with:
{
  "message": "A friendly summary message for the farmer",
  "crops": ["Crop1", "Crop2", "Crop3", "Crop4"],
  "fertilizers": ["Fertilizer1: dosage", "Fertilizer2: dosage"],
  "organicSolutions": ["Solution1", "Solution2"],
  "irrigation": "Recommended irrigation method with details",
  "cropRotation": "Suggested crop rotation plan",
  "warnings": ["Warning1", "Warning2"],
  "riskLevel": "low/medium/high",
  "yieldPotential": "Estimated yield description"
}

Consider Indian climate, seasons (Kharif/Rabi/Zaid), and locally available resources. Respond in ${language}.`;

  const messages = [
    { role: 'system', content: getSystemPrompt(language) },
    { role: 'user', content: prompt }
  ];

  try {
    const aiResponse = await callAI(messages, 0.7);
    
    // Parse structured response
    let parsedResponse;
    try {
      // Extract JSON from response
      const jsonMatch = aiResponse.match(/\{[\s\S]*\}/);
      parsedResponse = jsonMatch ? JSON.parse(jsonMatch[0]) : {
        message: aiResponse,
        crops: [],
        fertilizers: [],
        organicSolutions: [],
        irrigation: '',
        warnings: [],
        riskLevel: 'medium'
      };
    } catch (parseError) {
      parsedResponse = {
        message: aiResponse,
        crops: [],
        fertilizers: [],
        organicSolutions: [],
        irrigation: '',
        warnings: [],
        riskLevel: 'medium'
      };
    }

    // Find nearby fertilizer shops
    const shops = await findNearbyShops(location, 'fertilizer');

    // Save the analysis to the database
    const newAnalysis = new SoilAnalysis({
      userId,
      ph,
      nitrogen,
      phosphorus,
      potassium,
      season,
      location,
      recommendations: {
        crops: parsedResponse.crops || [],
        fertilizers: parsedResponse.fertilizers || [],
        organicSolutions: parsedResponse.organicSolutions || [],
        irrigation: parsedResponse.irrigation || '',
      },
    });
    await newAnalysis.save();

    return {
      ...parsedResponse,
      shops,
      analysisId: newAnalysis._id,
    };
  } catch (error) {
    console.error('Soil Analysis Error:', error);
    throw new Error('Failed to analyze soil data');
  }
};

const DiseaseDetection = require('../models/disease_detection_model');

/**
 * Get disease diagnosis from an image using OpenAI Vision.
 */
exports.getDiseaseDiagnosis = async (imageData, userId, context = {}) => {
  const { language = 'en', location } = context;

  // imageData can be base64 or URL
  const imageUrl = imageData.startsWith('http') ? imageData : `data:image/jpeg;base64,${imageData}`;

  const prompt = `Analyze this plant leaf image and provide a detailed diagnosis.

Provide a structured JSON response:
{
  "plantType": "Name of the plant",
  "disease": "Name of the disease or 'Healthy' if no disease",
  "confidence": 0.95,
  "medicines": ["Medicine1: dosage/instructions", "Medicine2: dosage/instructions"],
  "organicAlternatives": ["Organic solution1", "Organic solution2"],
  "preventiveSteps": ["Step1", "Step2", "Step3"],
  "severity": "low/medium/high",
  "symptoms": "Description of visible symptoms",
  "spreadRisk": "Description of how the disease spreads"
}

Focus on diseases common in Indian agriculture. Be precise and provide practical solutions available in India.`;

  const messages = [
    {
      role: 'system',
      content: getSystemPrompt(language) + ' You are an expert in plant disease identification.'
    },
    {
      role: 'user',
      content: [
        { type: 'text', text: prompt },
        { type: 'image_url', image_url: { url: imageUrl } }
      ]
    }
  ];

  try {
    let aiResponseText;

    if (USE_GEMINI && GEMINI_API_KEY) {
      // Use Gemini Vision (FREE)
      const prompt = messages.find(m => m.role === 'user').content.find(c => c.type === 'text').text;
      const base64Image = imageUrl.split(',')[1] || imageUrl; // Extract base64 from data URL
      
      const response = await axios.post(
        `${GEMINI_VISION_API_URL}?key=${GEMINI_API_KEY}`,
        {
          contents: [{
            parts: [
              { text: prompt },
              { inline_data: { mime_type: 'image/jpeg', data: base64Image } }
            ]
          }]
        },
        { headers: { 'Content-Type': 'application/json' } }
      );
      
      aiResponseText = response.data.candidates[0].content.parts[0].text;
    } else if (OPENAI_API_KEY) {
      // Use OpenAI Vision (PAID)
      const response = await axios.post(
        VISION_API_URL,
        {
          model: 'gpt-4o',
          messages,
          max_tokens: 1500,
        },
        {
          headers: {
            'Authorization': `Bearer ${OPENAI_API_KEY}`,
            'Content-Type': 'application/json',
          },
        }
      );
      aiResponseText = response.data.choices[0].message.content;
    } else {
      throw new Error('No vision API configured');
    }

    // Parse structured response
    let parsedResponse;
    try {
      const jsonMatch = aiResponseText.match(/\{[\s\S]*\}/);
      parsedResponse = jsonMatch ? JSON.parse(jsonMatch[0]) : {
        plantType: 'Unknown',
        disease: 'Unable to detect',
        confidence: 0.5,
        medicines: [],
        organicAlternatives: [],
        preventiveSteps: [],
        severity: 'medium'
      };
    } catch (parseError) {
      parsedResponse = {
        plantType: 'Unknown',
        disease: aiResponseText,
        confidence: 0.5,
        medicines: [],
        organicAlternatives: [],
        preventiveSteps: [],
        severity: 'medium'
      };
    }

    // Find nearby shops with medicines
    const shops = location ? await findNearbyShops(location, 'medicine') : [];

    // Save the detection to the database
    const newDetection = new DiseaseDetection({
      userId,
      imageUrl: imageData.startsWith('http') ? imageData : 'base64_image',
      plantType: parsedResponse.plantType,
      disease: parsedResponse.disease,
      confidence: parsedResponse.confidence,
      recommendations: {
        medicines: parsedResponse.medicines || [],
        organicAlternatives: parsedResponse.organicAlternatives || [],
        preventiveSteps: parsedResponse.preventiveSteps || [],
      },
    });
    await newDetection.save();

    return {
      ...parsedResponse,
      shops,
      detectionId: newDetection._id,
    };
  } catch (error) {
    console.error('Disease Detection Error:', error.response?.data || error.message);
    throw new Error('Failed to analyze plant image');
  }
};

const AIVoiceLog = require('../models/ai_voice_log_model');

/**
 * Transcribe audio using OpenAI Whisper
 */
const transcribeAudio = async (audioBuffer, language = 'auto') => {
  try {
    const formData = new FormData();
    formData.append('file', audioBuffer, 'audio.mp3');
    formData.append('model', 'whisper-1');
    if (language !== 'auto') {
      formData.append('language', language === 'hi' || language === 'cg' ? 'hi' : 'en');
    }

    const response = await axios.post(WHISPER_API_URL, formData, {
      headers: {
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
        ...formData.getHeaders(),
      },
    });

    return response.data.text;
  } catch (error) {
    console.error('Whisper API Error:', error.response?.data || error.message);
    throw new Error('Failed to transcribe audio');
  }
};

/**
 * Convert text to speech using OpenAI TTS
 */
const textToSpeech = async (text, voice = 'alloy') => {
  try {
    const response = await axios.post(
      TTS_API_URL,
      {
        model: 'tts-1',
        input: text,
        voice, // alloy, echo, fable, onyx, nova, shimmer
      },
      {
        headers: {
          'Authorization': `Bearer ${OPENAI_API_KEY}`,
          'Content-Type': 'application/json',
        },
        responseType: 'arraybuffer',
      }
    );

    return Buffer.from(response.data).toString('base64');
  } catch (error) {
    console.error('TTS API Error:', error.response?.data || error.message);
    return null;
  }
};

/**
 * Process a voice query with transcription and TTS response.
 */
exports.processVoiceQuery = async (audioData, userId, context = {}) => {
  const { language = 'auto', conversationId, enableTTS = true } = context;

  try {
    // Convert base64 to buffer if needed
    const audioBuffer = Buffer.isBuffer(audioData) 
      ? audioData 
      : Buffer.from(audioData, 'base64');

    // 1. Transcribe audio to text using Whisper
    const transcribedText = await transcribeAudio(audioBuffer, language);

    if (!transcribedText || transcribedText.trim() === '') {
      throw new Error('Could not transcribe audio. Please speak clearly.');
    }

    // 2. Get chat response for the transcribed text
    const aiChatResponse = await exports.getChatResponse(transcribedText, userId, {
      conversationId,
      language: language === 'auto' ? 'en' : language,
    });

    // 3. Convert response to speech
    let audioResponse = null;
    if (enableTTS && aiChatResponse.message) {
      // For long responses, truncate to first few sentences
      const shortResponse = aiChatResponse.message
        .split(/[.!?]/)
        .slice(0, 3)
        .join('. ') + '.';
      
      audioResponse = await textToSpeech(shortResponse);
    }

    // 4. Log the voice interaction
    const newLog = new AIVoiceLog({
      userId,
      audioUrl: 'stored_audio', // In production, upload to S3 and store URL
      transcribedText,
      aiResponseText: aiChatResponse.message,
      language: language === 'auto' ? 'detected' : language,
    });
    await newLog.save();

    return {
      transcribedText,
      aiResponse: aiChatResponse.message,
      conversationId: aiChatResponse.conversationId,
      audioResponse, // base64 audio
      voiceLogId: newLog._id,
    };
  } catch (error) {
    console.error('Voice Processing Error:', error);
    throw new Error(error.message || 'Failed to process voice query');
  }
};

/**
 * Fetch conversation history from the database.
 */
exports.getConversationHistory = async (userId, limit = 50) => {
  const history = await AIConversation.find({ userId })
    .sort({ createdAt: -1 })
    .limit(limit);
  
  return history.map(conv => ({
    id: conv._id,
    title: conv.title,
    messageCount: conv.messages.length,
    lastMessage: conv.messages[conv.messages.length - 1]?.content?.substring(0, 100) || '',
    createdAt: conv.createdAt,
  }));
};

/**
 * Get a specific conversation with all messages
 */
exports.getConversation = async (conversationId, userId) => {
  const conversation = await AIConversation.findOne({ _id: conversationId, userId });
  if (!conversation) {
    throw new Error('Conversation not found or unauthorized');
  }
  return conversation;
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

/**
 * Get soil analysis history
 */
exports.getSoilHistory = async (userId, limit = 20) => {
  const SoilAnalysis = require('../models/soil_analysis_model');
  const history = await SoilAnalysis.find({ userId })
    .sort({ createdAt: -1 })
    .limit(limit);
  
  return history.map(analysis => ({
    id: analysis._id,
    season: analysis.season,
    ph: analysis.ph,
    crops: analysis.recommendations?.crops || [],
    createdAt: analysis.createdAt,
  }));
};

/**
 * Get disease detection history
 */
exports.getDiseaseHistory = async (userId, limit = 20) => {
  const DiseaseDetection = require('../models/disease_detection_model');
  const history = await DiseaseDetection.find({ userId })
    .sort({ createdAt: -1 })
    .limit(limit);
  
  return history.map(detection => ({
    id: detection._id,
    plantType: detection.plantType,
    disease: detection.disease,
    confidence: detection.confidence,
    createdAt: detection.createdAt,
  }));
};

/**
 * Get voice query history
 */
exports.getVoiceHistory = async (userId, limit = 20) => {
  const AIVoiceLog = require('../models/ai_voice_log_model');
  const history = await AIVoiceLog.find({ userId })
    .sort({ createdAt: -1 })
    .limit(limit);
  
  return history.map(log => ({
    id: log._id,
    transcribedText: log.transcribedText?.substring(0, 100) || '',
    language: log.language,
    createdAt: log.createdAt,
  }));
};

module.exports = exports;