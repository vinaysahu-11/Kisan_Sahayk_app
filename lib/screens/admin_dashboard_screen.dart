import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../utils/app_localizations.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Map<String, dynamic>> pendingTransportPartners = [];
  List<Map<String, dynamic>> pendingLabourPartners = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingRegistrations();
  }

  Future<void> _loadPendingRegistrations() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load transport partners
    final transportStatus = prefs.getString('transport_partner_status');
    if (transportStatus == 'pending') {
      pendingTransportPartners.add({
        'type': 'transport',
        'phone': prefs.getString('transport_phone') ?? '',
        'vehicle_type': prefs.getString('transport_vehicle_type') ?? '',
        'vehicle_number': prefs.getString('transport_vehicle_number') ?? '',
        'price': prefs.getString('transport_price') ?? '',
        'area': prefs.getString('transport_area') ?? '',
      });
    }
    
    // Load labour partners
    final labourStatus = prefs.getString('labour_partner_status');
    if (labourStatus == 'pending') {
      pendingLabourPartners.add({
        'type': 'labour',
        'name': prefs.getString('labour_name') ?? '',
        'phone': prefs.getString('labour_phone') ?? '',
        'skills': prefs.getStringList('labour_skills') ?? [],
        'experience': prefs.getString('labour_experience') ?? '',
        'wage': prefs.getString('labour_wage') ?? '',
        'area': prefs.getString('labour_area') ?? '',
      });
    }
    
    setState(() => isLoading = false);
  }

  Future<void> _approvePartner(String type, int index) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (type == 'transport') {
      await prefs.setString('transport_partner_status', 'approved');
      setState(() => pendingTransportPartners.removeAt(index));
    } else {
      await prefs.setString('labour_partner_status', 'approved');
      setState(() => pendingLabourPartners.removeAt(index));
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${type == 'transport' ? 'Transport' : 'Labour'} partner approved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _rejectPartner(String type, int index) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (type == 'transport') {
      await prefs.remove('transport_partner_status');
      await prefs.remove('transport_phone');
      await prefs.remove('transport_vehicle_type');
      await prefs.remove('transport_vehicle_number');
      await prefs.remove('transport_price');
      await prefs.remove('transport_area');
      setState(() => pendingTransportPartners.removeAt(index));
    } else {
      await prefs.remove('labour_partner_status');
      await prefs.remove('labour_name');
      await prefs.remove('labour_phone');
      await prefs.remove('labour_skills');
      await prefs.remove('labour_experience');
      await prefs.remove('labour_wage');
      await prefs.remove('labour_area');
      setState(() => pendingLabourPartners.removeAt(index));
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${type == 'transport' ? 'Transport' : 'Labour'} partner rejected'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      appBar: AppBar(
        title: Text(loc.translate('admin_dashboard'), style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient(context),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Transport\nPending', pendingTransportPartners.length, Icons.local_shipping),
                        Container(width: 1, height: 50, color: Colors.white24),
                        _buildStatItem('Labour\nPending', pendingLabourPartners.length, Icons.groups),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Transport Partners Section
                  if (pendingTransportPartners.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.local_shipping, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Transport Partners',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...pendingTransportPartners.asMap().entries.map((entry) {
                      final index = entry.key;
                      final partner = entry.value;
                      return _buildTransportPartnerCard(partner, index);
                    }),
                    const SizedBox(height: 24),
                  ],
                  
                  // Labour Partners Section
                  if (pendingLabourPartners.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.groups, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Labour Partners',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...pendingLabourPartners.asMap().entries.map((entry) {
                      final index = entry.key;
                      final partner = entry.value;
                      return _buildLabourPartnerCard(partner, index);
                    }),
                  ],
                  
                  // Empty State
                  if (pendingTransportPartners.isEmpty && pendingLabourPartners.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          Icon(Icons.check_circle_outline, size: 80, color: Colors.green[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No Pending Approvals',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'All registrations are up to date!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildTransportPartnerCard(Map<String, dynamic> partner, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 122, 61, 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_shipping, color: Color(0xFFFF7A3D)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transport Partner',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      partner['phone'],
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Vehicle Type', partner['vehicle_type']),
          _buildInfoRow('Vehicle Number', partner['vehicle_number']),
          _buildInfoRow('Price/KM', '₹${partner['price']}'),
          _buildInfoRow('Service Area', partner['area']),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approvePartner('transport', index),
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: Text(AppLocalizations.of(context)!.translate('approve')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _rejectPartner('transport', index),
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabourPartnerCard(Map<String, dynamic> partner, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(46, 204, 113, 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.groups, color: Color(0xFF2ECC71)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      partner['phone'],
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Skills', (partner['skills'] as List).join(', ')),
          _buildInfoRow('Experience', '${partner['experience']} years'),
          _buildInfoRow('Daily Wage', '₹${partner['wage']}'),
          _buildInfoRow('Working Area', partner['area']),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approvePartner('labour', index),
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: Text(AppLocalizations.of(context)!.translate('approve')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _rejectPartner('labour', index),
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
