const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const dotenv = require('dotenv');
const connectDB = require('./config/database');
const { errorHandler, notFound } = require('./middleware/errorHandler');

// Load environment variables
dotenv.config();

const app = express();

// Connect to MongoDB
connectDB();

// Security Middleware
app.use(helmet());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
});
app.use('/api/', limiter);

// CORS Configuration for Development
const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);
    
    // Allow all localhost origins for development
    if (origin.includes('localhost') || origin.includes('127.0.0.1')) {
      return callback(null, true);
    }
    
    // Allow specific origins from env
    const allowedOrigins = (process.env.FRONTEND_URL || '*').split(',');
    if (allowedOrigins.includes('*') || allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    
    callback(new Error('Not allowed by CORS'));
  },
  credentials: true,
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
};

app.use(cors(corsOptions));

// Body Parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request Logger (Development)
if (process.env.NODE_ENV === 'development') {
  app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    console.log('  Headers:', req.headers['content-type']);
    console.log('  Origin:', req.headers.origin);
    next();
  });
}

// Health Check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Kisan Sahayk API is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// API Test Endpoint
app.get('/api/test', (req, res) => {
  res.json({
    success: true,
    message: 'API is working!',
    endpoints: {
      auth: '/api/auth',
      ai: '/api/ai',
      weather: '/api/weather',
      buyer: '/api/buyer',
      seller: '/api/seller',
      labour: '/api/labour',
      transport: '/api/transport',
    },
    timestamp: new Date().toISOString(),
  });
});

// Import Routes
const authRoutes = require('./routes/auth');
const buyerRoutes = require('./routes/buyer');
const sellerRoutes = require('./routes/seller');
const labourRoutes = require('./routes/labour_routes');
const transportRoutes = require('./routes/transport_routes');
const deliveryRoutes = require('./routes/delivery');
const adminRoutes = require('./routes/admin');
const weatherRoutes = require('./routes/weather');
const aiRoutes = require('./routes/ai_routes');
const voiceRoutes = require('./routes/voice_routes');

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/buyer', buyerRoutes);
app.use('/api/seller', sellerRoutes);
app.use('/api/labour', labourRoutes);
app.use('/api/transport', transportRoutes);
app.use('/api/delivery', deliveryRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/weather', weatherRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/voice', voiceRoutes);

// 404 Handler
app.use(notFound);

// Global Error Handler
app.use(errorHandler);

// Start Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log('═══════════════════════════════════════════════');
  console.log('🚀 Kisan Sahayk Backend Server Started');
  console.log('═══════════════════════════════════════════════');
  console.log(`📍 Local:    http://localhost:${PORT}`);
  console.log(`📍 Network:  http://0.0.0.0:${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log('');
  console.log('📡 API Endpoints:');
  console.log(`   - Health:     GET  /health`);
  console.log(`   - Test:       GET  /api/test`);
  console.log(`   - Auth:       POST /api/auth/*`);
  console.log(`   - AI Chat:    POST /api/ai/chat`);
  console.log(`   - AI Soil:    POST /api/ai/soil-analysis`);
  console.log(`   - AI Disease: POST /api/ai/disease-scan`);
  console.log(`   - AI History: GET  /api/ai/history`);
  console.log(`   - Voice CMD:  POST /api/voice/process`);
  console.log(`   - Voice TTS:  POST /api/voice/tts`);
  console.log(`   - Voice Hist: GET  /api/voice/history`);
  console.log('');
  console.log('🔑 AI Engine:', process.env.USE_GEMINI === 'false' ? 'OpenAI GPT-4o' : 'Google Gemini 2.5 Flash');
  console.log('🎙️  Voice System: Active');
  console.log('═══════════════════════════════════════════════');
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('❌ Unhandled Promise Rejection:', err);
  process.exit(1);
});

