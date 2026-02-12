import 'package:flutter/material.dart';
import 'transport_booking_models.dart';
import 'transport_load_details_screen.dart';

class TransportBookingMapScreen extends StatefulWidget {
  const TransportBookingMapScreen({super.key});

  @override
  State<TransportBookingMapScreen> createState() => _TransportBookingMapScreenState();
}

class _TransportBookingMapScreenState extends State<TransportBookingMapScreen> {
  final List<Vehicle> vehicles = Vehicle.getAvailableVehicles();
  Vehicle? selectedVehicle;
  final pickupController = TextEditingController(text: 'Arang, Raipur, Chhattisgarh');
  final dropController = TextEditingController(text: 'Mandi, Raipur, Chhattisgarh');

  @override
  void dispose() {
    pickupController.dispose();
    dropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Simulated Map Background
          _buildMapBackground(),
          
          // Top Search Section
          _buildTopSearchSection(),
          
          // Bottom Sheet with Vehicle Selection
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildMapBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[200]!,
            Colors.grey[300]!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Map View',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Pickup Location',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red[600],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Drop Location',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSearchSection() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pickup Location
            _buildLocationField(
              controller: pickupController,
              icon: Icons.circle,
              iconColor: const Color(0xFF2E7D32),
              hint: 'Pickup Location',
            ),
            const SizedBox(height: 12),
            // Drop Location
            _buildLocationField(
              controller: dropController,
              icon: Icons.location_on,
              iconColor: Colors.red[600]!,
              hint: 'Drop Location',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          IconButton(
            icon: Icon(Icons.my_location, color: Colors.grey[600], size: 20),
            onPressed: () {
              // Current location action
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.15),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'Select Vehicle Type',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B3D2A),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Vehicle Cards
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      final isSelected = selectedVehicle == vehicle;
                      return _buildVehicleCard(vehicle, isSelected);
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: selectedVehicle == null ? null : _onConfirmVehicle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Confirm Vehicle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedVehicle = vehicle;
        });
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                vehicle.icon,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 8),
              Text(
                vehicle.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF1B3D2A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${vehicle.loadCapacity} Ton',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white70 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color.fromRGBO(46, 125, 50, 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '₹${vehicle.pricePerKm}/km',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${vehicle.estimatedArrival} min',
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? Colors.white60 : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onConfirmVehicle() {
    if (selectedVehicle == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransportLoadDetailsScreen(
          vehicle: selectedVehicle!,
          pickupLocation: pickupController.text,
          dropLocation: dropController.text,
        ),
      ),
    );
  }
}
