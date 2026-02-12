import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final forecast = [
      {'day': 'Mon', 'high': 34, 'low': 24, 'condition': 'Sunny', 'icon': '☀️'},
      {'day': 'Tue', 'high': 33, 'low': 23, 'condition': 'Partly Cloudy', 'icon': '⛅'},
      {'day': 'Wed', 'high': 31, 'low': 22, 'condition': 'Rainy', 'icon': '🌧️'},
      {'day': 'Thu', 'high': 30, 'low': 21, 'condition': 'Cloudy', 'icon': '☁️'},
      {'day': 'Fri', 'high': 32, 'low': 23, 'condition': 'Sunny', 'icon': '☀️'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('weather_forecast'), style: const TextStyle(color: Colors.white)),
        elevation: 0,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Weather Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Raipur, Chhattisgarh',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Today, ${DateTime.now().toString().split(' ')[0]}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '32°C',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Partly Cloudy',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Feels like 35°C',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            '🌤',
                            style: TextStyle(fontSize: 80),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Weather Details Grid
                Row(
                  children: [
                    Expanded(
                      child: _WeatherDetailCard(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: '65%',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _WeatherDetailCard(
                        icon: Icons.air,
                        label: 'Wind Speed',
                        value: '12 km/h',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _WeatherDetailCard(
                        icon: Icons.visibility,
                        label: 'Visibility',
                        value: '10 km',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _WeatherDetailCard(
                        icon: Icons.compress,
                        label: 'Pressure',
                        value: '1013 mb',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 5-Day Forecast
                const Text(
                  '5-Day Forecast',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B3D2A),
                  ),
                ),
                const SizedBox(height: 16),
                
                ...forecast.map((day) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(
                          day['day'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        day['icon'] as String,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          day['condition'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Text(
                        '${day['high']}°/${day['low']}°',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeatherDetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherDetailCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF4A90E2), size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B3D2A),
            ),
          ),
        ],
      ),
    );
  }
}
