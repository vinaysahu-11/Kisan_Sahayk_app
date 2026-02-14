import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../models/transport_models.dart';
import '../services/transport_booking_service.dart';
import 'transport_active_booking_screen.dart';

class TransportFareBreakdownScreen extends StatefulWidget {
  final Location pickupLocation;
  final Location dropLocation;
  final double distance;
  final VehicleInfo vehicleInfo;
  final LoadType loadType;
  final double loadWeightTon;
  final String? loadNotes;
  final BookingType bookingType;
  final DateTime? scheduledTime;

  const TransportFareBreakdownScreen({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
    required this.distance,
    required this.vehicleInfo,
    required this.loadType,
    required this.loadWeightTon,
    this.loadNotes,
    required this.bookingType,
    this.scheduledTime,
  });

  @override
  State<TransportFareBreakdownScreen> createState() =>
      _TransportFareBreakdownScreenState();
}

class _TransportFareBreakdownScreenState
    extends State<TransportFareBreakdownScreen> {
  final _bookingService = TransportBookingService();
  Map<String, dynamic>? _fareBreakdown;
  bool _isBooking = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateFare();
  }

  Future<void> _calculateFare() async {
    try {
      final fare = await _bookingService.calculateFare(
        vehicleType: widget.vehicleInfo.type.name,
        distance: widget.distance,
        loadWeight: widget.loadWeightTon,
      );
      setState(() {
        _fareBreakdown = fare;
        _isLoading = false;
      });
    } catch (e) {
      print('Calculate fare error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmBooking() async {
    if (_fareBreakdown == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.translate('fare_calculation_failed')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      final result = await _bookingService.createBooking(
        vehicleType: widget.vehicleInfo.type.name,
        loadType: widget.loadType.name,
        loadWeight: widget.loadWeightTon,
        pickupLocation: {
          'latitude': widget.pickupLocation.latitude,
          'longitude': widget.pickupLocation.longitude,
          'address': widget.pickupLocation.address,
        },
        dropLocation: {
          'latitude': widget.dropLocation.latitude,
          'longitude': widget.dropLocation.longitude,
          'address': widget.dropLocation.address,
        },
        distance: widget.distance,
        scheduledDate: widget.scheduledTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
        fare: _fareBreakdown!,
        notes: widget.loadNotes,
      );

      if (mounted) {
        // Navigate to active booking screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => TransportActiveBookingScreen(
              booking: TransportBooking.fromJson(result['booking']),
            ),
          ),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.translate('booking_failed')),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isBooking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    if (_isLoading || _fareBreakdown == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.translate('confirm_booking')),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('confirm_booking')),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip details
                  _SectionTitle(title: 'Trip Details'),
                  const SizedBox(height: 12),
                  _DetailCard(
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.radio_button_checked,
                          iconColor: const Color(0xFF2E7D32),
                          label: 'Pickup',
                          value: widget.pickupLocation.address,
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.location_on,
                          iconColor: Colors.red,
                          label: 'Drop',
                          value: widget.dropLocation.address,
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.route,
                          iconColor: Colors.blue,
                          label: 'Distance',
                          value: '${widget.distance.toStringAsFixed(1)} km',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Vehicle details
                  _SectionTitle(title: 'Vehicle & Load'),
                  const SizedBox(height: 12),
                  _DetailCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.vehicleInfo.icon,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.vehicleInfo.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Capacity: ${widget.vehicleInfo.capacityTon} Ton',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.inventory_2_outlined,
                          iconColor: Colors.orange,
                          label: 'Load Type',
                          value: _getLoadTypeLabel(widget.loadType),
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.scale,
                          iconColor: Colors.purple,
                          label: 'Load Weight',
                          value: '${widget.loadWeightTon.toStringAsFixed(1)} Ton',
                        ),
                        if (widget.bookingType == BookingType.scheduled) ...[
                          const Divider(height: 24),
                          _DetailRow(
                            icon: Icons.schedule,
                            iconColor: Colors.teal,
                            label: 'Scheduled',
                            value: widget.scheduledTime != null
                                ? '${widget.scheduledTime!.day}/${widget.scheduledTime!.month} at ${widget.scheduledTime!.hour}:${widget.scheduledTime!.minute.toString().padLeft(2, '0')}'
                                : 'Not set',
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Fare breakdown
                  _SectionTitle(title: loc.translate('fare_breakdown')),
                  const SizedBox(height: 12),
                  _DetailCard(
                    child: Column(
                      children: [
                        _FareRow(
                          label: 'Base Fare',
                          value: '${widget.distance.toStringAsFixed(1)} km × ₹${(_fareBreakdown!['baseFare'] ?? 0).toStringAsFixed(0)}',
                          amount: (_fareBreakdown!['baseFare'] ?? 0).toDouble(),
                        ),
                        const Divider(height: 16),
                        _FareRow(
                          label: 'GST',
                          value: '',
                          amount: (_fareBreakdown!['gst'] ?? 0).toDouble(),
                        ),
                        const Divider(height: 16, thickness: 2),
                        _FareRow(
                          label: 'Total Amount',
                          value: '',
                          amount: (_fareBreakdown!['totalFare'] ?? 0).toDouble(),
                          isBold: true,
                          color: const Color(0xFF2E7D32),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Payment will be collected after delivery. Multiple payment options available.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confirm button
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.translate('total'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₹${(_fareBreakdown!['totalFare'] ?? 0).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isBooking ? null : _confirmBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isBooking
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            loc.translate('confirm_booking'),
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
        ],
      ),
    );
  }

  String _getLoadTypeLabel(LoadType type) {
    switch (type) {
      case LoadType.crop:
        return 'Crop';
      case LoadType.fertilizer:
        return 'Fertilizer';
      case LoadType.equipment:
        return 'Equipment';
      case LoadType.other:
        return 'Other';
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final Widget child;

  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final String value;
  final double amount;
  final bool isBold;
  final Color? color;

  const _FareRow({
    required this.label,
    required this.value,
    required this.amount,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isBold ? 15 : 14,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                  color: color ?? Colors.black87,
                ),
              ),
              if (value.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
