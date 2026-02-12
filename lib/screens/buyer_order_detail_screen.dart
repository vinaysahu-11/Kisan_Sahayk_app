import 'package:flutter/material.dart';
import '../services/buyer_service.dart';
import '../models/buyer_models.dart';

class BuyerOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const BuyerOrderDetailScreen({super.key, required this.orderId});

  @override
  State<BuyerOrderDetailScreen> createState() => _BuyerOrderDetailScreenState();
}

class _BuyerOrderDetailScreenState extends State<BuyerOrderDetailScreen> {
  final _service = BuyerService();

  @override
  Widget build(BuildContext context) {
    final order = _service.getOrders().where((o) => o.id == widget.orderId).firstOrNull;
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details'), backgroundColor: const Color(0xFF2E7D32)),
        body: const Center(child: Text('Order not found')),
      );
    }

    final address = _service.getAddresses().where((a) => a.id == order.addressId).firstOrNull;
    final canCancel = order.status == BuyerOrderStatus.placed || order.status == BuyerOrderStatus.accepted;
    final canRate = order.status == BuyerOrderStatus.delivered && !order.isRated;
    final canReturn = order.status == BuyerOrderStatus.delivered && order.deliveredDate != null && DateTime.now().difference(order.deliveredDate!).inHours < 48;
    final canSimulate = order.status != BuyerOrderStatus.delivered && order.status != BuyerOrderStatus.completed && order.status != BuyerOrderStatus.cancelled && order.status != BuyerOrderStatus.returned;

    return Scaffold(
      appBar: AppBar(title: Text('Order #${order.id}'), backgroundColor: const Color(0xFF2E7D32)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_statusColor(order.status), _statusColor(order.status).withValues(alpha: 0.7)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_statusLabel(order.status), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(_statusDescription(order.status, order.paymentMode), style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Order Timeline
            const Text('Order Timeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _buildTimeline(order),
            const SizedBox(height: 20),

            // Product Info
            const Text('Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: const Color(0xFF2E7D32).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.agriculture, color: Color(0xFF2E7D32)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text('by ${order.sellerName}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          const SizedBox(height: 4),
                          Text('Qty: ${order.quantity} × ₹${order.productPrice.toInt()}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Details
            const Text('Payment Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _detailRow('Subtotal', '₹${order.subtotal.toInt()}'),
                    _detailRow('Delivery Fee', order.deliveryFee == 0 ? 'FREE' : '₹${order.deliveryFee.toInt()}'),
                    if (order.codCharge > 0) _detailRow('COD Charge', '₹${order.codCharge.toInt()}'),
                    _detailRow('Platform Fee', '₹${order.platformFee.toInt()}'),
                    if (order.walletUsed > 0) _detailRow('Wallet Used', '-₹${order.walletUsed.toInt()}', valueColor: Colors.green),
                    const Divider(),
                    _detailRow('Total', '₹${order.totalAmount.toInt()}', isBold: true),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(order.paymentMode == 'cod' ? Icons.money : Icons.credit_card, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text(order.paymentMode == 'cod' ? 'Cash on Delivery' : 'Online (Escrow)', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        if (order.paymentMode == 'online') ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: order.escrowReleased ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              order.escrowReleased ? 'Escrow Released' : 'Escrow Held',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: order.escrowReleased ? Colors.green : Colors.blue),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Delivery Address
            if (address != null) ...[
              const Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(address.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(address.fullAddress, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            Text('📞 ${address.mobile}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Actions
            if (canSimulate)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.fast_forward),
                  label: const Text('Simulate Next Step (Demo)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple,
                    side: const BorderSide(color: Colors.purple),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    _service.simulateOrderProgress(order.id);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order progressed to next step'), backgroundColor: Colors.purple),
                    );
                  },
                ),
              ),
            if (canSimulate) const SizedBox(height: 10),

            if (canRate)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.star, color: Colors.white),
                  label: const Text('Rate this Order', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/buyer-rating', arguments: order.id).then((_) => setState(() {})),
                ),
              ),
            if (canRate) const SizedBox(height: 10),

            if (canReturn)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.assignment_return),
                  label: const Text('Raise Return / Dispute'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/buyer-return', arguments: order.id).then((_) => setState(() {})),
                ),
              ),

            if (canCancel) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () => _showCancelDialog(context, order.id),
                  child: const Text('Cancel Order'),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(BuyerOrder order) {
    final allSteps = [
      BuyerOrderStatus.placed,
      BuyerOrderStatus.accepted,
      BuyerOrderStatus.packed,
      BuyerOrderStatus.shipped,
      BuyerOrderStatus.outForDelivery,
      BuyerOrderStatus.delivered,
    ];

    final currentIndex = allSteps.indexOf(order.status);
    final isCancelled = order.status == BuyerOrderStatus.cancelled;
    final isReturned = order.status == BuyerOrderStatus.returned;

    return Column(
      children: allSteps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final isDone = !isCancelled && !isReturned && (currentIndex >= i);
        final isActive = currentIndex == i && !isCancelled && !isReturned;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: isDone ? const Color(0xFF2E7D32) : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                  ),
                  if (i < allSteps.length - 1)
                    Container(width: 2, height: 30, color: isDone ? const Color(0xFF2E7D32) : Colors.grey[300]),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _statusLabel(step),
                      style: TextStyle(fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isDone ? Colors.black87 : Colors.grey[400], fontSize: 14),
                    ),
                    if (isActive) Text('Current status', style: TextStyle(fontSize: 11, color: Colors.green[700])),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _statusColor(BuyerOrderStatus status) {
    switch (status) {
      case BuyerOrderStatus.placed: return Colors.blue;
      case BuyerOrderStatus.accepted: return Colors.indigo;
      case BuyerOrderStatus.packed: return Colors.purple;
      case BuyerOrderStatus.shipped: return Colors.teal;
      case BuyerOrderStatus.outForDelivery: return Colors.orange;
      case BuyerOrderStatus.delivered: return const Color(0xFF2E7D32);
      case BuyerOrderStatus.completed: return const Color(0xFF2E7D32);
      case BuyerOrderStatus.cancelled: return Colors.red;
      case BuyerOrderStatus.returned: return Colors.brown;
    }
  }

  String _statusLabel(BuyerOrderStatus status) {
    switch (status) {
      case BuyerOrderStatus.placed: return 'Order Placed';
      case BuyerOrderStatus.accepted: return 'Accepted by Seller';
      case BuyerOrderStatus.packed: return 'Packed';
      case BuyerOrderStatus.shipped: return 'Shipped';
      case BuyerOrderStatus.outForDelivery: return 'Out for Delivery';
      case BuyerOrderStatus.delivered: return 'Delivered';
      case BuyerOrderStatus.completed: return 'Completed';
      case BuyerOrderStatus.cancelled: return 'Cancelled';
      case BuyerOrderStatus.returned: return 'Returned';
    }
  }

  String _statusDescription(BuyerOrderStatus status, String paymentMode) {
    switch (status) {
      case BuyerOrderStatus.placed: return 'Waiting for seller to accept your order';
      case BuyerOrderStatus.accepted: return 'Seller is preparing your order';
      case BuyerOrderStatus.packed: return 'Your order is packed and ready for pickup';
      case BuyerOrderStatus.shipped: return 'Your order is on the way';
      case BuyerOrderStatus.outForDelivery: return 'Your order will arrive today';
      case BuyerOrderStatus.delivered:
        return paymentMode == 'cod' ? 'Delivered! Pay cash to delivery partner' : 'Delivered! Escrow will be released to seller';
      case BuyerOrderStatus.completed: return 'Order completed successfully';
      case BuyerOrderStatus.cancelled: return 'Order was cancelled and refunded';
      case BuyerOrderStatus.returned: return 'Return has been processed';
    }
  }

  Widget _detailRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: isBold ? FontWeight.w700 : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500, color: valueColor ?? (isBold ? const Color(0xFF2E7D32) : Colors.grey[800]))),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text('Are you sure you want to cancel this order? Refund will be credited to your wallet for online payments.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _service.cancelOrder(orderId, 'Cancelled by buyer');
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order cancelled'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Cancel Order', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
