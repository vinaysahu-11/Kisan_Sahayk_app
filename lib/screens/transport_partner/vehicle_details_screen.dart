import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_localizations.dart';
import 'application_status_screen.dart';

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  String selectedVehicle = 'Tractor';
  String selectedCapacity = '1 Ton';
  String selectedRadius = '10km';
  final vehicleNumberController = TextEditingController();
  final rateController = TextEditingController();
  bool rcUploaded = false;
  bool licenseUploaded = false;
  Set<String> selectedLoadTypes = {'Crops'};

  final List<String> vehicleTypes = ['Tractor', 'Pickup', 'Mini Truck', 'Heavy Truck'];
  final List<String> capacities = ['1 Ton', '2 Ton', '5 Ton', '10 Ton'];
  final List<String> loadTypes = ['Crops', 'Fertilizer', 'Equipment', 'Mixed'];
  final List<String> radiusOptions = ['10km', '20km', '50km'];

  Future<void> _submitApplication() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transport_partner_status', 'pending');
    await prefs.setString('transport_vehicle_type', selectedVehicle);
    await prefs.setString('transport_vehicle_number', vehicleNumberController.text);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ApplicationStatusScreen(partnerType: 'transport'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(loc.translate('vehicle_information'), style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vehicle Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: vehicleTypes.map((type) {
                final isSelected = selectedVehicle == type;
                return InkWell(
                  onTap: () => setState(() => selectedVehicle = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                      border: Border.all(color: const Color(0xFF2E7D32)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: vehicleNumberController,
              decoration: InputDecoration(
                labelText: 'Vehicle Number',
                hintText: 'CG01AB1234',
                prefixIcon: const Icon(Icons.local_shipping),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => setState(() => rcUploaded = !rcUploaded),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2E7D32)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(rcUploaded ? Icons.check_circle : Icons.upload_file, color: const Color(0xFF2E7D32)),
                    const SizedBox(width: 12),
                    Text(rcUploaded ? 'RC Uploaded' : 'Upload RC'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => setState(() => licenseUploaded = !licenseUploaded),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2E7D32)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(licenseUploaded ? Icons.check_circle : Icons.upload_file, color: const Color(0xFF2E7D32)),
                    const SizedBox(width: 12),
                    Text(licenseUploaded ? 'License Uploaded' : loc.translate('upload_driving_license')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(loc.translate('load_capacity'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: capacities.map((capacity) {
                final isSelected = selectedCapacity == capacity;
                return InkWell(
                  onTap: () => setState(() => selectedCapacity = capacity),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                      border: Border.all(color: const Color(0xFF2E7D32)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      capacity,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(loc.translate('type_of_load'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...loadTypes.map((type) {
              final isSelected = selectedLoadTypes.contains(type);
              return CheckboxListTile(
                value: isSelected,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      selectedLoadTypes.add(type);
                    } else {
                      selectedLoadTypes.remove(type);
                    }
                  });
                },
                title: Text(type),
                activeColor: const Color(0xFF2E7D32),
              );
            }),
            const SizedBox(height: 24),
            Text(loc.translate('service_area_radius'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: radiusOptions.map((radius) {
                final isSelected = selectedRadius == radius;
                return InkWell(
                  onTap: () => setState(() => selectedRadius = radius),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                      border: Border.all(color: const Color(0xFF2E7D32)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      radius,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: rateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Per KM Rate (₹)',
                hintText: '15',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(loc.translate('submit_application'), style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
