import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../models/transport_models.dart';
import '../services/transport_booking_service.dart';
import 'transport_load_details_screen.dart';

class TransportVehicleSelectionScreen extends StatefulWidget {
  final Location pickupLocation;
  final Location dropLocation;
  final double distance;

  const TransportVehicleSelectionScreen({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
    required this.distance,
  });

  @override
  State<TransportVehicleSelectionScreen> createState() =>
      _TransportVehicleSelectionScreenState();
}

class _TransportVehicleSelectionScreenState
    extends State<TransportVehicleSelectionScreen> {
  final _bookingService = TransportBookingService();
  VehicleType? _selectedVehicle;
  final List<VehicleInfo> _vehicles = VehicleInfo.getAvailableVehicles();

  void _selectVehicle(VehicleType type) {
    setState(() {
      _selectedVehicle = type;
    });
  }

  void _proceedToLoadDetails() {
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.translate('select_vehicle_type')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final vehicleInfo =
        _vehicles.firstWhere((v) => v.type == _selectedVehicle);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransportLoadDetailsScreen(
          pickupLocation: widget.pickupLocation,
          dropLocation: widget.dropLocation,
          distance: widget.distance,
          vehicleInfo: vehicleInfo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('select_vehicle')),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Trip summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2E7D32).withValues(alpha: 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.route,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.distance.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'From: ${widget.pickupLocation.address}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'To: ${widget.dropLocation.address}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Vehicle list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = _vehicles[index];
                final fare = _bookingService.calculateFare(
                  distance: widget.distance,
                  ratePerKm: vehicle.ratePerKm,
                  minimumFare: vehicle.minimumFare,
                );
                final isSelected = _selectedVehicle == vehicle.type;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _VehicleCard(
                    vehicle: vehicle,
                    fare: fare,
                    isSelected: isSelected,
                    onTap: () => _selectVehicle(vehicle.type),
                  ),
                );
              },
            ),
          ),

          // Continue button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed:
                    _selectedVehicle != null ? _proceedToLoadDetails : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  loc.translate('next'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleInfo vehicle;
  final FareBreakdown fare;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.vehicle,
    required this.fare,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: isSelected ? 4 : 2,
      shadowColor: isSelected
          ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
          : Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle icon
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    vehicle.icon,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Vehicle details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vehicle.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Capacity and rate
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.scale,
                          label: '${vehicle.capacityTon} Ton',
                        ),
                        const SizedBox(width: 8),
                        _InfoChip(
                          icon: Icons.currency_rupee,
                          label: '${vehicle.ratePerKm.toInt()}/km',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Fare
                    Row(
                      children: [
                        Text(
                          '₹${fare.totalFare.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (fare.actualFare == fare.minimumFare)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Min fare',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[800],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estimated arrival: 15-20 min',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
