import 'package:flutter/material.dart';
import '../services/delivery_service.dart';

class DeliveryNotificationsScreen extends StatefulWidget {
  const DeliveryNotificationsScreen({super.key});

  @override
  State<DeliveryNotificationsScreen> createState() => _DeliveryNotificationsScreenState();
}

class _DeliveryNotificationsScreenState extends State<DeliveryNotificationsScreen> {
  final _deliveryService = DeliveryService();

  @override
  Widget build(BuildContext context) {
    final partner = _deliveryService.getCurrentPartner();
    if (partner == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    final notifications = _deliveryService.getNotifications(partner.id);
    final unreadCount = _deliveryService.getUnreadCount(partner.id);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications${unreadCount > 0 ? ' ($unreadCount)' : ''}'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                _deliveryService.markAllRead(partner.id);
                setState(() {});
              },
              child: const Text('Mark All Read', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No notifications yet', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final config = _getNotificationConfig(notification.type);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: notification.isRead ? null : Colors.green.shade50,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: config['color'].withValues(alpha: 0.2),
                      child: Icon(config['icon'], color: config['color']),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.message),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(notification.date),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: !notification.isRead
                        ? const Icon(Icons.circle, color: Colors.green, size: 12)
                        : null,
                    onTap: () {
                      if (!notification.isRead) {
                        _deliveryService.markNotificationRead(notification.id);
                        setState(() {});
                      }
                      if (notification.orderId != null) {
                        Navigator.pushNamed(
                          context,
                          '/delivery-order-detail',
                          arguments: notification.orderId,
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  Map<String, dynamic> _getNotificationConfig(String type) {
    switch (type) {
      case 'new_order':
        return {'icon': Icons.assignment, 'color': Colors.blue};
      case 'surge_alert':
        return {'icon': Icons.trending_up, 'color': Colors.orange};
      case 'target_achieved':
        return {'icon': Icons.celebration, 'color': Colors.purple};
      case 'rating_drop':
        return {'icon': Icons.star_border, 'color': Colors.red};
      case 'subscription':
        return {'icon': Icons.notifications, 'color': Colors.green};
      default:
        return {'icon': Icons.info, 'color': Colors.grey};
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
