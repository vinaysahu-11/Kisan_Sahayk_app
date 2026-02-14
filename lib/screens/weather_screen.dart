import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../services/weather_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _currentWeather;
  Map<String, dynamic>? _forecast;
  Map<String, dynamic>? _agriAdvice;
  Position? _position;
  String _cityName = 'Loading...';
  DateTime? _lastUpdateTime;
  bool _isOfflineMode = false;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isOfflineMode = false;
    });

    try {
      double latitude;
      double longitude;

      // Try to get current location, fallback to default coordinates if denied
      try {
        _position = await _weatherService.getCurrentLocation();
        latitude = _position!.latitude;
        longitude = _position!.longitude;
      } catch (locationError) {
        // If location permission denied, use default coordinates (Raipur, Chhattisgarh)
        print('Location access denied, using default location: $locationError');
        latitude = 21.2514;  // Raipur latitude
        longitude = 81.6296; // Raipur longitude
        _cityName = 'Raipur (Default)';
      }

      // If we got the location successfully, get city name
      if (_position != null) {
        _cityName = await _weatherService.getCityName(latitude, longitude);
      }

      // Fetch all weather data in parallel
      final results = await Future.wait([
        _weatherService.getCurrentWeather(
          latitude: latitude,
          longitude: longitude,
        ),
        _weatherService.getWeatherForecast(
          latitude: latitude,
          longitude: longitude,
          days: 5,
        ),
        _weatherService.getAgricultureAdvice(
          latitude: latitude,
          longitude: longitude,
        ),
      ]);

      // Get last update time to show offline indicator
      _lastUpdateTime = await _weatherService.getLastUpdateTime();

      // Debug logging
      print('==================== WEATHER DATA DEBUG ====================');
      print('Current Weather Response: ${results[0]}');
      print('Forecast Response: ${results[1]}');
      print('Agriculture Advice Response: ${results[2]}');
      print('==========================================================');

      if (mounted) {
        setState(() {
          _currentWeather = results[0];
          _forecast = results[1];
          _agriAdvice = results[2];
          _isLoading = false;
        });
      }
    } catch (e) {
      // Check if we're showing cached data (offline mode)
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          // If error occurred but we have weather data, we're in offline mode
          _isOfflineMode = (_currentWeather != null || _forecast != null || _agriAdvice != null);
        });
      }
    }
  }

  String _getWeatherEmoji(String? icon) {
    if (icon == null) return '🌤';
    if (icon.startsWith('01')) return '☀️';
    if (icon.startsWith('02')) return '⛅';
    if (icon.startsWith('03') || icon.startsWith('04')) return '☁️';
    if (icon.startsWith('09') || icon.startsWith('10')) return '🌧️';
    if (icon.startsWith('11')) return '⛈️';
    if (icon.startsWith('13')) return '❄️';
    if (icon.startsWith('50')) return '🌫️';
    return '🌤';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEE, MMM d').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.translate('weather_forecast'),
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient(context),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeatherData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && !_isOfflineMode
              ? _buildErrorWidget()
              : _buildWeatherContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient(context),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load weather data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadWeatherData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E6B3F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    if (_currentWeather == null || _forecast == null) {
      return const Center(child: Text('No weather data available'));
    }

    final current = _currentWeather!['current'] ?? {};
    final location = _currentWeather!['location'] ?? {};
    final forecastData = _forecast!['forecast'] ?? [];
    final advice = _agriAdvice ?? {};

    // Debug logging
    print('==================== DISPLAY DATA DEBUG ====================');
    print('Current data: $current');
    print('Location data: $location');
    print('Temperature: ${current['temperature']}');
    print('Humidity: ${current['humidity']}');
    print('Pressure: ${current['pressure']}');
    print('==========================================================');

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient(context),
      ),
      child: RefreshIndicator(
        onRefresh: _loadWeatherData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Weather Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.weatherGradient(context),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
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
                          const Icon(Icons.location_on,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${location['name'] ?? _cityName}, ${location['country'] ?? ''}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Today, ${DateFormat('MMM d, yyyy').format(DateTime.now())}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      // Offline indicator
                      if (_lastUpdateTime != null && _lastUpdateTime!.isBefore(DateTime.now().subtract(const Duration(minutes: 30))))
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white38),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.cloud_off, color: Colors.white70, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Offline - Last updated ${_getTimeAgo(_lastUpdateTime!)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
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
                                '${current['temperature'] ?? 0}°C',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                (current['description'] ?? 'N/A')
                                    .toString()
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Feels like ${current['feelsLike'] ?? 0}°C',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _getWeatherEmoji(current['icon']),
                            style: const TextStyle(fontSize: 80),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                //Weather Details Grid
                Row(
                  children: [
                    Expanded(
                      child: _WeatherDetailCard(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: '${current['humidity'] ?? 0}%',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _WeatherDetailCard(
                        icon: Icons.air,
                        label: 'Wind',
                        value: '${current['windSpeed'] ?? 0} km/h',
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
                        value: '${current['visibility'] ?? 0} km',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _WeatherDetailCard(
                        icon: Icons.compress,
                        label: 'Pressure',
                        value: '${current['pressure'] ?? 0} mb',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _WeatherDetailCard(
                        icon: Icons.cloud,
                        label: 'Cloudiness',
                        value: '${current['cloudiness'] ?? 0}%',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _WeatherDetailCard(
                        icon: Icons.navigation,
                        label: 'Wind Dir',
                        value: current['windDirection'] ?? 'N/A',
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

                ...forecastData.map<Widget>((day) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              _formatDate(day['date'] ?? ''),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            _getWeatherEmoji(day['icon']),
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (day['description'] ?? '').toString(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                if (day['rainfall'] != null &&
                                    day['rainfall'] > 0)
                                  Text(
                                    '💧 ${day['rainfall']}mm',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '${day['maxTemp']}°/${day['minTemp']}°',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 24),

                // Agriculture Advice
                if (advice.isNotEmpty) ...[
                  const Text(
                    'Agriculture Advice',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B3D2A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recommendations
                  if (advice['recommendations'] != null)
                    ...List<Map<String, dynamic>>.from(advice['recommendations'])
                        .map((rec) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _getPriorityColor(rec['priority']),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        rec['icon'] ?? '📌',
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              rec['category'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getPriorityColor(
                                                        rec['priority'])
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '${rec['priority']} Priority',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: _getPriorityColor(
                                                      rec['priority']),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    rec['advice'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        rec['timing'] ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.iconColor(context).withOpacity(0.8), size: 28),
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
