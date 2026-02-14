// Dashboard - Main service hub for farmers

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_localizations.dart';
import '../theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  final bool showAppBar;
  
  const DashboardScreen({super.key, this.showAppBar = true});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = 'Kisan';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      setState(() => userName = args);
    }
  }

  List<ServiceCard> _getServices(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return [
      ServiceCard(
        title: 'AI Krishi Mitra',
        description: 'Smart Farming Assistant',
        icon: Icons.psychology_alt,
        color: const Color(0xFF00BFA5),
        route: '/ai-assistant',
      ),
      
      ServiceCard(
        title: l10n.weather,
        description: l10n.weatherForecast,
        icon: Icons.wb_cloudy,
        color: const Color(0xFF4A90E2),
        route: '/weather',
      ),
      
      ServiceCard(
        title: l10n.buyProduct,
        description: 'Seeds, Tools & More',
        icon: Icons.shopping_cart,
        color: const Color(0xFF7B68EE),
        route: '/buy-product',
      ),
      
      ServiceCard(
        title: l10n.transport,
        description: l10n.bookTransport,
        icon: Icons.local_shipping,
        color: const Color(0xFFFF8C42),
        route: '/transport',
      ),
      
      ServiceCard(
        title: l10n.labour,
        description: l10n.hireLabour,
        icon: Icons.people,
        color: const Color(0xFF26A69A),
        route: '/labour',
      ),
      
      ServiceCard(
        title: l10n.sellProduct,
        description: l10n.listYourProduct,
        icon: Icons.inventory,
        color: const Color(0xFFE91E63),
        route: '/sell-product',
      ),
      
      ServiceCard(
        title: l10n.jobs,
        description: l10n.jobOpportunities,
        icon: Icons.work,
        color: const Color(0xFF9C27B0),
        route: '/jobs',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final services = _getServices(context);
    
    return Scaffold(
      key: _scaffoldKey,
      
      appBar: widget.showAppBar ? AppBar(
        title: Row(
          children: [
            const Icon(Icons.eco_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(l10n.appName, style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [

          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient(context),
          ),
        ),
      ) : null,
      drawer: Drawer(
        child: Column(
          children: [
            // Custom Green Header
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient(context),
              ),
              child: Stack(
                children: [
                  // Close button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Logo
                  Positioned(
                    top: 12,
                    left: 16,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Color(0xFF2E6B3F),
                        size: 24,
                      ),
                    ),
                  ),
                  // Profile section
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 36,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Menu Items
            ListTile(
              leading: Icon(Icons.person_outline, color: Colors.grey[700]),
              title: Text(
                l10n.profile,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.dark_mode_outlined, color: Colors.grey[700]),
              title: Text(
                l10n.darkMode,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              onTap: () async {
                Navigator.pop(context);
                // Toggle theme
                final mainApp = context.findAncestorStateOfType<State<StatefulWidget>>();
                if (mainApp != null) {
                  final prefs = await SharedPreferences.getInstance();
                  final isDark = prefs.getBool('is_dark_mode') ?? false;
                  await prefs.setBool('is_dark_mode', !isDark);
                  // Restart app to apply theme
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.language, color: Colors.grey[700]),
              title: Text(
                l10n.language,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/language');
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.grey[700]),
              title: Text(
                l10n.about,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings_outlined, color: Colors.grey[700]),
              title: Text(
                l10n.settings,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline, color: Colors.grey[700]),
              title: Text(
                l10n.help,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/help');
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                l10n.logout,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient(context),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top App Bar for Bottom Nav Mode
              if (!widget.showAppBar)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient(context),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        l10n.appName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                        onPressed: () {
                          Navigator.pushNamed(context, '/notifications');
                        },
                      ),
                    ],
                  ),
                ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  // Welcome Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient(context),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.welcomeBack,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.appTagline,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.wb_sunny,
                          color: Colors.amber,
                          size: 50,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Services Title
                  Text(
                    l10n.ourServices,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B3D2A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Services Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return ServiceCardWidget(
                        service: service,
                        onTap: () {
                          Navigator.pushNamed(context, service.route);
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/voice-assistant');
        },
        backgroundColor: const Color(0xFF2E6B3F),
        child: const Icon(Icons.mic, color: Colors.white, size: 32),
        tooltip: 'Voice Assistant',
      ),
    );
  }
}

class ServiceCard {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  ServiceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class ServiceCardWidget extends StatelessWidget {
  final ServiceCard service;
  final VoidCallback onTap;

  const ServiceCardWidget({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: service.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                service.icon,
                size: 40,
                color: service.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              service.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B3D2A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              service.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
