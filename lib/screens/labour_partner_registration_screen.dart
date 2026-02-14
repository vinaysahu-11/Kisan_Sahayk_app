import 'package:flutter/material.dart';
import '../models/labour_models.dart';
import '../utils/app_localizations.dart';
import 'labour_partner/labour_partner_dashboard.dart';

class LabourPartnerRegistrationScreen extends StatefulWidget {
  const LabourPartnerRegistrationScreen({super.key});

  @override
  State<LabourPartnerRegistrationScreen> createState() =>
      _LabourPartnerRegistrationScreenState();
}

class _LabourPartnerRegistrationScreenState
    extends State<LabourPartnerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Personal Details
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _ageController = TextEditingController();

  // Bank Details
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();

  // Skill Details
  final List<LabourSkillType> _selectedSkills = [];
  final Map<LabourSkillType, TextEditingController> _fullDayWageControllers = {};
  final Map<LabourSkillType, TextEditingController> _halfDayWageControllers = {};
  final _experienceController = TextEditingController();
  final _serviceRadiusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize wage controllers for all skill types
    for (var skill in LabourSkillType.values) {
      _fullDayWageControllers[skill] = TextEditingController();
      _halfDayWageControllers[skill] = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('labour_partner_registration')),
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
                        _currentStep == 3 ? loc.translate('submit') : loc.translate('next'),
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
                        child: Text(loc.translate('back'), style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: Text(loc.translate('personal_details')),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildPersonalDetails(),
            ),
            Step(
              title: Text(loc.translate('bank_details')),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildBankDetails(),
            ),
            Step(
              title: Text(loc.translate('skills_experience')),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: _buildSkillDetails(),
            ),
            Step(
              title: Text(loc.translate('documents')),
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
          controller: _ageController,
          decoration: const InputDecoration(
            labelText: 'Age *',
            prefixIcon: Icon(Icons.cake),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v?.isEmpty ?? true) return 'Required';
            final age = int.tryParse(v!);
            if (age == null || age < 18 || age > 65) {
              return 'Age must be 18-65';
            }
            return null;
          },
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

  Widget _buildSkillDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Skills *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...LabourSkillType.values.map((skill) {
          final isSelected = _selectedSkills.contains(skill);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                CheckboxListTile(
                  title: Text(
                    _getSkillName(skill),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(_getSkillDescription(skill)),
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedSkills.add(skill);
                        _setDefaultWage(skill);
                      } else {
                        _selectedSkills.remove(skill);
                      }
                    });
                  },
                  activeColor: const Color(0xFF2E7D32),
                ),
                if (isSelected) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _fullDayWageControllers[skill],
                          decoration: const InputDecoration(
                            labelText: 'Full Day Wage (₹)',
                            prefixIcon: Icon(Icons.currency_rupee),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _halfDayWageControllers[skill],
                          decoration: const InputDecoration(
                            labelText: 'Half Day Wage (₹)',
                            prefixIcon: Icon(Icons.currency_rupee),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        TextFormField(
          controller: _experienceController,
          decoration: const InputDecoration(
            labelText: 'Total Experience (Years) *',
            prefixIcon: Icon(Icons.work_history),
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
            helperText: 'How far are you willing to travel?',
          ),
          keyboardType: TextInputType.number,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDocuments() {
    return Column(
      children: [
        _DocumentUploadCard(
          title: 'Profile Photo',
          icon: Icons.photo_camera,
          onUpload: () {},
        ),
        const SizedBox(height: 16),
        _DocumentUploadCard(
          title: 'Aadhaar Card',
          icon: Icons.account_box,
          onUpload: () {},
        ),
        const SizedBox(height: 16),
        _DocumentUploadCard(
          title: 'Experience Certificate (Optional)',
          icon: Icons.workspace_premium,
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
                  'Your profile will be verified within 24-48 hours',
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
    // Validate current step
    bool isValid = false;
    
    if (_currentStep == 0) {
      isValid = _validateStep0();
      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required fields in Personal Details'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (_currentStep == 1) {
      isValid = _validateStep1();
      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required fields in Bank Details'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (_currentStep == 2) {
      isValid = _validateStep2();
      if (!isValid) {
        return; // Error message already shown in _validateStep2
      }
    }

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
    // Trigger validation on all form fields and show error messages
    final isValid = _formKey.currentState?.validate() ?? false;
    return isValid;
  }

  bool _validateStep1() {
    // Trigger validation on all form fields and show error messages
    final isValid = _formKey.currentState?.validate() ?? false;
    return isValid;
  }

  bool _validateStep2() {
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.translate('select_at_least_one_skill')),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    // Trigger validation on all form fields and show error messages
    final isValid = _formKey.currentState?.validate() ?? false;
    return isValid;
  }

  void _setDefaultWage(LabourSkillType skill) {
    switch (skill) {
      case LabourSkillType.harvesting:
        _fullDayWageControllers[skill]!.text = '500';
        _halfDayWageControllers[skill]!.text = '300';
        break;
      case LabourSkillType.loadingUnloading:
        _fullDayWageControllers[skill]!.text = '450';
        _halfDayWageControllers[skill]!.text = '250';
        break;
      case LabourSkillType.fieldWorker:
        _fullDayWageControllers[skill]!.text = '400';
        _halfDayWageControllers[skill]!.text = '250';
        break;
      case LabourSkillType.irrigation:
        _fullDayWageControllers[skill]!.text = '480';
        _halfDayWageControllers[skill]!.text = '280';
        break;
      case LabourSkillType.constructionHelper:
        _fullDayWageControllers[skill]!.text = '550';
        _halfDayWageControllers[skill]!.text = '320';
        break;
      case LabourSkillType.generalFarm:
        _fullDayWageControllers[skill]!.text = '420';
        _halfDayWageControllers[skill]!.text = '250';
        break;
    }
  }

  void _completeRegistration() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: Text(AppLocalizations.of(context)!.translate('registration_successful')),
        content: const Text(
          'Your profile has been submitted. You will be notified once verified (24-48 hours).',
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LabourPartnerDashboardScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: Text(AppLocalizations.of(context)!.translate('go_to_dashboard')),
          ),
        ],
      ),
    );
  }

  String _getSkillName(LabourSkillType skill) {
    switch (skill) {
      case LabourSkillType.harvesting:
        return 'Harvesting';
      case LabourSkillType.loadingUnloading:
        return 'Loading & Unloading';
      case LabourSkillType.fieldWorker:
        return 'Field Worker';
      case LabourSkillType.irrigation:
        return 'Irrigation';
      case LabourSkillType.constructionHelper:
        return 'Construction Helper';
      case LabourSkillType.generalFarm:
        return 'General Farm Work';
    }
  }

  String _getSkillDescription(LabourSkillType skill) {
    switch (skill) {
      case LabourSkillType.harvesting:
        return 'Crop harvesting and collection';
      case LabourSkillType.loadingUnloading:
        return 'Loading/unloading goods';
      case LabourSkillType.fieldWorker:
        return 'General field maintenance';
      case LabourSkillType.irrigation:
        return 'Water management';
      case LabourSkillType.constructionHelper:
        return 'Farm construction work';
      case LabourSkillType.generalFarm:
        return 'All-round farm assistance';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _aadhaarController.dispose();
    _ageController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _experienceController.dispose();
    _serviceRadiusController.dispose();
    for (var controller in _fullDayWageControllers.values) {
      controller.dispose();
    }
    for (var controller in _halfDayWageControllers.values) {
      controller.dispose();
    }
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
