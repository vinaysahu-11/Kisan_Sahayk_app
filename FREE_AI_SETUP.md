# 🆓 FREE AI Setup Guide

## Get Started in 3 Minutes (100% FREE)

### Step 1: Get FREE Google Gemini API Key

1. Go to: **https://makersuite.google.com/app/apikey**
2. Sign in with your Google account
3. Click **"Create API Key"**
4. Copy the key (starts with `AIza...`)

**Free Limits:**
- ✅ 15 requests per minute
- ✅ 1,500 requests per day
- ✅ Completely FREE forever
- ✅ Supports chat AND vision (image analysis)

### Step 2: Configure Backend

1. Copy `.env.example` to `.env`:
   ```bash
   cd backend
   copy .env.example .env
   ```

2. Edit `.env` file and add your Gemini key:
   ```env
   USE_GEMINI=true
   GEMINI_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```

3. Save the file

### Step 3: Start the System

```bash
# Start backend
cd backend
npm install
npm start

# Start Flutter app (in another terminal)
cd ..
flutter pub get
flutter run
```

## ✅ What Works with FREE Gemini

- ✅ **AI Chat** - Natural language conversations
- ✅ **Soil Analysis** - Crop recommendations
- ✅ **Disease Detection** - Plant image analysis
- ✅ **Multi-Language** - Hindi, English, Chhattisgarhi, Hinglish
- ✅ **Shop Recommendations** - Nearby agri shops
- ✅ **Conversation History** - Saved chats

## ❌ What Requires Paid APIs

- ❌ **Voice-to-Text** (Whisper) - Needs OpenAI
- ❌ **Text-to-Speech** (TTS) - Needs OpenAI

**Note:** Voice features are optional and not required for core AI functionality.

## 🔄 Switch to OpenAI Later (Optional)

If you want better quality or voice features:

1. Get OpenAI key: https://platform.openai.com/api-keys
2. Update `.env`:
   ```env
   USE_GEMINI=false
   OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx
   ```
3. Restart backend

## 💡 Tips to Stay Within Free Limits

1. **Rate Limiting**: 15 requests/minute is plenty for testing
2. **Daily Limit**: 1,500 requests = ~60 users per day
3. **Optimize**: Cache common questions
4. **Monitor**: Check usage at https://console.cloud.google.com/

## 🆘 Troubleshooting

**"Failed to get AI response"**
- Check if Gemini key is correct in `.env`
- Verify `USE_GEMINI=true` is set
- Check internet connection

**"Rate limit exceeded"**
- Wait 1 minute and try again
- Gemini free tier: 15 requests/minute

**"API key not valid"**
- Regenerate key at https://makersuite.google.com/app/apikey
- Make sure you copied the full key

## 📊 Comparison: Gemini vs OpenAI

| Feature | Gemini (FREE) | OpenAI (PAID) |
|---------|---------------|---------------|
| Chat | ✅ Excellent | ✅ Best |
| Vision/Image | ✅ Very Good | ✅ Excellent |
| Voice (STT) | ❌ Not available | ✅ Whisper API |
| Voice (TTS) | ❌ Not available | ✅ TTS API |
| Cost | 🆓 FREE | 💰 $0.01-0.05/request |
| Speed | ⚡ Fast | ⚡ Very Fast |
| Multi-language | ✅ Yes | ✅ Yes |

## 🎉 You're All Set!

With Gemini API, you get:
- Professional AI agriculture assistant
- Image-based disease detection
- Multi-language support
- Completely FREE

No credit card required! 🚀
