import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_localizations.dart';
import 'transport_partner_dashboard.dart';

class ApplicationStatusScreen extends StatefulWidget {
  final String partnerType;
  const ApplicationStatusScreen({super.key, required this.partnerType});

  @override
  State<ApplicationStatusScreen> createState() => _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState extends State<ApplicationStatusScreen> {
  bool simulateApproval = false;

  Future<void> _approveManually() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${widget.partnerType}_partner_status', 'approved');
    
    if (mounted) {
      if (widget.partnerType == 'transport') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TransportPartnerDashboardScreen()),
        );
      }
    }
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
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9C4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.pending_actions, size: 60, color: Color(0xFFF57C00)),
                  const SizedBox(height: 16),
                  const Text(
                    'Application Submitted',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Under Review',
                    style: TextStyle(fontSize: 18, color: Color(0xFFF57C00)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusStep('Submitted', true),
                _buildStatusStep('Reviewing', true),
                _buildStatusStep('Approved', false),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Your application is being reviewed by our team. You will be notified once approved.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            // Demo approval button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                children: [
                  const Text(
                    '🎮 DEMO MODE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap below to simulate approval'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _approveManually,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text(loc.translate('approve_now_demo'), style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStep(String label, bool completed) {
    return Column(
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.circle_outlined,
          color: completed ? Colors.green : Colors.grey,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: completed ? Colors.green : Colors.grey)),
      ],
    );
  }
}
