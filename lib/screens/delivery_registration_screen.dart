import 'package:flutter/material.dart';
import '../models/delivery_models.dart';
import '../services/delivery_service.dart';
import '../utils/app_localizations.dart';

class DeliveryRegistrationScreen extends StatefulWidget {
  const DeliveryRegistrationScreen({super.key});

  @override
  State<DeliveryRegistrationScreen> createState() => _DeliveryRegistrationScreenState();
}

class _DeliveryRegistrationScreenState extends State<DeliveryRegistrationScreen> {
  final _deliveryService = DeliveryService();
  int _currentStep = 0;

  // Controllers
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _dlController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _otpController = TextEditingController();

  VehicleType _selectedVehicle = VehicleType.bike;
  double _serviceRadius = 10.0;
  bool _otpVerified = false;
  bool _policeVerified = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _aadhaarController.dispose();
    _dlController.dispose();
    _vehicleNumberController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    _emergencyNameController.dispose();
    _emergencyContactController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    final partner = DeliveryPartner(
      id: 'DP${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      mobile: _mobileController.text,
      email: _emailController.text,
      aadhaar: _aadhaarController.text,
      drivingLicense: _dlController.text,
      policeVerified: _policeVerified,
      bankAccount: _bankAccountController.text,
      ifscCode: _ifscController.text,
      emergencyContact: _emergencyContactController.text,
      emergencyName: _emergencyNameController.text,
      serviceRadius: _serviceRadius,
      vehicleType: _selectedVehicle,
      vehicleNumber: _vehicleNumberController.text,
      status: DeliveryPartnerStatus.submitted,
      registeredDate: DateTime.now(),
    );

    final navigator = Navigator.of(context);
    await _deliveryService.register(partner);
    navigator.pushReplacementNamed('/delivery-application-status');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('become_delivery_partner')),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 4) {
            setState(() => _currentStep++);
          } else {
            _submitRegistration();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        steps: [
          Step(
            title: Text(loc.translate('registration')),
            content: Column(
              children: [
                TextField(
                  controller: _mobileController,
                  decoration: InputDecoration(
                    labelText: loc.translate('personal_details'),
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                ),
                const SizedBox(height: 16),
                if (!_otpVerified) ...[
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _otpVerified = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.translate('registration_submitted'))),
                      );
                    },
                    child: const Text('Send OTP'),
                  ),
                ] else ...[
                  TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: loc.translate('verify'),
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('OTP Verified', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ],
              ],
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text(loc.translate('personal_info')),
            content: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emergencyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Emergency Contact Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emergencyContactController,
                  decoration: const InputDecoration(
                    labelText: 'Emergency Contact Number',
                    prefixIcon: Icon(Icons.phone_in_talk),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text(loc.translate('documents')),
            content: Column(
              children: [
                TextField(
                  controller: _aadhaarController,
                  decoration: const InputDecoration(
                    labelText: 'Aadhaar Number',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                    hintText: '1234-5678-9012',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _dlController,
                  decoration: const InputDecoration(
                    labelText: 'Driving License Number',
                    prefixIcon: Icon(Icons.payment),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text(loc.translate('police_verification')),
                  subtitle: Text(loc.translate('required_for_approval')),
                  value: _policeVerified,
                  onChanged: (val) => setState(() => _policeVerified = val ?? false),
                  secondary: const Icon(Icons.verified_user),
                ),
              ],
            ),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Vehicle Details'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Vehicle Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: VehicleType.values.map((type) {
                    return ChoiceChip(
                      label: Text(type.name.toUpperCase()),
                      selected: _selectedVehicle == type,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedVehicle = type);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _vehicleNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Number',
                    prefixIcon: Icon(Icons.directions_bike),
                    border: OutlineInputBorder(),
                    hintText: 'MP09XX1234',
                  ),
                ),
                const SizedBox(height: 16),
                Text('Service Radius: ${_serviceRadius.toInt()} KM'),
                Slider(
                  value: _serviceRadius,
                  min: 5,
                  max: 25,
                  divisions: 20,
                  label: '${_serviceRadius.toInt()} KM',
                  onChanged: (val) => setState(() => _serviceRadius = val),
                ),
              ],
            ),
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text(loc.translate('bank_details')),
            content: Column(
              children: [
                TextField(
                  controller: _bankAccountController,
                  decoration: const InputDecoration(
                    labelText: 'Bank Account Number',
                    prefixIcon: Icon(Icons.account_balance),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _ifscController,
                  decoration: const InputDecoration(
                    labelText: 'IFSC Code',
                    prefixIcon: Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            isActive: _currentStep >= 4,
            state: _currentStep > 4 ? StepState.complete : StepState.indexed,
          ),
        ],
      ),
    );
  }
}
