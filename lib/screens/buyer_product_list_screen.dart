import 'package:flutter/material.dart';
import '../services/buyer_service.dart';
import '../models/seller_models.dart';
import '../utils/app_localizations.dart';

class BuyerProductListScreen extends StatefulWidget {
  final String? categoryId;
  final String title;

  const BuyerProductListScreen({super.key, this.categoryId, this.title = 'Products'});

  @override
  State<BuyerProductListScreen> createState() => _BuyerProductListScreenState();
}

class _BuyerProductListScreenState extends State<BuyerProductListScreen> {
  final _service = BuyerService();
  String _sortBy = 'newest';
  bool _codOnly = false;
  double? _minPrice;
  double? _maxPrice;
  String? _selectedSubcategory;

  List<AgriProduct> get _products {
    if (widget.categoryId == null) {
      return _service.filterProducts(
        categoryId: _selectedSubcategory,
        sortBy: _sortBy,
        codOnly: _codOnly,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );
    }
    return _service.filterProducts(
      categoryId: _selectedSubcategory ?? widget.categoryId,
      sortBy: _sortBy,
      codOnly: _codOnly,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final products = _products;
    final subcategories = widget.categoryId != null ? _service.getSubcategories(widget.categoryId!) : <AgriCategory>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Subcategories horizontal list
          if (subcategories.isNotEmpty) ...[
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: subcategories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(loc.translate('all')),
                        selected: _selectedSubcategory == null,
                        selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                        onSelected: (_) => setState(() => _selectedSubcategory = null),
                      ),
                    );
                  }
                  final sub = subcategories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(sub.name),
                      selected: _selectedSubcategory == sub.id,
                      selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                      onSelected: (_) => setState(() => _selectedSubcategory = _selectedSubcategory == sub.id ? null : sub.id),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
          ],

          // Active Filters
          if (_codOnly || _minPrice != null || _maxPrice != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.orange.withValues(alpha: 0.05),
              child: Row(
                children: [
                  Icon(Icons.filter_alt, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  if (_codOnly) _filterChip('COD Only'),
                  if (_minPrice != null) _filterChip('Min ₹${_minPrice!.toInt()}'),
                  if (_maxPrice != null) _filterChip('Max ₹${_maxPrice!.toInt()}'),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() { _codOnly = false; _minPrice = null; _maxPrice = null; }),
                    child: const Text('Clear', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

          // Results
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('${products.length} products found', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const Spacer(),
                Text('Sort: $_sortLabel', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),

          // Product Grid
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(loc.translate('no_products_found'), style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) => _ProductGridCard(product: products[index]),
                  ),
          ),
        ],
      ),
    );
  }

  String get _sortLabel {
    switch (_sortBy) {
      case 'price_low': return 'Price ↑';
      case 'price_high': return 'Price ↓';
      case 'popular': return 'Popular';
      default: return 'Newest';
    }
  }

  Widget _filterChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 11, color: Colors.orange[800])),
    );
  }

  void _showSortSheet(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.translate('sort_by'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            RadioGroup<String>(
              groupValue: _sortBy,
              onChanged: (v) {
                setState(() => _sortBy = v!);
                Navigator.pop(ctx);
              },
              child: Column(
                children: ['newest', 'price_low', 'price_high', 'popular'].map((s) {
                  final labels = {
                    'newest': loc.translate('newest_first'),
                    'price_low': loc.translate('price_low_to_high'),
                    'price_high': loc.translate('price_high_to_low'),
                    'popular': loc.translate('most_popular')
                  };
                  return RadioListTile<String>(
                    value: s,
                    title: Text(labels[s]!),
                    activeColor: const Color(0xFF2E7D32),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    double? tempMin = _minPrice;
    double? tempMax = _maxPrice;
    bool tempCod = _codOnly;
    final minCtrl = TextEditingController(text: _minPrice?.toInt().toString() ?? '');
    final maxCtrl = TextEditingController(text: _maxPrice?.toInt().toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.translate('filters'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(loc.translate('cod_available_only_filter')),
                value: tempCod,
                activeThumbColor: const Color(0xFF2E7D32),
                onChanged: (v) => setSheetState(() => tempCod = v),
              ),
              const SizedBox(height: 8),
              Text(loc.translate('price_range'), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Min ₹', border: OutlineInputBorder(), isDense: true),
                      onChanged: (v) => tempMin = double.tryParse(v),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('–')),
                  Expanded(
                    child: TextField(
                      controller: maxCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Max ₹', border: OutlineInputBorder(), isDense: true),
                      onChanged: (v) => tempMax = double.tryParse(v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    setState(() { _codOnly = tempCod; _minPrice = tempMin; _maxPrice = tempMax; });
                    Navigator.pop(ctx);
                  },
                  child: Text(loc.translate('apply_filters'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ Product Grid Card ============
class _ProductGridCard extends StatelessWidget {
  final AgriProduct product;

  const _ProductGridCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final service = BuyerService();
    final seller = service.getSeller(product.sellerId);
    final sellerRating = service.getSellerRating(product.sellerId);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/buyer-product-detail', arguments: product.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 110,
              width: double.infinity,
              color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
              child: Stack(
                children: [
                  Center(child: Icon(Icons.agriculture, size: 44, color: const Color(0xFF2E7D32).withValues(alpha: 0.3))),
                  if (product.codEnabled)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                        child: const Text('COD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  if (product.stock <= 5 && product.stock > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                        child: Text('Only ${product.stock} left', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    if (seller != null)
                      Row(
                        children: [
                          Icon(Icons.store, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 3),
                          Expanded(child: Text(seller.name, style: TextStyle(fontSize: 10, color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
                          if (sellerRating > 0) ...[
                            Icon(Icons.star, size: 12, color: Colors.amber[700]),
                            Text(sellerRating.toStringAsFixed(1), style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                          ],
                        ],
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        Text('₹${product.price.toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
                        Text('/${product.unit}', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                      ],
                    ),
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
