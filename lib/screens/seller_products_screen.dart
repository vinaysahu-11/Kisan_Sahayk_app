import 'package:flutter/material.dart';
import '../models/seller_models.dart';
import '../services/seller_service.dart';
import '../utils/app_localizations.dart';

class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({super.key});

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  final _service = SellerService();
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final seller = _service.getCurrentSeller();
    if (seller == null) return const Scaffold();

    var products = _service.getSellerProducts(seller.id);

    if (_filter == 'low') {
      products = _service.getLowStockProducts(seller.id, 10);
    } else if (_filter == 'out') {
      products = _service.getOutOfStockProducts(seller.id);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('my_products')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _filter == 'all',
                  onTap: () => setState(() => _filter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Low Stock',
                  isSelected: _filter == 'low',
                  onTap: () => setState(() => _filter = 'low'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Out of Stock',
                  isSelected: _filter == 'out',
                  onTap: () => setState(() => _filter = 'out'),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _ProductCard(
                        product: products[index],
                        onRefresh: () => setState(() {}),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final AgriProduct product;
  final VoidCallback onRefresh;

  const _ProductCard({required this.product, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final service = SellerService();
    final category = service.getAllCategories().firstWhere(
          (c) => c.id == product.categoryId,
          orElse: () => AgriCategory(
            id: '',
            name: 'Unknown',
            commissionPercent: 0,
            isEnabled: false,
          ),
        );

    Color stockColor;
    if (product.stock == 0) {
      stockColor = Colors.red;
    } else if (product.stock <= 10) {
      stockColor = Colors.orange;
    } else {
      stockColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.agriculture,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '₹${product.price.toInt()}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          Text(
                            '/${product.unit}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${product.stock.toInt()} ${product.unit}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: stockColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orders',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${product.orderCount}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Views',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${product.viewCount}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _updateStock(context, product),
                    icon: const Icon(Icons.inventory, size: 18),
                    label: Text(loc.translate('update_stock')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Edit product functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit feature coming soon')),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(loc.translate('edit')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStock(BuildContext context, AgriProduct product) async {
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: product.stock.toInt().toString());
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('update_stock')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Stock (${product.unit})',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: Text(loc.translate('save')),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final newStock = int.tryParse(result);
      if (newStock != null && newStock >= 0) {
        final service = SellerService();
        service.updateProductStock(product.id, newStock);
        onRefresh();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('stock_updated')),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
