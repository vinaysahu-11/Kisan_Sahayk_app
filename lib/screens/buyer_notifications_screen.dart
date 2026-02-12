import 'package:flutter/material.dart';
import '../services/buyer_service.dart';

class BuyerNotificationsScreen extends StatefulWidget {
  const BuyerNotificationsScreen({super.key});

  @override
  State<BuyerNotificationsScreen> createState() => _BuyerNotificationsScreenState();
}

class _BuyerNotificationsScreenState extends State<BuyerNotificationsScreen> {
  final _service = BuyerService();

  @override
  Widget build(BuildContext context) {
    final notifications = _service.getNotifications();
    final unread = _service.getUnreadCount();

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications${unread > 0 ? ' ($unread)' : ''}'),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () {
                _service.markAllRead();
                setState(() {});
              },
              child: const Text('Mark all read', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 72, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('No notifications', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                ],
              ),
            )
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = notifications[index];
                final typeIcons = {
                  'order': Icons.receipt_long,
                  'refund': Icons.replay,
                  'promo': Icons.local_offer,
                  'delivery': Icons.local_shipping,
                };
                final typeColors = {
                  'order': Colors.blue,
                  'refund': Colors.green,
                  'promo': Colors.purple,
                  'delivery': Colors.orange,
                };

                return Container(
                  color: n.isRead ? Colors.white : const Color(0xFF2E7D32).withValues(alpha: 0.03),
                  child: ListTile(
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: (typeColors[n.type] ?? Colors.grey).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(typeIcons[n.type] ?? Icons.notifications, color: typeColors[n.type] ?? Colors.grey, size: 20),
                    ),
                    title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700, fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(n.message, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        Text(_timeAgo(n.date), style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                      ],
                    ),
                    trailing: n.isRead ? null : Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle)),
                    onTap: () {
                      _service.markNotificationRead(n.id);
                      setState(() {});
                      if (n.orderId != null) {
                        Navigator.pushNamed(context, '/buyer-order-detail', arguments: n.orderId);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
