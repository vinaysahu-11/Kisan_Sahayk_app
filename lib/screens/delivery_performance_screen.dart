import 'package:flutter/material.dart';
import '../services/delivery_service.dart';
import '../utils/app_localizations.dart';

class DeliveryPerformanceScreen extends StatelessWidget {
  const DeliveryPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final deliveryService = DeliveryService();
    final partner = deliveryService.getCurrentPartner();

    if (partner == null) {
      return Scaffold(body: Center(child: Text(loc.translate('not_logged_in'))));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('performance')),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallRating(partner.rating, partner.totalDeliveries),
            const SizedBox(height: 24),
            const Text('Performance Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildMetricCard(
              'Acceptance Rate',
              partner.acceptanceRate,
              Icons.check_circle,
              Colors.blue,
              'Orders accepted vs assigned',
            ),
            _buildMetricCard(
              'On-Time Delivery Rate',
              partner.onTimeRate,
              Icons.timer,
              Colors.green,
              'Deliveries completed on time',
            ),
            _buildMetricCard(
              'Cancellation Rate',
              partner.cancellationRate,
              Icons.cancel,
              Colors.red,
              'Orders cancelled after acceptance',
              isNegative: true,
            ),
            const SizedBox(height: 24),
            _buildImprovementTips(partner),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallRating(double rating, int totalDeliveries) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Overall Rating', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star, color: Colors.amber, size: 48),
              ],
            ),
            const SizedBox(height: 8),
            Text('Based on $totalDeliveries deliveries', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, int value, IconData icon, Color color, String description, {bool isNegative = false}) {
    final isGood = isNegative ? value < 5 : value >= 90;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.2),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Text(
                  '$value%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isGood ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey.shade300,
              color: isGood ? Colors.green : Colors.orange,
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementTips(partner) {
    final tips = <Map<String, String>>[];

    if (partner.acceptanceRate < 90) {
      tips.add({
        'title': 'Improve Acceptance Rate',
        'tip': 'Accept more orders to improve your acceptance rate. Higher rates get priority for new deliveries.',
      });
    }

    if (partner.onTimeRate < 95) {
      tips.add({
        'title': 'Improve On-Time Delivery',
        'tip': 'Plan your routes efficiently and start deliveries early to maintain high on-time rate.',
      });
    }

    if (partner.cancellationRate > 5) {
      tips.add({
        'title': 'Reduce Cancellations',
        'tip': 'Only accept orders you can complete. High cancellation rate affects your rating and assignment priority.',
      });
    }

    if (partner.rating < 4.5) {
      tips.add({
        'title': 'Improve Rating',
        'tip': 'Be courteous, handle packages carefully, and deliver on time to get better ratings from customers.',
      });
    }

    if (tips.isEmpty) {
      tips.add({
        'title': 'Excellent Performance!',
        'tip': 'You are performing exceptionally well. Keep up the great work to maintain your high ratings.',
      });
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Improvement Tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tip['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(tip['tip']!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
