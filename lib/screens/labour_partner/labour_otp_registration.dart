import 'package:flutter/material.dart';
import 'labour_personal_details.dart';

class LabourOTPRegistration extends StatefulWidget {
  const LabourOTPRegistration({super.key});

  @override
  State<LabourOTPRegistration> createState() => _LabourOTPRegistrationState();
}

class _LabourOTPRegistrationState extends State<LabourOTPRegistration> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  bool otpSent = false;
  bool isVerifying = false;

  void _sendOTP() {
    if (phoneController.text.length == 10) {
      setState(() => otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to your mobile'), backgroundColor: Colors.green),
      );
    }
  }

  void _verifyOTP() {
    setState(() => isVerifying = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LabourPersonalDetails()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('Mobile Verification', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Enter Mobile Number',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            
            // Phone Number Field
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              style: const TextStyle(fontSize: 20, letterSpacing: 2),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone, size: 28),
                hintText: 'Mobile Number',
                hintStyle: const TextStyle(fontSize: 18),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
              ),
            ),
            
            const SizedBox(height: 20),
            
            if (!otpSent)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Send OTP', style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
            
            if (otpSent) ...[
              const SizedBox(height: 24),
              const Text(
                'Enter OTP',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // OTP Field
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(fontSize: 24, letterSpacing: 4),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '• • • • • •',
                  hintStyle: const TextStyle(fontSize: 24),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  counterText: '',
                ),
              ),
              
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isVerifying ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: isVerifying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Verify OTP', style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
