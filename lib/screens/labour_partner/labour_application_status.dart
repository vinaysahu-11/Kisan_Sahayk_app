import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_localizations.dart';
import 'labour_partner_dashboard.dart';

class LabourApplicationStatusScreen extends StatefulWidget {
  const LabourApplicationStatusScreen({super.key});

  @override
  State<LabourApplicationStatusScreen> createState() => _LabourApplicationStatusScreenState();
}

class _LabourApplicationStatusScreenState extends State<LabourApplicationStatusScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-approve after 5 seconds for demo
    Future.delayed(const Duration(seconds: 5), () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('labour_partner_status', 'approved');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LabourPartnerDashboardScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(loc.translate('application_status'), style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Icon
            Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_empty,
                size: 80,
                color: Color(0xFFFF9800),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Under Review',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF9800),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              loc.translate('registration_submitted'),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Your profile is under admin verification.\nYou will be notified once approved.',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700, height: 1.5),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Progress Steps
            _buildProgressStep('Submitted', true, true),
            _buildProgressLine(true),
            _buildProgressStep('Under Review', true, false),
            _buildProgressLine(false),
            _buildProgressStep('Approved', false, false),
            
            const SizedBox(height: 40),
            
            // Demo: Manual Approve Button (for testing)
            OutlinedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('labour_partner_status', 'approved');
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LabourPartnerDashboardScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Demo: Approve Now',
                style: TextStyle(fontSize: 16, color: Color(0xFF2E7D32)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(String title, bool isCompleted, bool isCurrent) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFF2E7D32) : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.circle,
            color: Colors.white,
            size: isCompleted ? 24 : 12,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCompleted ? const Color(0xFF2E7D32) : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(left: 19, top: 8, bottom: 8),
      width: 2,
      height: 30,
      color: isCompleted ? const Color(0xFF2E7D32) : Colors.grey.shade300,
    );
  }
}
