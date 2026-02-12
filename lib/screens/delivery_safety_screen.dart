import 'package:flutter/material.dart';

class DeliverySafetyScreen extends StatelessWidget {
  const DeliverySafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Center'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPanicButton(context),
            const SizedBox(height: 24),
            _buildEmergencyContacts(),
            const SizedBox(height: 24),
            _buildSafetyFeatures(),
            const SizedBox(height: 24),
            _buildSafetyTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildPanicButton(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Emergency Panic Button',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Emergency Alert'),
                    content: const Text(
                      'This will immediately notify:\n\n'
                      '• Your emergency contact\n'
                      '• Admin team\n'
                      '• Local authorities (if needed)\n'
                      '• Share your live location\n\n'
                      'Use only in genuine emergencies.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Emergency alert sent! Help is on the way.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('SEND ALERT'),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, color: Colors.white, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap and hold for 3 seconds in emergency',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Emergency Contacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildContactItem('Your Emergency Contact', 'Rajesh Kumar', '9876543211', Icons.person),
            _buildContactItem('Admin Support', '24/7 Available', '1800-123-4567', Icons.support_agent),
            _buildContactItem('Police', 'Emergency Services', '100', Icons.local_police),
            _buildContactItem('Ambulance', 'Medical Emergency', '102', Icons.local_hospital),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(String label, String name, String number, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withValues(alpha: 0.2),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(label),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 12)),
          Text(number, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.call, color: Colors.green),
        onPressed: () {},
      ),
    );
  }

  Widget _buildSafetyFeatures() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Safety Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            SwitchListTile(
              title: const Text('Real-time Location Sharing'),
              subtitle: const Text('Share your location with admin during deliveries'),
              value: true,
              onChanged: (val) {},
              secondary: const Icon(Icons.location_on, color: Colors.blue),
            ),
            SwitchListTile(
              title: const Text('Auto Check-in'),
              subtitle: const Text('Automatic safety check-ins every 30 minutes'),
              value: true,
              onChanged: (val) {},
              secondary: const Icon(Icons.access_time, color: Colors.orange),
            ),
            ListTile(
              leading: const Icon(Icons.verified_user, color: Colors.green),
              title: const Text('Verified Partner Badge'),
              subtitle: const Text('Police verification completed'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Safety Tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildTipItem('Always verify pickup and delivery addresses before starting'),
            _buildTipItem('Use OTP verification for secure handovers'),
            _buildTipItem('Keep emergency contacts updated in your profile'),
            _buildTipItem('Report any suspicious activities immediately'),
            _buildTipItem('Avoid dark or isolated areas during late deliveries'),
            _buildTipItem('Keep your vehicle well-maintained and fueled'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(tip)),
        ],
      ),
    );
  }
}
