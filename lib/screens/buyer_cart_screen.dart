import 'package:flutter/material.dart';
import '../services/buyer_service.dart';
import '../models/seller_models.dart';
import '../utils/app_localizations.dart';

class BuyerCartScreen extends StatefulWidget {
  const BuyerCartScreen({super.key});

  @override
  State<BuyerCartScreen> createState() => _BuyerCartScreenState();
}

class _BuyerCartScreenState extends State<BuyerCartScreen> {
  final _service = BuyerService();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cartItems = _service.cartItems;
    final subtotal = _service.getCartSubtotal();
    final delivery = _service.getDeliveryFee();
    final platform = _service.getPlatformFee();
    final total = subtotal + delivery + platform;

    return Scaffold(
      appBar: AppBar(
        title: Text('${loc.translate('cart')} (${cartItems.length})'),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(loc.translate('clear_cart')),
                    content: Text(loc.translate('remove_all_items')),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.translate('cancel'))),
                      TextButton(
                        onPressed: () {
                          _service.clearCart();
                          Navigator.pop(ctx);
                          setState(() {});
                        },
                        child: Text(loc.translate('clear'), style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: Text(loc.translate('clear'), style: const TextStyle(color: Colors.white70)),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(loc.translate('your_cart_is_empty'), style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text(loc.translate('browse_and_add'), style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                    onPressed: () => Navigator.pop(context),
                    child: Text(loc.translate('start_shopping'), style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final product = _service.getProduct(item.productId);
                      if (product == null) return const SizedBox();
                      return _CartItemCard(
                        product: product,
                        quantity: item.quantity,
                        onIncrease: () {
                          if (item.quantity < product.stock) {
                            _service.updateCartQuantity(item.productId, item.quantity + 1);
                            setState(() {});
                          }
                        },
                        onDecrease: () {
                          if (item.quantity > product.moq) {
                            _service.updateCartQuantity(item.productId, item.quantity - 1);
                          } else {
                            _service.removeFromCart(item.productId);
                          }
                          setState(() {});
                        },
                        onRemove: () {
                          _service.removeFromCart(item.productId);
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),

                // Price Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, -2))],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        _priceRow(loc.translate('subtotal'), subtotal),
                        const SizedBox(height: 6),
                        _priceRow(loc.translate('delivery_fee'), delivery, note: delivery == 0 ? loc.translate('free') : null),
                        const SizedBox(height: 6),
                        _priceRow(loc.translate('platform_fee_pct'), platform),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(loc.translate('total'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            Text('₹${total.toInt()}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
                          ],
                        ),
                        if (delivery == 0) ...[
                          const SizedBox(height: 4),
                          Text('🎉 Free delivery applied!', style: TextStyle(fontSize: 12, color: Colors.green[700])),
                        ] else if (subtotal < 5000) ...[
                          const SizedBox(height: 4),
                          Text('Add ₹${(5000 - subtotal).toInt()} more for free delivery', style: TextStyle(fontSize: 12, color: Colors.orange[700])),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.pushNamed(context, '/buyer-checkout').then((_) => setState(() {})),
                            child: Text(loc.translate('proceed_to_checkout'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _priceRow(String label, double amount, {String? note}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(
          note ?? '₹${amount.toInt()}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: note != null ? Colors.green[700] : Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final AgriProduct product;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.product,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.agriculture, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('₹${product.price.toInt()} / ${product.unit}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: onDecrease,
                              child: Container(padding: const EdgeInsets.all(6), child: Icon(Icons.remove, size: 16, color: Colors.grey[600])),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            InkWell(
                              onTap: onIncrease,
                              child: Container(padding: const EdgeInsets.all(6), child: const Icon(Icons.add, size: 16, color: Color(0xFF2E7D32))),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text('₹${(product.price * quantity).toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
