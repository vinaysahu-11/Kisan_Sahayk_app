import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/app_localizations.dart';
import 'trip_progress_screen.dart';
import 'transport_wallet_screen.dart';

class TransportPartnerDashboardScreen extends StatefulWidget {
  const TransportPartnerDashboardScreen({super.key});

  @override
  State<TransportPartnerDashboardScreen> createState() => _TransportPartnerDashboardScreenState();
}

class _TransportPartnerDashboardScreenState extends State<TransportPartnerDashboardScreen> {
  bool isOnline = false;
  double todayEarnings = 1250.0;
  int totalTrips = 45;
  double weeklyEarnings = 8500.0;
  int completedDeliveries = 42;
  double rating = 4.7;
  bool showBooking = false;
  int bookingTimer = 20;
  Timer? _timer;

  void _toggleOnline() {
    setState(() => isOnline = !isOnline);
    if (isOnline) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && isOnline) {
          setState(() => showBooking = true);
          _startTimer();
        }
      });
    } else {
      setState(() => showBooking = false);
      _timer?.cancel();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (bookingTimer > 0) {
        setState(() => bookingTimer--);
      } else {
        timer.cancel();
        setState(() => showBooking = false);
        bookingTimer = 20;
      }
    });
  }

  void _acceptBooking() {
    _timer?.cancel();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TripProgressScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(loc.translate('transport_partner'), style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TransportWalletScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Online/Offline Toggle
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isOnline
                      ? [const Color(0xFF2E7D32), const Color(0xFF66BB6A)]
                      : [Colors.grey[400]!, Colors.grey[600]!],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOnline ? 'You are Online' : 'You are Offline',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOnline ? 'Ready to accept bookings' : 'Tap to go online',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  Switch(
                    value: isOnline,
                    onChanged: (val) => _toggleOnline(),
                    activeThumbColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Today's Earnings
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('Today\'s Earnings', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    '₹ ${todayEarnings.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Total Trips', totalTrips.toString(), Icons.local_shipping),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Weekly Earnings', '₹$weeklyEarnings', Icons.currency_rupee),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Completed', completedDeliveries.toString(), Icons.check_circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Rating', '⭐ $rating', Icons.star),
                ),
              ],
            ),

            // Incoming Booking Card
            if (showBooking) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'New Booking!',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$bookingTimer s',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildBookingDetail(Icons.location_on, 'Pickup', 'Raipur Mandi, Sector 5'),
                    _buildBookingDetail(Icons.flag, 'Drop', 'Dhamtari Village, NH 30'),
                    _buildBookingDetail(Icons.inventory_2, 'Load', 'Rice Sacks'),
                    _buildBookingDetail(Icons.scale, 'Weight', '2 Ton'),
                    _buildBookingDetail(Icons.currency_rupee, 'Fare', '₹850'),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _acceptBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Accept', style: TextStyle(fontSize: 18, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showBooking = false;
                                bookingTimer = 20;
                              });
                              _timer?.cancel();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Reject', style: TextStyle(fontSize: 18, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBookingDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.orange),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
