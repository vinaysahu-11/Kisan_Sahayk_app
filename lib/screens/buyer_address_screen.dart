import 'package:flutter/material.dart';
import '../services/buyer_service.dart';

class BuyerAddressScreen extends StatefulWidget {
  const BuyerAddressScreen({super.key});

  @override
  State<BuyerAddressScreen> createState() => _BuyerAddressScreenState();
}

class _BuyerAddressScreenState extends State<BuyerAddressScreen> {
  final _service = BuyerService();

  @override
  Widget build(BuildContext context) {
    final addresses = _service.getAddresses();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_off, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('No addresses saved', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final addr = addresses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(addr.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            if (addr.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFF2E7D32).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                child: const Text('Default', style: TextStyle(fontSize: 10, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                              ),
                            ],
                            const Spacer(),
                            PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'default') {
                                  _service.setDefaultAddress(addr.id);
                                  setState(() {});
                                } else if (val == 'delete') {
                                  _service.deleteAddress(addr.id);
                                  setState(() {});
                                }
                              },
                              itemBuilder: (_) => [
                                if (!addr.isDefault)
                                  const PopupMenuItem(value: 'default', child: Text('Set as Default')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(addr.addressLine, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                        Text('${addr.city}, ${addr.state} - ${addr.pincode}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                        const SizedBox(height: 4),
                        Text('📞 ${addr.mobile}', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressSheet(context),
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Address', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final stateCtrl = TextEditingController();
    final pincodeCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add New Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder(), isDense: true),
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: mobileCtrl,
                decoration: const InputDecoration(labelText: 'Mobile Number *', border: OutlineInputBorder(), isDense: true),
                keyboardType: TextInputType.phone,
                validator: (v) => (v?.trim().length ?? 0) < 10 ? 'Enter valid mobile' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'Address Line *', border: OutlineInputBorder(), isDense: true),
                maxLines: 2,
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: cityCtrl,
                      decoration: const InputDecoration(labelText: 'City *', border: OutlineInputBorder(), isDense: true),
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: stateCtrl,
                      decoration: const InputDecoration(labelText: 'State *', border: OutlineInputBorder(), isDense: true),
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: pincodeCtrl,
                decoration: const InputDecoration(labelText: 'Pincode *', border: OutlineInputBorder(), isDense: true),
                keyboardType: TextInputType.number,
                validator: (v) => (v?.trim().length ?? 0) < 6 ? 'Enter valid pincode' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      _service.addAddressFromFields(
                        name: nameCtrl.text.trim(),
                        mobile: mobileCtrl.text.trim(),
                        addressLine: addressCtrl.text.trim(),
                        city: cityCtrl.text.trim(),
                        state: stateCtrl.text.trim(),
                        pincode: pincodeCtrl.text.trim(),
                      );
                      if (mounted) {
                        Navigator.pop(ctx);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Address added'), backgroundColor: Color(0xFF2E7D32)),
                        );
                      }
                    }
                  },
                  child: const Text('Save Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
