import 'package:flutter/material.dart';
import 'transport_booking_models.dart';

class TransportRatingScreen extends StatefulWidget {
  final TransportBooking booking;

  const TransportRatingScreen({super.key, required this.booking});

  @override
  State<TransportRatingScreen> createState() => _TransportRatingScreenState();
}

class _TransportRatingScreenState extends State<TransportRatingScreen> {
  int rating = 0;
  final feedbackController = TextEditingController();

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driver = widget.booking.driver!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'How was your trip?',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B3D2A)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your feedback helps us improve the service',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Driver Info
              Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color.fromRGBO(46, 125, 50, 0.1),
                    child: Text(driver.photo, style: const TextStyle(fontSize: 50)),
                  ),
                  const SizedBox(height: 16),
                  Text(driver.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(widget.booking.vehicle.name, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      size: 48,
                      color: index < rating ? Colors.amber : Colors.grey[300],
                    ),
                    onPressed: () => setState(() => rating = index + 1),
                  );
                }),
              ),
              
              const SizedBox(height: 32),
              
              TextField(
                controller: feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add feedback for the driver...',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              
              const SizedBox(height: 48),
              
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: rating == 0 ? null : () {
                    // Show final thank you and exit to dashboard
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thank you for your feedback!')),
                    );
                    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Submit Rating', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
