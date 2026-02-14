import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class WeatherService {
  static const String _currentWeatherKey = 'cached_current_weather';
  static const String _forecastKey = 'cached_forecast';
  static const String _agriAdviceKey = 'cached_agri_advice';
  static const String _lastUpdateKey = 'weather_last_update';

  /// Save weather data to cache
  Future<void> _saveToCache(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(data));
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error saving to cache: $e');
    }
  }

  /// Load weather data from cache
  Future<Map<String, dynamic>?> _loadFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(key);
      if (cached != null) {
        return jsonDecode(cached) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error loading from cache: $e');
    }
    return null;
  }

  /// Get last update time
  Future<DateTime?> getLastUpdateTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getString(_lastUpdateKey);
      if (lastUpdate != null) {
        return DateTime.parse(lastUpdate);
      }
    } catch (e) {
      print('Error getting last update time: $e');
    }
    return null;
  }
  /// Get current location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable location services.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Get city name from coordinates
  Future<String> getCityName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return place.locality ?? place.subAdministrativeArea ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      print('Error getting city name: $e');
      return 'Unknown';
    }
  }

  /// Get current weather data
  Future<Map<String, dynamic>> getCurrentWeather({
    double? latitude,
    double? longitude,
    String? city,
    bool useCache = true,
  }) async {
    try {
      // If no location provided, get current location
      if (latitude == null || longitude == null) {
        if (city == null) {
          final position = await getCurrentLocation();
          latitude = position.latitude;
          longitude = position.longitude;
        }
      }

      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (city != null) queryParams['city'] = city;

      final uri = Uri.parse('${ApiConfig.baseUrl}/weather/current')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final data = result['data'] ?? result;
        // Save to cache for offline use
        await _saveToCache(_currentWeatherKey, data);
        return data;
      } else {
        throw Exception('Failed to get weather data: ${response.statusCode}');
      }
    } catch (e) {
      // Try to load from cache if online request fails
      if (useCache) {
        final cached = await _loadFromCache(_currentWeatherKey);
        if (cached != null) {
          print('Using cached weather data (offline mode)');
          return cached;
        }
      }
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  /// Get weather forecast
  Future<Map<String, dynamic>> getWeatherForecast({
    double? latitude,
    double? longitude,
    String? city,
    int days = 7,
    bool useCache = true,
  }) async {
    try {
      // If no location provided, get current location
      if (latitude == null || longitude == null) {
        if (city == null) {
          final position = await getCurrentLocation();
          latitude = position.latitude;
          longitude = position.longitude;
        }
      }

      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (city != null) queryParams['city'] = city;
      queryParams['days'] = days.toString();

      final uri = Uri.parse('${ApiConfig.baseUrl}/weather/forecast')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final data = result['data'] ?? result;
        await _saveToCache(_forecastKey, data);
        return data;
      } else {
        throw Exception('Failed to get forecast data: ${response.statusCode}');
      }
    } catch (e) {
      // Try to load from cache if online request fails
      if (useCache) {
        final cached = await _loadFromCache(_forecastKey);
        if (cached != null) {
          print('Using cached forecast data (offline mode)');
          return cached;
        }
      }
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  /// Get agriculture advice
  Future<Map<String, dynamic>> getAgricultureAdvice({
    double? latitude,
    double? longitude,
    String? cropType,
    String? stage,
    bool useCache = true,
  }) async {
    try {
      // If no location provided, get current location
      if (latitude == null || longitude == null) {
        final position = await getCurrentLocation();
        latitude = position.latitude;
        longitude = position.longitude;
      }

      final queryParams = <String, String>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      };
      if (cropType != null) queryParams['cropType'] = cropType;
      if (stage != null) queryParams['stage'] = stage;

      final uri = Uri.parse('${ApiConfig.baseUrl}/weather/agriculture-advice')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final data = result['data'] ?? result;
        await _saveToCache(_agriAdviceKey, data);
        return data;
      } else {
        throw Exception('Failed to get agriculture advice: ${response.statusCode}');
      }
    } catch (e) {
      // Try to load from cache if online request fails
      if (useCache) {
        final cached = await _loadFromCache(_agriAdviceKey);
        if (cached != null) {
          print('Using cached agriculture advice (offline mode)');
          return cached;
        }
      }
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }
}
