// Quick Start Guide - Voice system testing

## Test Voice System

### 1. Start Backend
```bash
cd backend
node server.js
```

### 2. Test Commands (via app)
- Tap floating mic button
- Say: "Transport book karna hai Raipur se Durg"
- System should navigate and fill form

### 3. Common Commands to Test

**Navigation:**
- "Dashboard pe jao"
- "Transport section kholo"
- "Beej kharidna hai"
- "Apni fasal bechni hai"

**Transport Booking:**
- "Mini truck chahiye Raipur se Durg"
- "Tractor book karo kal ke liye"

**Buy Products:**
- "Beej kharidna hai 10 kg"
- "Khaad dikhao"

**Sell Products:**
- "Dhan bechna hai 50 quintal"
- "Sabzi list karna hai"

**Labour Hiring:**
- "5 majdoor chahiye katai ke liye"
- "Planting ke liye labour dhundho"

### 4. Backend API Configuration
Add to `backend/.env`:
```
OPENAI_API_KEY=your_openai_key
MONGODB_URI=your_mongodb_uri
```

### Features Working:
✅ Voice command processing
✅ Auto navigation
✅ Form field extraction
✅ Learning mode explanations
✅ Context memory (MongoDB)
✅ Multi-language support
✅ Interactive tutorial

### Next: Deploy & Test on Real Devices
