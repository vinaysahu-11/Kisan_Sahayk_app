import 'package:flutter/material.dart';

import '../../utils/app_localizations.dart';
import 'labour_document_verification.dart';

class LabourWorkDetails extends StatefulWidget {
  const LabourWorkDetails({super.key});

  @override
  State<LabourWorkDetails> createState() => _LabourWorkDetailsState();
}

class _LabourWorkDetailsState extends State<LabourWorkDetails> {
  final dailyWageController = TextEditingController();
  final halfDayWageController = TextEditingController();
  String workRadius = '10km';
  String availableTime = 'Full Day';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('Work Details', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            // Daily Wage
            const Text(
              'Expected Daily Wage (₹)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: dailyWageController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.currency_rupee, size: 24),
                hintText: 'Enter daily wage',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Half Day Wage
            const Text(
              'Half Day Wage (₹) - Optional',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: halfDayWageController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.currency_rupee, size: 24),
                hintText: 'Half day wage',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Work Area Radius
            const Text(
              'Work Area Radius',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(child: _buildRadiusButton('5km')),
                const SizedBox(width: 12),
                Expanded(child: _buildRadiusButton('10km')),
                const SizedBox(width: 12),
                Expanded(child: _buildRadiusButton('20km')),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Available Time
            const Text(
              'Available Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Column(
              children: [
                _buildTimeOption('Morning'),
                const SizedBox(height: 12),
                _buildTimeOption('Full Day'),
                const SizedBox(height: 12),
                _buildTimeOption('Flexible'),
              ],
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LabourDocumentVerification()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(loc.translate('next'), style: const TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusButton(String radius) {
    final isSelected = workRadius == radius;
    return GestureDetector(
      onTap: () => setState(() => workRadius = radius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            radius,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeOption(String time) {
    final isSelected = availableTime == time;
    return GestureDetector(
      onTap: () => setState(() => availableTime = time),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade600,
              size: 28,
            ),
            const SizedBox(width: 16),
            Text(
              time,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
