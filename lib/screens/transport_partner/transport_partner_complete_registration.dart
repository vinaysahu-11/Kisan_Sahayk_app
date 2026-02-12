import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_localizations.dart';

class TransportPartnerCompleteRegistration extends StatefulWidget {
  const TransportPartnerCompleteRegistration({super.key});

  @override
  State<TransportPartnerCompleteRegistration> createState() => _TransportPartnerCompleteRegistrationState();
}

class _TransportPartnerCompleteRegistrationState extends State<TransportPartnerCompleteRegistration> {
  final _formKey = GlobalKey<FormState>();
  String selectedVehicle = 'Pickup';
  final List<String> vehicleTypes = ['Pickup', 'Tractor', 'Mini Truck', 'Full Truck'];
  
  final phoneController = TextEditingController();
  final vehicleNumberController = TextEditingController();
  final priceController = TextEditingController();
  final serviceAreaController = TextEditingController();
  bool licenseUploaded = false;

  @override
  void dispose() {
    phoneController.dispose();
    vehicleNumberController.dispose();
    priceController.dispose();
    serviceAreaController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      if (!licenseUploaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.translate('upload_driving_license'))),
        );
        return;
      }

      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      // Save registration data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('transport_partner_status', 'pending');
      await prefs.setString('transport_phone', phoneController.text);
      await prefs.setString('transport_vehicle_type', selectedVehicle);
      await prefs.setString('transport_vehicle_number', vehicleNumberController.text);
      await prefs.setString('transport_price', priceController.text);
      await prefs.setString('transport_area', serviceAreaController.text);

      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(loc.translate('registration_submitted')),
          backgroundColor: const Color(0xFF2E6B3F),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('transport_partner_registration'), style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E6B3F), Color(0xFF3F8D54)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone Number
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: '10-digit mobile number',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.white,
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2E6B3F), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter phone number';
                        if (value.length != 10) return 'Enter valid 10-digit number';
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Vehicle Type
                    Row(
                      children: [
                        Icon(Icons.local_shipping, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Vehicle Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF424242),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.5,
                      children: vehicleTypes.map((type) {
                        final isSelected = selectedVehicle == type;
                        return InkWell(
                          onTap: () => setState(() => selectedVehicle = type),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF2E6B3F) : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected ? const Color(0xFF2E6B3F) : Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Vehicle Number
                    Row(
                      children: [
                        Icon(Icons.confirmation_number, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Vehicle Number',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF424242),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: vehicleNumberController,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'e.g., CG04AB1234',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2E6B3F), width: 2),
                        ),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Enter vehicle number' : null,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Driving License
                    Row(
                      children: [
                        Icon(Icons.credit_card, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Driving License',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF424242),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        setState(() => licenseUploaded = !licenseUploaded);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(licenseUploaded ? 'License uploaded' : 'License removed')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2E6B3F),
                            width: 1.5,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              licenseUploaded ? Icons.check_circle : Icons.upload_outlined,
                              color: const Color(0xFF2E6B3F),
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              licenseUploaded ? 'License Uploaded' : 'Upload License Photo',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2E6B3F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Price per KM
                    Row(
                      children: [
                        Icon(Icons.currency_rupee, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Price per KM (₹)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF424242),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'e.g., 15',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2E6B3F), width: 2),
                        ),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Enter price per KM' : null,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Service Area
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Service Area',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF424242),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: serviceAreaController,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'e.g., Raipur, Chhattisgarh',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2E6B3F), width: 2),
                        ),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Enter service area' : null,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _submitRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E6B3F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Complete Registration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
