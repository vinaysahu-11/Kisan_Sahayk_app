import 'package:flutter/material.dart';
import '../services/buyer_service.dart';
import '../models/buyer_models.dart';

class BuyerOrdersScreen extends StatefulWidget {
  const BuyerOrdersScreen({super.key});

  @override
  State<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends State<BuyerOrdersScreen> with SingleTickerProviderStateMixin {
  final _service = BuyerService();
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: const Color(0xFF2E7D32),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Returns'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildOrderList(_service.getActiveOrders()),
          _buildOrderList(_service.getCompletedOrders()),
          _buildReturnList(_service.getReturns()),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<BuyerOrder> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('No orders here', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _OrderCard(
            order: order,
            onTap: () => Navigator.pushNamed(context, '/buyer-order-detail', arguments: order.id).then((_) => setState(() {})),
          );
        },
      ),
    );
  }

  Widget _buildReturnList(List<ReturnRequest> returns) {
    if (returns.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_return_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('No return requests', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: returns.length,
      itemBuilder: (context, index) {
        final ret = returns[index];
        final order = _service.getOrders().where((o) => o.id == ret.orderId).firstOrNull;
        final statusColor = {
          DisputeStatus.raised: Colors.orange,
          DisputeStatus.underReview: Colors.blue,
          DisputeStatus.resolved: Colors.green,
          DisputeStatus.rejected: Colors.red,
        }[ret.status]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(order?.productName ?? 'Order ${ret.orderId}', style: const TextStyle(fontWeight: FontWeight.w600))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(ret.status.name.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Reason: ${ret.reason}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                if (ret.details != null && ret.details!.isNotEmpty) Text('Details: ${ret.details}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                if (ret.resolution != null && ret.resolution!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(6)),
                    child: Text('Resolution: ${ret.resolution}', style: TextStyle(fontSize: 12, color: Colors.green[700])),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final BuyerOrder order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      BuyerOrderStatus.placed: Colors.blue,
      BuyerOrderStatus.accepted: Colors.indigo,
      BuyerOrderStatus.packed: Colors.purple,
      BuyerOrderStatus.shipped: Colors.teal,
      BuyerOrderStatus.outForDelivery: Colors.orange,
      BuyerOrderStatus.delivered: const Color(0xFF2E7D32),
      BuyerOrderStatus.completed: const Color(0xFF2E7D32),
      BuyerOrderStatus.cancelled: Colors.red,
      BuyerOrderStatus.returned: Colors.brown,
    };
    final statusLabels = {
      BuyerOrderStatus.placed: 'Order Placed',
      BuyerOrderStatus.accepted: 'Accepted',
      BuyerOrderStatus.packed: 'Packed',
      BuyerOrderStatus.shipped: 'Shipped',
      BuyerOrderStatus.outForDelivery: 'Out for Delivery',
      BuyerOrderStatus.delivered: 'Delivered',
      BuyerOrderStatus.completed: 'Completed',
      BuyerOrderStatus.cancelled: 'Cancelled',
      BuyerOrderStatus.returned: 'Returned',
    };

    final color = statusColors[order.status] ?? Colors.grey;
    final label = statusLabels[order.status] ?? order.status.name;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text('by ${order.sellerName}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Qty: ${order.quantity}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(width: 16),
                  Icon(order.paymentMode == 'cod' ? Icons.money : Icons.credit_card, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(order.paymentMode == 'cod' ? 'COD' : 'Online', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  const Spacer(),
                  Text('₹${order.totalAmount.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Order #${order.id}', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  const Spacer(),
                  Text(_formatDate(order.orderDate), style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

}
