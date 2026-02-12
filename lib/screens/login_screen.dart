import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _showOtpField = false;
  String _errorMessage = '';
  
  // Mock valid phone numbers for demo
  final List<String> validPhoneNumbers = ['9876543210', '1234567890'];
  final String correctOtp = '123456';
  final Map<String, String> userData = {
    '9876543210': 'Ramesh Kumar',
    '1234567890': 'Suresh Patel',
  };

  void _handlePhoneSubmit() {
    setState(() => _errorMessage = '');
    
    final phone = _phoneController.text.trim();
    
    if (phone.length != 10 || !RegExp(r'^\d{10}$').hasMatch(phone)) {
      setState(() => _errorMessage = AppLocalizations.of(context)!.invalidPhone);
      return;
    }
    
    if (!validPhoneNumbers.contains(phone)) {
      setState(() => _errorMessage = AppLocalizations.of(context)!.phoneNotRegistered);
      return;
    }
    
    setState(() => _showOtpField = true);
  }

  void _handleOtpSubmit() {
    final otp = _otpController.text.trim();
    
    if (otp == correctOtp) {
      final userName = userData[_phoneController.text] ?? 'Kisan';
        if (mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard', arguments: userName);
        }
    } else {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.invalidOTP;
        _otpController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5E9), Color(0xFFF1F8F4), Color(0xFFE8F5E9)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 80,
                      color: Color(0xFF2E6B3F),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.appName,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E6B3F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.appTagline,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4A7C59),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Login Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.loginToContinue,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B3D2A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        
                        // Phone Number Field
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          enabled: !_showOtpField,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.mobileNumber,
                            prefixText: '+91 ',
                            prefixIcon: const Icon(Icons.phone_android),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: _showOtpField ? Colors.grey[100] : Colors.white,
                          ),
                        ),
                        
                        if (_showOtpField) ...[
                          const SizedBox(height: 16),
                          // OTP Field
                          TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.enterOTP,
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showOtpField = false;
                                _otpController.clear();
                                _errorMessage = '';
                              });
                            },
                            child: Text(AppLocalizations.of(context)!.changePhoneNumber),
                          ),
                        ],
                        
                        if (_errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // Submit Button
                        ElevatedButton(
                          onPressed: _showOtpField ? _handleOtpSubmit : _handlePhoneSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E6B3F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            _showOtpField ? AppLocalizations.of(context)!.verifyOtp : AppLocalizations.of(context)!.sendOtp,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${AppLocalizations.of(context)!.dontHaveAccount} '),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: Text(
                                AppLocalizations.of(context)!.signup,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E6B3F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.demoCredentials,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
