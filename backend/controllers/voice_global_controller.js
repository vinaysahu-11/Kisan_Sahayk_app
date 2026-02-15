// Voice Global Controller - Process voice commands with AI
// Returns structured actions for app navigation and control

const OpenAI = require('openai');
const VoiceSession = require('../models/VoiceSession');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || 'YOUR_OPENAI_KEY',
});

// Screen action mappings
const SCREEN_ROUTES = {
  dashboard: '/',
  transport: '/transport',
  buy_product: '/buy-product',
  sell_product: '/sell-product',
  labour: '/labour',
  weather: '/weather',
  ai_assistant: '/ai-assistant',
  profile: '/profile',
  notifications: '/notifications',
  settings: '/settings',
  cart: '/buyer-cart',
  orders: '/buyer-orders',
  wallet: '/buyer-wallet',
};

// Process global voice command
exports.processGlobalCommand = async (req, res) => {
  try {
    const {
      text,
      language = 'hi',
      sessionId,
      currentScreen,
      learningMode = false,
      availableActions = [],
      context = {},
    } = req.body;

    if (!text) {
      return res.status(400).json({
        success: false,
        message: 'Text required',
      });
    }

    // Get AI response with structured output
    const aiResponse = await getAIResponse({
      text,
      language,
      currentScreen,
      learningMode,
      availableActions,
      context,
    });

    // Parse AI response and create action
    const result = parseAIResponse(aiResponse, language, learningMode);

    // Auto-save conversation to MongoDB
    try {
      await autoSaveConversation({
        sessionId,
        userMessage: text,
        assistantMessage: result.message,
        context: result.context,
        language,
      });
    } catch (saveError) {
      console.error('Auto-save error:', saveError);
      // Don't fail the request if save fails
    }

    res.json({
      success: true,
      message: result.message,
      action: result.action,
      context: result.context,
      sessionId,
    });
  } catch (error) {
    console.error('Process global command error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// Get AI response using GPT-4
async function getAIResponse({
  text,
  language,
  currentScreen,
  learningMode,
  availableActions,
  context,
}) {
  const systemPrompt = `You are a voice assistant for Kisan Sahayak - a farming app for Indian farmers.

Current Context:
- Current Screen: ${currentScreen || 'dashboard'}
- Available Actions: ${availableActions.join(', ')}
- Learning Mode: ${learningMode ? 'ON (explain steps)' : 'OFF'}
- Language: ${language === 'hi' ? 'Hindi/Hinglish' : language === 'en' ? 'English' : 'Chhattisgarhi'}

Your job:
1. Understand user's intent
2. Guide them to complete their task
3. Return structured JSON response

Response format:
{
  "intent": "navigate|fill_form|confirm|select|back|help",
  "message": "Natural language response in ${language}",
  "action": {
    "type": "navigate|fill_form|confirm|select|back",
    "route": "/screen-route",
    "explanation": "Explanation for learning mode",
    "fields": {},
    "confirmMessage": "Confirmation text"
  },
  "context": {
    "lastIntent": "intent_name",
    "data": {}
  }
}

Common intents:
- "transport chahiye" → navigate to /transport
- "beej kharidna hai" → navigate to /buy-product
- "majdoor chahiye" → navigate to /labour
- "mausam dikhao" → navigate to /weather
- "dashboard pe jao" → navigate to /
- "booking confirm karo" → confirm action
- "back jao" → back action

Reply in simple ${language} suitable for rural farmers.`;

  const userMessage = `User said: "${text}"
  
Previous context: ${JSON.stringify(context)}

What should the app do? Return JSON only.`;

  const completion = await openai.chat.completions.create({
    model: 'gpt-4-turbo-preview',
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userMessage },
    ],
    response_format: { type: 'json_object' },
    temperature: 0.7,
  });

  const response = completion.choices[0].message.content;
  return JSON.parse(response);
}

// Parse AI response
function parseAIResponse(aiResponse, language, learningMode) {
  const { intent, message, action, context } = aiResponse;

  let finalAction = null;

  if (action && action.type === 'navigate') {
    // Map intent to route
    const route = action.route || mapIntentToRoute(intent);
    
    finalAction = {
      type: 'navigate',
      route,
      arguments: action.arguments || {},
      explanation: learningMode ? action.explanation : null,
    };
  } else if (action && action.type === 'fill_form') {
    finalAction = {
      type: 'fill_form',
      fields: action.fields || {},
    };
  } else if (action && action.type === 'confirm') {
    finalAction = {
      type: 'confirm',
      confirmMessage: action.confirmMessage || 'Confirm?',
      confirmedAction: action.confirmedAction || null,
    };
  } else if (action && action.type === 'back') {
    finalAction = {
      type: 'back',
    };
  }

  return {
    message: message || getDefaultMessage(intent, language),
    action: finalAction,
    context: context || {},
  };
}

// Map intent to route
function mapIntentToRoute(intent) {
  const intentRouteMap = {
    navigate_transport: '/transport',
    navigate_buy: '/buy-product',
    navigate_sell: '/sell-product',
    navigate_labour: '/labour',
    navigate_weather: '/weather',
    navigate_ai_assistant: '/ai-assistant',
    navigate_profile: '/profile',
    navigate_dashboard: '/',
    navigate_cart: '/buyer-cart',
    navigate_orders: '/buyer-orders',
    navigate_wallet: '/buyer-wallet',
    navigate_notifications: '/notifications',
  };

  return intentRouteMap[intent] || '/';
}

// Default messages
function getDefaultMessage(intent, language) {
  const messages = {
    hi: {
      navigate_transport: 'Main aapko transport section me le ja raha hoon.',
      navigate_buy: 'Chaliye product kharidne ka section dekhte hain.',
      navigate_sell: 'Product bechne ke liye yaha aayiye.',
      navigate_labour: 'Majdoor dhundne me madad karta hoon.',
      navigate_weather: 'Mausam ka haal dikhata hoon.',
      navigate_dashboard: 'Dashboard pe wapas ja rahe hain.',
      default: 'Samajh gaya. Kya karu?',
    },
    en: {
      navigate_transport: 'Taking you to transport section.',
      navigate_buy: 'Let me show you products.',
      navigate_sell: 'Opening sell section.',
      navigate_labour: 'Finding workers for you.',
      navigate_weather: 'Showing weather forecast.',
      navigate_dashboard: 'Going back to dashboard.',
      default: 'Got it. What should I do?',
    },
  };

  const langMessages = messages[language] || messages['hi'];
  return langMessages[intent] || langMessages['default'];
}

// Get voice shortcuts
exports.getVoiceShortcuts = async (req, res) => {
  try {
    const { language = 'hi' } = req.query;

    const shortcuts = {
      hi: [
        { command: 'dashboard pe jao', description: 'Dashboard kholo' },
        { command: 'transport chahiye', description: 'Transport book karo' },
        { command: 'beej kharidna hai', description: 'Product khareedo' },
        { command: 'bechna hai', description: 'Apna product becho' },
        { command: 'majdoor chahiye', description: 'Labour dhundo' },
        { command: 'mausam dikhao', description: 'Weather dekho' },
        { command: 'AI se baat karo', description: 'AI assistant' },
        { command: 'mere orders', description: 'Orders dikhao' },
        { command: 'wallet kholo', description: 'Wallet dekho' },
        { command: 'back jao', description: 'Pichle page pe jao' },
      ],
      en: [
        { command: 'go to dashboard', description: 'Open dashboard' },
        { command: 'book transport', description: 'Book vehicle' },
        { command: 'buy products', description: 'Shop products' },
        { command: 'sell products', description: 'List your product' },
        { command: 'hire labour', description: 'Find workers' },
        { command: 'show weather', description: 'Weather forecast' },
        { command: 'AI assistant', description: 'Talk to AI' },
        { command: 'my orders', description: 'View orders' },
        { command: 'my wallet', description: 'View wallet' },
        { command: 'go back', description: 'Previous page' },
      ],
    };

    res.json({
      success: true,
      shortcuts: shortcuts[language] || shortcuts['hi'],
    });
  } catch (error) {
    console.error('Get shortcuts error:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
};

// Helper: Auto-save conversation to MongoDB
async function autoSaveConversation({ sessionId, userMessage, assistantMessage, context, language }) {
  try {
    let session = await VoiceSession.findOne({ conversationId: sessionId });

    const userMsg = {
      role: 'user',
      content: userMessage,
      timestamp: new Date(),
    };

    const assistantMsg = {
      role: 'assistant',
      content: assistantMessage,
      timestamp: new Date(),
    };

    if (session) {
      // Update existing session
      session.messages.push(userMsg, assistantMsg);
      session.context = context;
      session.updatedAt = Date.now();
      await session.save();
    } else {
      // Create new session
      session = new VoiceSession({
        conversationId: sessionId,
        messages: [userMsg, assistantMsg],
        context,
        language,
        status: 'active',
      });
      await session.save();
    }

    return session;
  } catch (error) {
    console.error('Auto-save conversation error:', error);
    throw error;
  }
}

// Get conversation history
exports.getConversationHistory = async (req, res) => {
  try {
    const { sessionId } = req.params;

    const session = await VoiceSession.findOne({ conversationId: sessionId });

    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Session not found',
      });
    }

    res.json({
      success: true,
      session: {
        id: session.conversationId,
        messages: session.messages,
        context: session.context,
        language: session.language,
        createdAt: session.createdAt,
        updatedAt: session.updatedAt,
      },
    });
  } catch (error) {
    console.error('Get conversation history error:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
};

// Save voice context for future reference
exports.saveVoiceContext = async (req, res) => {
  try {
    const { sessionId, context, messages } = req.body;

    // Find existing session or create new
    let session = await VoiceSession.findOne({ conversationId: sessionId });

    if (session) {
      // Update existing session
      session.context = context || session.context;
      if (messages && messages.length > 0) {
        session.messages.push(...messages);
      }
      session.updatedAt = Date.now();
      await session.save();
    } else {
      // Create new session
      session = new VoiceSession({
        conversationId: sessionId,
        context: context || {},
        messages: messages || [],
        language: context?.language || 'hi',
        status: 'active',
      });
      await session.save();
    }

    res.json({
      success: true,
      message: 'Context saved',
      sessionId: session.conversationId,
    });
  } catch (error) {
    console.error('Save context error:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
};
