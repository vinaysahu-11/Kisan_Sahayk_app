const axios = require('axios');
const FormData = require('form-data');
const VoiceSession = require('../models/VoiceSession');
const { v4: uuidv4 } = require('uuid');

// Import AI service for intent detection
const aiService = require('./ai_service');

// Google Speech-to-Text (if configured)
const GOOGLE_SPEECH_API_KEY = process.env.GOOGLE_SPEECH_API_KEY || '';

// OpenAI Whisper (if configured)
const OPENAI_API_KEY = process.env.OPENAI_API_KEY || '';

// Gemini API
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';

/**
 * Greetings in different languages
 */
const getGreeting = (language) => {
  const greetings = {
    en: 'Hello! What would you like to do today?',
    hi: 'नमस्ते! आप क्या करना चाहते हैं?',
    cg: 'नमस्कार! तुमन का करे चाहत हव?',
    hinglish: 'Namaste! Aap kya karna chahte hain?',
  };
  return greetings[language] || greetings.hi;
};

/**
 * Get system prompt for intent detection
 */
const getIntentPrompt = (language) => {
  return `You are a voice assistant for Indian farmers using Kisan Sahayak app.

Your job is to:
1. Understand user intent
2. Extract booking details
3. Ask follow-up questions if needed
4. Maintain friendly conversation tone

Available intents:
- book_transport: User wants to book vehicle/truck
- book_labour: User wants to hire farm labour
- buy_product: User wants to buy agriculture products
- sell_product: User wants to sell their produce
- weather_query: User asks about weather
- soil_analysis: User wants soil testing advice
- disease_scan: User asks about plant diseases
- general_query: General farming question

IMPORTANT: Always respond in ${language === 'hi' ? 'Hindi' : language === 'en' ? 'English' : language === 'cg' ? 'Chhattisgarhi' : 'Hinglish'}.
Use simple, rural-friendly language.
Be conversational and helpful.

If user provides partial information, ask for missing details one by one.

Format your response as JSON:
{
  "intent": "book_transport|book_labour|...",
  "message": "Your friendly reply to user in ${language}",
  "entities": {
    "pickup": "location",
    "drop": "location",
    "load": "weight",
    "vehicle": "type",
    "date": "date",
    "workers": "count",
    "duration": "days"
  },
  "complete": true/false,
  "nextQuestion": "What to ask next if incomplete"
}`;
};

/**
 * Process voice command end-to-end
 */
exports.processVoiceCommand = async (audioBuffer, userId, sessionId, language = 'hi') => {
  try {
    // Step 1: Speech-to-Text
    const transcription = await speechToText(audioBuffer, language);
    
    if (!transcription || transcription.trim() === '') {
      return {
        success: false,
        error: 'Could not understand audio. Please try again.',
      };
    }

    // Step 2: Get or create session
    let session = sessionId ? await VoiceSession.findOne({ conversationId: sessionId }) : null;
    
    if (!session) {
      session = new VoiceSession({
        userId: userId || null,
        conversationId: uuidv4(),
        language,
        messages: [],
        context: {},
      });
    }

    // Add user message
    session.messages.push({
      role: 'user',
      content: transcription,
      timestamp: new Date(),
    });

    // Step 3: Intent detection & response generation
    const intentResponse = await detectIntentAndRespond(transcription, session, language);

    // Add assistant message
    session.messages.push({
      role: 'assistant',
      content: intentResponse.message,
      timestamp: new Date(),
    });

    // Update context
    session.context = {
      ...session.context,
      lastIntent: intentResponse.intent,
      entities: { ...session.context.entities, ...intentResponse.entities },
    };

    await session.save();

    return {
      success: true,
      sessionId: session.conversationId,
      transcription,
      intent: intentResponse.intent,
      message: intentResponse.message,
      entities: intentResponse.entities,
      complete: intentResponse.complete,
      action: intentResponse.action, // Navigation action
    };
  } catch (error) {
    console.error('Voice processing error:', error);
    throw error;
  }
};

/**
 * Speech-to-Text using available service
 */
const speechToText = async (audioBuffer, language) => {
  // Try Google Speech API first (if configured)
  if (GOOGLE_SPEECH_API_KEY) {
    try {
      return await googleSpeechToText(audioBuffer, language);
    } catch (error) {
      console.log('Google Speech failed, trying alternative:', error.message);
    }
  }

  // Fallback: Return placeholder for now
  // In production, implement OpenAI Whisper or other STT
  throw new Error('Speech-to-text not configured. Please set GOOGLE_SPEECH_API_KEY in .env');
};

/**
 * Google Speech-to-Text
 */
const googleSpeechToText = async (audioBuffer, language) => {
  const langCode = language === 'hi' ? 'hi-IN' : 'en-IN';
  
  const response = await axios.post(
    `https://speech.googleapis.com/v1/speech:recognize?key=${GOOGLE_SPEECH_API_KEY}`,
    {
      config: {
        encoding: 'WEBM_OPUS',
        sampleRateHertz: 48000,
        languageCode: langCode,
        alternativeLanguageCodes: ['hi-IN', 'en-IN'],
        enableAutomaticPunctuation: true,
      },
      audio: {
        content: audioBuffer.toString('base64'),
      },
    }
  );

  if (response.data.results && response.data.results.length > 0) {
    return response.data.results[0].alternatives[0].transcript;
  }

  throw new Error('No transcription result');
};

/**
 * Detect intent and generate response using Gemini
 */
const detectIntentAndRespond = async (userMessage, session, language) => {
  const systemPrompt = getIntentPrompt(language);
  
  // Build conversation history
  const conversationHistory = session.messages
    .slice(-4) // Last 2 exchanges
    .map(msg => `${msg.role === 'user' ? 'User' : 'Assistant'}: ${msg.content}`)
    .join('\n');

  const prompt = `${systemPrompt}

Previous conversation:
${conversationHistory}

Current context:
${JSON.stringify(session.context, null, 2)}

User just said: "${userMessage}"

Respond with JSON only.`;

  // Call Gemini
  const response = await axios.post(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`,
    {
      contents: [{
        parts: [{ text: prompt }]
      }],
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 1024,
      }
    }
  );

  const aiResponse = response.data.candidates[0].content.parts[0].text;
  
  // Extract JSON from response
  let intentData;
  try {
    // Try to extract JSON from markdown code blocks
    const jsonMatch = aiResponse.match(/```json\n([\s\S]*?)\n```/) || aiResponse.match(/\{[\s\S]*\}/);
    const jsonString = jsonMatch ? (jsonMatch[1] || jsonMatch[0]) : aiResponse;
    intentData = JSON.parse(jsonString);
  } catch (error) {
    // Fallback: treat as general query
    intentData = {
      intent: 'general_query',
      message: aiResponse,
      entities: {},
      complete: true,
    };
  }

  // Determine navigation action
  const action = getNavigationAction(intentData.intent, intentData.complete, intentData.entities);

  return {
    ...intentData,
    action,
  };
};

/**
 * Determine which screen to navigate to
 */
const getNavigationAction = (intent, complete, entities) => {
  if (!complete) return null;

  const actions = {
    book_transport: { screen: 'TransportBooking', data: entities },
    book_labour: { screen: 'LabourBooking', data: entities },
    buy_product: { screen: 'BuyerDashboard', data: entities },
    sell_product: { screen: 'SellerDashboard', data: entities },
    weather_query: { screen: 'Weather', data: entities },
    soil_analysis: { screen: 'SoilAnalysis', data: entities },
    disease_scan: { screen: 'DiseaseScanner', data: entities },
  };

  return actions[intent] || null;
};

/**
 * Process text command (for testing and fallback)
 */
exports.processTextCommand = async (text, userId, sessionId, language = 'hi') => {
  try {
    // Get or create session
    let session = sessionId ? await VoiceSession.findOne({ conversationId: sessionId }) : null;
    
    if (!session) {
      session = new VoiceSession({
        userId: userId || null,
        conversationId: uuidv4(),
        language,
        messages: [],
        context: {},
      });
    }

    // Add user message
    session.messages.push({
      role: 'user',
      content: text,
      timestamp: new Date(),
    });

    // Intent detection & response generation
    const intentResponse = await detectIntentAndRespond(text, session, language);

    // Add assistant message
    session.messages.push({
      role: 'assistant',
      content: intentResponse.message,
      timestamp: new Date(),
    });

    // Update context
    session.context = {
      ...session.context,
      lastIntent: intentResponse.intent,
      entities: { ...session.context.entities, ...intentResponse.entities },
    };

    await session.save();

    return {
      success: true,
      sessionId: session.conversationId,
      transcription: text,
      intent: intentResponse.intent,
      message: intentResponse.message,
      entities: intentResponse.entities,
      complete: intentResponse.complete,
      action: intentResponse.action,
    };
  } catch (error) {
    console.error('Text processing error:', error);
    throw error;
  }
};

/**
 * Get voice session history
 */
exports.getVoiceHistory = async (userId, limit = 10) => {
  const sessions = await VoiceSession.find(
    userId ? { userId } : {}
  )
    .sort({ updatedAt: -1 })
    .limit(limit)
    .select('conversationId language messages.0 createdAt updatedAt status');

  return sessions.map(s => ({
    sessionId: s.conversationId,
    language: s.language,
    preview: s.messages[0]?.content.substring(0, 50) || 'Empty session',
    createdAt: s.createdAt,
    status: s.status,
  }));
};

/**
 * Get specific session
 */
exports.getVoiceSession = async (sessionId, userId) => {
  const session = await VoiceSession.findOne({ conversationId: sessionId });
  
  if (!session) {
    throw new Error('Session not found');
  }

  // Check ownership for logged-in users
  if (userId && session.userId && session.userId.toString() !== userId.toString()) {
    throw new Error('Unauthorized');
  }

  return session;
};

/**
 * Clear/end session
 */
exports.endVoiceSession = async (sessionId, userId) => {
  const session = await VoiceSession.findOne({ conversationId: sessionId });
  
  if (!session) {
    throw new Error('Session not found');
  }

  if (userId && session.userId && session.userId.toString() !== userId.toString()) {
    throw new Error('Unauthorized');
  }

  session.status = 'completed';
  await session.save();

  return { success: true };
};

/**
 * Text-to-Speech placeholder
 * In production, use Google TTS or OpenAI TTS
 */
exports.textToSpeech = async (text, language = 'hi') => {
  // This will be handled client-side using flutter_tts or google_tts
  // Backend just returns the text
  return {
    text,
    language,
    audioUrl: null, // Can implement server-side TTS if needed
  };
};

module.exports = exports;
