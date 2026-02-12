import 'package:flutter/material.dart';
import '../../utils/app_localizations.dart';
import 'labour_otp_registration.dart';

class LabourPartnerEntry extends StatelessWidget {
  const LabourPartnerEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(loc.translate('become_labour_partner'), style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // Large illustration
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.agriculture, size: 100, color: Color(0xFF2E7D32)),
                    SizedBox(height: 10),
                    Icon(Icons.groups, size: 60, color: Color(0xFF66BB6A)),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                loc.translate('become_labour_partner'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Earn by working in farms and physical tasks',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Benefits Cards
              _buildBenefitCard(
                icon: Icons.currency_rupee,
                title: 'Good Daily Wages',
                subtitle: '₹400 - ₹800 per day',
              ),
              
              const SizedBox(height: 16),
              
              _buildBenefitCard(
                icon: Icons.calendar_today,
                title: 'Flexible Work Days',
                subtitle: 'Work when you want',
              ),
              
              const SizedBox(height: 16),
              
              _buildBenefitCard(
                icon: Icons.location_on,
                title: 'Nearby Jobs',
                subtitle: 'Work in your area',
              ),
              
              const SizedBox(height: 16),
              
              _buildBenefitCard(
                icon: Icons.account_balance_wallet,
                title: 'Direct Payment',
                subtitle: 'Money in your account',
              ),
              
              const SizedBox(height: 40),
              
              // Register Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LabourOTPRegistration(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    loc.translate('become_labour_partner'),
                    style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 30, color: const Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
