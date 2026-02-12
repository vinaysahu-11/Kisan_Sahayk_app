import 'package:flutter/material.dart';
import '../models/seller_models.dart';
import '../services/seller_service.dart';
import '../utils/app_localizations.dart';
import 'seller_dashboard_screen.dart';

class SellerRegistrationScreen extends StatefulWidget {
  final String mobile;

  const SellerRegistrationScreen({super.key, required this.mobile});

  @override
  State<SellerRegistrationScreen> createState() => _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState extends State<SellerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _service = SellerService();
  
  SellerType _selectedType = SellerType.farmer;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('complete_registration')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Text
              Text(
                loc.translate('welcome_exclaim'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete your profile to start selling',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Profile Photo (Placeholder)
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name / Business Name*',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // Mobile (Read-only)
              TextFormField(
                initialValue: widget.mobile,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Seller Type
              const Text(
                'Seller Type*',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              RadioGroup<SellerType>(
                groupValue: _selectedType,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
                child: Column(
                  children: SellerType.values
                      .map((type) => RadioListTile<SellerType>(
                            title: Text(_getSellerTypeName(type)),
                            subtitle: Text(
                              _getSellerTypeDescription(type),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            value: type,
                            activeColor: const Color(0xFF2E7D32),
                            contentPadding: EdgeInsets.zero,
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location / City*',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                  hintText: 'e.g., Indore, Madhya Pradesh',
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 32),

              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'You will be registered as:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(text: 'Basic Seller'),
                    _InfoTile(text: 'Commission: 3%'),
                    _InfoTile(text: 'Can list unlimited products'),
                    _InfoTile(text: 'Upgrade to Big Seller anytime'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        loc.translate('complete_registration'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSellerTypeName(SellerType type) {
    switch (type) {
      case SellerType.farmer:
        return 'Farmer';
      case SellerType.shop:
        return 'Shop / Store';
      case SellerType.mill:
        return 'Mill / Processing Unit';
      case SellerType.individual:
        return 'Individual Seller';
    }
  }

  String _getSellerTypeDescription(SellerType type) {
    switch (type) {
      case SellerType.farmer:
        return 'Selling crops and farm produce';
      case SellerType.shop:
        return 'Retail shop or agricultural store';
      case SellerType.mill:
        return 'Processing and packaging unit';
      case SellerType.individual:
        return 'Individual seller or trader';
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final loc = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);

    try {
      await _service.registerSeller(
        mobile: widget.mobile,
        name: _nameController.text,
        type: _selectedType,
        location: _locationController.text,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          title: Text(loc.translate('welcome_exclaim')),
          content: Text(
            loc.translate('success'),
            textAlign: TextAlign.center,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SellerDashboardScreen(),
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
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}

class _InfoTile extends StatelessWidget {
  final String text;

  const _InfoTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
