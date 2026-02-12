import 'package:flutter/material.dart';
import '../services/buyer_service.dart';
import '../models/seller_models.dart';
import '../utils/app_localizations.dart';

class BuyerProductDetailScreen extends StatefulWidget {
  final String productId;

  const BuyerProductDetailScreen({super.key, required this.productId});

  @override
  State<BuyerProductDetailScreen> createState() => _BuyerProductDetailScreenState();
}

class _BuyerProductDetailScreenState extends State<BuyerProductDetailScreen> {
  final _service = BuyerService();
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final product = _service.getProduct(widget.productId);
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.translate('product')), backgroundColor: const Color(0xFF2E7D32)),
        body: Center(child: Text(loc.translate('product_not_found_msg'))),
      );
    }

    final seller = _service.getSeller(product.sellerId);
    final category = _service.getCategory(product.categoryId);
    final sellerRating = _service.getSellerRating(product.sellerId);
    final ratings = _service.getProductRatings(widget.productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('product_details')),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.pushNamed(context, '/buyer-cart'),
              ),
              if (_service.cartItemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('${_service.cartItemCount}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 250,
              width: double.infinity,
              color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
              child: Stack(
                children: [
                  Center(child: Icon(Icons.agriculture, size: 80, color: const Color(0xFF2E7D32).withValues(alpha: 0.3))),
                  if (product.codEnabled)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(6)),
                        child: Text(loc.translate('cod_available'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                    ),
                  if (product.stock <= 5 && product.stock > 0)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                        child: Text('Only ${product.stock} left!', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  if (category != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFF2E7D32).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(category.name, style: const TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                    ),

                  // Name
                  Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${product.price.toInt()}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('per ${product.unit}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (product.moq > 1)
                    Text('Minimum order: ${product.moq} ${product.unit}', style: TextStyle(fontSize: 13, color: Colors.orange[700])),
                  const SizedBox(height: 4),
                  Text(product.stock > 0 ? 'In Stock (${product.stock} ${product.unit} available)' : 'Out of Stock',
                      style: TextStyle(fontSize: 13, color: product.stock > 0 ? Colors.green[700] : Colors.red[700], fontWeight: FontWeight.w500)),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Description
                  Text(loc.translate('description'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(product.description, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Seller Info
                  Text(loc.translate('seller_information'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (seller != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                                radius: 22,
                                child: Text(seller.name[0], style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w700, fontSize: 18)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(seller.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                        const SizedBox(width: 6),
                                        _levelBadge(seller.level),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(seller.location, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  ],
                                ),
                              ),
                              if (sellerRating > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star, size: 16, color: Colors.amber[700]),
                                      const SizedBox(width: 3),
                                      Text(sellerRating.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.w700, color: Colors.amber[800])),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _infoChip(Icons.phone, seller.mobile),
                              const SizedBox(width: 12),
                              _infoChip(Icons.location_on, seller.location),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Delivery Info
                  Text(loc.translate('delivery_and_payment'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _infoRow(Icons.local_shipping, loc.translate('delivery'), product.sellerDelivery ? loc.translate('seller_delivers_free') : loc.translate('self_pickup_only')),
                  const SizedBox(height: 8),
                  _infoRow(Icons.money, 'COD', product.codEnabled ? loc.translate('cod_charge_desc') : loc.translate('not_available')),
                  const SizedBox(height: 8),
                  _infoRow(Icons.security, loc.translate('escrow'), loc.translate('escrow_desc')),
                  const SizedBox(height: 8),
                  _infoRow(Icons.replay, loc.translate('returns'), loc.translate('returns_desc')),

                  // Ratings
                  if (ratings.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text('Ratings (${ratings.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ...ratings.take(3).map((r) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ...List.generate(5, (i) => Icon(i < r.productRating ? Icons.star : Icons.star_border, size: 16, color: Colors.amber[700])),
                              const Spacer(),
                              Text(_formatDate(r.date), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                            ],
                          ),
                          if (r.review != null && r.review!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(r.review!, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                          ],
                        ],
                      ),
                    )),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: product.stock > 0
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, -2))],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Quantity selector
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 20),
                            onPressed: _quantity > product.moq ? () => setState(() => _quantity--) : null,
                            constraints: const BoxConstraints(minWidth: 36),
                          ),
                          Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: _quantity < product.stock ? () => setState(() => _quantity++) : null,
                            constraints: const BoxConstraints(minWidth: 36),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_cart, color: Colors.white),
                        label: Text(loc.translate('add_to_cart'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          _service.addToCart(product.id, _quantity);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart'),
                              backgroundColor: const Color(0xFF2E7D32),
                              behavior: SnackBarBehavior.floating,
                              action: SnackBarAction(
                                label: loc.translate('view_cart'),
                                textColor: Colors.white,
                                onPressed: () => Navigator.pushNamed(context, '/buyer-cart'),
                              ),
                            ),
                          );
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              child: SafeArea(
                child: Center(child: Text(loc.translate('out_of_stock'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red))),
              ),
            ),
    );
  }

  Widget _levelBadge(SellerLevel level) {
    final colors = {SellerLevel.basic: Colors.grey, SellerLevel.bigSeller: Colors.amber};
    final names = {SellerLevel.basic: 'Basic', SellerLevel.bigSeller: 'Big Seller'};
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: colors[level]!.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
      child: Text(names[level]!, style: TextStyle(fontSize: 10, color: colors[level]!, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(value, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
