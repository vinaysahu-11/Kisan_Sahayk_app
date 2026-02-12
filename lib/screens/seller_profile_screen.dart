import 'package:flutter/material.dart';
import '../models/seller_models.dart';
import '../services/seller_service.dart';
import '../utils/app_localizations.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final _service = SellerService();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final seller = _service.getCurrentSeller();
    if (seller == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: const Color(0xFF2E7D32)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(loc.translate('product_not_found')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.translate('go_back')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('profile')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF2E7D32),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      seller.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      seller.mobile,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: seller.level == SellerLevel.basic
                            ? Colors.grey[200]
                            : Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            seller.level == SellerLevel.basic
                                ? Icons.store
                                : Icons.verified,
                            size: 16,
                            color: seller.level == SellerLevel.basic
                                ? Colors.grey[700]
                                : Colors.amber[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            seller.level == SellerLevel.basic
                                ? 'Basic Seller'
                                : 'Big Seller',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: seller.level == SellerLevel.basic
                                  ? Colors.grey[700]
                                  : Colors.amber[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    _InfoRow(label: 'Seller Type', value: _getSellerTypeName(seller.type)),
                    _InfoRow(label: 'Location', value: seller.location),
                    _InfoRow(label: 'Commission Rate', value: '${seller.commissionRate}%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // KYC Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'KYC Verification',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _KYCStatusBadge(status: seller.kycStatus),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (seller.kycStatus == KYCStatus.notSubmitted) ...[
                      Text(
                        'Complete your KYC to unlock Big Seller benefits',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _showKYCForm(context, seller.id),
                        icon: const Icon(Icons.upload_file),
                        label: Text(loc.translate('upload_kyc')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          minimumSize: const Size(double.infinity, 44),
                        ),
                      ),
                    ] else if (seller.kycStatus == KYCStatus.pending) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.hourglass_empty, color: Colors.orange[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your KYC is under review. You\'ll be notified once verified.',
                                style: TextStyle(fontSize: 13, color: Colors.orange[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (seller.kycStatus == KYCStatus.approved) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your KYC is verified. You can now upgrade to Big Seller.',
                                style: TextStyle(fontSize: 13, color: Colors.green[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (seller.kycStatus == KYCStatus.rejected) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.error, color: Colors.red[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'KYC Rejected',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Reason: Document not clear. Please resubmit with clear documents.',
                              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _showKYCForm(context, seller.id),
                        icon: const Icon(Icons.refresh),
                        label: Text(loc.translate('resubmit_kyc')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2E7D32),
                          minimumSize: const Size(double.infinity, 44),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Subscription Section
            if (seller.level == SellerLevel.basic &&
                seller.kycStatus == KYCStatus.approved) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upgrade to Big Seller',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Get exclusive benefits:',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      _BenefitTile(text: 'Lower commission rates (1-1.5%)'),
                      _BenefitTile(text: 'Priority listing in search results'),
                      _BenefitTile(text: 'Verified seller badge'),
                      _BenefitTile(text: 'Faster settlements'),
                      const SizedBox(height: 16),
                      _buildSubscriptionPlans(),
                    ],
                  ),
                ),
              ),
            ] else if (seller.level == SellerLevel.bigSeller) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subscription',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: seller.subscriptionStatus == SubscriptionStatus.active
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              seller.subscriptionStatus == SubscriptionStatus.active
                                  ? 'Active'
                                  : 'Expired',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: seller.subscriptionStatus == SubscriptionStatus.active
                                    ? Colors.green[700]
                                    : Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Expires On',
                        value: _formatDate(seller.subscriptionExpiry!),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Renew subscription
                          _buildSubscriptionPlans();
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(loc.translate('renew_subscription')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          minimumSize: const Size(double.infinity, 44),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlans() {
    final loc = AppLocalizations.of(context)!;
    final plans = _service.getSubscriptionPlans();

    return Column(
      children: plans.map((plan) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: Colors.grey[50],
          child: ListTile(
            title: Text(
              plan.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('₹${plan.price} • ${plan.durationDays} days • ${plan.commissionRate}% commission'),
            trailing: ElevatedButton(
              onPressed: () => _upgradeToBigSeller(plan.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: Text(loc.translate('subscribe')),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _upgradeToBigSeller(String planId) async {
    final loc = AppLocalizations.of(context)!;
    final seller = _service.getCurrentSeller();
    if (seller == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('confirm_subscription')),
        content: Text(loc.translate('confirm_upgrade_big_seller')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: Text(loc.translate('confirm')),
          ),
        ],
      ),
    );

    if (result == true) {
      await _service.upgradeToBigSeller(seller.id, planId);
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('successfully_upgraded')),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _showKYCForm(BuildContext context, String sellerId) async {
    final loc = AppLocalizations.of(context)!;
    final aadhaarController = TextEditingController();
    final panController = TextEditingController();
    final accountController = TextEditingController();
    final ifscController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('kyc_documents')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: aadhaarController,
                decoration: const InputDecoration(
                  labelText: 'Aadhaar Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 12,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: panController,
                decoration: const InputDecoration(
                  labelText: 'PAN Number',
                  border: OutlineInputBorder(),
                ),
                maxLength: 10,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: accountController,
                decoration: const InputDecoration(
                  labelText: 'Bank Account Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ifscController,
                decoration: const InputDecoration(
                  labelText: 'IFSC Code',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: Text(loc.translate('submit')),
          ),
        ],
      ),
    );

    if (result == true) {
      final kycDoc = KYCDocument(
        sellerId: sellerId,
        aadhaarNumber: aadhaarController.text,
        panNumber: panController.text,
        bankAccountNumber: accountController.text,
        ifscCode: ifscController.text,
        aadhaarPhoto: '',
        panPhoto: '',
        bankProof: '',
        submittedDate: DateTime.now(),
        status: KYCStatus.pending,
      );

      await _service.submitKYC(kycDoc);
      if (!context.mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('kyc_submitted')),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getSellerTypeName(SellerType type) {
    switch (type) {
      case SellerType.farmer:
        return 'Farmer';
      case SellerType.shop:
        return 'Shop/Store';
      case SellerType.mill:
        return 'Mill/Processing Unit';
      case SellerType.individual:
        return 'Individual Seller';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _KYCStatusBadge extends StatelessWidget {
  final KYCStatus status;

  const _KYCStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case KYCStatus.notSubmitted:
        color = Colors.grey;
        text = 'Not Submitted';
        break;
      case KYCStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case KYCStatus.approved:
        color = Colors.green;
        text = 'Approved';
        break;
      case KYCStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  final String text;

  const _BenefitTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
