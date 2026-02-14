# AI Krishi Mitra - Setup Guide

## 🌟 Overview

The AI Krishi Mitra is a comprehensive ChatGPT-style AI agriculture assistant integrated into the Kisan Sahayak app. It provides:

- **Chat Interface**: Natural language conversations about farming
- **Soil Analysis**: AI-powered soil testing with crop recommendations
- **Disease Detection**: Vision AI to identify plant diseases from photos
- **Voice Mode**: Speech-to-text and text-to-speech capabilities  
- **Multi-Language Support**: Hindi, English, Chhattisgarhi, Hinglish
- **Shop Recommendations**: Find nearby agri shops with products
- **Contextual Memory**: Remembers previous conversations and analyses

## 🔧 Backend Setup

### 1. Environment Variables

Create or update your `.env` file in the backend directory:

```bash
# OpenAI Configuration (REQUIRED)
OPENAI_API_KEY=sk-your-openai-api-key-here

# MongoDB (if not already set)
MONGODB_URI=mongodb://localhost:27017/kisan_sahayak

# JWT (if not already set)
JWT_SECRET=your-secret-key-here
```

### 2. Install Dependencies

```bash
cd backend
npm install
```

Required packages:
- `axios` - For API calls
- `dotenv` - Environment variables
- `form-data` - For multipart requests
- `mongoose` - MongoDB ODM

### 3. Database Indexes

The system uses MongoDB geospatial indexes for shop recommendations. These are created automatically when the AgriShop model is first used.

### 4. Populate Sample Agri Shops (Optional)

To test shop recommendations, you can populate sample data:

```javascript
// backend/scripts/populate_shops.js
const mongoose = require('mongoose');
const AgriShop = require('../models/AgriShop');

const sampleShops = [
  {
    name: "Sharma Agri Store",
    owner: "Rajesh Sharma",
    phone: "+91 9876543210",
    address: "Main Market, Raipur, Chhattisgarh",
    location: {
      type: "Point",
      coordinates: [81.6296, 21.2514] // [longitude, latitude]
    },
    inventory: [
      { productName: "DAP", category: "fertilizer", inStock: true, price: 1200 },
      { productName: "Urea", category: "fertilizer", inStock: true, price: 266 },
      { productName: "Mancozeb", category: "medicine", inStock: true, price: 450 }
    ],
    rating: 4.5,
    verified: true
  },
  // Add more shops...
];

mongoose.connect(process.env.MONGODB_URI)
  .then(async () => {
    await AgriShop.insertMany(sampleShops);
    console.log('Sample shops inserted');
    process.exit(0);
  });
```

### 5. Start Backend Server

```bash
npm start
```

## 📱 Flutter/Frontend Setup

### 1. Install Flutter Dependencies

```bash
cd ..  # Back to project root
flutter pub get
```

### 2. Configure API Endpoint

Update the base URL in `lib/services/ai_service.dart`:

```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:5000/api/ai';

// For iOS Simulator
// static const String baseUrl = 'http://localhost:5000/api/ai';

// For Physical Device (use your machine's IP)
// static const String baseUrl = 'http://192.168.x.x:5000/api/ai';
```

### 3. Run the App

```bash
flutter run
```

## 🚀 Features Usage

### Chat Interface

1. Open the AI Krishi Mitra screen from the dashboard
2. Type any agriculture-related question
3. AI responds in selected language
4. Conversation history is saved automatically

### Soil Analysis

1. Click "Soil Test" button
2. Enter soil parameters (pH, N, P, K)
3. Select season (Kharif/Rabi/Zaid)
4. Get AI recommendations for:
   - Suitable crops
   - Fertilizers with dosages
   - Organic alternatives
   - Irrigation methods
   - Nearby shops with fertilizers

### Disease Detection

1. Click "Scan Disease" or "From Gallery"
2. Take/select a photo of the affected plant
3. AI analyzes using Vision API
4. Get diagnosis with:
   - Plant type & disease name
   - Confidence score
   - Medicine recommendations
   - Organic alternatives
   - Preventive measures
   - Nearby shops with medicines

### Voice Mode (Coming Soon)

1. Click microphone button
2. Speak in any supported language
3. Audio transcribed using Whisper
4. AI responds with text and optional voice

### Multi-Language

1. Click language icon in top bar
2. Select: English, Hindi, Chhattisgarhi, or Hinglish
3. All AI responses adapt to selected language

### Conversation History

1. Open left drawer
2. View all past conversations
3. Click to load a conversation
4. Swipe or click delete icon to remove

## 🔑 API Endpoints

All endpoints require JWT authentication:

### Chat
- `POST /api/ai/chat`
  ```json
  {
    "message": "How to grow wheat?",
    "conversationId": "optional-id",
    "language": "en",
    "location": { "coordinates": [lon, lat] }
  }
  ```

### Soil Analysis
- `POST /api/ai/soil-analysis`
  ```json
  {
    "ph": 6.5,
    "nitrogen": 250,
    "phosphorus": 30,
    "potassium": 200,
    "season": "Kharif",
    "language": "en",
    "location": { "coordinates": [lon, lat] }
  }
  ```

### Disease Detection
- `POST /api/ai/disease-scan`
  ```json
  {
    "image": "base64-encoded-image-or-url",
    "language": "en",
    "location": { "coordinates": [lon, lat] }
  }
  ```

### Voice Processing
- `POST /api/ai/voice`
  ```json
  {
    "audio": "base64-encoded-audio",
    "language": "auto",
    "conversationId": "optional-id",
    "enableTTS": true
  }
  ```

### History
- `GET /api/ai/history?type=chat&limit=50`
  - Types: `chat`, `soil`, `disease`, `voice`

### Get Conversation
- `GET /api/ai/conversation/:id`

### Delete Conversation
- `DELETE /api/ai/conversation/:id`

## 💰 Cost Considerations

### OpenAI API Pricing (as of 2024)

- **GPT-4o**: ~$5 per 1M input tokens, ~$15 per 1M output tokens
- **GPT-4o Vision**: ~$10 per 1M tokens (includes image processing)
- **Whisper**: ~$0.006 per minute of audio
- **TTS**: ~$15 per 1M characters

### Optimization Tips

1. **Implement caching**: Cache common questions
2. **Rate limiting**: Prevent abuse
3. **Token management**: Limit conversation history length
4. **Image compression**: Compress images before sending
5. **Use fast model**: For simple queries, use gpt-3.5-turbo

## 🛡️ Security Best Practices

1. **Never commit API keys** to version control
2. **Use environment variables** for all secrets
3. **Implement rate limiting** per user
4. **Validate input** on both frontend and backend
5. **Sanitize user uploads** (images/audio)
6. **Set max file sizes** (5MB for images)
7. **Use HTTPS** in production
8. **Implement proper auth** (JWT already in place)

## 🐛 Troubleshooting

### "OpenAI API Error"
- Check if `OPENAI_API_KEY` is set correctly
- Verify API key has sufficient credits
- Check internet connectivity

### "Failed to get AI response"
- Ensure backend server is running
- Check API endpoint URL in Flutter app
- Verify user is authenticated (token is valid)

### "No nearby shops found"
- Populate AgriShop collection with data
- Verify location coordinates are correct
- Check MongoDB geospatial index is created

### Image Upload Fails
- Check image size (<5MB)
- Verify image format (JPEG/PNG)
- Ensure proper base64 encoding

### Voice Not Working
- Request microphone permissions
- Check audio format compatibility
- Verify Whisper API access

## 📚 Additional Resources

- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [MongoDB Geospatial Queries](https://docs.mongodb.com/manual/geospatial-queries/)

## 🎯 Next Steps

1. **Voice Implementation**: Complete voice recording and playback
2. **Offline Mode**: Cache responses for offline access
3. **Analytics**: Track usage and popular queries
4. **Feedback System**: Allow users to rate AI responses
5. **Push Notifications**: Farming tips and reminders
6. **Weather Integration**: Combine with weather data for better recommendations

## 📞 Support

For issues or questions, refer to the main README.md or contact the development team.

---

**Built with ❤️ for Indian Farmers**
