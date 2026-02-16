# 🔧 AI TIMEOUT ISSUE - DEBUGGING GUIDE

## ⚠️ Problem: TimeoutException after 30 seconds

Your Flutter APK shows: **"TimeoutException after 30 seconds, Future not completed"**

This guide helps you identify and fix the root cause.

---

## 🎯 Quick Diagnosis

The issue is in **ONE** of these 3 places:

| Case | Meaning | How to Check |
|------|---------|--------------|
| **Backend log me request nahi aa raha** | Ngrok / Network problem | Check backend terminal |
| **Backend log me aa raha par reply nahi** | AI controller hanging | Check backend logs |
| **Backend reply slow** | OpenAI/Gemini call taking too long | Check response time |

---

## 🔍 STEP 1: Test Backend Reachability

### 1.1 Test Health Endpoint

**On your phone browser or Postman:**
```
GET https://YOUR_NGROK_URL.ngrok.io/api/health
```

**Expected Response:**
```json
{
  "status": "OK",
  "message": "Kisan Sahayak API is running",
  "timestamp": "2026-02-15T...",
  "uptime": 123.45,
  "port": 5000
}
```

**If this fails:**
- ❌ Ngrok not running  → Run: `ngrok http 5000`
- ❌ Wrong ngrok URL in Flutter → Update `api_config.dart`
- ❌ Backend not running → Run: `cd backend && node server.js`

---

### 1.2 Test AI Health Endpoint

```
GET https://YOUR_NGROK_URL.ngrok.io/api/ai/health
```

**Expected Response:**
```json
{
  "success": true,
  "status": "Configured",
  "aiEngine": "Gemini",
  "geminiKey": "Present",
  "message": "AI service is ready"
}
```

**If status is "Not Configured":**
- ❌ Missing API key in backend `.env`
- Add: `GEMINI_API_KEY=your_key_here`

---

## 🔍 STEP 2: Test AI Chat (Simple)

**Use Postman or curl to test AI directly:**

```bash
POST https://YOUR_NGROK_URL.ngrok.io/api/ai/chat
Content-Type: application/json

{
  "message": "Hello",
  "language": "en"
}
```

**Watch Backend Terminal:**

You should see:
```
==================================================
📨 [1234567890] AI Chat Request Received
==================================================
[1234567890] User: anonymous
[1234567890] Message: Hello...
[1234567890] Language: en
📬 Chat Request: { userId: null, message: 'Hello' }
📝 Context: 0 previous messages
🤖 Calling Gemini API...
✅ Gemini response received in 2345ms
✅ Chat response completed in 2500ms
[1234567890] ✅ Response ready, sending to client
==================================================
```

---

## 🔍 STEP 3: Identify the Problem

### Case 1: Request Not Reaching Backend

**Symptoms:**
- Backend terminal shows **NO** logs
- No "AI Chat Request Received" message

**Cause:**
- Wrong ngrok URL in Flutter
- Network issue
- CORS blocking request

**Fix:**
1. Check `lib/config/api_config.dart`:
   ```dart
   static const String ngrokUrl = 'https://YOUR_URL.ngrok.io';
   static const bool useNgrok = true;
   ```
2. Rebuild APK: `flutter build apk`
3. Reinstall on device

---

### Case 2: Request Received, No Response

**Symptoms:**
- Backend shows: "AI Chat Request Received"
- Backend shows: "Calling Gemini/OpenAI API..."
- But **NEVER** shows: "Response ready, sending to client"

**Cause:**
- AI API taking too long (>20s)
- AI API key invalid
- Network timeout

**Fix:**
1. Check API key in backend `.env`:
   ```
   GEMINI_API_KEY=AIza...
   ```
2. Test API key manually:
   ```bash
   curl "https://generativelanguage.googleapis.com/v1beta/models?key=YOUR_KEY"
   ```

---

### Case 3: Backend Responds, Flutter Times Out

**Symptoms:**
- Backend shows: "Response ready, sending to client"
- Flutter still shows timeout

**Cause:**
- Response too large
- Network dropped after backend sent response
- Ngrok tunnel unstable

**Fix:**
1. Restart ngrok: `ngrok http 5000`
2. Update ngrok URL in Flutter
3. Rebuild APK

---

## ✅ APPLIED FIXES (Already Done)

### Backend Fixes:

1. **Timeout Protection in AI Service:**
   - Gemini/OpenAI calls timeout after 18 seconds
   - Controller times out after 20 seconds
   - Never leaves request hanging

2. **Reduced Token Limits:**
   - Gemini: 2048 → 800 tokens (faster response)
   - OpenAI: 1500 → 800 tokens

3. **Fallback Response:**
   - If AI fails, returns: "AI service temporarily unavailable"
   - Never crashes or hangs

4. **Context Limit:**
   - Only last 6 messages sent to AI (reduced prompt size)

5. **Detailed Logging:**
   - Every request/response logged with timing
   - Easy to debug in terminal

### Flutter Fixes:

1. **Increased Timeout:**
   - 30s → 60s (gives AI more time)

2. **Better Error Messages:**
   - Shows detailed error instead of generic timeout

---

## 🧪 TESTING WORKFLOW

### Test 1: Health Check from APK

**In your app:**
1. Make a simple API call
2. Check if `/api/health` returns 200 OK

**If this works:** Network is fine, issue is AI-specific

---

### Test 2: Simple AI Message

**In your app:**
1. Open AI Chat
2. Send: "Hi"
3. Wait 10 seconds

**Expected:** Response in 3-10 seconds

**If timeout:** Check backend logs (Step 3 above)

---

### Test 3: Complex AI Message

**In your app:**
1. Send long message (100+ words)
2. Wait 20 seconds

**Expected:** Response in 5-20 seconds

**If timeout:** Message too complex, AI needs more time

---

## 🚨 Common Issues & Solutions

### Issue: "Cannot connect to server"

**Meaning:** Ngrok URL wrong or backend down

**Fix:**
1. Check backend running: `netstat -ano | findstr :5000`
2. Check ngrok running: Open http://127.0.0.1:4040
3. Update Flutter with correct URL

---

### Issue: "AI service temporarily unavailable"

**Meaning:** AI API call failed

**Fix:**
1. Check API key: `echo $env:GEMINI_API_KEY` (Windows)
2. Test key manually (see Case 2 above)
3. Switch to OpenAI if Gemini fails

---

### Issue: Works on WiFi, fails on mobile data

**Meaning:** Ngrok free tier blocks some mobile networks

**Solution:**
- Upgrade to ngrok paid plan ($10/month)
- Or deploy backend to cloud (AWS/Heroku)

---

## 📊 Performance Benchmarks

**Normal Response Times:**

| Scenario | Expected Time | Max Time |
|----------|---------------|----------|
| Simple chat (1 sentence) | 2-5 seconds | 10 seconds |
| Complex chat (paragraph) | 5-10 seconds | 20 seconds |
| With history (6 messages) | 3-8 seconds | 15 seconds |
| Soil analysis | 3-7 seconds | 15 seconds |
| Disease scan | 5-12 seconds | 25 seconds |

**If exceeding max time:** Check network or AI API status

---

## 🔥 Emergency Quick Fix

If nothing works, try this:

### Backend Terminal:
```bash
cd backend
node server.js
```

### Terminal 2 (Ngrok):
```bash
ngrok http 5000
```

### Terminal 3 (Test):
```bash
# Copy ngrok URL from Terminal 2
curl -X POST https://YOUR_URL.ngrok.io/api/ai/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"test","language":"en"}'
```

**If this works:** Flutter config issue
**If this fails:** Backend issue

---

## 📱 APK Testing Checklist

Before testing on real device:

- [ ] Backend running (`node server.js`)
- [ ] Ngrok running (`ngrok http 5000`)
- [ ] Ngrok URL copied
- [ ] `api_config.dart` updated with ngrok URL
- [ ] `useNgrok = true` in api_config.dart
- [ ] APK rebuilt (`flutter build apk`)
- [ ] APK installed on device
- [ ] Device has internet connection
- [ ] Device can access ngrok URL in browser

---

## 🎯 Next Steps

1. **Test health endpoint** (Step 1.1)
2. **Test AI health** (Step 1.2)
3. **Check backend logs** (Step 2)
4. **Identify case** (Step 3)
5. **Apply fix**

---

## 📞 Still Having Issues?

**Check these logs:**

1. **Backend Terminal:**
   - Look for "AI Chat Request Received"
   - Look for "Gemini/OpenAI response received"
   - Look for any errors

2. **Flutter Debug Console:**
   - Look for HTTP errors
   - Look for timeout messages
   - Look for connection errors

3. **Ngrok Dashboard:**
   - Open: http://127.0.0.1:4040
   - Check request/response logs
   - Verify status codes

**Most likely issue:** Ngrok URL not updated in Flutter after restart

**Fix:** Update URL, rebuild APK, reinstall

---

**🎉 After fixes, AI should respond in 3-10 seconds on real device!**
