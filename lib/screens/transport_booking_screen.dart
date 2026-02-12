import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../models/transport_models.dart';
import '../services/transport_booking_service.dart';
import 'transport_vehicle_selection_screen.dart';
import 'transport_active_booking_screen.dart';

class TransportBookingScreen extends StatefulWidget {
  const TransportBookingScreen({super.key});

  @override
  State<TransportBookingScreen> createState() => _TransportBookingScreenState();
}

class _TransportBookingScreenState extends State<TransportBookingScreen> {
  final _bookingService = TransportBookingService();
  Location? _pickupLocation;
  Location? _dropLocation;
  double? _distance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkActiveBooking();
  }

  Future<void> _checkActiveBooking() async {
    setState(() => _isLoading = true);
    
    // Check if user has an active booking
    final activeBooking = _bookingService.getActiveBooking('USER001');
    
    if (activeBooking != null && mounted) {
      // Navigate to active booking screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TransportActiveBookingScreen(booking: activeBooking),
        ),
      );
      return;
    }
    
    setState(() => _isLoading = false);
  }

  void _selectLocation(bool isPickup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationSearchSheet(
        isPickup: isPickup,
        onLocationSelected: (location) {
          setState(() {
            if (isPickup) {
              _pickupLocation = location;
            } else {
              _dropLocation = location;
            }
            _calculateDistance();
          });
        },
      ),
    );
  }

  void _calculateDistance() {
    if (_pickupLocation != null && _dropLocation != null) {
      final distance =
          _bookingService.calculateDistance(_pickupLocation!, _dropLocation!);
      setState(() {
        _distance = distance;
      });
    }
  }

  void _proceedToVehicleSelection() {
    if (_pickupLocation == null || _dropLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.translate('select_both_locations')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransportVehicleSelectionScreen(
          pickupLocation: _pickupLocation!,
          dropLocation: _dropLocation!,
          distance: _distance!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.translate('transport_booking')),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('book_transport')),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Map placeholder
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.grey[200],
            child: Stack(
              children: [
                // Map would go here (Google Maps in production)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Map View',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_distance != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Distance: ${_distance!.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_pickupLocation != null)
                  const Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Icon(
                        Icons.location_on,
                        color: Color(0xFF2E7D32),
                        size: 40,
                      ),
                    ),
                  ),
                if (_dropLocation != null)
                  const Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Location selection cards
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Pickup location
                  _LocationCard(
                    icon: Icons.radio_button_checked,
                    iconColor: const Color(0xFF2E7D32),
                    title: AppLocalizations.of(context)!.translate('from_location'),
                    location: _pickupLocation,
                    onTap: () => _selectLocation(true),
                  ),
                  const SizedBox(height: 12),

                  // Drop location
                  _LocationCard(
                    icon: Icons.location_on,
                    iconColor: Colors.red,
                    title: AppLocalizations.of(context)!.translate('to_location'),
                    location: _dropLocation,
                    onTap: () => _selectLocation(false),
                  ),

                  const Spacer(),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _pickupLocation != null && _dropLocation != null
                          ? _proceedToVehicleSelection
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.translate('select_vehicle'),
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
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Location? location;
  final VoidCallback onTap;

  const _LocationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location?.address ?? 'Select location',
                      style: TextStyle(
                        fontSize: 15,
                        color: location != null ? Colors.black87 : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationSearchSheet extends StatefulWidget {
  final bool isPickup;
  final Function(Location) onLocationSelected;

  const _LocationSearchSheet({
    required this.isPickup,
    required this.onLocationSelected,
  });

  @override
  State<_LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<_LocationSearchSheet> {
  final _searchController = TextEditingController();
  final List<Location> _suggestions = _getDummyLocations();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static List<Location> _getDummyLocations() {
    return [
      Location(
        latitude: 21.2514,
        longitude: 81.6296,
        address: 'Raipur Railway Station, Raipur',
      ),
      Location(
        latitude: 21.2612,
        longitude: 81.6384,
        address: 'Bilaspur Road, Raipur',
      ),
      Location(
        latitude: 21.2420,
        longitude: 81.6203,
        address: 'Dhamtari Road, Raipur',
      ),
      Location(
        latitude: 21.2560,
        longitude: 81.6350,
        address: 'Tatibandh, Raipur',
      ),
      Location(
        latitude: 21.2480,
        longitude: 81.6410,
        address: 'Mana Camp, Raipur',
      ),
      Location(
        latitude: 21.2590,
        longitude: 81.6450,
        address: 'Devendra Nagar, Raipur',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.isPickup ? 'Select Pickup' : 'Select Drop',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Current location option
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.my_location,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
            ),
            title: const Text(
              'GPS auto-detect',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('GPS auto-detect'),
            onTap: () {
              // In production, use Geolocator package
              final currentLocation = Location(
                latitude: 21.2514,
                longitude: 81.6296,
                address: 'Current Location, Raipur',
              );
              widget.onLocationSelected(currentLocation);
              Navigator.pop(context);
            },
          ),

          const Divider(height: 1),

          // Location suggestions
          Expanded(
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final location = _suggestions[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey[700],
                      size: 20,
                    ),
                  ),
                  title: Text(
                    location.address,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    widget.onLocationSelected(location);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
