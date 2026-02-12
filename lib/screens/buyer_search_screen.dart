import 'package:flutter/material.dart';
import '../services/buyer_service.dart';
import '../models/seller_models.dart';
import '../utils/app_localizations.dart';

class BuyerSearchScreen extends StatefulWidget {
  const BuyerSearchScreen({super.key});

  @override
  State<BuyerSearchScreen> createState() => _BuyerSearchScreenState();
}

class _BuyerSearchScreenState extends State<BuyerSearchScreen> {
  final _service = BuyerService();
  final _searchCtrl = TextEditingController();
  List<AgriProduct> _results = [];
  bool _hasSearched = false;

  void _search() {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _results = _service.searchProducts(q);
      _hasSearched = true;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final categories = _service.getRootCategories();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: loc.translate('search_products'),
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
            border: InputBorder.none,
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() { _hasSearched = false; _results = []; });
                    },
                  )
                : null,
          ),
          cursorColor: Colors.white,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _search),
        ],
      ),
      body: _hasSearched ? _buildResults(loc) : _buildSuggestions(categories, loc),
    );
  }

  Widget _buildSuggestions(List<AgriCategory> categories, AppLocalizations loc) {
    final popular = ['Rice', 'Wheat Seeds', 'Fertilizer', 'Mango', 'Tomato', 'Organic'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.translate('popular_searches'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: popular.map((s) => ActionChip(
              label: Text(s),
              onPressed: () {
                _searchCtrl.text = s;
                _search();
              },
            )).toList(),
          ),
          const SizedBox(height: 24),
          Text(loc.translate('browse_categories'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...categories.map((c) => ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              child: const Icon(Icons.category, color: Color(0xFF2E7D32), size: 20),
            ),
            title: Text(c.name),
            trailing: const Icon(Icons.chevron_right),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              Navigator.pushNamed(context, '/buyer-product-list', arguments: {'categoryId': c.id, 'title': c.name});
            },
          )),
        ],
      ),
    );
  }

  Widget _buildResults(AppLocalizations loc) {
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('No products found for "${_searchCtrl.text}"', style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 8),
            TextButton(onPressed: () { _searchCtrl.clear(); setState(() => _hasSearched = false); }, child: Text(loc.translate('clear_search'))),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('${_results.length} results for "${_searchCtrl.text}"', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final p = _results[index];
              final seller = _service.getSeller(p.sellerId);
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  onTap: () => Navigator.pushNamed(context, '/buyer-product-detail', arguments: p.id),
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.agriculture, color: Color(0xFF2E7D32)),
                  ),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${seller?.name ?? ''} • ₹${p.price.toInt()}/${p.unit}'),
                  trailing: p.codEnabled
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                          child: const Text('COD', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w600)),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
