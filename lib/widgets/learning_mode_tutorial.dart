// Learning Mode Tutorial - Interactive guide for first-time users

import 'package:flutter/material.dart';

class LearningModeTutorial extends StatefulWidget {
  const LearningModeTutorial({super.key});

  @override
  State<LearningModeTutorial> createState() => _LearningModeTutorialState();
}

class _LearningModeTutorialState extends State<LearningModeTutorial> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<TutorialPage> _pages = [
    TutorialPage(
      icon: Icons.school,
      title: 'Learning Mode mein aapka swagat hai!',
      description: '''
Learning Mode naye users ke liye hai jo pehli baar app use kar rahe hain.

Is mode mein:
• Har action ki detailed explanation milegi
• Step-by-step guidance milega
• Voice commands ka sahi tarika sikhega
• App ke har feature ko samajhna aasan hoga

Jab aap expert ho jao, to off kar sakte ho.
''',
      color: Colors.blue,
    ),
    
    TutorialPage(
      icon: Icons.mic,
      title: 'Voice Commands Kaise Use Karein',
      description: '''
Voice commands use karna bahut simple hai:

1. Floating green mic button dabayein (bottom-right)
2. Mic me naturally bolein Hindi ya English me
3. App automatically aapki baat samajh jayega
4. AI aapko guide karega har step me

Example commands:
• "Transport book karna hai"
• "Beej kharidna hai"  
• "Dashboard pe jao"
• "Mere orders dikhao"
''',
      color: Colors.green,
    ),
    
    TutorialPage(
      icon: Icons.navigation,
      title: 'App mein Kaise Navigate Karein',
      description: '''
App me ghoomna bahut easy hai:

Voice se:
"{{screen_name}} kholo" ya "{{screen_name}} pe jao"

Manual se:
Dashboard se koi bhi card tap karein

Navigation Tips:
• Back jaane ke liye: "peeche jao"
• Home jaane ke liye: "dashboard pe jao"
• Bottom bar se bhi switch kar sakte hain
''',
      color: Colors.orange,
    ),
    
    TutorialPage(
      icon: Icons.work,
      title: 'Workflows Kaise Complete Karein',
      description: '''
Transport booking example:

Aap bolein: "Mujhe transport book karna hai"

AI automatically:
1. Transport screen pe le jayega
2. Aapse vehicle type poochega
3. Pickup location poochega
4. Drop location poochega
5. Price dikhayega
6. Booking confirm kar dega

Bas naturally bolte rahein, AI sab sambhal lega!
''',
      color: Colors.purple,
    ),
    
    TutorialPage(
      icon: Icons.tips_and_updates,
      title: 'Pro Tips',
      description: '''
App ko aur better use karne ke liye:

1. **Learning mode toggle karein**
   Voice overlay ke header mein school icon hai

2. **Voice Shortcuts dekhen**
   Settings → Voice Shortcuts me sab commands hain

3. **Naturally bolein**
   Formal commands ki zaroorat nahi

4. **Text bhi use kar sakte hain**
   Agar voice nahi sunega, text box use karein

5. **Practice karein**
   Jitna use karoge utna achha samajh aayega
''',
      color: Colors.teal,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Learning Mode Guide'),
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : const Color(0xFF2E6B3F),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Page indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.green
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          // Pages
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildPage(_pages[index], isDark);
              },
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous button
                if (_currentPage > 0)
                  OutlinedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Peeche'),
                  )
                else
                  const SizedBox(width: 80),

                // Next/Done button
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Aage' : 'Samajh Gaya',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(TutorialPage page, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: page.color,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              page.description,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TutorialPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  TutorialPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
