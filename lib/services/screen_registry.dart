// Screen Registry - Maps screens to available voice commands and actions

class ScreenRegistry {
  static final ScreenRegistry _instance = ScreenRegistry._internal();
  factory ScreenRegistry() => _instance;
  ScreenRegistry._internal();

  final Map<String, ScreenConfig> _screens = {
    'dashboard': ScreenConfig(
      name: 'Dashboard',
      route: '/',
      actions: [
        'navigate_transport',
        'navigate_weather',
        'navigate_buy',
        'navigate_sell',
        'navigate_labour',
        'navigate_jobs',
        'navigate_ai_assistant',
        'show_profile',
        'show_notifications',
      ],
      voiceCommands: [
        'transport kholo',
        'mausam dikhao',
        'kharidari karo',
        'becho',
        'majdoor chahiye',
        'naukri dhundo',
        'AI assistant',
        'profile dikhao',
        'notifications',
      ],
    ),
    'transport': ScreenConfig(
      name: 'Transport',
      route: '/transport',
      actions: [
        'select_vehicle',
        'set_pickup',
        'set_drop',
        'set_date',
        'confirm_booking',
        'view_bookings',
        'become_partner',
      ],
      voiceCommands: [
        'mini truck select karo',
        'pickup location Raipur',
        'drop location Durg',
        'date select karo',
        'booking confirm karo',
        'mere bookings dikhao',
        'partner banna hai',
      ],
    ),
    'buy_product': ScreenConfig(
      name: 'Buy Products',
      route: '/buy-product',
      actions: [
        'search_product',
        'filter_category',
        'add_to_cart',
        'view_cart',
        'checkout',
      ],
      voiceCommands: [
        'beej dhundo',
        'khad dikhao',
        'cart me dalo',
        'cart dikhao',
        'order karo',
      ],
    ),
    'sell_product': ScreenConfig(
      name: 'Sell Products',
      route: '/sell-product',
      actions: [
        'select_category',
        'enter_title',
        'enter_price',
        'enter_quantity',
        'add_photo',
        'publish',
      ],
      voiceCommands: [
        'category select karo',
        'naam likho',
        'price daalo',
        'quantity bataao',
        'photo add karo',
        'publish karo',
      ],
    ),
    'labour': ScreenConfig(
      name: 'Labour',
      route: '/labour',
      actions: [
        'select_skill',
        'set_location',
        'set_duration',
        'set_workers_count',
        'post_requirement',
        'view_applications',
      ],
      voiceCommands: [
        'skill select karo',
        'location bataao',
        'kitne din chahiye',
        'kitne log chahiye',
        'requirement post karo',
        'applications dikhao',
      ],
    ),
    'weather': ScreenConfig(
      name: 'Weather',
      route: '/weather',
      actions: [
        'current_weather',
        'forecast',
        'alerts',
      ],
      voiceCommands: [
        'aaj ka mausam',
        'agle hafte ka mausam',
        'alerts dikhao',
      ],
    ),
    'ai_assistant': ScreenConfig(
      name: 'AI Assistant',
      route: '/ai-assistant',
      actions: [
        'ask_question',
        'crop_recommendation',
        'disease_detection',
        'farming_tips',
      ],
      voiceCommands: [
        'sawal pucho',
        'kaun si fasal lagaun',
        'bimari pehchano',
        'tips do',
      ],
    ),
    'profile': ScreenConfig(
      name: 'Profile',
      route: '/profile',
      actions: [
        'edit_profile',
        'view_orders',
        'view_wallet',
        'settings',
        'logout',
      ],
      voiceCommands: [
        'profile edit karo',
        'orders dikhao',
        'wallet dikhao',
        'settings',
        'logout karo',
      ],
    ),
  };

  ScreenConfig? getScreen(String screenName) {
    return _screens[screenName];
  }

  List<String> getScreenActions(String screenName) {
    return _screens[screenName]?.actions ?? [];
  }

  List<String> getVoiceCommands(String screenName) {
    return _screens[screenName]?.voiceCommands ?? [];
  }

  String? getRouteForScreen(String screenName) {
    return _screens[screenName]?.route;
  }

  List<String> getAllScreenNames() {
    return _screens.keys.toList();
  }

  Map<String, String> getScreenRoutes() {
    return Map.fromEntries(
      _screens.entries.map((e) => MapEntry(e.key, e.value.route)),
    );
  }

  // Get screen by route
  String? getScreenNameByRoute(String route) {
    for (var entry in _screens.entries) {
      if (entry.value.route == route) {
        return entry.key;
      }
    }
    return null;
  }

  // Get help text for current screen
  String getHelpText(String screenName, String language) {
    final screen = _screens[screenName];
    if (screen == null) return 'Screen not found';

    final commands = screen.voiceCommands.take(3).join(', ');
    
    if (language == 'hi') {
      return 'Aap yeh bol sakte hain: $commands';
    } else if (language == 'en') {
      return 'You can say: $commands';
    } else {
      return 'Bole sakte: $commands';
    }
  }
}

class ScreenConfig {
  final String name;
  final String route;
  final List<String> actions;
  final List<String> voiceCommands;

  ScreenConfig({
    required this.name,
    required this.route,
    required this.actions,
    required this.voiceCommands,
  });
}
