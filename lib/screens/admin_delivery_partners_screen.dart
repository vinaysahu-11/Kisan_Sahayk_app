import 'package:flutter/material.dart';
import '../models/delivery_models.dart';
import '../services/delivery_service.dart';
import '../utils/app_localizations.dart';

class AdminDeliveryPartnersScreen extends StatefulWidget {
  const AdminDeliveryPartnersScreen({super.key});

  @override
  State<AdminDeliveryPartnersScreen> createState() => _AdminDeliveryPartnersScreenState();
}

class _AdminDeliveryPartnersScreenState extends State<AdminDeliveryPartnersScreen> {
  final _deliveryService = DeliveryService();
  DeliveryPartnerStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    var partners = _deliveryService.getAllPartners();
    if (_filterStatus != null) {
      partners = partners.where((p) => p.status == _filterStatus).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('delivery_partners')),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: partners.isEmpty
                ? Center(child: Text(loc.translate('no_partners_found')))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: partners.length,
                    itemBuilder: (context, index) => _buildPartnerCard(context, partners[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('All'),
              selected: _filterStatus == null,
              onSelected: (_) => setState(() => _filterStatus = null),
            ),
            ...DeliveryPartnerStatus.values.map((status) => FilterChip(
                  label: Text(status.name),
                  selected: _filterStatus == status,
                  onSelected: (_) => setState(() => _filterStatus = status),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerCard(BuildContext context, DeliveryPartner partner) {
    final loc = AppLocalizations.of(context)!;
    final statusConfig = _getStatusConfig(partner.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusConfig['color'].withValues(alpha: 0.2),
          child: Icon(statusConfig['icon'], color: statusConfig['color']),
        ),
        title: Text(partner.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(partner.mobile),
            Text(
              statusConfig['label'],
              style: TextStyle(color: statusConfig['color'], fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: partner.isOnline
            ? const Icon(Icons.circle, color: Colors.green, size: 12)
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Email', partner.email),
                _buildDetailRow('Vehicle', '${partner.vehicleType.name.toUpperCase()} - ${partner.vehicleNumber}'),
                _buildDetailRow('Rating', '${partner.rating}⭐ (${partner.totalDeliveries} deliveries)'),
                _buildDetailRow('Acceptance Rate', '${partner.acceptanceRate}%'),
                _buildDetailRow('On-Time Rate', '${partner.onTimeRate}%'),
                _buildDetailRow('Cancellation Rate', '${partner.cancellationRate}%'),
                _buildDetailRow('Active Orders', '${partner.activeOrders}'),
                _buildDetailRow('Today Earnings', '₹${partner.todayEarnings.toInt()}'),
                _buildDetailRow('Month Earnings', '₹${partner.monthEarnings.toInt()}'),
                const Divider(),
                if (partner.status == DeliveryPartnerStatus.underReview) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _deliveryService.approvePartner(partner.id);
                            if (!context.mounted) return;
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${partner.name} approved')),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          icon: const Icon(Icons.check),
                          label: Text(loc.translate('approve')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final reason = await _showRejectDialog();
                              if (reason != null) {
                                await _deliveryService.rejectPartner(partner.id, reason);
                                if (!context.mounted) return;
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${partner.name} rejected')),
                                );
                              }
                            },
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                        ),
                      ),
                    ],
                  ),
                ],
                if (partner.status == DeliveryPartnerStatus.active) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      _deliveryService.blockPartner(partner.id);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${partner.name} blocked')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    icon: const Icon(Icons.block),
                    label: Text(loc.translate('block_partner')),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<String?> _showRejectDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application'),
        content: const Text('Please select rejection reason:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'Incomplete documents'),
            child: const Text('Incomplete documents'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Police verification failed'),
            child: const Text('Verification failed'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Duplicate application'),
            child: const Text('Duplicate application'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(DeliveryPartnerStatus status) {
    switch (status) {
      case DeliveryPartnerStatus.submitted:
        return {'icon': Icons.receipt_long, 'color': Colors.blue, 'label': 'Submitted'};
      case DeliveryPartnerStatus.underReview:
        return {'icon': Icons.hourglass_empty, 'color': Colors.orange, 'label': 'Under Review'};
      case DeliveryPartnerStatus.approved:
        return {'icon': Icons.check_circle, 'color': Colors.green, 'label': 'Approved'};
      case DeliveryPartnerStatus.active:
        return {'icon': Icons.verified, 'color': const Color(0xFF2E7D32), 'label': 'Active'};
      case DeliveryPartnerStatus.blocked:
        return {'icon': Icons.block, 'color': Colors.red, 'label': 'Blocked'};
      case DeliveryPartnerStatus.rejected:
        return {'icon': Icons.cancel, 'color': Colors.red, 'label': 'Rejected'};
    }
  }
}
