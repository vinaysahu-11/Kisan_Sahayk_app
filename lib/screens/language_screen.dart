import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_localizations.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final loc = AppLocalizations.of(context)!;
    final currentLanguage = languageProvider.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.language, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E6B3F), Color(0xFF3F8D54)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAF8), Color(0xFFE8F5E9)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                loc.chooseLanguage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E6B3F),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                loc.selectLanguageHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _LanguageCard(
                    nativeName: 'English',
                    icon: '🇬🇧',
                    languageCode: 'en',
                    isSelected: currentLanguage == 'en',
                    onTap: () {
                      languageProvider.changeLanguage('en');
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _LanguageCard(
                    nativeName: 'हिन्दी',
                    icon: '🇮🇳',
                    languageCode: 'hi',
                    isSelected: currentLanguage == 'hi',
                    onTap: () {
                      languageProvider.changeLanguage('hi');
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _LanguageCard(
                    nativeName: 'छत्तीसगढ़ी',
                    icon: '🏞️',
                    languageCode: 'cg',
                    isSelected: currentLanguage == 'cg',
                    onTap: () {
                      languageProvider.changeLanguage('cg');
                    },
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E6B3F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    loc.done,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String nativeName;
  final String icon;
  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.nativeName,
    required this.icon,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E6B3F) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                nativeName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF2E6B3F) : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2E6B3F),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
