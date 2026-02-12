import 'package:flutter/material.dart';
import 'transport_personal_details.dart';

class TransportOTPRegistration extends StatefulWidget {
  const TransportOTPRegistration({super.key});

  @override
  State<TransportOTPRegistration> createState() => _TransportOTPRegistrationState();
}

class _TransportOTPRegistrationState extends State<TransportOTPRegistration> {
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
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TransportPersonalDetails()),
      );
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: '10-digit mobile number',
                prefixIcon: const Icon(Icons.phone, color: Color(0xFF2E7D32)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
              ),
            ),
            if (!otpSent) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Send OTP', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
            if (otpSent) ...[
              const SizedBox(height: 24),
              const Text(
                'Enter OTP',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: '6-digit OTP',
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF2E7D32)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                      : const Text('Verify OTP', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
