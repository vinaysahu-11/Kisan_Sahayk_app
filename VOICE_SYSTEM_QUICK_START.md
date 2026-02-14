# Voice Command System - Quick Start Guide

## 🎯 Overview

The Kisan Sahayak Voice Command System is a production-ready conversational AI assistant that understands Hindi, English, and Chhattisgarhi voice commands for farming tasks.

---

## 🚀 Quick Start

### 1. Backend Setup

**Start the backend:**
```bash
cd backend
node server.js
```

**Verify running:**
```bash
curl http://localhost:3000/health
```

### 2. Flutter App Setup

**Install dependencies:**
```bash
flutter pub get
```

**Run the app:**
```bash
flutter run -d chrome  # For web
flutter run            # For Android/iOS
```

### 3. Using Voice Assistant

1. **Open Dashboard** - Navigate to the main dashboard
2. **Click Mic Button** - Floating action button (bottom-right)
3. **Speak Command** - Say your command in Hindi or English
4. **AI Responds** - Get instant response with follow-up questions
5. **Auto Navigation** - System navigates to relevant screen when ready

---

## 🎙️ Example Voice Commands

### Transport Booking 🚚
```
Hindi:    "Mujhe transport book karna hai Raipur se Durg"
English:  "I need to book transport from Raipur to Durg"
Result:   → Navigates to Transport Booking screen
```

### Labour Hiring 👥
```
Hindi:    "5 mazdoor chahiye kal subah 7 baje"
English:  "I need 5 workers tomorrow morning at 7"
Result:   → Navigates to Labour Booking screen
```

### Weather Check 🌤️
```
Hindi:    "Aaj ka mausam kaisa hai?"
English:  "What is the weather today?"
Result:   → Navigates to Weather screen
```

### Buy Products 🛒
```
Hindi:    "Mujhe beej kharidna hai"
English:  "I want to buy seeds"
Result:   → Navigates to Buyer Dashboard
```

### Sell Products 💰
```
Hindi:    "Mujhe apni fasal bechni hai"
English:  "I want to sell my crops"
Result:   → Navigates to Seller Dashboard
```

### Soil Health 🌱
```
Hindi:    "Mitti ki jaanch karwa do"
English:  "Check my soil health"
Result:   → Navigates to AI Assistant (Soil tab)
```

### Disease Detection 🔬
```
Hindi:    "Patte pe daag aa gaye hain"
English:  "My plants have spots on leaves"
Result:   → Navigates to AI Assistant (Disease tab)
```

---

## 📁 Key Files

### Backend
```
backend/
├── models/VoiceSession.js          # MongoDB schema for sessions
├── services/voice_service.js       # Core voice processing engine
├── controllers/voice_controller.js # Request handlers
└── routes/voice_routes.js          # API routes
```

### Flutter
```
lib/
├── services/
│   ├── voice_service.dart          # Audio recording & API client
│   └── voice_navigation_service.dart # Intent-based navigation
└── screens/
    └── voice_assistant_screen.dart  # Voice UI with chat & waveform
```

---

## 🔧 API Endpoints

### Process Text Command (Testing)
```http
POST /api/voice/process-text
Content-Type: application/json

{
  "text": "Mujhe transport book karna hai",
  "language": "hi",
  "sessionId": "optional-uuid"
}
```

### Process Audio Command
```http
POST /api/voice/process
Content-Type: multipart/form-data

audio: <audio file>
language: hi
sessionId: optional-uuid
```

### Get Voice History
```http
GET /api/voice/history?limit=10
```

### Get Session Details
```http
GET /api/voice/session/:sessionId
```

### End Session
```http
POST /api/voice/session/:sessionId/end
```

### Text-to-Speech
```http
POST /api/voice/tts

{
  "text": "Hello farmer!",
  "language": "en"
}
```

---

## 🌐 Supported Languages

| Language | Code | Status | Example |
|----------|------|--------|---------|
| Hindi | `hi` | ✅ | "मुझे मदद चाहिए" |
| English | `en` | ✅ | "I need help" |
| Chhattisgarhi | `cg` | ✅ | "मोला मदद चाही" |
| Hinglish | `hinglish` | ✅ | "Mujhe help chahiye" |

---

## 🎯 Intent Categories

| Intent | Trigger Words | Navigation |
|--------|--------------|------------|
| `book_transport` | transport, vehicle, gaadi | Transport Booking |
| `book_labour` | labour, mazdoor, worker | Labour Booking |
| `buy_product` | buy, kharido, seeds, tools | Buyer Dashboard |
| `sell_product` | sell, becho, fasal, crop | Seller Dashboard |
| `weather_query` | weather, mausam, forecast | Weather Screen |
| `soil_analysis` | soil, mitti, health, test | AI Assistant (Soil) |
| `disease_scan` | disease, beemari, spots, pests | AI Assistant (Disease) |
| `general_query` | Any other farming question | AI Assistant |

---

## ⚙️ Configuration

### Required Environment Variables

**Backend (.env):**
```env
# Required
MONGODB_URI=mongodb://localhost:27017/kisan_sahayak
GEMINI_API_KEY=AIzaSyDRhUjAIuvGS3HdhPjBPbB976I7bJXAfKc
JWT_SECRET=your_jwt_secret
PORT=3000

# Optional (for Speech-to-Text)
GOOGLE_SPEECH_API_KEY=your_google_speech_key  # Recommended
OPENAI_API_KEY=your_openai_key                # Alternative (Whisper)

# AI Engine Selection
USE_GEMINI=true  # Use Gemini (free), false for OpenAI (paid)
```

### Flutter Configuration

**pubspec.yaml dependencies:**
```yaml
dependencies:
  record: ^5.2.1          # Audio recording
  flutter_tts: ^4.0.2     # Text-to-speech
  http: ^1.1.0            # API calls
  provider: ^6.0.5        # State management
  path_provider: ^2.1.0   # File paths
```

---

## 🧪 Testing

### Manual Testing via PowerShell

**Test intent detection:**
```powershell
$body = @{
    text = 'Mujhe transport book karna hai Raipur se Durg'
    language = 'hi'
} | ConvertTo-Json

Invoke-RestMethod -Uri http://localhost:3000/api/voice/process-text `
    -Method POST `
    -Body $body `
    -ContentType 'application/json'
```

**Test with session continuity:**
```powershell
# First message
$sessionId = $null
$body = @{text='Mujhe transport chahiye'; language='hi'} | ConvertTo-Json
$response = Invoke-RestMethod -Uri http://localhost:3000/api/voice/process-text -Method POST -Body $body -ContentType 'application/json'
$sessionId = $response.sessionId

# Follow-up message (uses same session)
$body = @{text='Raipur se Durg'; language='hi'; sessionId=$sessionId} | ConvertTo-Json
$response = Invoke-RestMethod -Uri http://localhost:3000/api/voice/process-text -Method POST -Body $body -ContentType 'application/json'
```

### Testing in Flutter App

1. Run app: `flutter run -d chrome`
2. Click floating mic button
3. Speak or type command
4. Verify:
   - ✅ Intent detected correctly
   - ✅ Response in correct language
   - ✅ Navigation happens when complete
   - ✅ Form fields pre-filled with entities

---

## 🐛 Troubleshooting

### Backend won't start
```bash
# Check if port 3000 is in use
netstat -ano | findstr :3000

# Kill the process
taskkill /F /PID <process_id>

# Restart backend
cd backend
node server.js
```

### MongoDB connection error
```bash
# Start MongoDB service
net start MongoDB

# Or use MongoDB Atlas connection string in .env
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/dbname
```

### Flutter dependencies error
```bash
# Clean and reinstall
flutter clean
flutter pub get

# If still failing, upgrade
flutter pub upgrade
```

### Voice recording not working
1. Check browser/device microphone permissions
2. Verify HTTPS (required for Web)
3. Test with audio file upload endpoint
4. Check console logs for errors

### STT not working
- **Symptom:** "Speech-to-text not configured" error
- **Cause:** GOOGLE_SPEECH_API_KEY not set
- **Solution:** Add API key to backend/.env or use text endpoint for testing

---

## 📊 System Architecture

```
┌─────────────────┐
│  Flutter App    │
│  (Web/Mobile)   │
└────────┬────────┘
         │
         │ HTTP REST API
         │
┌────────▼────────┐
│  Backend        │
│  (Node.js)      │  
│                 │
│  ┌──────────┐  │
│  │  Voice   │  │
│  │ Service  │  │
│  └────┬─────┘  │
│       │        │
│       ├─ STT (Google/OpenAI)
│       ├─ Intent Detection (Gemini)
│       ├─ Entity Extraction
│       └─ Navigation Actions
│                 │
└────────┬────────┘
         │
┌────────▼────────┐
│   MongoDB       │
│ (VoiceSession)  │
│  - Messages     │
│  - Context      │
│  - Entities     │
└─────────────────┘
```

---

## 🔒 Security Features

- ✅ Optional authentication (works with/without login)
- ✅ Session-based context isolation
- ✅ 10MB audio file size limit
- ✅ Audio format validation
- ✅ JWT token support
- ✅ CORS configured for localhost origins

---

## 📈 Performance Tips

1. **Session Management:**
   - Reuse sessionId for conversation continuity
   - End sessions when done to free resources

2. **Network Optimization:**
   - Use audio compression (m4a recommended)
   - Implement request timeouts
   - Cache frequent responses

3. **User Experience:**
   - Show loading indicators
   - Provide text fallback option
   - Display transcription for confirmation
   - Enable editing before submission

---

## 🚀 Deployment Checklist

### Backend
- [ ] Set production MongoDB URI
- [ ] Configure Google Speech API key
- [ ] Set secure JWT secret
- [ ] Enable HTTPS
- [ ] Configure CORS for production domains
- [ ] Set up error logging (Sentry, etc.)
- [ ] Configure rate limiting
- [ ] Set up health monitoring

### Flutter
- [ ] Update API URLs for production
- [ ] Enable HTTPS enforcement
- [ ] Configure release build settings
- [ ] Test on target devices
- [ ] Optimize TTS speech rate for users
- [ ] Add offline fallback messages
- [ ] Implement analytics tracking

---

## 📞 Support

For issues or questions:
1. Check [VOICE_SYSTEM_TEST_RESULTS.md](VOICE_SYSTEM_TEST_RESULTS.md)
2. Review backend console logs
3. Check Flutter debug console
4. Verify API endpoints with curl/Postman
5. Test with text endpoint first

---

## 🎉 Success Metrics

**Current Status:**
- ✅ 8 intents implemented
- ✅ Multi-turn conversations working
- ✅ Hindi + English support tested
- ✅ Entity extraction functional
- ✅ Navigation actions configured
- ✅ Session memory working
- ⏳ STT pending API key

**Ready for:**
- ✅ Text-based voice commands (immediate)
- ⏳ Audio-based voice commands (needs STT API key)
- ✅ Production deployment (with text input)
- ✅ User acceptance testing
