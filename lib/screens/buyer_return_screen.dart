import 'package:flutter/material.dart';
import '../services/buyer_service.dart';

class BuyerReturnScreen extends StatefulWidget {
  final String orderId;

  const BuyerReturnScreen({super.key, required this.orderId});

  @override
  State<BuyerReturnScreen> createState() => _BuyerReturnScreenState();
}

class _BuyerReturnScreenState extends State<BuyerReturnScreen> {
  final _service = BuyerService();
  String? _selectedReason;
  final _detailsCtrl = TextEditingController();
  bool _submitted = false;

  final _reasons = [
    'Wrong product received',
    'Damaged / broken product',
    'Quality not as described',
    'Quantity mismatch',
    'Expired product',
    'Not as shown',
    'Other',
  ];

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = _service.getOrders().where((o) => o.id == widget.orderId).firstOrNull;
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Return / Dispute'), backgroundColor: const Color(0xFF2E7D32)),
        body: const Center(child: Text('Order not found')),
      );
    }

    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Return Raised'), backgroundColor: const Color(0xFF2E7D32)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.orange, size: 72),
                const SizedBox(height: 16),
                const Text('Return Request Raised', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('We\'ll review your request and get back to you within 24-48 hours.', style: TextStyle(color: Colors.grey[600], fontSize: 14), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Return / Dispute'), backgroundColor: const Color(0xFF2E7D32)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(color: const Color(0xFF2E7D32).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.agriculture, color: Color(0xFF2E7D32)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('Order #${order.id} • ₹${order.totalAmount.toInt()}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Return window notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.timer, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Return window: 48 hours after delivery', style: TextStyle(fontSize: 13, color: Colors.orange[700]))),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Reason
            const Text('Reason for Return', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            RadioGroup<String>(
              groupValue: _selectedReason,
              onChanged: (v) => setState(() => _selectedReason = v),
              child: Column(
                children: _reasons.map((r) => RadioListTile<String>(
                  value: r,
                  activeColor: const Color(0xFF2E7D32),
                  title: Text(r, style: const TextStyle(fontSize: 14)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Details
            const Text('Additional Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _detailsCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the issue in detail...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            Text('Providing clear details helps us resolve your issue faster.', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 24),

            // Refund Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Refund will be credited to your wallet after approval', style: TextStyle(fontSize: 13, color: Colors.blue[700]))),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _selectedReason != null ? () {
                  _service.raiseReturn(
                    orderId: order.id,
                    reason: _selectedReason!,
                    details: _detailsCtrl.text.trim(),
                  );
                  setState(() => _submitted = true);
                } : null,
                child: const Text('Submit Return Request', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
