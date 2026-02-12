import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_localizations.dart';
import 'labour_application_status.dart';

class LabourDocumentVerification extends StatefulWidget {
  const LabourDocumentVerification({super.key});

  @override
  State<LabourDocumentVerification> createState() => _LabourDocumentVerificationState();
}

class _LabourDocumentVerificationState extends State<LabourDocumentVerification> {
  final aadhaarController = TextEditingController();
  final accountController = TextEditingController();
  final ifscController = TextEditingController();
  bool aadhaarUploaded = false;
  bool selfieUploaded = false;

  Future<void> _submitApplication() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('labour_partner_status', 'pending');
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LabourApplicationStatusScreen(),
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
        title: Text(loc.translate('document_verification'), style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            // Aadhaar Number
            const Text(
              'Aadhaar Number',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: aadhaarController,
              keyboardType: TextInputType.number,
              maxLength: 12,
              style: const TextStyle(fontSize: 18, letterSpacing: 2),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.credit_card, size: 24),
                hintText: 'XXXX XXXX XXXX',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Upload Aadhaar
            GestureDetector(
              onTap: () {
                setState(() => aadhaarUploaded = !aadhaarUploaded);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(aadhaarUploaded ? 'Aadhaar uploaded' : 'Aadhaar removed')),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: aadhaarUploaded ? const Color(0xFFE8F5E9) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: aadhaarUploaded ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      aadhaarUploaded ? Icons.check_circle : Icons.upload_file,
                      color: aadhaarUploaded ? const Color(0xFF2E7D32) : Colors.grey.shade600,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      aadhaarUploaded ? 'Aadhaar Uploaded' : 'Upload Aadhaar Photo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: aadhaarUploaded ? const Color(0xFF2E7D32) : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Bank Account Details
            const Text(
              'Bank Account Number',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: accountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.account_balance, size: 24),
                hintText: 'Account Number',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // IFSC Code
            const Text(
              'IFSC Code',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ifscController,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.account_balance, size: 24),
                hintText: 'IFSC Code',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Selfie Verification
            const Text(
              'Selfie Verification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            GestureDetector(
              onTap: () {
                setState(() => selfieUploaded = !selfieUploaded);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(selfieUploaded ? 'Selfie uploaded' : 'Selfie removed')),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: selfieUploaded ? const Color(0xFFE8F5E9) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selfieUploaded ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selfieUploaded ? Icons.check_circle : Icons.camera_alt,
                      color: selfieUploaded ? const Color(0xFF2E7D32) : Colors.grey.shade600,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      selfieUploaded ? 'Selfie Uploaded' : 'Take Selfie',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: selfieUploaded ? const Color(0xFF2E7D32) : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  loc.translate('submit_application'),
                  style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
