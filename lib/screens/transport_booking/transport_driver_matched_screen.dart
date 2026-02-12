import 'dart:async';
import 'package:flutter/material.dart';
import 'transport_booking_models.dart';
import 'transport_live_tracking_screen.dart';

class TransportDriverMatchedScreen extends StatefulWidget {
  final TransportBooking booking;

  const TransportDriverMatchedScreen({super.key, required this.booking});

  @override
  State<TransportDriverMatchedScreen> createState() => _TransportDriverMatchedScreenState();
}

class _TransportDriverMatchedScreenState extends State<TransportDriverMatchedScreen> {
  double driverPosition = 0.0;
  late Timer _timer;
  int etaSeconds = 180; // 3 minutes demo

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (etaSeconds > 0) {
            etaSeconds--;
            driverPosition += 0.005; // Simulate movement
          } else {
            _timer.cancel();
            _onDriverArrived();
          }
        });
      }
    });
  }

  void _onDriverArrived() {
    if (mounted) {
      widget.booking.status = BookingStatus.driverArriving;
      // Automatically navigate to live tracking after arrival
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TransportLiveTrackingScreen(booking: widget.booking),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.booking.driver == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: Stack(
        children: [
          // Simulated Map with Route
          _buildMapWithRoute(),
          
          // Back Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF1B3D2A)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          
          // Driver Info Bottom Sheet
          _buildDriverCard(),
        ],
      ),
    );
  }

  Widget _buildMapWithRoute() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Route line (simplified)
            Container(
              width: 300,
              height: 2,
              color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
            ),
            // Pickup point
            const Positioned(
              left: 40,
              child: Column(
                children: [
                  Icon(Icons.location_on, color: Color(0xFF2E7D32), size: 32),
                  Text('Pickup', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Moving Driver
            Positioned(
              right: 40 + (driverPosition * 200),
              child: Column(
                children: [
                  const Text('Driver', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  Transform.rotate(
                    angle: 1.57, // 90 degrees
                    child: Text(widget.booking.vehicle.icon, style: const TextStyle(fontSize: 32)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard() {
    final driver = widget.booking.driver!;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color.fromRGBO(46, 125, 50, 0.1),
                  child: Text(driver.photo, style: const TextStyle(fontSize: 30)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B3D2A)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(' ${driver.rating.toStringAsFixed(1)} • ', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(driver.vehicleNumber, style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('ETA', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '${(etaSeconds / 60).floor()}:${(etaSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Call',
                    icon: Icons.phone,
                    color: const Color(0xFF2E7D32),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: 'Track Live',
                    icon: Icons.navigation,
                    color: const Color(0xFF1B3D2A),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransportLiveTrackingScreen(booking: widget.booking),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  label: 'Cancel',
                  icon: Icons.close,
                  color: Colors.red[600]!,
                  onTap: () => Navigator.pop(context),
                  isSquare: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isSquare;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isSquare = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSquare) {
      return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}
