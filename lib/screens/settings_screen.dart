import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_localizations.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool weatherAlerts = true;
  bool priceUpdates = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings, style: const TextStyle(color: Colors.white)),
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SettingsSection(
              title: l10n.notificationSettings,
              children: [
                SwitchListTile(
                  title: Text(l10n.enableNotifications),
                  subtitle: Text(l10n.receiveAllNotifications),
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() => notificationsEnabled = value);
                  },
                  activeThumbColor: const Color(0xFF2E6B3F),
                ),
                SwitchListTile(
                  title: Text(l10n.weatherAlerts),
                  subtitle: Text(l10n.getWeatherUpdates),
                  value: weatherAlerts,
                  onChanged: (value) {
                    setState(() => weatherAlerts = value);
                  },
                  activeThumbColor: const Color(0xFF2E6B3F),
                ),
                SwitchListTile(
                  title: Text(l10n.priceUpdates),
                  subtitle: Text(l10n.marketPriceNotifications),
                  value: priceUpdates,
                  onChanged: (value) {
                    setState(() => priceUpdates = value);
                  },
                  activeThumbColor: const Color(0xFF2E6B3F),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _SettingsSection(
              title: l10n.appearance,
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return SwitchListTile(
                      title: Text(l10n.darkMode),
                      subtitle: Text(l10n.switchToDarkTheme),
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        themeProvider.setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                      activeThumbColor: const Color(0xFF2E6B3F),
                    );
                  },
                ),
                ListTile(
                  title: Text(l10n.language),
                  subtitle: Text(l10n.changeAppLanguage),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/language');
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _SettingsSection(
              title: l10n.account,
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: Color(0xFF2E6B3F)),
                  title: Text(l10n.editProfile),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock, color: Color(0xFF2E6B3F)),
                  title: Text(l10n.changePassword),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.featureComingSoon)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: Color(0xFF2E6B3F)),
                  title: Text(l10n.privacyPolicy),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.openingPrivacyPolicy)),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _SettingsSection(
              title: l10n.more,
              children: [
                ListTile(
                  leading: const Icon(Icons.help, color: Color(0xFF2E6B3F)),
                  title: Text(l10n.help),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/help');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info, color: Color(0xFF2E6B3F)),
                  title: Text(l10n.about),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/about');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(l10n.rateApp),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.thankYouSupport)),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Version Info
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Center(
              child: Text(
                '© 2026 Kisan Sahayk',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E6B3F),
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}
