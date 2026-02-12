import 'package:flutter/material.dart';
import '../../utils/app_localizations.dart';

class TripProgressScreen extends StatefulWidget {
  const TripProgressScreen({super.key});

  @override
  State<TripProgressScreen> createState() => _TripProgressScreenState();
}

class _TripProgressScreenState extends State<TripProgressScreen> {
  int currentStep = 0;
  final List<String> steps = ['Accepted', 'Reached Pickup', 'Load Confirmed', 'Delivery Completed'];

  void _nextStep() {
    if (currentStep < steps.length - 1) {
      setState(() => currentStep++);
    } else {
      _completeTrip();
    }
  }

  void _completeTrip() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('trip_completed')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 16),
            Text('₹850 credited to your wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(loc.translate('trip_in_progress'), style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ...List.generate(steps.length, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep;
              return Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : (isCurrent ? Icons.radio_button_checked : Icons.circle_outlined),
                        color: isCompleted || isCurrent ? Colors.green : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        steps[index],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCompleted || isCurrent ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (index < steps.length - 1)
                    Container(
                      margin: const EdgeInsets.only(left: 15, top: 8, bottom: 8),
                      width: 2,
                      height: 40,
                      color: isCompleted ? Colors.green : Colors.grey[300],
                    ),
                ],
              );
            }),
            const Spacer(),
            if (currentStep < steps.length)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    currentStep == steps.length - 1 ? 'Mark Completed' : 'Next Step',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
