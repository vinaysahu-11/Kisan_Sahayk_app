import 'package:flutter/material.dart';
import '../services/buyer_service.dart';
import '../utils/app_localizations.dart';

class BuyerCheckoutScreen extends StatefulWidget {
  const BuyerCheckoutScreen({super.key});

  @override
  State<BuyerCheckoutScreen> createState() => _BuyerCheckoutScreenState();
}

class _BuyerCheckoutScreenState extends State<BuyerCheckoutScreen> {
  final _service = BuyerService();
  int _step = 0; // 0=address, 1=payment, 2=confirm
  String? _selectedAddressId;
  String _paymentMode = 'online';
  bool _useWallet = false;
  bool _isPlacing = false;

  @override
  void initState() {
    super.initState();
    final addresses = _service.getAddresses();
    final defaultAddr = addresses.where((a) => a.isDefault).firstOrNull;
    _selectedAddressId = defaultAddr?.id ?? (addresses.isNotEmpty ? addresses.first.id : null);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cartItems = _service.cartItems;
    if (cartItems.isEmpty && _step < 2) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.translate('checkout')), backgroundColor: const Color(0xFF2E7D32)),
        body: Center(child: Text(loc.translate('cart_empty'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('checkout')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Stepper(
        currentStep: _step,
        type: StepperType.horizontal,
        controlsBuilder: (context, details) => const SizedBox(),
        steps: [
          Step(
            title: const Text('Address', style: TextStyle(fontSize: 12)),
            isActive: _step >= 0,
            state: _step > 0 ? StepState.complete : StepState.indexed,
            content: _buildAddressStep(),
          ),
          Step(
            title: const Text('Payment', style: TextStyle(fontSize: 12)),
            isActive: _step >= 1,
            state: _step > 1 ? StepState.complete : StepState.indexed,
            content: _buildPaymentStep(),
          ),
          Step(
            title: const Text('Confirm', style: TextStyle(fontSize: 12)),
            isActive: _step >= 2,
            content: _buildConfirmStep(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (_step > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step--),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Back'),
                  ),
                ),
              if (_step > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isPlacing ? null : _onContinue,
                  child: _isPlacing
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          _step == 2 ? loc.translate('place_order') : loc.translate('continue_btn'),
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onContinue() {
    final loc = AppLocalizations.of(context)!;
    if (_step == 0) {
      if (_selectedAddressId == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('select_delivery_address')), backgroundColor: Colors.red));
        return;
      }
      setState(() => _step = 1);
    } else if (_step == 1) {
      setState(() => _step = 2);
    } else {
      _placeOrder();
    }
  }

  Future<void> _placeOrder() async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _isPlacing = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate

    final walletUsed = _useWallet ? _service.walletBalance : 0.0;
    final orders = await _service.placeOrder(
      addressId: _selectedAddressId!,
      paymentMode: _paymentMode,
      walletUsed: walletUsed,
    );

    setState(() => _isPlacing = false);

    if (orders.isNotEmpty && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 64),
              const SizedBox(height: 16),
              const Text('Order Placed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('${orders.length} order(s) placed successfully', style: TextStyle(color: Colors.grey[600])),
              if (_paymentMode == 'online') ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Icon(Icons.security, size: 18, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(child: Text(loc.translate('escrow_payment_held'), style: TextStyle(fontSize: 12, color: Colors.blue[700]))),
                    ],
                  ),
                ),
              ],
              if (_paymentMode == 'cod') ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Icon(Icons.money, size: 18, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(child: Text(loc.translate('cod_pay_cash'), style: TextStyle(fontSize: 12, color: Colors.orange[700]))),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(ctx); Navigator.pushNamedAndRemoveUntil(context, '/buyer-orders', (r) => r.isFirst); },
              child: Text(loc.translate('view_orders')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
              onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
              child: Text(loc.translate('continue_shopping'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  // ====== ADDRESS STEP ======
  Widget _buildAddressStep() {
    final addresses = _service.getAddresses();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Select Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New'),
              onPressed: () => Navigator.pushNamed(context, '/buyer-address').then((_) => setState(() {})),
            ),
          ],
        ),
        if (addresses.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.location_off, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Text('No addresses saved', style: TextStyle(color: Colors.grey[500])),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/buyer-address').then((_) => setState(() {})),
                  child: const Text('Add Address'),
                ),
              ],
            ),
          ),
        RadioGroup<String>(
          groupValue: _selectedAddressId,
          onChanged: (v) => setState(() => _selectedAddressId = v),
          child: Column(
            children: addresses.map((addr) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: RadioListTile<String>(
                value: addr.id,
                activeColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: _selectedAddressId == addr.id ? const Color(0xFF2E7D32).withValues(alpha: 0.05) : Colors.grey[50],
                title: Row(
                  children: [
                    Text(addr.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (addr.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF2E7D32).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: const Text('Default', style: TextStyle(fontSize: 10, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(addr.fullAddress, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    const SizedBox(height: 2),
                    Text('📞 ${addr.mobile}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  // ====== PAYMENT STEP ======
  Widget _buildPaymentStep() {
    // Check if all cart items support COD
    final allCodEnabled = _service.cartItems.every((item) {
      final p = _service.getProduct(item.productId);
      return p?.codEnabled == true;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),

        RadioGroup<String>(
          groupValue: _paymentMode,
          onChanged: (v) => setState(() => _paymentMode = v!),
          child: Column(
            children: [
              RadioListTile<String>(
                value: 'online',
                activeColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: _paymentMode == 'online' ? const Color(0xFF2E7D32).withValues(alpha: 0.05) : Colors.grey[50],
                title: const Text('Online Payment', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('UPI / Card / Net Banking (Simulated)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          Icon(Icons.security, size: 14, color: Colors.blue[700]),
                          const SizedBox(width: 6),
                          Expanded(child: Text('Escrow protected — money released only after delivery', style: TextStyle(fontSize: 11, color: Colors.blue[700]))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RadioListTile<String>(
                value: 'cod',
                activeColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: _paymentMode == 'cod' ? const Color(0xFF2E7D32).withValues(alpha: 0.05) : Colors.grey[50],
                title: Row(
                  children: [
                    const Text('Cash on Delivery', style: TextStyle(fontWeight: FontWeight.w600)),
                    if (!allCodEnabled) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(4)),
                        child: Text('Not available', style: TextStyle(fontSize: 10, color: Colors.red[700])),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(allCodEnabled ? 'Extra ₹25 COD charge applies' : 'Some items in your cart don\'t support COD', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                enabled: allCodEnabled,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),

        // Wallet
        SwitchListTile(
          value: _useWallet,
          onChanged: _service.walletBalance > 0 ? (v) => setState(() => _useWallet = v) : null,
          activeThumbColor: const Color(0xFF2E7D32),
          contentPadding: EdgeInsets.zero,
          title: const Text('Use Wallet Balance', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            'Available: ₹${_service.walletBalance.toInt()}',
            style: TextStyle(fontSize: 13, color: _service.walletBalance > 0 ? Colors.green[700] : Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  // ====== CONFIRM STEP ======
  Widget _buildConfirmStep() {
    final subtotal = _service.getCartSubtotal();
    final delivery = _service.getDeliveryFee();
    final codCharge = _paymentMode == 'cod' ? _service.getCODCharge() : 0.0;
    final platform = _service.getPlatformFee();
    final walletUsed = _useWallet ? _service.walletBalance.clamp(0.0, subtotal + delivery + codCharge + platform) : 0.0;
    final total = subtotal + delivery + codCharge + platform - walletUsed;

    final address = _service.getAddresses().where((a) => a.id == _selectedAddressId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),

        // Delivery Address
        if (address != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF2E7D32), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(address.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(address.fullAddress, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),

        // Payment mode
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Icon(_paymentMode == 'online' ? Icons.payment : Icons.money, color: _paymentMode == 'online' ? Colors.blue : Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(_paymentMode == 'online' ? 'Online Payment (Escrow)' : 'Cash on Delivery', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Items
        const Text('Items', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ..._service.cartItems.map((item) {
          final product = _service.getProduct(item.productId);
          if (product == null) return const SizedBox();
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(child: Text('${product.name} × ${item.quantity}', style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                Text('₹${(product.price * item.quantity).toInt()}', style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          );
        }),

        const Divider(height: 20),
        _summaryRow('Subtotal', subtotal),
        _summaryRow('Delivery Fee', delivery, highlight: delivery == 0 ? 'FREE' : null),
        if (codCharge > 0) _summaryRow('COD Charge', codCharge),
        _summaryRow('Platform Fee (2%)', platform),
        if (walletUsed > 0) _summaryRow('Wallet Used', -walletUsed, isGreen: true),
        const Divider(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Payable', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text('₹${total.toInt()}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
          ],
        ),
      ],
    );
  }

  Widget _summaryRow(String label, double amount, {String? highlight, bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            highlight ?? (isGreen ? '-₹${amount.abs().toInt()}' : '₹${amount.toInt()}'),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: highlight != null || isGreen ? Colors.green[700] : Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}
