import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../models/transport_models.dart';
import '../services/transport_booking_service.dart';
import '../services/live_tracking_service.dart';


class TransportActiveBookingScreen extends StatefulWidget {
  final TransportBooking booking;

  const TransportActiveBookingScreen({
    super.key,
    required this.booking,
  });

  @override
  State<TransportActiveBookingScreen> createState() =>
      _TransportActiveBookingScreenState();
}

class _TransportActiveBookingScreenState
    extends State<TransportActiveBookingScreen> {
  final _bookingService = TransportBookingService();
  final _trackingService = LiveTrackingService();
  late TransportBooking _currentBooking;
  StreamSubscription<TransportBooking>? _bookingSubscription;
  StreamSubscription<LocationUpdate>? _locationSubscription;
  LocationUpdate? _currentLocation;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
    _subscribeToUpdates();
  }

  void _subscribeToUpdates() {
    // For now, just keep the current booking state
    // In production, implement WebSocket or polling for real-time updates
    
    // Start tracking when driver is assigned
    if (_currentBooking.status == BookingStatus.driverAssigned &&
        _currentBooking.assignedPartner != null) {
      _startTracking();
    }
  }

  void _startTracking() {
    if (_currentBooking.assignedPartner?.currentLocation != null) {
      _locationSubscription = _trackingService
          .startTracking(
            bookingId: _currentBooking.bookingId,
            partnerId: _currentBooking.assignedPartner!.id,
            startLocation: _currentBooking.assignedPartner!.currentLocation!,
            destination: _currentBooking.status == BookingStatus.driverArriving ||
                    _currentBooking.status == BookingStatus.driverAssigned
                ? _currentBooking.pickupLocation
                : _currentBooking.dropLocation,
          )
          .listen((location) {
        setState(() => _currentLocation = location);
      });
    }
  }

  void _simulateStatusChange(BookingStatus newStatus) {
    _bookingService.updateBookingStatus(_currentBooking.bookingId, newStatus.name);
  }

  void _cancelBooking() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('cancel_booking')),
        content: Text(
          AppLocalizations.of(context)!.translate('cancel_booking'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.translate('cancel_booking_no')),
          ),
          ElevatedButton(
            onPressed: () {
              _bookingService.updateBookingStatus(
                _currentBooking.bookingId,
                'cancelled',
              );
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(AppLocalizations.of(context)!.translate('cancel_booking_yes')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bookingSubscription?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('active_booking')),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Status indicator
          _StatusBar(status: _currentBooking.status),

          // Map view
          Container(
            height: 280,
            width: double.infinity,
            color: Colors.grey[200],
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Live Tracking',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_currentLocation != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.navigation,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${_currentLocation!.distanceToDestination.toStringAsFixed(1)} km away • ${_currentLocation!.etaMinutes} min',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_currentLocation != null)
                  Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_shipping,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Booking details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Driver info (if assigned)
                  if (_currentBooking.assignedPartner != null) ...[
                    _DriverCard(partner: _currentBooking.assignedPartner!),
                    const SizedBox(height: 16),
                  ],

                  // Trip info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Trip Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _TripDetailRow(
                          icon: Icons.radio_button_checked,
                          iconColor: const Color(0xFF2E7D32),
                          label: 'Pickup',
                          value: _currentBooking.pickupLocation.address,
                        ),
                        const SizedBox(height: 12),
                        _TripDetailRow(
                          icon: Icons.location_on,
                          iconColor: Colors.red,
                          label: 'Drop',
                          value: _currentBooking.dropLocation.address,
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoItem(
                                label: 'Distance',
                                value:
                                    '${_currentBooking.distance.toStringAsFixed(1)} km',
                                icon: Icons.route,
                              ),
                            ),
                            Expanded(
                              child: _InfoItem(
                                label: 'Fare',
                                value:
                                    '₹${_currentBooking.fareBreakdown.totalFare.toStringAsFixed(0)}',
                                icon: Icons.currency_rupee,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Load info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoItem(
                            label: 'Load Type',
                            value: _getLoadTypeLabel(_currentBooking.loadType),
                            icon: Icons.inventory_2_outlined,
                          ),
                        ),
                        Expanded(
                          child: _InfoItem(
                            label: 'Weight',
                            value:
                                '${_currentBooking.loadWeightTon.toStringAsFixed(1)} Ton',
                            icon: Icons.scale,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Demo buttons (remove in production)
                  if (_currentBooking.status != BookingStatus.completed &&
                      _currentBooking.status != BookingStatus.cancelled) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Demo Controls',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _getNextStatuses()
                                .map((status) => OutlinedButton(
                                      onPressed: () =>
                                          _simulateStatusChange(status),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        side: const BorderSide(
                                          color: Colors.orange,
                                        ),
                                      ),
                                      child: Text(
                                        _getStatusLabel(status),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Action buttons
          if (_currentBooking.status != BookingStatus.completed &&
              _currentBooking.status != BookingStatus.cancelled)
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
              child: Row(
                children: [
                  if (_currentBooking.status == BookingStatus.searching) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancelBooking,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(loc.translate('cancel')),
                      ),
                    ),
                  ] else if (_currentBooking.assignedPartner != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Call driver
                        },
                        icon: const Icon(Icons.call),
                      label: Text(loc.translate('call')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2E7D32),
                          side:
                              const BorderSide(color: Color(0xFF2E7D32)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Chat with driver
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                      label: Text(loc.translate('chat')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
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

  String _getStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.searching:
        return 'Searching';
      case BookingStatus.driverAssigned:
        return 'Driver Assigned';
      case BookingStatus.driverArriving:
        return 'Arriving';
      case BookingStatus.loadStarted:
        return 'Loading';
      case BookingStatus.inTransit:
        return 'In Transit';
      case BookingStatus.delivered:
        return 'Delivered';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  List<BookingStatus> _getNextStatuses() {
    switch (_currentBooking.status) {
      case BookingStatus.searching:
        return [BookingStatus.driverAssigned];
      case BookingStatus.driverAssigned:
        return [BookingStatus.driverArriving];
      case BookingStatus.driverArriving:
        return [BookingStatus.loadStarted];
      case BookingStatus.loadStarted:
        return [BookingStatus.inTransit];
      case BookingStatus.inTransit:
        return [BookingStatus.delivered];
      default:
        return [];
    }
  }
}

class _StatusBar extends StatelessWidget {
  final BookingStatus status;

  const _StatusBar({required this.status});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusInfo['color'].withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: statusInfo['color'].withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusInfo['color'],
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusInfo['icon'],
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusInfo['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: statusInfo['color'],
                  ),
                ),
                Text(
                  statusInfo['subtitle'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          if (status == BookingStatus.searching)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFF2E7D32)),
              ),
            ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(BookingStatus status) {
    switch (status) {
      case BookingStatus.searching:
        return {
          'title': 'Searching for Driver',
          'subtitle': 'Finding nearby partners...',
          'icon': Icons.search,
          'color': Colors.orange,
        };
      case BookingStatus.driverAssigned:
        return {
          'title': 'Driver Assigned',
          'subtitle': 'Driver is preparing to arrive',
          'icon': Icons.check_circle,
          'color': const Color(0xFF2E7D32),
        };
      case BookingStatus.driverArriving:
        return {
          'title': 'Driver Arriving',
          'subtitle': 'Driver is on the way to pickup',
          'icon': Icons.navigation,
          'color': Colors.blue,
        };
      case BookingStatus.loadStarted:
        return {
          'title': 'Loading in Progress',
          'subtitle': 'Driver is loading your goods',
          'icon': Icons.inventory_2,
          'color': Colors.purple,
        };
      case BookingStatus.inTransit:
        return {
          'title': 'In Transit',
          'subtitle': 'Your goods are on the way',
          'icon': Icons.local_shipping,
          'color': const Color(0xFF2E7D32),
        };
      case BookingStatus.delivered:
        return {
          'title': 'Delivered',
          'subtitle': 'Goods delivered successfully',
          'icon': Icons.done_all,
          'color': Colors.green,
        };
      case BookingStatus.completed:
        return {
          'title': 'Completed',
          'subtitle': 'Trip completed',
          'icon': Icons.check_circle,
          'color': Colors.green,
        };
      case BookingStatus.cancelled:
        return {
          'title': 'Cancelled',
          'subtitle': 'Booking was cancelled',
          'icon': Icons.cancel,
          'color': Colors.red,
        };
    }
  }
}

class _DriverCard extends StatelessWidget {
  final TransportPartner partner;

  const _DriverCard({required this.partner});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF2E7D32),
            child: Text(
              partner.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partner.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '${partner.rating}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${partner.totalTrips} trips',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  partner.vehicleNumber,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripDetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _TripDetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
