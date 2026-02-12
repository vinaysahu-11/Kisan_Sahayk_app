import 'dart:async';
import 'dart:math';
import '../models/transport_models.dart';

class LocationUpdate {
  final String partnerId;
  final String bookingId;
  final Location location;
  final double speed; // km/h
  final DateTime timestamp;
  final double distanceToDestination; // km
  final int etaMinutes;

  LocationUpdate({
    required this.partnerId,
    required this.bookingId,
    required this.location,
    required this.speed,
    required this.timestamp,
    required this.distanceToDestination,
    required this.etaMinutes,
  });

  Map<String, dynamic> toJson() => {
        'partnerId': partnerId,
        'bookingId': bookingId,
        'location': location.toJson(),
        'speed': speed,
        'timestamp': timestamp.toIso8601String(),
        'distanceToDestination': distanceToDestination,
        'etaMinutes': etaMinutes,
      };

  factory LocationUpdate.fromJson(Map<String, dynamic> json) => LocationUpdate(
        partnerId: json['partnerId'],
        bookingId: json['bookingId'],
        location: Location.fromJson(json['location']),
        speed: json['speed'],
        timestamp: DateTime.parse(json['timestamp']),
        distanceToDestination: json['distanceToDestination'],
        etaMinutes: json['etaMinutes'],
      );
}

class LiveTrackingService {
  static final LiveTrackingService _instance = LiveTrackingService._internal();
  factory LiveTrackingService() => _instance;
  LiveTrackingService._internal();

  // Streams for real-time location updates
  final Map<String, StreamController<LocationUpdate>>
      _locationControllers = {};
  
  // Active tracking sessions
  final Map<String, Timer> _trackingSessions = {};
  
  // Simulated location data
  final Map<String, Location> _currentLocations = {};
  final Map<String, Location> _destinations = {};

  // Start tracking a booking
  Stream<LocationUpdate> startTracking({
    required String bookingId,
    required String partnerId,
    required Location startLocation,
    required Location destination,
  }) {
    // Stop any existing tracking for this booking
    stopTracking(bookingId);

    // Create new stream controller
    final controller = StreamController<LocationUpdate>.broadcast();
    _locationControllers[bookingId] = controller;

    // Initialize locations
    _currentLocations[bookingId] = startLocation;
    _destinations[bookingId] = destination;

    // Start periodic updates (every 5 seconds)
    final timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateLocation(bookingId, partnerId);
    });

    _trackingSessions[bookingId] = timer;

    // Send initial update
    _updateLocation(bookingId, partnerId);

    return controller.stream;
  }

  // Update location (simulated GPS movement)
  void _updateLocation(String bookingId, String partnerId) {
    final controller = _locationControllers[bookingId];
    if (controller == null || controller.isClosed) return;

    final currentLocation = _currentLocations[bookingId];
    final destination = _destinations[bookingId];

    if (currentLocation == null || destination == null) return;

    // Calculate distance to destination
    final distance = _calculateDistance(currentLocation, destination);

    // If very close to destination, stop updating
    if (distance < 0.1) {
      stopTracking(bookingId);
      return;
    }

    // Simulate movement towards destination
    final newLocation = _moveTowards(currentLocation, destination, 0.5); // Move 500m
    _currentLocations[bookingId] = newLocation;

    // Calculate speed (30-50 km/h random)
    final speed = 30.0 + Random().nextDouble() * 20.0;

    // Calculate ETA
    final etaMinutes = ((distance / speed) * 60).ceil();

    // Create location update
    final update = LocationUpdate(
      partnerId: partnerId,
      bookingId: bookingId,
      location: newLocation,
      speed: speed,
      timestamp: DateTime.now(),
      distanceToDestination: distance,
      etaMinutes: etaMinutes,
    );

    // Send update
    controller.add(update);
  }

  // Stop tracking a booking
  void stopTracking(String bookingId) {
    // Cancel timer
    _trackingSessions[bookingId]?.cancel();
    _trackingSessions.remove(bookingId);

    // Close stream
    _locationControllers[bookingId]?.close();
    _locationControllers.remove(bookingId);

    // Clean up data
    _currentLocations.remove(bookingId);
    _destinations.remove(bookingId);
  }

  // Calculate distance between two locations (Haversine formula)
  double _calculateDistance(Location from, Location to) {
    const earthRadiusKm = 6371;

    final dLat = _toRadians(to.latitude - from.latitude);
    final dLon = _toRadians(to.longitude - from.longitude);

    final lat1 = _toRadians(from.latitude);
    final lat2 = _toRadians(to.latitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Move location towards destination
  Location _moveTowards(Location from, Location to, double distanceKm) {
    final totalDistance = _calculateDistance(from, to);
    if (totalDistance <= distanceKm) {
      return to;
    }

    final fraction = distanceKm / totalDistance;
    final newLat = from.latitude + (to.latitude - from.latitude) * fraction;
    final newLng = from.longitude + (to.longitude - from.longitude) * fraction;

    return Location(
      latitude: newLat,
      longitude: newLng,
      address: 'En route', // Would be reverse geocoded in production
    );
  }

  // Manual location update (for partner app to send real GPS)
  void updatePartnerLocation({
    required String bookingId,
    required String partnerId,
    required Location location,
    required double speed,
  }) {
    final controller = _locationControllers[bookingId];
    if (controller == null || controller.isClosed) return;

    final destination = _destinations[bookingId];
    if (destination == null) return;

    // Update current location
    _currentLocations[bookingId] = location;

    // Calculate distance to destination
    final distance = _calculateDistance(location, destination);

    // Calculate ETA
    final etaMinutes = speed > 0 ? ((distance / speed) * 60).ceil() : 0;

    // Create location update
    final update = LocationUpdate(
      partnerId: partnerId,
      bookingId: bookingId,
      location: location,
      speed: speed,
      timestamp: DateTime.now(),
      distanceToDestination: distance,
      etaMinutes: etaMinutes,
    );

    // Send update
    controller.add(update);
  }

  // Get current location for booking
  Location? getCurrentLocation(String bookingId) {
    return _currentLocations[bookingId];
  }

  void dispose() {
    // Cancel all timers
    for (final timer in _trackingSessions.values) {
      timer.cancel();
    }
    _trackingSessions.clear();

    // Close all streams
    for (final controller in _locationControllers.values) {
      controller.close();
    }
    _locationControllers.clear();

    // Clear data
    _currentLocations.clear();
    _destinations.clear();
  }
}
