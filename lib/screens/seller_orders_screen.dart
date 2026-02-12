import 'package:flutter/material.dart';
import '../models/seller_models.dart';
import '../services/seller_service.dart';
import '../utils/app_localizations.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final _service = SellerService();
  OrderStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final seller = _service.getCurrentSeller();
    if (seller == null) return const Scaffold();

    final orders = _service.getSellerOrders(seller.id, status: _selectedStatus);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('orders')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedStatus == null,
                  onTap: () => setState(() => _selectedStatus = null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'New',
                  isSelected: _selectedStatus == OrderStatus.placed,
                  onTap: () => setState(() => _selectedStatus = OrderStatus.placed),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Accepted',
                  isSelected: _selectedStatus == OrderStatus.accepted,
                  onTap: () => setState(() => _selectedStatus = OrderStatus.accepted),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Shipped',
                  isSelected: _selectedStatus == OrderStatus.shipped,
                  onTap: () => setState(() => _selectedStatus = OrderStatus.shipped),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Completed',
                  isSelected: _selectedStatus == OrderStatus.delivered,
                  onTap: () => setState(() => _selectedStatus = OrderStatus.delivered),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No orders found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return _OrderCard(
                        order: orders[index],
                        onRefresh: () => setState(() {}),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final SellerOrder order;
  final VoidCallback onRefresh;

  const _OrderCard({required this.order, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final service = SellerService();
    final product = service.getProduct(order.productId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _StatusBadge(status: order.status),
              ],
            ),
            const Divider(height: 16),
            if (product != null) ...[
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                Text(
                  'Quantity: ${order.quantity}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                Text(
                  'Payment: ${order.paymentMode.name.toUpperCase()}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                    Text(
                      '₹${order.totalAmount.toInt()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'You Earn',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '₹${order.netEarnings.toInt()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (order.status == OrderStatus.placed) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton(
                      onPressed: () => _rejectOrder(context, order.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text(loc.translate('cancel')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _acceptOrder(context, order.id, onRefresh),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
            if (order.status == OrderStatus.accepted) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _markShipped(context, order.id, onRefresh),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: Text(loc.translate('mark_shipped')),
              ),
            ],
            if (order.status == OrderStatus.shipped) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _markDelivered(context, order.id, onRefresh),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: Text(loc.translate('mark_delivered')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _acceptOrder(BuildContext context, String orderId, VoidCallback onRefresh) async {
    final loc = AppLocalizations.of(context)!;
    final service = SellerService();
    await service.acceptOrder(orderId);
    onRefresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.translate('order_accepted_msg')), backgroundColor: Colors.green),
    );
  }

  Future<void> _rejectOrder(BuildContext context, String orderId) async {
    final loc = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('reject_order_confirm')),
        content: Text(loc.translate('reject_order_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(loc.translate('cancel')),
          ),
        ],
      ),
    );

    if (result == true) {
      final service = SellerService();
      await service.rejectOrder(orderId, 'Out of stock');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('order_rejected_msg'))),
      );
    }
  }

  Future<void> _markShipped(BuildContext context, String orderId, VoidCallback onRefresh) async {
    final loc = AppLocalizations.of(context)!;
    final service = SellerService();
    await service.markOrderShipped(orderId);
    onRefresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.translate('order_shipped')), backgroundColor: Colors.green),
    );
  }

  Future<void> _markDelivered(BuildContext context, String orderId, VoidCallback onRefresh) async {
    final loc = AppLocalizations.of(context)!;
    final service = SellerService();
    await service.markOrderDelivered(orderId);
    onRefresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.translate('order_delivered')), backgroundColor: Colors.green),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.placed:
        color = Colors.orange;
        text = 'New';
        break;
      case OrderStatus.accepted:
        color = Colors.blue;
        text = 'Accepted';
        break;
      case OrderStatus.shipped:
        color = Colors.purple;
        text = 'Shipped';
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        text = 'Delivered';
        break;
      case OrderStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
      default:
        color = Colors.grey;
        text = status.name;
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
