# Voice-Guided App Control System

## Overview

The Kisan Sahayak app now includes a revolutionary **Voice-Guided Navigation & Control System** that allows users to control the entire app through natural speech commands in Hindi, English, Chhattisgarhi, and Hinglish.

This is not just voice chat - it's an AI-powered app instructor and workflow automation system.

## Architecture

### Core Components

1. **Global Voice Controller** (`voice_global_controller.dart`)
   - Listens continuously across all screens
   - Processes voice commands via OpenAI GPT-4
   - Executes navigation and form-filling actions
   - Maintains conversation context

2. **Screen Registry** (`screen_registry.dart`)
   - Maps each screen to available actions
   - Provides screen-specific voice commands
   - Enables context-aware assistance

3. **Voice Assistant Overlay** (`voice_assistant_overlay.dart`)
   - Floating translucent interface
   - Shows conversation history
   - Animated waveform during recording
   - Text input fallback for web

4. **Floating Voice Button** (`floating_voice_button.dart`)
   - Global mic button accessible from any screen
   - Always visible, activates overlay

5. **Screen Tracker** (`screen_tracker.dart`)
   - Reports current screen to voice controller
   - Enables screen-aware commands

## Features

### 1. Natural Language Understanding
Users can speak naturally. The system understands:
- "Transport book karna hai"
- "Beej kharidna hai"
- "Mere orders dikhao"
- "Dashboard pe jao"

### 2. Screen-to-Screen Navigation
The assistant automatically navigates between screens based on user intent.

**Example Flow:**
```
User: "Transport book karna hai"
System: "Thik hai. Main aapko transport section me le ja raha hoon."
→ Navigates to Transport Screen

System: "Yaha aap vehicle select kar sakte hain. Aap kaunsa vehicle chahte hain?"
User: "Mini truck"
System: "Mini truck select kar diya gaya hai. Pickup location bataiye."
```

### 3. Learning Mode
Toggle learning mode to get step-by-step explanations:
- Explains what each step does
- Teaches app usage to new users
- Perfect for rural farmers

### 4. Voice Shortcuts
Quick commands to navigate anywhere:
- `dashboard pe jao` - Open dashboard
- `transport chahiye` - Book transport
- `beej kharidna hai` - Buy products
- `mere orders` - View orders
- `wallet kholo` - Open wallet
- `back jao` - Go back

### 5. Context Memory
System remembers:
- Previous commands
- User preferences
- Last actions
- Form data

### 6. Multi-Language Support
Responds in the user's selected language:
- Hindi: "Thik hai, main aapki madad karta hoon"
- English: "Okay, I can help with that"
- Hinglish: "Sure, let me help you"
- Chhattisgarhi: Regional dialect support

## Usage

### For Users

1. **Activate Voice Assistant**
   - Tap the floating green mic button (bottom-right)
   - Or navigate to any screen and tap mic

2. **Speak Your Command**
   - Press and hold mic button
   - Speak naturally in Hindi/English/Hinglish
   - Release when done

3. **Text Input (Alternative)**
   - Type command in text box
   - Press send or Enter

4. **Learning Mode**
   - Tap school icon in overlay header
   - Get explanations for each step

5. **View Available Commands**
   - Navigate to Settings → Voice Shortcuts
   - See all available commands

### For Developers

#### Adding Voice Control to New Screen

1. **Wrap screen with ScreenTracker:**
```dart
import '../widgets/screen_tracker.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenTracker(
      screenName: 'my_screen',
      child: Scaffold(
        // Your screen content
      ),
    );
  }
}
```

2. **Register screen in Screen Registry:**
```dart
// In screen_registry.dart
'my_screen': ScreenConfig(
  name: 'My Screen',
  route: '/my-screen',
  actions: [
    'do_action_1',
    'do_action_2',
  ],
  voiceCommands: [
    'action 1 karo',
    'action 2 dikhao',
  ],
),
```

3. **Update backend to handle new intents (optional):**
```javascript
// In voice_global_controller.js
const intentRouteMap = {
  navigate_my_screen: '/my-screen',
  // ... other mappings
};
```

## Backend Setup

### Prerequisites
- OpenAI API key
- Node.js backend running

### Environment Variables
```bash
OPENAI_API_KEY=your_openai_key_here
```

### API Endpoints

#### Process Global Voice Command
```
POST /api/voice/process-global
Body: {
  "text": "transport book karna hai",
  "language": "hi",
  "sessionId": "session-123",
  "currentScreen": "dashboard",
  "learningMode": false,
  "availableActions": ["navigate_transport", ...],
  "context": {}
}

Response: {
  "success": true,
  "message": "Thik hai. Main aapko transport section me le ja raha hoon.",
  "action": {
    "type": "navigate",
    "route": "/transport",
    "explanation": "..."
  },
  "context": {},
  "sessionId": "session-123"
}
```

#### Get Voice Shortcuts
```
GET /api/voice/shortcuts?language=hi

Response: {
  "success": true,
  "shortcuts": [
    {
      "command": "transport chahiye",
      "description": "Transport book karo"
    },
    ...
  ]
}
```

## Screen Actions Reference

### Dashboard
- `navigate_transport` - Open transport booking
- `navigate_weather` - Show weather forecast
- `navigate_buy` - Buy products
- `navigate_sell` - Sell products
- `navigate_labour` - Hire labour
- `navigate_ai_assistant` - Talk to AI

### Transport Screen
- `select_vehicle` - Choose vehicle type
- `set_pickup` - Set pickup location
- `set_drop` - Set drop location
- `confirm_booking` - Confirm transport booking

### Buy Products
- `search_product` - Search for items
- `add_to_cart` - Add item to cart
- `view_cart` - Show cart
- `checkout` - Place order

### Sell Products
- `select_category` - Choose product category
- `enter_title` - Set product name
- `enter_price` - Set price
- `publish` - List product for sale

## Customization

### Add Custom Voice Commands

1. Update Screen Registry:
```dart
actions: [
  'my_custom_action',
],
voiceCommands: [
  'mera custom command',
],
```

2. Handle in backend AI prompt or add specific parsing logic

3. Execute action in voice controller

### Change Voice Feedback Language

The system automatically uses the app's selected language. To customize:
```dart
final language = languageProvider.locale.languageCode;
// Uses 'hi', 'en', or 'cg'
```

## Performance Tips

1. **Optimize API Calls**
   - Cache frequent commands
   - Use streaming for real-time feedback

2. **Reduce Latency**
   - Pre-load common screens
   - Use optimistic UI updates

3. **Battery Optimization**
   - Stop listening when inactive
   - Use efficient speech recognition

## Troubleshooting

### Voice not working on web
- Web browsers don't support direct voice recording
- Use text input instead
- System automatically shows text field on web

### Commands not recognized
- Speak clearly in simple language
- Check current screen context
- Use voice shortcuts guide

### Navigation not working
- Ensure screen is registered in Screen Registry
- Check route is added in main.dart
- Verify backend AI intent mapping

## Security

- Voice sessions are tied to user authentication
- Rate limiting prevents abuse
- Commands are validated before execution
- Sensitive actions require confirmation

## Future Enhancements

- [ ] Offline voice recognition
- [ ] Voice-based form filling with validation
- [ ] Multi-step wizard guidance
- [ ] Voice macros (record custom commands)
- [ ] Screen element highlighting during guidance
- [ ] Voice-controlled filters and sorting
- [ ] Integration with phone calls for support

## Support

For issues or questions:
- Check Voice Shortcuts screen in app
- Enable Learning Mode for guidance
- Contact: support@kisansahayak.com

---

**Built with ❤️ for Indian Farmers**
