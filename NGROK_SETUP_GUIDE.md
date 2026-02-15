# 🚀 NGROK INTEGRATION GUIDE - Complete Setup

## 📋 Prerequisites Checklist

Before starting, ensure you have:
- ✅ Ngrok installed on your system
- ✅ Node.js installed (for backend)
- ✅ MongoDB running locally
- ✅ Flutter project setup complete
- ✅ Android device with USB debugging enabled

---

## 🔧 STEP 1: Backend Configuration

### 1.1 Start Backend Server

```bash
cd backend
node server.js
```

**Expected Output:**
```
═══════════════════════════════════════════════
🚀 Kisan Sahayk Backend Server Started
═══════════════════════════════════════════════
📍 Local:    http://localhost:5000
📍 Network:  http://0.0.0.0:5000
🌍 Environment: development

🔗 For ngrok: Run "ngrok http 5000" in another terminal
   Then update Flutter ApiConfig.ngrokUrl with the HTTPS URL
```

### 1.2 Verify Backend is Running

Open browser and test:
```
http://localhost:5000/health
```

Should return:
```json
{
  "status": "OK",
  "message": "Kisan Sahayk API is running",
  "timestamp": "2026-02-15T..."
}
```

---

## 🌐 STEP 2: Start Ngrok

### 2.1 Run Ngrok in New Terminal

```bash
ngrok http 5000
```

### 2.2 Copy the HTTPS URL

You'll see output like:
```
Session Status                online
Account                       your_account
Version                       3.x.x
Region                        United States (us)
Latency                       -
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://abc123xyz.ngrok.io -> http://localhost:5000
```

**Copy this URL:** `https://abc123xyz.ngrok.io`

### 2.3 Test Ngrok URL

In browser:
```
https://abc123xyz.ngrok.io/health
```

Should return same JSON as localhost.

---

## 📱 STEP 3: Configure Flutter App

### 3.1 Update ApiConfig

Open: `lib/config/api_config.dart`

Find these lines:
```dart
/// Set this to your ngrok HTTPS URL when using real device
/// Example: 'https://abc123.ngrok.io'
static const String ngrokUrl = 'REPLACE_WITH_NGROK_URL';

/// Set to true when testing on real Android device
static const bool useNgrok = false;
```

Change to:
```dart
static const String ngrokUrl = 'https://abc123xyz.ngrok.io'; // ← YOUR NGROK URL
static const bool useNgrok = true; // ← SET TO TRUE
```

### 3.2 Validate Configuration

The app will automatically validate:
- Ngrok URL is not default value
- URL starts with https:// or http://
- Will print logs in console

---

## 🔨 STEP 4: Build APK

### 4.1 Clean Previous Build (Optional)

```bash
flutter clean
flutter pub get
```

### 4.2 Build Release APK

```bash
flutter build apk --release
```

**APK Location:**
```
build/app/outputs/flutter-apk/app-release.apk
```

### 4.3 Install APK on Device

**Option A: USB Cable**
```bash
flutter install
```

**Option B: Manual Transfer**
1. Copy APK to device
2. Enable "Install from Unknown Sources"
3. Open APK and install

---

## ✅ STEP 5: Testing Checklist

### Before Testing, Verify:

- [ ] **Backend Running** - Terminal shows server started on port 5000
- [ ] **MongoDB Running** - No connection errors in backend logs
- [ ] **Ngrok Running** - Terminal shows forwarding URL
- [ ] **Ngrok URL Updated** - Correct URL in `api_config.dart`
- [ ] **useNgrok = true** - Flag set in `api_config.dart`
- [ ] **APK Rebuilt** - After updating ngrok URL
- [ ] **Device Connected to Internet** - WiFi or mobile data active
- [ ] **Permissions Granted** - Internet, Microphone permissions

### Test These Features:

#### 1. AI Chat
- Open AI Assistant
- Send message: "What is photosynthesis?"
- Should get response from backend

#### 2. Weather Forecast
- Open Weather screen
- Enter location: "Raipur"
- Should show weather data

#### 3. Voice Commands
- Tap floating mic button
- Say: "Transport chahiye"
- Should navigate to transport screen

#### 4. Transport Booking
- Open Transport
- Fill details
- Submit booking
- Check backend logs for API call

---

## 🐛 TROUBLESHOOTING

### Problem: "Cannot connect to server"

**Check:**
1. Backend running? → `node server.js`
2. Ngrok running? → `ngrok http 5000`
3. Ngrok URL correct? → Check `api_config.dart`
4. useNgrok = true? → Check `api_config.dart`
5. APK rebuilt? → `flutter build apk`
6. Device has internet? → Test browser

**Debug Logs:**
App will print detailed logs:
```
🌐 HTTP POST: https://abc123.ngrok.io/api/ai/chat
   Body: {"message":"test","language":"en"}
✅ Response 200 from POST
   Body: {"success":true,...}
```

### Problem: "Ngrok tunnel expired"

**Solution:**
1. Ngrok free tunnels expire after 2 hours
2. Restart ngrok: `ngrok http 5000`
3. Copy new URL
4. Update `api_config.dart`
5. Rebuild APK
6. Reinstall on device

### Problem: "CORS error"

**Solution:**
Backend already configured for CORS. If still issues:
1. Check backend logs for CORS error
2. Verify ngrok URL doesn't have trailing slash
3. Restart backend server

### Problem: "Timeout error"

**Check:**
1. Internet speed - Ngrok adds latency
2. Timeout settings - Default is 30s
3. Backend responding - Test `/health` endpoint
4. Ngrok healthy - Check ngrok dashboard at http://127.0.0.1:4040

---

## 📊 Monitoring Tools

### 1. Backend Logs
Watch backend terminal for:
```
🌐 HTTP POST /api/ai/chat
   Headers: application/json
   Origin: https://abc123.ngrok.io
✅ Response 200
```

### 2. Ngrok Dashboard
Open in browser:
```
http://127.0.0.1:4040
```

Shows:
- All HTTP requests
- Request/response bodies
- Timings
- Errors

### 3. Flutter Logs
In Android Studio or VS Code, check Debug Console:
```
📡 API Configuration
═══════════════════════════════════════
Using Ngrok: true
Base URL: https://abc123.ngrok.io/api
═══════════════════════════════════════

🌐 POST: https://abc123.ngrok.io/api/ai/chat
   Body: {"message":"test"}
✅ Response 200 from POST
```

---

## 🔄 Development Workflow

### Daily Development Cycle:

```bash
# 1. Start MongoDB (if not auto-started)
mongod

# 2. Start Backend (Terminal 1)
cd backend
node server.js

# 3. Start Ngrok (Terminal 2)
ngrok http 5000

# 4. Copy Ngrok URL and update api_config.dart

# 5. Build & Install APK (if URL changed)
flutter build apk
flutter install

# 6. Test on device
```

### Hot Reload Support:

For faster development:
- Keep ngrok URL same
- Only rebuild APK when:
  - Ngrok URL changes
  - New features added
  - Major code changes

---

## 🎯 Production Deployment (Future)

When ready for production:

### Option 1: Deploy Backend to Cloud
- AWS, Google Cloud, Azure, DigitalOcean
- Get permanent URL (e.g., https://api.kisansahayak.com)
- Update ApiConfig with production URL
- Keep ngrok for development only

### Option 2: VPS with Domain
- Rent VPS (₹500-1000/month)
- Install Node.js, MongoDB
- Point domain to VPS IP
- Use PM2 to keep backend running

---

## 📝 Quick Reference Card

**Backend:**
```bash
cd backend && node server.js
# Runs on: http://localhost:5000
```

**Ngrok:**
```bash
ngrok http 5000
# Copy HTTPS URL
```

**Flutter:**
```dart
// api_config.dart
static const String ngrokUrl = 'https://YOUR_URL.ngrok.io';
static const bool useNgrok = true;
```

**Build APK:**
```bash
flutter build apk
# APK: build/app/outputs/flutter-apk/app-release.apk
```

**Test:**
```bash
# Browser test
https://YOUR_URL.ngrok.io/health

# Should return: {"status":"OK",...}
```

---

## 🆘 Need Help?

1. **Check Logs** - Backend, Ngrok, Flutter console
2. **Verify Checklist** - All 8 items before testing
3. **Test Health Endpoint** - Confirms connectivity
4. **Use Ngrok Dashboard** - See all requests
5. **Debug Mode** - Enable verbose logging

---

**✅ Setup Complete! Your app can now:**
- Connect from real Android device
- Use all API features (AI, Weather, Voice, etc.)
- Work with ngrok tunneling
- Provide detailed error messages

**Happy Testing! 🎉**
