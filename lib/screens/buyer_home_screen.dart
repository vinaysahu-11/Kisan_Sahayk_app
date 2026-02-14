import 'package:flutter/material.dart';
import '../services/buyer_service.dart';
import '../models/seller_models.dart';
import '../theme/app_colors.dart';
import '../utils/app_localizations.dart';
import 'buyer_product_list_screen.dart';
import 'buyer_search_screen.dart';
import 'buyer_cart_screen.dart';
import 'buyer_orders_screen.dart';
import 'buyer_wallet_screen.dart';
import 'buyer_notifications_screen.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  final _service = BuyerService();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final categories = _service.getRootCategories();
    final featuredProducts = _service.getAllProducts().take(6).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('kisan_market')),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyerSearchScreen())),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyerNotificationsScreen())).then((_) => setState(() {})),
              ),
              if (_service.getUnreadCount() > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('${_service.getUnreadCount()}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ),
            ],
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyerCartScreen())).then((_) => setState(() {})),
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
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyerSearchScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey[500]),
                        const SizedBox(width: 12),
                        Text(loc.translate('search_products'), style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),

              // Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.translate('fresh_from_farm'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 6),
                          Text(loc.translate('buy_directly_from_farmers'), style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9))),
                        ],
                      ),
                    ),
                    const Icon(Icons.agriculture, size: 64, color: Colors.white24),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _QuickAction(icon: Icons.receipt_long, label: loc.translate('orders'), color: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyerOrdersScreen())).then((_) => setState(() {}))),
                    const SizedBox(width: 12),
                    _QuickAction(icon: Icons.account_balance_wallet, label: loc.translate('wallet'), color: Colors.purple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyerWalletScreen()))),
                    const SizedBox(width: 12),
                    _QuickAction(icon: Icons.local_offer, label: loc.translate('deals'), color: Colors.red, onTap: () {}),
                    const SizedBox(width: 12),
                    _QuickAction(icon: Icons.eco, label: loc.translate('organic'), color: const Color(0xFF2E7D32), onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => BuyerProductListScreen(categoryId: 'CAT011', title: 'Organic Products'),
                      ));
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(loc.translate('categories'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return _CategoryChip(
                      category: cat,
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => BuyerProductListScreen(categoryId: cat.id, title: cat.name),
                      )),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Featured Products
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.translate('featured_products'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BuyerProductListScreen(title: loc.translate('products')))),
                      child: Text(loc.translate('view_all')),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: featuredProducts.length,
                itemBuilder: (context, index) {
                  return _ProductCard(product: featuredProducts[index]);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ WIDGETS ============

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final AgriCategory category;
  final VoidCallback onTap;

  const _CategoryChip({required this.category, required this.onTap});

  static const _icons = {
    'Crops': Icons.grass,
    'Fruits': Icons.apple,
    'Vegetables': Icons.eco,
    'Seeds': Icons.grain,
    'Fertilizers': Icons.science,
    'Pesticides': Icons.bug_report,
    'Equipment': Icons.precision_manufacturing,
    'Livestock': Icons.pets,
    'Dairy': Icons.water_drop,
    'Processed Goods': Icons.inventory_2,
    'Organic Products': Icons.spa,
    'Tools': Icons.build,
    'Irrigation Systems': Icons.water,
    'Agro Chemicals': Icons.biotech,
    'Feed & Fodder': Icons.restaurant,
  };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 85,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(_icons[category.name] ?? Icons.category, color: const Color(0xFF2E7D32), size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final AgriProduct product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final service = BuyerService();
    final seller = service.getSeller(product.sellerId);
    final category = service.getCategory(product.categoryId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/buyer-product-detail', arguments: product.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getCategoryIcon(category?.name ?? ''), size: 40, color: const Color(0xFF2E7D32).withValues(alpha: 0.5)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(seller?.name ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('₹${product.price.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
                        Text('/${product.unit}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const Spacer(),
                        if (product.codEnabled)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: const Text('COD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.orange)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? name) {
    const icons = {
      'Crops': Icons.grass,
      'Fruits': Icons.apple,
      'Vegetables': Icons.eco,
      'Seeds': Icons.grain,
      'Fertilizers': Icons.science,
      'Pesticides': Icons.bug_report,
      'Equipment': Icons.precision_manufacturing,
      'Livestock': Icons.pets,
      'Dairy': Icons.water_drop,
      'Processed Goods': Icons.inventory_2,
      'Organic Products': Icons.spa,
      'Tools': Icons.build,
      'Irrigation Systems': Icons.water,
      'Agro Chemicals': Icons.biotech,
      'Feed & Fodder': Icons.restaurant,
    };
    return icons[name] ?? Icons.agriculture;
  }
}
