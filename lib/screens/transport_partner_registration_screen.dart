import 'package:flutter/material.dart';
import '../models/transport_models.dart';
import 'transport_partner/transport_partner_dashboard.dart';

class TransportPartnerRegistrationScreen extends StatefulWidget {
  const TransportPartnerRegistrationScreen({super.key});

  @override
  State<TransportPartnerRegistrationScreen> createState() =>
      _TransportPartnerRegistrationScreenState();
}

class _TransportPartnerRegistrationScreenState
    extends State<TransportPartnerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Personal Details
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _aadhaarController = TextEditingController();

  // Bank Details
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();

  // Vehicle Details
  VehicleType? _selectedVehicleType;
  final _loadCapacityController = TextEditingController();
  final _baseRateController = TextEditingController();
  final _minFareController = TextEditingController();
  final _serviceRadiusController = TextEditingController();
  final List<LoadType> _selectedLoadTypes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Partner Registration'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _currentStep == 3 ? 'Complete Registration' : 'Continue',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Back', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Personal Details'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildPersonalDetails(),
            ),
            Step(
              title: const Text('Bank Details'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildBankDetails(),
            ),
            Step(
              title: const Text('Vehicle Details'),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: _buildVehicleDetails(),
            ),
            Step(
              title: const Text('Documents'),
              isActive: _currentStep >= 3,
              state: _currentStep > 3 ? StepState.complete : StepState.indexed,
              content: _buildDocuments(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDetails() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number *',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email (Optional)',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _aadhaarController,
          decoration: const InputDecoration(
            labelText: 'Aadhaar Number *',
            prefixIcon: Icon(Icons.badge),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          maxLength: 12,
          validator: (v) => v?.length != 12 ? 'Invalid Aadhaar' : null,
        ),
      ],
    );
  }

  Widget _buildBankDetails() {
    return Column(
      children: [
        TextFormField(
          controller: _accountHolderController,
          decoration: const InputDecoration(
            labelText: 'Account Holder Name *',
            prefixIcon: Icon(Icons.account_circle),
            border: OutlineInputBorder(),
          ),
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _accountNumberController,
          decoration: const InputDecoration(
            labelText: 'Account Number *',
            prefixIcon: Icon(Icons.account_balance),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ifscController,
          decoration: const InputDecoration(
            labelText: 'IFSC Code *',
            prefixIcon: Icon(Icons.code),
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bankNameController,
          decoration: const InputDecoration(
            labelText: 'Bank Name *',
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(),
          ),
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildVehicleDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vehicle Type *',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
          Column(
            children: VehicleType.values.map((type) => RadioListTile<VehicleType>(
                  title: Text(_getVehicleTypeName(type)),
                  value: type,
                  groupValue: _selectedVehicleType,
                  onChanged: (val) {
                    setState(() {
                      _selectedVehicleType = val;
                      if (val != null) {
                        _setDefaultRates(val);
                      }
                    });
                  },
                  activeColor: const Color(0xFF2E7D32),
                )).toList(),
          ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _loadCapacityController,
          decoration: const InputDecoration(
            labelText: 'Load Capacity (Ton) *',
            prefixIcon: Icon(Icons.scale),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _baseRateController,
          decoration: const InputDecoration(
            labelText: 'Base Rate per KM (₹) *',
            prefixIcon: Icon(Icons.currency_rupee),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _minFareController,
          decoration: const InputDecoration(
            labelText: 'Minimum Fare (₹) *',
            prefixIcon: Icon(Icons.money),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _serviceRadiusController,
          decoration: const InputDecoration(
            labelText: 'Service Radius (KM) *',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        const Text(
          'Supported Load Types *',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: LoadType.values.map((type) {
            final isSelected = _selectedLoadTypes.contains(type);
            return FilterChip(
              label: Text(_getLoadTypeName(type)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedLoadTypes.add(type);
                  } else {
                    _selectedLoadTypes.remove(type);
                  }
                });
              },
              selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.3),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDocuments() {
    return Column(
      children: [
        _DocumentUploadCard(
          title: 'Vehicle RC',
          icon: Icons.description,
          onUpload: () {},
        ),
        const SizedBox(height: 16),
        _DocumentUploadCard(
          title: 'Driving License',
          icon: Icons.badge,
          onUpload: () {},
        ),
        const SizedBox(height: 16),
        _DocumentUploadCard(
          title: 'Aadhaar Card',
          icon: Icons.account_box,
          onUpload: () {},
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your documents will be verified within 24-48 hours',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0 && !_validateStep0()) return;
    if (_currentStep == 1 && !_validateStep1()) return;
    if (_currentStep == 2 && !_validateStep2()) return;

    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      _completeRegistration();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  bool _validateStep0() {
    return _formKey.currentState!.validate();
  }

  bool _validateStep1() {
    return _formKey.currentState!.validate();
  }

  bool _validateStep2() {
    if (_selectedVehicleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select vehicle type')),
      );
      return false;
    }
    if (_selectedLoadTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one load type')),
      );
      return false;
    }
    return _formKey.currentState!.validate();
  }

  void _setDefaultRates(VehicleType type) {
    switch (type) {
      case VehicleType.tractor:
        _loadCapacityController.text = '2';
        _baseRateController.text = '15';
        _minFareController.text = '300';
        _serviceRadiusController.text = '50';
        break;
      case VehicleType.pickup:
        _loadCapacityController.text = '1';
        _baseRateController.text = '12';
        _minFareController.text = '250';
        _serviceRadiusController.text = '40';
        break;
      case VehicleType.miniTruck:
        _loadCapacityController.text = '3';
        _baseRateController.text = '18';
        _minFareController.text = '400';
        _serviceRadiusController.text= '60';
        break;
      case VehicleType.largeTruck:
        _loadCapacityController.text = '10';
        _baseRateController.text = '25';
        _minFareController.text = '600';
        _serviceRadiusController.text = '100';
        break;
    }
  }

  void _completeRegistration() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('Registration Successful!'),
        content: const Text(
          'Your application has been submitted. You will be notified once verified (24-48 hours).',
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransportPartnerDashboardScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }

  String _getVehicleTypeName(VehicleType type) {
    switch (type) {
      case VehicleType.tractor:
        return 'Tractor';
      case VehicleType.pickup:
        return 'Pickup';
      case VehicleType.miniTruck:
        return 'Mini Truck';
      case VehicleType.largeTruck:
        return 'Large Truck';
    }
  }

  String _getLoadTypeName(LoadType type) {
    switch (type) {
      case LoadType.crop:
        return 'Crop';
      case LoadType.fertilizer:
        return 'Fertilizer';
      case LoadType.equipment:
        return 'Equipment';
      case LoadType.other:
        return 'Other';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _aadhaarController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _loadCapacityController.dispose();
    _baseRateController.dispose();
    _minFareController.dispose();
    _serviceRadiusController.dispose();
    super.dispose();
  }
}

class _DocumentUploadCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onUpload;

  const _DocumentUploadCard({
    required this.title,
    required this.icon,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Upload'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
