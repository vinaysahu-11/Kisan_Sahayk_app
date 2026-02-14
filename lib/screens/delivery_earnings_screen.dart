import 'package:flutter/material.dart';
import '../services/delivery_service.dart';
import '../utils/app_localizations.dart';

class DeliveryEarningsScreen extends StatefulWidget {
  const DeliveryEarningsScreen({super.key});

  @override
  State<DeliveryEarningsScreen> createState() => _DeliveryEarningsScreenState();
}

class _DeliveryEarningsScreenState extends State<DeliveryEarningsScreen> {
  final _deliveryService = DeliveryService();
  String _selectedPeriod = 'Today';
  Map<String, dynamic>? _analytics;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    final partner = _deliveryService.getCurrentPartner();
    if (partner == null) return;

    DateTime? startDate;
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
    }

    setState(() {
      _analytics = _deliveryService.getPartnerAnalytics(partner.id, startDate: startDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final partner = _deliveryService.getCurrentPartner();
    if (partner == null) {
      return Scaffold(body: Center(child: Text(loc.translate('not_logged_in'))));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('earnings')),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 24),
            _buildEarningsSummary(),
            const SizedBox(height: 24),
            _buildEarningsBreakdown(),
            const SizedBox(height: 24),
            _buildMonthlyOverview(partner),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final loc = AppLocalizations.of(context)!;
    final periodLabels = {
      'Today': loc.translate('today'),
      'This Week': loc.translate('this_week'),
      'This Month': loc.translate('this_month'),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: periodLabels.entries.map((entry) {
            final selected = _selectedPeriod == entry.key;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Center(child: Text(entry.value)),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedPeriod = entry.key);
                    _loadAnalytics();
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEarningsSummary() {
    if (_analytics == null) return const SizedBox();
    final loc = AppLocalizations.of(context)!;

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(loc.translate('total_earnings'), style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              '₹${_analytics!['totalEarnings'].toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Deliveries', '${_analytics!['totalDeliveries']}'),
                _buildStatItem('Avg Earning', '₹${_analytics!['avgEarning'].toStringAsFixed(0)}'),
                _buildStatItem('Avg Distance', '${_analytics!['avgDistance'].toStringAsFixed(1)} KM'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildEarningsBreakdown() {
    if (_analytics == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildBreakdownRow('COD Orders', _analytics!['codOrders'], Icons.money, Colors.orange),
            _buildBreakdownRow('Online Orders', _analytics!['onlineOrders'], Icons.credit_card, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, int count, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(child: Text(label)),
          Text('$count', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMonthlyOverview(partner) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This Month Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildDetailRow('Total Earnings', '₹${partner.monthEarnings.toInt()}'),
            _buildDetailRow('Total Deliveries', '${partner.totalDeliveries}'),
            _buildDetailRow('Acceptance Rate', '${partner.acceptanceRate}%'),
            _buildDetailRow('On-Time Rate', '${partner.onTimeRate}%'),
            _buildDetailRow('Cancellation Rate', '${partner.cancellationRate}%'),
            _buildDetailRow('Rating', '${partner.rating}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
