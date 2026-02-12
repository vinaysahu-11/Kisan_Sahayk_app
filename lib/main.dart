import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'utils/app_localizations.dart';
import 'providers/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fks_app/screens/login_screen.dart';
import 'package:fks_app/screens/signup_screen.dart';
import 'package:fks_app/screens/buy_product_screen.dart';
import 'package:fks_app/screens/transport_screen.dart';
import 'package:fks_app/screens/transport_booking/transport_booking_map_screen.dart';
import 'package:fks_app/screens/labour_screen.dart';
import 'package:fks_app/screens/labour_skill_selection_screen.dart';
import 'package:fks_app/screens/labour_partner_screen.dart';
import 'package:fks_app/screens/sell_product_screen.dart';
import 'package:fks_app/screens/job_screen.dart';
import 'package:fks_app/screens/profile_screen.dart';
import 'package:fks_app/screens/notifications_screen.dart';
import 'package:fks_app/screens/settings_screen.dart';
import 'package:fks_app/screens/help_screen.dart';
import 'package:fks_app/screens/about_screen.dart';
import 'package:fks_app/screens/language_screen.dart';
import 'package:fks_app/screens/main_wrapper_screen.dart';
import 'package:fks_app/screens/seller_login_screen.dart';
import 'package:fks_app/screens/admin_category_screen.dart';
import 'package:fks_app/screens/admin_seller_screen.dart';
import 'package:fks_app/widgets/auth_wrapper.dart';
import 'providers/theme_provider.dart';
import 'package:fks_app/screens/buyer_home_screen.dart';
import 'package:fks_app/screens/buyer_product_list_screen.dart';
import 'package:fks_app/screens/buyer_product_detail_screen.dart';
import 'package:fks_app/screens/buyer_search_screen.dart';
import 'package:fks_app/screens/buyer_cart_screen.dart';
import 'package:fks_app/screens/buyer_checkout_screen.dart';
import 'package:fks_app/screens/buyer_address_screen.dart';
import 'package:fks_app/screens/buyer_orders_screen.dart';
import 'package:fks_app/screens/buyer_order_detail_screen.dart';
import 'package:fks_app/screens/buyer_rating_screen.dart';
import 'package:fks_app/screens/weather_screen.dart';
import 'package:fks_app/screens/bookings_screen.dart';
import 'package:fks_app/screens/transport_partner/transport_partner_entry.dart';
import 'package:fks_app/screens/transport_partner/transport_partner_dashboard.dart';
import 'package:fks_app/screens/buyer_wallet_screen.dart';
import 'package:fks_app/screens/buyer_return_screen.dart';
import 'package:fks_app/screens/buyer_notifications_screen.dart';
import 'package:fks_app/screens/delivery_registration_screen.dart';
import 'package:fks_app/screens/delivery_application_status_screen.dart';
import 'package:fks_app/screens/delivery_dashboard_screen.dart';
import 'package:fks_app/screens/delivery_order_detail_screen.dart';
import 'package:fks_app/screens/delivery_earnings_screen.dart';
import 'package:fks_app/screens/delivery_wallet_screen.dart';
import 'package:fks_app/screens/delivery_incentives_screen.dart';
import 'package:fks_app/screens/delivery_performance_screen.dart';
import 'package:fks_app/screens/delivery_cod_screen.dart';
import 'package:fks_app/screens/delivery_notifications_screen.dart';
import 'package:fks_app/screens/delivery_safety_screen.dart';
import 'package:fks_app/screens/admin_delivery_partners_screen.dart';

const String kLogoPath = 'assets/images/kisan_sahayk_logo.png';
const String kAppName = 'Kisan Sahayk';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // Log to a service or print in debug
    debugPrint('Flutter Error: ${details.exception}');
  };
  
  // Catch asynchronous errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Native/Async Error: $error');
    return true;
  };

  final languageProvider = LanguageProvider();
  await languageProvider.loadSavedLanguage();
  
  final themeProvider = ThemeProvider();
  await themeProvider.loadSavedTheme();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: languageProvider.locale,
      themeMode: themeProvider.themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('cg'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // If Chhattisgarhi (cg) is selected, use Hindi for Material components
        if (locale?.languageCode == 'cg') {
          return const Locale('hi');
        }
        // Check if the current locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        // Fallback to English
        return const Locale('en');
      },
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E6B3F),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E6B3F),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
        ),
        cardColor: const Color(0xFF1E1E1E),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF1E1E1E),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const MainWrapperScreen(),
        '/weather': (context) => const WeatherScreen(),
        '/buy-product': (context) => const BuyProductScreen(),
        '/transport': (context) => const TransportScreen(),
        '/transport-booking': (context) => const TransportBookingMapScreen(),
        '/transport-partner': (context) => const TransportPartnerEntry(),
        '/transport-partner-dashboard': (context) => const TransportPartnerDashboardScreen(),
        '/labour': (context) => const LabourScreen(),
        '/labour-booking': (context) => const LabourSkillSelectionScreen(),
        '/labour-partner': (context) => const LabourPartnerEntry(),
        '/labour-partner-dashboard': (context) => const LabourPartnerDashboardScreen(),
        '/sell-product': (context) => const SellProductScreen(),
        '/jobs': (context) => const JobScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/bookings': (context) => const BookingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/language': (context) => const LanguageScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/help': (context) => const HelpScreen(),
        '/about': (context) => const AboutScreen(),
        '/seller-login': (context) => const SellerLoginScreen(),
        '/admin-categories': (context) => const AdminCategoryScreen(),
        '/admin-sellers': (context) => const AdminSellerScreen(),
        '/buyer-home': (context) => const BuyerHomeScreen(),
        '/buyer-search': (context) => const BuyerSearchScreen(),
        '/buyer-cart': (context) => const BuyerCartScreen(),
        '/buyer-checkout': (context) => const BuyerCheckoutScreen(),
        '/buyer-address': (context) => const BuyerAddressScreen(),
        '/buyer-orders': (context) => const BuyerOrdersScreen(),
        '/buyer-wallet': (context) => const BuyerWalletScreen(),
        '/buyer-notifications': (context) => const BuyerNotificationsScreen(),
        '/delivery-registration': (context) => const DeliveryRegistrationScreen(),
        '/delivery-application-status': (context) => const DeliveryApplicationStatusScreen(),
        '/delivery-dashboard': (context) => const DeliveryDashboardScreen(),
        '/delivery-earnings': (context) => const DeliveryEarningsScreen(),
        '/delivery-wallet': (context) => const DeliveryWalletScreen(),
        '/delivery-incentives': (context) => const DeliveryIncentivesScreen(),
        '/delivery-performance': (context) => const DeliveryPerformanceScreen(),
        '/delivery-cod': (context) => const DeliveryCODScreen(),
        '/delivery-notifications': (context) => const DeliveryNotificationsScreen(),
        '/delivery-safety': (context) => const DeliverySafetyScreen(),
        '/delivery-orders': (context) => const DeliveryDashboardScreen(),
        '/admin-delivery-partners': (context) => const AdminDeliveryPartnersScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/buyer-product-detail') {
          final productId = settings.arguments as String;
          return MaterialPageRoute(builder: (_) => BuyerProductDetailScreen(productId: productId));
        }
        if (settings.name == '/buyer-order-detail') {
          final orderId = settings.arguments as String;
          return MaterialPageRoute(builder: (_) => BuyerOrderDetailScreen(orderId: orderId));
        }
        if (settings.name == '/buyer-rating') {
          final orderId = settings.arguments as String;
          return MaterialPageRoute(builder: (_) => BuyerRatingScreen(orderId: orderId));
        }
        if (settings.name == '/buyer-return') {
          final orderId = settings.arguments as String;
          return MaterialPageRoute(builder: (_) => BuyerReturnScreen(orderId: orderId));
        }
        if (settings.name == '/buyer-product-list') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(builder: (_) => BuyerProductListScreen(categoryId: args['categoryId'], title: args['title'] ?? 'Products'));
        }
        if (settings.name == '/delivery-order-detail') {
          final orderId = settings.arguments as String;
          return MaterialPageRoute(builder: (_) => DeliveryOrderDetailScreen(orderId: orderId));
        }
        return null;
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _leafScale;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _glowStrength;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );

    _leafScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    );

    _taglineOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
    );

    _glowStrength = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const LanguageSelectionScreen(),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F7A3B),
              Color(0xFF2BB673),
              Color(0xFF69D28E),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final bounce = sin(_controller.value * pi) * 6;
              return Transform.translate(
                offset: Offset(0, -bounce),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AnimatedLogo(
                      scale: _leafScale.value,
                      glow: _glowStrength.value,
                    ),
                    const SizedBox(height: 14),
                    FadeTransition(
                      opacity: _taglineOpacity,
                      child: Text(
                        loc.translate('app_name'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeTransition(
                      opacity: _taglineOpacity,
                      child: Text(
                        loc.translate('tagline'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({required this.scale, required this.glow});

  final double scale;
  final double glow;

  @override
  Widget build(BuildContext context) {
    final glowRadius = 18 + (glow * 16);
    final glowOpacity = 0.25 + (glow * 0.3);
    return Transform.scale(
      scale: scale.clamp(0.0, 1.0),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color.fromRGBO(255, 255, 255, 0.08),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(255, 255, 255, glowOpacity),
              blurRadius: glowRadius,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Image.asset(
          kLogoPath,
          width: 150,
          height: 150,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 16,
                  child: Icon(
                    Icons.wb_sunny_rounded,
                    size: 58,
                    color: Color(0xFFFFD44D),
                  ),
                ),
                Icon(
                  Icons.eco_rounded,
                  size: 110,
                  color: Colors.white,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  void _openNext(BuildContext context, String language) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LanguageSelectedScreen(language: language),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3FFF6),
              Color(0xFFE7F6ED),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 6),
                const _SmallLogo(),
                const SizedBox(height: 24),
                Text(
                  loc.translate('choose_language'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF114E2B),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  loc.translate('select_language_hint'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF2C6E49),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 26),
                LanguageCard(
                  label: 'English',
                  flag: '🇬🇧',
                  onTap: () => _openNext(context, 'English'),
                ),
                const SizedBox(height: 16),
                LanguageCard(
                  label: 'हिंदी',
                  flag: '🇮🇳',
                  onTap: () => _openNext(context, 'हिंदी'),
                ),
                const SizedBox(height: 16),
                LanguageCard(
                  label: 'छत्तीसगढ़ी',
                  flag: '🌾',
                  onTap: () => _openNext(context, 'छत्तीसगढ़ी'),
                ),
                const Spacer(),
                Text(
                  loc.translate('select_language_hint'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF4C7A5A),
                      ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallLogo extends StatelessWidget {
  const _SmallLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          kLogoPath,
          width: 52,
          height: 52,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Row(
              children: const [
                Icon(Icons.eco_rounded, color: Color(0xFF1B8C4A), size: 28),
                SizedBox(width: 6),
                Icon(Icons.wb_sunny_rounded, color: Color(0xFFFFC945), size: 22),
              ],
            );
          },
        ),
      ],
    );
  }
}

class LanguageCard extends StatefulWidget {
  const LanguageCard({
    super.key,
    required this.label,
    required this.flag,
    required this.onTap,
  });

  final String label;
  final String flag;
  final VoidCallback onTap;

  @override
  State<LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends State<LanguageCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onTap,
          onHighlightChanged: (value) {
            setState(() {
              _pressed = value;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Text(widget.flag, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 14),
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B3D2A),
                      ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF7AAE8B),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LanguageSelectedScreen extends StatelessWidget {
  const LanguageSelectedScreen({super.key, required this.language});

  final String language;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    // Navigate to login screen after a brief delay using post-frame callback
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!context.mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      });
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3FFF6), Color(0xFFE7F6ED)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 80,
                color: Color(0xFF2E6B3F),
              ),
              const SizedBox(height: 24),
              Text(
                '${loc.translate('language_selected')}: $language',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E6B3F),
                    ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                color: Color(0xFF2E6B3F),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
