import 'dart:async';
import 'package:flutter/material.dart';
import 'transport_booking_models.dart';
import 'transport_payment_screen.dart';

class TransportLiveTrackingScreen extends StatefulWidget {
  final TransportBooking booking;

  const TransportLiveTrackingScreen({super.key, required this.booking});

  @override
  State<TransportLiveTrackingScreen> createState() => _TransportLiveTrackingScreenState();
}

class _TransportLiveTrackingScreenState extends State<TransportLiveTrackingScreen> {
  double progress = 0.0;
  late Timer _timer;
  BookingStatus currentStatus = BookingStatus.onTheWay;
  double currentFare = 0.0;

  @override
  void initState() {
    super.initState();
    currentFare = (widget.booking.fare ?? 0.0) * 0.5; // Start with half fare for demo
    _startTrackingSimulation();
  }

  void _startTrackingSimulation() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          if (progress < 1.0) {
            progress += 0.005;
            currentFare += 0.5; // Simulated meter
            
            // Update status based on progress
            if (progress > 0.95) {
              currentStatus = BookingStatus.delivered;
            } else if (progress > 0.0) {
              currentStatus = BookingStatus.onTheWay;
            }
          } else {
            _timer.cancel();
            _onTripCompleted();
          }
        });
      }
    });
  }

  void _onTripCompleted() {
    setState(() {
      currentStatus = BookingStatus.delivered;
      currentFare = widget.booking.fare ?? currentFare;
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TransportPaymentScreen(booking: widget.booking),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Simulated Full Screen Map
          _buildTrackingMap(),
          
          // Current Fare Floating Card
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Live Fare', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '₹${currentFare.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ),
          ),
          
          // Tracking Bottom Sheet
          _buildTrackingInfo(),
        ],
      ),
    );
  }

  Widget _buildTrackingMap() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Route Arc
            CustomPaint(
              size: const Size(300, 200),
              painter: _RoutePainter(progress),
            ),
            // Origin
            Positioned(
              top: 50,
              left: 50,
              child: _MapMarker(icon: Icons.circle, color: const Color(0xFF2E7D32), label: 'Pickup'),
            ),
            // Destination
            Positioned(
              bottom: 50,
              right: 50,
              child: _MapMarker(icon: Icons.location_on, color: Colors.red, label: 'Drop'),
            ),
            // Moving Vehicle is handled by the progress in the painter or a separate widget
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingInfo() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 20, offset: Offset(0, -4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF2E7D32).withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Text(widget.booking.vehicle.icon, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentStatus == BookingStatus.delivered ? 'Arrived at Destination' : 'On the Way',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B3D2A)),
                      ),
                      Text(
                        currentStatus == BookingStatus.delivered ? 'Please check your load' : 'Approximately 5 mins remaining',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Stepper
            _buildStatusStepper(),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Emergency / Support', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStepper() {
    final steps = ['Accepted', 'Arriving', 'Loading', 'En Route', 'Delivered'];
    int currentStepIndex = 3; // Default to En route
    
    if (currentStatus == BookingStatus.delivered) {
      currentStepIndex = 4;
    } else if (progress < 0.2) {
      currentStepIndex = 1; // Arriving
    } else if (progress < 0.4) {
      currentStepIndex = 2; // Loading
    } else {
      currentStepIndex = 3; // En route
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (index) {
        bool isCompleted = index < currentStepIndex;
        bool isCurrent = index == currentStepIndex;
        
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: index == 0 ? const SizedBox() : Container(height: 2, color: isCompleted ? const Color(0xFF2E7D32) : Colors.grey[300])),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent ? const Color(0xFF2E7D32) : Colors.white,
                      border: Border.all(color: isCompleted || isCurrent ? const Color(0xFF2E7D32) : Colors.grey[300]!),
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted 
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : isCurrent ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))) : null,
                  ),
                  Expanded(child: index == steps.length - 1 ? const SizedBox() : Container(height: 2, color: isCompleted ? const Color(0xFF2E7D32) : Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                steps[index],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? const Color(0xFF2E7D32) : Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _MapMarker({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 30),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  final double progress;
  _RoutePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E7D32).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path();
    path.moveTo(50, 50);
    path.quadraticBezierTo(size.width / 2, size.height / 2, size.width - 50, size.height - 50);
    
    canvas.drawPath(path, paint);

    // Draw active portion (simplified progress on path)
    // In a real app we would compute the metric of the path
    
    // Draw vehicle icon at progress point
    // Simplified for demo
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
