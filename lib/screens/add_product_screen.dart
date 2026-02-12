import 'package:flutter/material.dart';
import '../models/seller_models.dart';
import '../services/seller_service.dart';
import '../utils/app_localizations.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _service = SellerService();
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Step 1: Category
  AgriCategory? _selectedCategory;

  // Step 2: Product Details
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _moqController = TextEditingController();
  String _selectedUnit = 'kg';
  final Map<String, TextEditingController> _dynamicFieldControllers = {};

  // Step 3: Delivery Options
  bool _codEnabled = true;
  bool _selfPickup = true;
  bool _sellerDelivery = false;

  // Step 4: Pricing Preview
  double get _customerPays => double.tryParse(_priceController.text) ?? 0;
  double get _commission {
    if (_selectedCategory == null) return 0;
    return _customerPays * _selectedCategory!.commissionPercent / 100;
  }
  double get _sellerReceives => _customerPays - _commission;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('add_new_product')),
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
                        _currentStep == 4 ? 'Publish Product' : 'Continue',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: Text(loc.translate('category')),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildCategoryStep(),
            ),
            Step(
              title: Text(loc.translate('product_details')),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildDetailsStep(),
            ),
            Step(
              title: Text(loc.translate('delivery_options')),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: _buildDeliveryStep(loc),
            ),
            Step(
              title: Text(loc.translate('pricing_preview')),
              isActive: _currentStep >= 3,
              state: _currentStep > 3 ? StepState.complete : StepState.indexed,
              content: _buildPricingStep(),
            ),
            Step(
              title: Text(loc.translate('confirm')),
              isActive: _currentStep >= 4,
              content: _buildConfirmStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStep() {
    final categories = _service.getRootCategories();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Product Category',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        RadioGroup<AgriCategory>(
          groupValue: _selectedCategory,
          onChanged: (val) {
            setState(() => _selectedCategory = val);
          },
          child: Column(
            children: categories.map((category) => RadioListTile<AgriCategory>(
                  title: Text(category.name),
                  subtitle: Text('Commission: ${category.commissionPercent}%'),
                  value: category,
                  activeColor: const Color(0xFF2E7D32),
                )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsStep() {
    final dynamicFields = _selectedCategory?.dynamicFields?['details'] ?? [];
    
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Product Name *',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description *',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price *',
                  prefixText: '₹',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Unit *',
                  border: OutlineInputBorder(),
                ),
                items: ['kg', 'ton', 'piece', 'liter', 'bag', 'quintal']
                    .map((unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedUnit = val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _moqController,
                decoration: const InputDecoration(
                  labelText: 'MOQ *',
                  border: OutlineInputBorder(),
                  helperText: 'Min Order',
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
          ],
        ),
        
        // Dynamic fields based on category
        if (dynamicFields.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Category Specific Details',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          ...dynamicFields.map((field) {
            _dynamicFieldControllers[field] ??= TextEditingController();
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _dynamicFieldControllers[field],
                decoration: InputDecoration(
                  labelText: field,
                  border: const OutlineInputBorder(),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildDeliveryStep(AppLocalizations loc) {
    final seller = _service.getCurrentSeller();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Options',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Cash on Delivery (COD)'),
          subtitle: Text(loc.translate('cod_desc')),
          value: _codEnabled,
          onChanged: (val) => setState(() => _codEnabled = val),
          activeThumbColor: const Color(0xFF2E7D32),
        ),
        SwitchListTile(
          title: const Text('Self Pickup'),
          subtitle: Text('From ${seller?.location ?? "your location"}'),
          value: _selfPickup,
          onChanged: (val) => setState(() => _selfPickup = val),
          activeThumbColor: const Color(0xFF2E7D32),
        ),
        SwitchListTile(
          title: Text(loc.translate('seller_delivery')),
          subtitle: Text(loc.translate('seller_delivery_desc')),
          value: _sellerDelivery,
          onChanged: (val) => setState(() => _sellerDelivery = val),
          activeThumbColor: const Color(0xFF2E7D32),
        ),
      ],
    );
  }

  Widget _buildPricingStep() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pricing Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          _PricingRow(
            label: 'Customer Pays',
            value: _customerPays,
            color: Colors.black,
          ),
          const Divider(height: 24),
          _PricingRow(
            label: 'Platform Commission (${_selectedCategory?.commissionPercent ?? 0}%)',
            value: _commission,
            color: Colors.red,
            isNegative: true,
          ),
          const Divider(height: 24),
          _PricingRow(
            label: 'You Receive',
            value: _sellerReceives,
            color: const Color(0xFF2E7D32),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Product Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _ConfirmTile(label: 'Category', value: _selectedCategory?.name ?? ''),
        _ConfirmTile(label: 'Product', value: _nameController.text),
        _ConfirmTile(label: 'Price', value: '₹${_priceController.text}/$_selectedUnit'),
        _ConfirmTile(label: 'Stock', value: _stockController.text),
        _ConfirmTile(label: 'MOQ', value: _moqController.text),
        _ConfirmTile(label: 'COD', value: _codEnabled ? 'Enabled' : 'Disabled'),
        _ConfirmTile(label: 'You Receive', value: '₹${_sellerReceives.toStringAsFixed(2)}'),
      ],
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0 && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (_currentStep == 1 && !_formKey.currentState!.validate()) {
      return;
    }

    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _publishProduct();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _publishProduct() async {
    final seller = _service.getCurrentSeller();
    if (seller == null || _selectedCategory == null) return;

    final dynamicFields = <String, dynamic>{};
    _dynamicFieldControllers.forEach((key, controller) {
      dynamicFields[key] = controller.text;
    });

    final product = AgriProduct(
      id: 'P${DateTime.now().millisecondsSinceEpoch}',
      sellerId: seller.id,
      categoryId: _selectedCategory!.id,
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      stock: int.parse(_stockController.text),
      unit: _selectedUnit,
      moq: int.parse(_moqController.text),
      images: [],
      location: seller.location,
      codEnabled: _codEnabled,
      selfPickup: _selfPickup,
      sellerDelivery: _sellerDelivery,
      dynamicFields: dynamicFields,
      listedDate: DateTime.now(),
      isActive: true,
    );

    await _service.addProduct(product);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('Success!'),
        content: const Text('Product listed successfully'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _moqController.dispose();
    for (final controller in _dynamicFieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

class _PricingRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isNegative;
  final bool isBold;

  const _PricingRow({
    required this.label,
    required this.value,
    required this.color,
    this.isNegative = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        Text(
          '${isNegative ? "-" : ""}₹${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ConfirmTile extends StatelessWidget {
  final String label;
  final String value;

  const _ConfirmTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
