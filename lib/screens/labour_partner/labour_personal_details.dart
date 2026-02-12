import 'package:flutter/material.dart';
import '../../utils/app_localizations.dart';
import 'labour_type_selection.dart';

class LabourPersonalDetails extends StatefulWidget {
  const LabourPersonalDetails({super.key});

  @override
  State<LabourPersonalDetails> createState() => _LabourPersonalDetailsState();
}

class _LabourPersonalDetailsState extends State<LabourPersonalDetails> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  bool photoUploaded = false;

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
            const SizedBox(height: 20),
            
            // Profile Photo Upload
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() => photoUploaded = !photoUploaded);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(photoUploaded ? 'Photo uploaded' : 'Photo removed')),
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2E7D32), width: 3),
                  ),
                  child: photoUploaded
                      ? const Icon(Icons.person, size: 60, color: Color(0xFF2E7D32))
                      : const Icon(Icons.add_a_photo, size: 50, color: Color(0xFF2E7D32)),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            const Center(
              child: Text(
                'Upload Profile Photo',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Full Name
            const Text(
              'Full Name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                hintStyle: const TextStyle(fontSize: 16),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Address
            const Text(
              'Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addressController,
              maxLines: 3,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Enter your full address',
                hintStyle: const TextStyle(fontSize: 16),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
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
                    MaterialPageRoute(builder: (context) => const LabourTypeSelection()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(loc.translate('next'), style: const TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
