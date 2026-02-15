// Learning Mode Helper - Provides detailed explanations for app features

class LearningModeHelper {
  // Screen-specific introductions
  static Map<String, String> screenIntroductions = {
    'dashboard': '''
Dashboard ekdum home page hai jaha se aap poore app ko control kar sakte hain.
Yaha par aapko 6 main sections dikhenge:
1. Transport - Gaadi book karne ke liye
2. Buy Products - Beej, khaad kharidne ke liye  
3. Sell Products - Apni fasal bechne ke liye
4. Labour - Majdoor dhoondhne ke liye
5. Weather - Mausam ka haal jaanne ke liye
6. AI Assistant - Kisi bhi sawaal ka jawab paane ke liye
''',
    
    'transport': '''
Transport section me aap apni fasal ya saman ko ek jagah se doosri jagah le jaane ke liye gaadi book kar sakte hain.

Isme teen step hain:
1. Pehle gaadi type select karein - Mini truck, Tractor, Tempo, Pickup
2. Fir pickup location batayein - Aap kaha se saman uthana chahte hain
3. Phir drop location batayein - Aap kaha saman pahunchana chahte hain

Jaise hi yeh sab fill hoga, aapko gaadi ka rate dikh jayega aur booking confirm kar sakte hain.
''',
    
    'buy_product': '''
Buy Products section me aap kheti ke liye zaroori cheezein kharid sakte hain:
- Beej (Seeds)
- Khaad (Fertilizers)
- Keetnaashak (Pesticides)
- Kheti ke auzeaar (Farming tools)

Search bar me product ka naam type karein ya category select karein.
Pasand aane par product pe click karein, details dekhein aur Add to Cart dabayein.
Cart me jaake sab items check karein aur order place kar dein.
''',
    
    'sell_product': '''
Sell Products section me aap apni fasal ya products online list kar sakte hain.

Product list karne ke liye:
1. Category select karein - Kya bech rahe hain (beej, sabzi, fasal)
2. Product ka naam aur description likhein
3. Price set karein - Kitne rupay ka bechna hai
4. Photos upload karein - Apne product ki acchi photos
5. Publish dabayein

Jab koi khareedega to aapko notification milega.
''',
    
    'labour': '''
Labour section me aap apne khet ke kaam ke liye majdoor dhundh sakte hain.

Majdoor hire karne ke steps:
1. Skill select karein - Kis kaam ke liye chahiye (harvesting, planting, etc)
2. Location batayein - Kaha kaam karna hai
3. Date aur time select karein - Kab se kab tak chahiye
4. Labour count batayein - Kitne majdoor chahiye

System aapko available labours dikhayega jo hiring ke liye ready hain.
''',
    
    'weather': '''
Weather section me aap apne area ka poora mausam forecast dekh sakte hain.

Yaha milega:
- Aaj ka temperature aur condition
- 7 din ka forecast
- Barish ka chance
- Wind speed
- Humidity level

Mausam ke hisaab se aap apni kheti ka kaam plan kar sakte hain.
Barish ke pehle fasal cover karna, fertilizer daalna etc.
''',
    
    'ai_assistant': '''
AI Assistant section me aap kheti se related koi bhi sawaal pooch sakte hain.

AI aapki madad karega:
- Fasal ki bimari ke baare me
- Sahi khad ka chunaav
- Beej selection
- Market prices
- Kheti techniques
- Government schemes

Bas apna sawaal Hindi ya English me type karein ya mic me bolein.
AI turant jawab dega with proper guidance.
''',
    
    'profile': '''
Profile section me aap apni personal details aur account settings manage kar sakte hain.

Yaha aap:
- Profile photo change kar sakte hain
- Phone number, email update kar sakte hain
- Address change kar sakte hain
- Language select kar sakte hain (Hindi/English/Chhattisgarhi)
- Theme mode change kar sakte hain (Light/Dark)
- Logout bhi kar sakte hain
'''
  };

  // Action-specific explanations
  static Map<String, String> actionExplanations = {
    'navigate': 'Main aapko {{screen}} section me le ja raha hoon. Waha jaake aap {{action}} kar paoge.',
    'fill_form': 'Main aapke liye form fill kar raha hoon. Aap values check kar lena submission se pehle.',
    'confirm': 'Yeh important action hai. Main aapse confirmation le raha hoon taaki galti na ho.',
    'select': 'Main yeh option select kar raha hoon: {{option}}. Agar change karna hai to batayein.',
    'back': 'Main aapko pichle screen pe le ja raha hoon.',
  };

  // Common workflow guides
  static Map<String, List<String>> workflowSteps = {
    'book_transport': [
      'Step 1: Sabse pehle vehicle type choose karein',
      'Step 2: Pickup location daalen - Kaha se uthana hai',
      'Step 3: Drop location daalen - Kaha pahunchana hai',
      'Step 4: Date aur time select karein',
      'Step 5: Price check karein aur booking confirm karein',
      'Ho gaya! Aapki booking confirm ho gayi.',
    ],
    
    'buy_product': [
      'Step 1: Category select karein ya search me product naam type karein',
      'Step 2: Product list me se koi pasand ka product select karein',
      'Step 3: Details padh kar Add to Cart dabayein',
      'Step 4: Cart me jaake sab items verify karein',
      'Step 5: Checkout pe jaayein aur delivery address confirm karein',
      'Step 6: Payment method select karein aur order place karein',
      'Badhiya! Aapka order place ho gaya.',
    ],
    
    'sell_product': [
      'Step 1: Sell Products section me jaayein',
      'Step 2: Category select karein - Kya bechna hai',
      'Step 3: Product details bharein - Naam, description, price',
      'Step 4: Product ki photos select karein (minimum 1)',
      'Step 5: Terms accept karke Publish dabayein',
      'Perfect! Aapka product list ho gaya.',
    ],
    
    'hire_labour': [
      'Step 1: Labour section me jaayein',
      'Step 2: Skill select karein - Kis kaam ke liye chahiye',
      'Step 3: Work location aur date/time set karein',
      'Step 4: Kitne labour chahiye wo batayein',
      'Step 5: Available labours ki list me se select karein',
      'Step 6: Hiring confirm karein',
      'Done! Labour hire ho gaya.',
    ],
  };

  // Feature tips
  static Map<String, List<String>> featureTips = {
    'voice_commands': [
      'Voice commands use karne ke liye, floating mic button dabayein',
      'Mic me naturally bolein, jaise kisi se baat kar rahe ho',
      'Hindi, English, ya Hinglish - koi bhi language use kar sakte hain',
      'Learning mode on karne se har step explain hoti hai',
      'Agar voice nahi sunega to text box me type kar sakte hain',
    ],
    
    'learning_mode': [
      'Learning mode first-time users ke liye hai',
      'Is mode me har action ki detailed explanation milti hai',
      'Voice overlay ke header me school icon pe click karke on/off karein',
      'On karne par AI har step explain karega',
      'Jab expert ho jao to turn off kar do for faster experience',
    ],
    
    'navigation': [
      'Dashboard se aap kisi bhi section me jaa sakte hain',
      'Voice se navigate karne ke liye "{{screen}} kholo" bolein',
      'Back jaane ke liye "peeche jao" ya back button dabayein',
      'Bottom navigation bar se quick switch kar sakte hain',
    ],
  };

  // Get screen introduction
  static String getScreenIntroduction(String screenName, String language) {
    if (language == 'en') {
      return _getEnglishIntroduction(screenName);
    }
    return screenIntroductions[screenName] ?? 
           'Is screen pe aap ${screenName} ke kaam kar sakte hain.';
  }

  // Get action explanation with placeholders replaced
  static String getActionExplanation(String actionType, String screenName, String specificAction) {
    String explanation = actionExplanations[actionType] ?? 'Main yeh action kar raha hoon.';
    explanation = explanation.replaceAll('{{screen}}', screenName);
    explanation = explanation.replaceAll('{{action}}', specificAction);
    return explanation;
  }

  // Get workflow steps
  static List<String> getWorkflowSteps(String workflowName) {
    return workflowSteps[workflowName] ?? [];
  }

  // Get feature tips
  static List<String> getFeatureTips(String featureName) {
    return featureTips[featureName] ?? [];
  }

  // Get current step explanation in a workflow
  static String getCurrentStepExplanation(String workflowName, int stepIndex) {
    final steps = getWorkflowSteps(workflowName);
    if (stepIndex >= 0 && stepIndex < steps.length) {
      return steps[stepIndex];
    }
    return '';
  }

  // English introductions (for English language users)
  static String _getEnglishIntroduction(String screenName) {
    final englishIntros = {
      'dashboard': '''
This is your main dashboard where you can access all app features.
You'll see 6 main sections here:
1. Transport - Book vehicles for transportation
2. Buy Products - Purchase seeds, fertilizers, etc.
3. Sell Products - List your crops for sale
4. Labour - Find workers for your farm
5. Weather - Check weather forecasts
6. AI Assistant - Get answers to any farming questions
''',
      'transport': '''
In the Transport section, you can book vehicles to transport your crops or goods.

Three simple steps:
1. Select vehicle type - Mini truck, Tractor, Tempo, or Pickup
2. Enter pickup location - Where to load the goods
3. Enter drop location - Where to deliver

Once filled, you'll see the rate and can confirm booking.
''',
      // Add more English versions as needed
    };
    
    return englishIntros[screenName] ?? 
           'On this screen, you can perform ${screenName} related tasks.';
  }
}
