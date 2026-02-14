import 'package:flutter/material.dart';
import '../models/delivery_models.dart';
import '../services/delivery_service.dart';
import '../utils/app_localizations.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() => _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  final _deliveryService = DeliveryService();
  late DeliveryPartner _partner;
  List<DeliveryOrder> _activeOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() => _isLoading = true);
    final partner = _deliveryService.getCurrentPartner();
    if (partner != null) {
      _partner = partner;
      _activeOrders = _deliveryService.getActiveOrders(partner.id);
    }
    setState(() => _isLoading = false);
  }

  void _toggleOnlineStatus() {
    _deliveryService.toggleOnlineStatus(_partner.id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('delivery_dashboard')),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/delivery-notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOnlineToggle(loc),
              const SizedBox(height: 16),
              _buildTodayStats(loc),
              const SizedBox(height: 24),
              _buildActiveOrders(),
              const SizedBox(height: 24),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineToggle(AppLocalizations loc) {
    return Card(
      color: _partner.isOnline ? Colors.green.shade50 : Colors.grey.shade50,
      child: SwitchListTile(
        title: Text(
          _partner.isOnline ? 'You are Online' : 'You are Offline',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_partner.isOnline ? loc.translate('online') : loc.translate('offline')),
        value: _partner.isOnline,
        onChanged: (_) => _toggleOnlineStatus(),
        secondary: Icon(
          _partner.isOnline ? Icons.cloud_done : Icons.cloud_off,
          color: _partner.isOnline ? Colors.green : Colors.grey,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildTodayStats(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Today Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '₹${_partner.todayEarnings.toInt()}',
                loc.translate('todays_earnings'),
                Icons.currency_rupee,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '${_activeOrders.length}',
                'Active Orders',
                Icons.assignment,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '${_partner.acceptanceRate}%',
                'Acceptance',
                Icons.check_circle,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '${_partner.rating}',
                'Rating',
                Icons.star,
                Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Active Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/delivery-orders'),
              child: const Text('See All'),
            ),
          ],
        ),
        if (_activeOrders.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'No active orders',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...(_activeOrders.take(3).map((order) => _buildOrderCard(order))),
      ],
    );
  }

  Widget _buildOrderCard(DeliveryOrder order) {
    final statusConfig = _getStatusConfig(order.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusConfig['color'],
          child: Icon(statusConfig['icon'], color: Colors.white),
        ),
        title: Text('Order #${order.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${order.pickupLocation} → ${order.dropLocation}'),
            Text(
              statusConfig['label'],
              style: TextStyle(color: statusConfig['color'], fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Text(
          '₹${order.netEarning.toInt()}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        onTap: () => Navigator.pushNamed(context, '/delivery-order-detail', arguments: order.id),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard('Earnings', Icons.account_balance_wallet, Colors.green, () {
              Navigator.pushNamed(context, '/delivery-earnings');
            }),
            _buildActionCard('Wallet', Icons.wallet, Colors.blue, () {
              Navigator.pushNamed(context, '/delivery-wallet');
            }),
            _buildActionCard('COD', Icons.money, Colors.orange, () {
              Navigator.pushNamed(context, '/delivery-cod');
            }),
            _buildActionCard('Incentives', Icons.card_giftcard, Colors.purple, () {
              Navigator.pushNamed(context, '/delivery-incentives');
            }),
            _buildActionCard('Performance', Icons.analytics, Colors.teal, () {
              Navigator.pushNamed(context, '/delivery-performance');
            }),
            _buildActionCard('Safety', Icons.security, Colors.red, () {
              Navigator.pushNamed(context, '/delivery-safety');
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.assigned:
        return {'icon': Icons.assignment, 'color': Colors.blue, 'label': 'New Delivery'};
      case DeliveryStatus.accepted:
        return {'icon': Icons.check_circle, 'color': Colors.green, 'label': 'Accepted'};
      case DeliveryStatus.reachedPickup:
        return {'icon': Icons.location_on, 'color': Colors.orange, 'label': 'At Pickup'};
      case DeliveryStatus.pickedUp:
        return {'icon': Icons.inventory_2, 'color': Colors.purple, 'label': 'Picked Up'};
      case DeliveryStatus.reachedCustomer:
        return {'icon': Icons.home, 'color': Colors.teal, 'label': 'At Delivery'};
      case DeliveryStatus.delivered:
        return {'icon': Icons.done_all, 'color': Colors.green, 'label': 'Delivered'};
      default:
        return {'icon': Icons.circle, 'color': Colors.grey, 'label': status.name};
    }
  }
}
