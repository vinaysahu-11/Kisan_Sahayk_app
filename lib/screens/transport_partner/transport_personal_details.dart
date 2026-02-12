import 'package:flutter/material.dart';

import '../../utils/app_localizations.dart';
import 'vehicle_details_screen.dart';

class TransportPersonalDetails extends StatefulWidget {
  const TransportPersonalDetails({super.key});

  @override
  State<TransportPersonalDetails> createState() => _TransportPersonalDetailsState();
}

class _TransportPersonalDetailsState extends State<TransportPersonalDetails> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  bool aadhaarUploaded = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(loc.translate('personal_details'), style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFF1F8E9),
                child: Icon(Icons.camera_alt, size: 40, color: Color(0xFF2E7D32)),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(loc.translate('upload_profile_photo'), style: const TextStyle(color: Color(0xFF2E7D32))),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: addressController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Address',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => setState(() => aadhaarUploaded = !aadhaarUploaded),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2E7D32)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      aadhaarUploaded ? Icons.check_circle : Icons.upload_file,
                      color: const Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      aadhaarUploaded ? 'Aadhaar Uploaded' : 'Upload Aadhaar Card',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const VehicleDetailsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Next', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
