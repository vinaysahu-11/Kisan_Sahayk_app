import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_localizations.dart';
import '../labour_wallet_screen.dart';

class LabourPartnerDashboardScreen extends StatefulWidget {
  const LabourPartnerDashboardScreen({super.key});

  @override
  State<LabourPartnerDashboardScreen> createState() => _LabourPartnerDashboardScreenState();
}

class _LabourPartnerDashboardScreenState extends State<LabourPartnerDashboardScreen> {
  bool isAvailable = true;
  bool showJobRequest = true;
  int countdown = 20;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() => countdown--);
      } else {
        timer.cancel();
        setState(() => showJobRequest = false);
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  void _acceptJob() {
    countdownTimer?.cancel();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LabourActiveJobScreen()),
    );
  }

  void _rejectJob() {
    countdownTimer?.cancel();
    setState(() {
      showJobRequest = false;
      countdown = 20;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.translate('job_request_rejected'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(AppLocalizations.of(context)!.translate('labour_dashboard'), style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LabourWalletScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Availability Toggle
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isAvailable
                      ? [const Color(0xFF2E7D32), const Color(0xFF66BB6A)]
                      : [Colors.grey.shade600, Colors.grey.shade700],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAvailable ? 'You are Available' : 'You are Offline',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Toggle to receive jobs',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                  Switch(
                    value: isAvailable,
                    onChanged: (value) => setState(() => isAvailable = value),
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.white.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Today's Earnings
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.translate('todays_earnings'),
                          style: const TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '₹ 950',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Total Jobs', '47', Icons.work, Colors.orange),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard('Weekly Earnings', '₹5,400', Icons.currency_rupee, Colors.green),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Completed', '42', Icons.check_circle, Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard('Rating', '4.5 ⭐', Icons.star, Colors.amber),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Incoming Job Request
                  if (showJobRequest && isAvailable)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2E7D32), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'New Job Request',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$countdown s',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          _buildJobDetail(Icons.grass, 'Job Type', 'Harvesting Work'),
                          const Divider(height: 24),
                          _buildJobDetail(Icons.location_on, 'Location', 'Village Rampur, 3.5 km away'),
                          const Divider(height: 24),
                          _buildJobDetail(Icons.currency_rupee, 'Wage Offered', '₹ 550 per day'),
                          const Divider(height: 24),
                          _buildJobDetail(Icons.calendar_today, 'Date', 'Today, 10 Feb 2026'),
                          const Divider(height: 24),
                          _buildJobDetail(Icons.access_time, 'Estimated Hours', '6-8 hours'),
                          
                          const SizedBox(height: 24),
                          
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 56,
                                  child: OutlinedButton(
                                    onPressed: _rejectJob,
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.red, width: 2),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Reject', style: TextStyle(color: Colors.red, fontSize: 18)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _acceptJob,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Accept', style: TextStyle(color: Colors.white, fontSize: 18)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildJobDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.grey.shade600),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class LabourActiveJobScreen extends StatelessWidget {
  const LabourActiveJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Job')),
      body: const Center(child: Text('Active Job Details')),
    );
  }
}
