import 'package:flutter/material.dart';
import 'buyer_home_screen.dart';
import '../theme/app_colors.dart';

class BuyProductScreen extends StatelessWidget {
  const BuyProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Products', style: TextStyle(color: Colors.white)),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Agriculture Marketplace Banner
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyerHomeScreen())),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient(context),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🛒 Agriculture Marketplace', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                            const SizedBox(height: 8),
                            Text(
                              'Browse products from verified farmers\nSeeds, Fertilizers, Crops, Equipment & more',
                              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9), height: 1.4),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                              child: const Text('Open Marketplace →', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.storefront, size: 60, color: Colors.white24),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Features
              Row(
                children: [
                  _FeatureCard(icon: Icons.security, title: 'Escrow\nPayment', color: Colors.blue),
                  const SizedBox(width: 12),
                  _FeatureCard(icon: Icons.money, title: 'COD\nAvailable', color: Colors.orange),
                  const SizedBox(width: 12),
                  _FeatureCard(icon: Icons.local_shipping, title: 'Free Delivery\n₹5000+', color: Colors.teal),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _FeatureCard(icon: Icons.star, title: 'Seller\nRatings', color: Colors.amber),
                  const SizedBox(width: 12),
                  _FeatureCard(icon: Icons.account_balance_wallet, title: 'Wallet\nCashback', color: Colors.purple),
                  const SizedBox(width: 12),
                  _FeatureCard(icon: Icons.replay, title: '48hr\nReturns', color: Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _FeatureCard({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color.withValues(alpha: 0.8)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
