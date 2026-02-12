import 'package:flutter/material.dart';
import '../models/delivery_models.dart';
import '../services/delivery_service.dart';
import '../utils/app_localizations.dart';

class DeliveryApplicationStatusScreen extends StatelessWidget {
  const DeliveryApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final partner = DeliveryService().getCurrentPartner();

    if (partner == null) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.translate('application_status'))),
        body: Center(child: Text(loc.translate('no_application_found'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('application_status')),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(partner),
            const SizedBox(height: 24),
            _buildTimeline(partner),
            const SizedBox(height: 24),
            if (partner.status == DeliveryPartnerStatus.rejected)
              _buildRejectionCard(partner),
            if (partner.status == DeliveryPartnerStatus.approved ||
                partner.status == DeliveryPartnerStatus.active)
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/delivery-dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(loc.translate('go_to_dashboard')),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(DeliveryPartner partner) {
    final statusConfig = _getStatusConfig(partner.status);
    return Card(
      color: statusConfig['color'],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(statusConfig['icon'], size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              statusConfig['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusConfig['message'],
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(DeliveryPartner partner) {
    final steps = [
      {
        'title': 'Application Submitted',
        'date': partner.registeredDate,
        'completed': true,
      },
      {
        'title': 'Under Review',
        'date': partner.status == DeliveryPartnerStatus.underReview ? DateTime.now() : null,
        'completed': partner.status == DeliveryPartnerStatus.underReview ||
            partner.status == DeliveryPartnerStatus.approved ||
            partner.status == DeliveryPartnerStatus.active,
      },
      {
        'title': 'Approved',
        'date': partner.approvedDate,
        'completed': partner.status == DeliveryPartnerStatus.approved ||
            partner.status == DeliveryPartnerStatus.active,
      },
      {
        'title': 'Active',
        'date': partner.status == DeliveryPartnerStatus.active ? DateTime.now() : null,
        'completed': partner.status == DeliveryPartnerStatus.active,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Application Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...steps.map((step) => _buildTimelineStep(
                  step['title'] as String,
                  step['date'] as DateTime?,
                  step['completed'] as bool,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(String title, DateTime? date, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: completed ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (date != null)
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionCard(DeliveryPartner partner) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rejection Reason:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(partner.rejectionReason ?? 'No reason provided'),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(DeliveryPartnerStatus status) {
    switch (status) {
      case DeliveryPartnerStatus.submitted:
        return {
          'icon': Icons.receipt_long,
          'color': Colors.blue,
          'title': 'Application Submitted',
          'message': 'Your application has been received successfully',
        };
      case DeliveryPartnerStatus.underReview:
        return {
          'icon': Icons.hourglass_empty,
          'color': Colors.orange,
          'title': 'Under Review',
          'message': 'Our team is reviewing your application',
        };
      case DeliveryPartnerStatus.approved:
        return {
          'icon': Icons.check_circle,
          'color': Colors.green,
          'title': 'Approved!',
          'message': 'Congratulations! Your application has been approved',
        };
      case DeliveryPartnerStatus.active:
        return {
          'icon': Icons.verified,
          'color': const Color(0xFF2E7D32),
          'title': 'Active',
          'message': 'You can now start accepting deliveries',
        };
      case DeliveryPartnerStatus.blocked:
        return {
          'icon': Icons.block,
          'color': Colors.red,
          'title': 'Account Blocked',
          'message': 'Your account has been temporarily blocked',
        };
      case DeliveryPartnerStatus.rejected:
        return {
          'icon': Icons.cancel,
          'color': Colors.red,
          'title': 'Application Rejected',
          'message': 'We are unable to approve your application at this time',
        };
    }
  }
}
