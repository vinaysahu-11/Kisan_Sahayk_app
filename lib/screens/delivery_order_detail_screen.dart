import 'package:flutter/material.dart';
import '../models/delivery_models.dart';
import '../services/delivery_service.dart';
import '../utils/app_localizations.dart';

class DeliveryOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const DeliveryOrderDetailScreen({super.key, required this.orderId});

  @override
  State<DeliveryOrderDetailScreen> createState() => _DeliveryOrderDetailScreenState();
}

class _DeliveryOrderDetailScreenState extends State<DeliveryOrderDetailScreen> {
  final _deliveryService = DeliveryService();
  final _otpController = TextEditingController();
  DeliveryOrder? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _loadOrder() {
    setState(() {
      _order = _deliveryService.getOrder(widget.orderId);
      _isLoading = false;
    });
  }

  Future<void> _acceptOrder() async {
    final success = await _deliveryService.acceptOrder(widget.orderId);
    if (success && mounted) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('order_accepted'))),
      );
      _loadOrder();
    }
  }

  Future<void> _rejectOrder() async {
    final loc = AppLocalizations.of(context)!;
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('reject_order')),
        content: Text(loc.translate('select_rejection_reason')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'Too far'),
            child: Text(loc.translate('too_far')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Vehicle not suitable'),
            child: Text(loc.translate('vehicle_issue')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Personal reason'),
            child: Text(loc.translate('personal')),
          ),
        ],
      ),
    );

    if (reason != null) {
      await _deliveryService.rejectOrder(widget.orderId, reason);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _updateStatus(DeliveryStatus newStatus, {bool needsOTP = false}) async {
    final loc = AppLocalizations.of(context)!;
    if (needsOTP) {
      final otp = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(loc.translate('verify')),
          content: TextField(
            controller: _otpController,
            decoration: InputDecoration(
              labelText: loc.translate('verify'),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            maxLength: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, _otpController.text),
              child: Text(loc.translate('verify')),
            ),
          ],
        ),
      );

      if (otp == null || otp.isEmpty) return;

      final success = await _deliveryService.updateOrderStatus(widget.orderId, newStatus, otp: otp);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to ${newStatus.name}')),
        );
        _loadOrder();
        if (newStatus == DeliveryStatus.completed) {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('invalid_otp_action_failed'))),
        );
      }
    } else {
      final success = await _deliveryService.updateOrderStatus(widget.orderId, newStatus);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to ${newStatus.name}')),
        );
        _loadOrder();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('action_failed'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_isLoading || _order == null) {
      return Scaffold(body: Center(child: Text(loc.translate('loading'))));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${_order!.id}'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusTimeline(),
            const SizedBox(height: 24),
            _buildLocationCard(loc.translate('pickup'), _order!.pickupLocation, _order!.pickupAddress, _order!.pickupPhone),
            const SizedBox(height: 16),
            _buildLocationCard(loc.translate('deliver'), _order!.dropLocation, _order!.dropAddress, _order!.dropPhone),
            const SizedBox(height: 24),
            _buildOrderDetails(),
            const SizedBox(height: 24),
            _buildEarningBreakdown(),
            const SizedBox(height: 24),
            _buildOTPSection(loc),
            const SizedBox(height: 24),
            _buildActionButtons(loc),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delivery Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTimelineItem('Assigned', _order!.assignedAt, true),
            _buildTimelineItem('Accepted', _order!.acceptedAt, _order!.acceptedAt != null),
            _buildTimelineItem('Picked Up', _order!.pickedAt, _order!.pickedAt != null),
            _buildTimelineItem('Delivered', _order!.deliveredAt, _order!.deliveredAt != null),
            _buildTimelineItem('Completed', _order!.completedAt, _order!.completedAt != null),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, DateTime? date, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                Text(title, style: TextStyle(fontWeight: completed ? FontWeight.bold : FontWeight.normal)),
                if (date != null)
                  Text(
                    '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(String title, String name, String address, String phone) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                Expanded(child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 4),
            Text(address),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(phone),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildDetailRow('Distance', '${_order!.distance.toStringAsFixed(1)} KM'),
            _buildDetailRow('Payment Mode', _order!.paymentMode),
            if (_order!.isCOD) _buildDetailRow('COD Amount', '₹${_order!.codAmount.toInt()}'),
            _buildDetailRow('Buyer Order ID', _order!.buyerOrderId),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningBreakdown() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Earning Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildEarningRow('Base Fee', _order!.baseFee),
            _buildEarningRow('Distance Bonus', _order!.distanceBonus),
            if (_order!.heavyItemBonus > 0) _buildEarningRow('Heavy Item Bonus', _order!.heavyItemBonus),
            if (_order!.codFee > 0) _buildEarningRow('COD Fee', _order!.codFee),
            if (_order!.surgeBonus > 0) _buildEarningRow('Surge Bonus', _order!.surgeBonus),
            const Divider(),
            _buildEarningRow('Total Earning', _order!.totalEarning, bold: true),
            _buildEarningRow('Platform Commission', -_order!.commission, color: Colors.red),
            const Divider(),
            _buildEarningRow('Net Earning', _order!.netEarning, bold: true, large: true, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildOTPSection(AppLocalizations loc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('OTP Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ListTile(
              leading: Icon(
                _order!.pickupOTPVerified ? Icons.check_circle : Icons.lock,
                color: _order!.pickupOTPVerified ? Colors.green : Colors.orange,
              ),
              title: Text(loc.translate('pickup_otp')),
              subtitle: Text(_order!.pickupOTP ?? ''),
              trailing: _order!.pickupOTPVerified
                  ? const Text('Verified', style: TextStyle(color: Colors.green))
                  : null,
            ),
            ListTile(
              leading: Icon(
                _order!.deliveryOTPVerified ? Icons.check_circle : Icons.lock,
                color: _order!.deliveryOTPVerified ? Colors.green : Colors.orange,
              ),
              title: Text(loc.translate('delivery_otp')),
              subtitle: Text(_order!.deliveryOTP ?? ''),
              trailing: _order!.deliveryOTPVerified
                  ? const Text('Verified', style: TextStyle(color: Colors.green))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations loc) {
    final status = _order!.status;
    return Column(
      children: [
        if (status == DeliveryStatus.assigned) ...[
          ElevatedButton(
            onPressed: _acceptOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(loc.translate('accept_order')),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _rejectOrder,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(loc.translate('reject_order')),
          ),
        ],
        if (status == DeliveryStatus.accepted)
          ElevatedButton(
            onPressed: () => _updateStatus(DeliveryStatus.reachedPickup),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(loc.translate('reached_pickup')),
          ),
        if (status == DeliveryStatus.reachedPickup)
          ElevatedButton(
            onPressed: () => _updateStatus(DeliveryStatus.pickedUp, needsOTP: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(loc.translate('confirm_pickup_otp')),
          ),
        if (status == DeliveryStatus.pickedUp)
          ElevatedButton(
            onPressed: () => _updateStatus(DeliveryStatus.reachedCustomer),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(loc.translate('reached_delivery')),
          ),
        if (status == DeliveryStatus.reachedCustomer)
          ElevatedButton(
            onPressed: () => _updateStatus(DeliveryStatus.delivered, needsOTP: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(loc.translate('confirm_delivery_otp')),
          ),
      ],
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

  Widget _buildEarningRow(String label, double amount, {bool bold = false, bool large = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: large ? 16 : 14,
              color: color,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: large ? 16 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
