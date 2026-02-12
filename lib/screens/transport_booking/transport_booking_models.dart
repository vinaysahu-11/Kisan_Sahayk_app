import 'dart:math';

// Vehicle Types
enum VehicleType {
  tractor,
  pickup,
  miniTruck,
  heavyTruck,
}

// Load Types
enum LoadType {
  crops,
  fertilizer,
  equipment,
  mixed,
}

// Booking Status
enum BookingStatus {
  searching,
  driverAccepted,
  driverArriving,
  loadStarted,
  onTheWay,
  delivered,
  completed,
}

// Vehicle Model
class Vehicle {
  final VehicleType type;
  final String name;
  final String icon;
  final double loadCapacity; // in tons
  final double pricePerKm;
  final int estimatedArrival; // in minutes

  Vehicle({
    required this.type,
    required this.name,
    required this.icon,
    required this.loadCapacity,
    required this.pricePerKm,
    required this.estimatedArrival,
  });

  static List<Vehicle> getAvailableVehicles() {
    return [
      Vehicle(
        type: VehicleType.tractor,
        name: 'Tractor',
        icon: '🚜',
        loadCapacity: 2.0,
        pricePerKm: 15.0,
        estimatedArrival: 5,
      ),
      Vehicle(
        type: VehicleType.pickup,
        name: 'Pickup',
        icon: '🛻',
        loadCapacity: 1.5,
        pricePerKm: 12.0,
        estimatedArrival: 3,
      ),
      Vehicle(
        type: VehicleType.miniTruck,
        name: 'Mini Truck',
        icon: '🚛',
        loadCapacity: 5.0,
        pricePerKm: 20.0,
        estimatedArrival: 8,
      ),
      Vehicle(
        type: VehicleType.heavyTruck,
        name: 'Heavy Truck',
        icon: '🚚',
        loadCapacity: 10.0,
        pricePerKm: 30.0,
        estimatedArrival: 12,
      ),
    ];
  }
}

// Driver Model
class Driver {
  final String id;
  final String name;
  final String photo;
  final double rating;
  final String vehicleNumber;
  final VehicleType vehicleType;
  final double loadCapacity;

  Driver({
    required this.id,
    required this.name,
    required this.photo,
    required this.rating,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.loadCapacity,
  });

  static Driver generateRandomDriver(VehicleType vehicleType, double capacity) {
    final random = Random();
    final names = ['Ramesh Kumar', 'Suresh Patel', 'Mahesh Singh', 'Rajesh Yadav', 'Dinesh Sharma'];
    final name = names[random.nextInt(names.length)];
    
    return Driver(
      id: 'DRV${random.nextInt(9999).toString().padLeft(4, '0')}',
      name: name,
      photo: '👨‍🌾', // Emoji as placeholder
      rating: 4.0 + random.nextDouble(),
      vehicleNumber: 'CG ${random.nextInt(99).toString().padLeft(2, '0')} ${random.nextInt(9999).toString().padLeft(4, '0')}',
      vehicleType: vehicleType,
      loadCapacity: capacity,
    );
  }
}

// Location Model
class Location {
  final double latitude;
  final double longitude;
  final String address;

  Location({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

// Booking Model
class TransportBooking {
  final String id;
  final Location pickupLocation;
  final Location dropLocation;
  final Vehicle vehicle;
  final LoadType loadType;
  final double weight;
  final DateTime pickupDateTime;
  final String notes;
  Driver? driver;
  BookingStatus status;
  double? distance;
  double? fare;

  TransportBooking({
    required this.id,
    required this.pickupLocation,
    required this.dropLocation,
    required this.vehicle,
    required this.loadType,
    required this.weight,
    required this.pickupDateTime,
    required this.notes,
    this.driver,
    this.status = BookingStatus.searching,
    this.distance,
    this.fare,
  });

  double calculateFare() {
    if (distance == null) return 0.0;
    final baseFare = distance! * vehicle.pricePerKm;
    final platformFee = baseFare * 0.1; // 10% platform fee
    return baseFare + platformFee;
  }

  String getStatusText() {
    switch (status) {
      case BookingStatus.searching:
        return 'Searching for driver...';
      case BookingStatus.driverAccepted:
        return 'Driver Accepted';
      case BookingStatus.driverArriving:
        return 'Driver Arriving';
      case BookingStatus.loadStarted:
        return 'Loading Started';
      case BookingStatus.onTheWay:
        return 'On the Way';
      case BookingStatus.delivered:
        return 'Delivered';
      case BookingStatus.completed:
        return 'Completed';
    }
  }
}

// Demo Data Generators
class DemoDataGenerator {
  static Location getRandomLocation(String type) {
    final random = Random();
    final baseLatitude = 21.2514; // Raipur, Chhattisgarh
    final baseLongitude = 81.6296;
    
    return Location(
      latitude: baseLatitude + (random.nextDouble() - 0.5) * 0.1,
      longitude: baseLongitude + (random.nextDouble() - 0.5) * 0.1,
      address: type == 'pickup' 
          ? 'Arang, Raipur, Chhattisgarh'
          : 'Mandi, Raipur, Chhattisgarh',
    );
  }

  static double calculateDistance(Location from, Location to) {
    // Simplified distance calculation (in km)
    final latDiff = (from.latitude - to.latitude).abs();
    final lonDiff = (from.longitude - to.longitude).abs();
    return sqrt(latDiff * latDiff + lonDiff * lonDiff) * 111; // Rough conversion to km
  }
}
