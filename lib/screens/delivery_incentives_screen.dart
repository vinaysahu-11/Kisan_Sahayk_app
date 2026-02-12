import 'package:flutter/material.dart';
import '../services/delivery_service.dart';
import '../utils/app_localizations.dart';

class DeliveryIncentivesScreen extends StatelessWidget {
  const DeliveryIncentivesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final deliveryService = DeliveryService();
    final partner = deliveryService.getCurrentPartner();

    if (partner == null) {
      return Scaffold(body: Center(child: Text(loc.translate('not_logged_in'))));
    }

    final incentives = deliveryService.getIncentives(partner.id);
    final dailyTarget = deliveryService.dailyTargetDeliveries;
    final dailyBonus = deliveryService.dailyTargetBonus;

    // Simulate progress
    final todayDeliveries = 15; // In real app, calculate from today's completed orders
    final progress = (todayDeliveries / dailyTarget).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('incentives_rewards')),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDailyTargetCard(dailyTarget, dailyBonus, todayDeliveries, progress),
            const SizedBox(height: 24),
            _buildIncentiveTypes(),
            const SizedBox(height: 24),
            const Text('Earned Incentives', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (incentives.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.card_giftcard, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('No incentives earned yet', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...incentives.map((incentive) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getIncentiveColor(incentive.type).withValues(alpha: 0.2),
                        child: Icon(_getIncentiveIcon(incentive.type), color: _getIncentiveColor(incentive.type)),
                      ),
                      title: Text(_getIncentiveLabel(incentive.type)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(incentive.description),
                          Text(
                            '${incentive.earnedDate.day}/${incentive.earnedDate.month}/${incentive.earnedDate.year}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${incentive.amount.toInt()}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          if (incentive.claimed)
                            const Text(
                              'Claimed',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTargetCard(int target, double bonus, int current, double progress) {
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily Target',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '₹${bonus.toInt()}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Complete $target deliveries today to earn bonus',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$current / $target deliveries',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              color: Colors.purple,
              minHeight: 8,
            ),
            if (progress >= 1.0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.celebration, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Target Achieved! Bonus will be credited soon',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIncentiveTypes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Incentive Types', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildIncentiveTypeItem(
              'Daily Target',
              'Complete 20 deliveries in a day',
              '₹500',
              Icons.today,
              Colors.purple,
            ),
            _buildIncentiveTypeItem(
              'Weekly Bonus',
              'Complete 100+ deliveries in a week',
              '₹2000',
              Icons.calendar_month,
              Colors.blue,
            ),
            _buildIncentiveTypeItem(
              'On-Time Reward',
              'Maintain 95%+ on-time delivery rate',
              '₹1000',
              Icons.timer,
              Colors.orange,
            ),
            _buildIncentiveTypeItem(
              'Rating Reward',
              'Maintain 4.5+ star rating',
              '₹800',
              Icons.star,
              Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncentiveTypeItem(String title, String description, String reward, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
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
          Text(reward, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  IconData _getIncentiveIcon(String type) {
    switch (type) {
      case 'daily_target':
        return Icons.today;
      case 'weekly_bonus':
        return Icons.calendar_month;
      case 'ontime_reward':
        return Icons.timer;
      case 'rating_reward':
        return Icons.star;
      default:
        return Icons.card_giftcard;
    }
  }

  Color _getIncentiveColor(String type) {
    switch (type) {
      case 'daily_target':
        return Colors.purple;
      case 'weekly_bonus':
        return Colors.blue;
      case 'ontime_reward':
        return Colors.orange;
      case 'rating_reward':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _getIncentiveLabel(String type) {
    switch (type) {
      case 'daily_target':
        return 'Daily Target Bonus';
      case 'weekly_bonus':
        return 'Weekly Bonus';
      case 'ontime_reward':
        return 'On-Time Reward';
      case 'rating_reward':
        return 'Rating Reward';
      default:
        return 'Incentive';
    }
  }
}
