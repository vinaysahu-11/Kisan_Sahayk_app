import 'package:flutter/material.dart';
import '../theme/app_colors.dart';


class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  final List<Map<String, dynamic>> bookings = const [
    {
      'type': 'Transport',
      'title': 'Truck Booking',
      'details': 'Raipur to Durg',
      'date': '15 Jan 2026',
      'status': 'Confirmed',
      'icon': Icons.local_shipping,
      'color': Colors.blue,
    },
    {
      'type': 'Labour',
      'title': 'Harvest Workers',
      'details': '5 Workers for 3 days',
      'date': '18 Jan 2026',
      'status': 'Active',
      'icon': Icons.groups,
      'color': Colors.green,
    },
    {
      'type': 'Product',
      'title': 'Wheat Seeds Purchase',
      'details': '10 Quintals',
      'date': '12 Jan 2026',
      'status': 'Completed',
      'icon': Icons.shopping_cart,
      'color': Colors.orange,
    },
    {
      'type': 'Transport',
      'title': 'Tractor Booking',
      'details': 'Local transport',
      'date': '20 Jan 2026',
      'status': 'Pending',
      'icon': Icons.agriculture,
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient(context),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient(context),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (booking['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        booking['icon'],
                        size: 28,
                        color: booking['color'],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  booking['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _StatusBadge(status: booking['status']),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking['details'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(
                                booking['date'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Confirmed':
        color = Colors.blue;
        break;
      case 'Active':
        color = Colors.green;
        break;
      case 'Pending':
        color = Colors.orange;
        break;
      case 'Completed':
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
