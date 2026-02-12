import 'package:flutter/material.dart';
import '../models/seller_models.dart';
import '../services/seller_service.dart';
import '../utils/app_localizations.dart';

class AdminSellerScreen extends StatefulWidget {
  const AdminSellerScreen({super.key});

  @override
  State<AdminSellerScreen> createState() => _AdminSellerScreenState();
}

class _AdminSellerScreenState extends State<AdminSellerScreen> {
  final _service = SellerService();
  String _filterType = 'all';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    var sellers = _service.getAllSellers();

    // Apply filters
    if (_filterType == 'basic') {
      sellers = sellers.where((s) => s.level == SellerLevel.basic).toList();
    } else if (_filterType == 'big') {
      sellers = sellers.where((s) => s.level == SellerLevel.bigSeller).toList();
    } else if (_filterType == 'kyc_pending') {
      sellers = sellers.where((s) => s.kycStatus == KYCStatus.pending).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      sellers = sellers
          .where((s) =>
              s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.mobile.contains(_searchQuery))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('manage_sellers')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: loc.translate('search'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All (${_service.getAllSellers().length})',
                  isSelected: _filterType == 'all',
                  onTap: () => setState(() => _filterType = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Basic Sellers',
                  isSelected: _filterType == 'basic',
                  onTap: () => setState(() => _filterType = 'basic'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Big Sellers',
                  isSelected: _filterType == 'big',
                  onTap: () => setState(() => _filterType = 'big'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'KYC Pending',
                  isSelected: _filterType == 'kyc_pending',
                  onTap: () => setState(() => _filterType = 'kyc_pending'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sellers List
          Expanded(
            child: sellers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No sellers found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sellers.length,
                    itemBuilder: (context, index) {
                      return _SellerCard(
                        seller: sellers[index],
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
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SellerCard extends StatelessWidget {
  final Seller seller;
  final VoidCallback onRefresh;

  const _SellerCard({required this.seller, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final service = SellerService();
    final products = service.getSellerProducts(seller.id);
    final orders = service.getSellerOrders(seller.id);
    final analytics = service.getAnalytics(seller.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: seller.level == SellerLevel.bigSeller
              ? Colors.amber.withValues(alpha: 0.2)
              : Colors.grey[200],
          child: Icon(
            seller.level == SellerLevel.bigSeller ? Icons.verified : Icons.store,
            color: seller.level == SellerLevel.bigSeller ? Colors.amber[700] : Colors.grey[700],
            size: 20,
          ),
        ),
        title: Text(
          seller.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(seller.mobile),
            const SizedBox(height: 4),
            Row(
              children: [
                _LevelBadge(level: seller.level),
                const SizedBox(width: 8),
                _KYCStatusBadge(status: seller.kycStatus),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatColumn(label: 'Products', value: '${products.length}'),
                    _StatColumn(label: 'Orders', value: '${orders.length}'),
                    _StatColumn(
                      label: 'Revenue',
                      value: '₹${analytics.totalRevenue.toInt()}',
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Info
                _InfoRow(
                  label: 'Type',
                  value: _getSellerTypeName(seller.type),
                ),
                _InfoRow(
                  label: 'Location',
                  value: seller.location,
                ),
                _InfoRow(
                  label: 'Commission',
                  value: '${seller.commissionRate}%',
                ),
                _InfoRow(
                  label: 'Wallet Balance',
                  value: '₹${seller.walletBalance.toInt()}',
                ),
                _InfoRow(
                  label: 'Pending Settlement',
                  value: '₹${seller.pendingSettlement.toInt()}',
                ),
                const SizedBox(height: 16),

                // KYC Actions
                if (seller.kycStatus == KYCStatus.pending) ...[
                  const Divider(height: 16),
                  const Text(
                    'KYC Pending Approval',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Reject KYC - would show rejection reason dialog
                            _showKYCRejectionDialog(context, seller.id);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: Text(loc.translate('reject_kyc')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _approveKYC(context, seller.id, onRefresh);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                          ),
                          child: Text(loc.translate('approve_kyc')),
                        ),
                      ),
                    ],
                  ),
                ],

                // Actions
                const Divider(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        // View seller products
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${seller.name} has ${products.length} products'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.inventory_2, size: 16),
                      label: Text(loc.translate('products')),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        // View seller orders
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${seller.name} has ${orders.length} orders'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_bag, size: 16),
                      label: Text(loc.translate('orders')),
                    ),
                    if (seller.level == SellerLevel.basic)
                      ElevatedButton.icon(
                        onPressed: () {
                          _forceUpgrade(context, seller.id, onRefresh);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.upgrade, size: 16),
                        label: Text(loc.translate('upgrade')),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () {
                          _forceDowngrade(context, seller.id, onRefresh);
                        },
                        icon: const Icon(Icons.arrow_downward, size: 16),
                        label: Text(loc.translate('downgrade')),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveKYC(BuildContext context, String sellerId, VoidCallback onRefresh) async {
    final loc = AppLocalizations.of(context)!;
    final service = SellerService();
    await service.approveKYC(sellerId);
    onRefresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.translate('kyc_approved')),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _showKYCRejectionDialog(BuildContext context, String sellerId) async {
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('reject_kyc')),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Rejection Reason',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(loc.translate('reject_kyc')),
          ),
        ],
      ),
    );

    if (result == true) {
      // Would reject KYC with reason
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('kyc_rejected'))),
      );
    }
  }

  Future<void> _forceUpgrade(BuildContext context, String sellerId, VoidCallback onRefresh) async {
    final loc = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('force_upgrade')),
        content: const Text('Upgrade this seller to Big Seller manually?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: Text(loc.translate('upgrade')),
          ),
        ],
      ),
    );

    if (result == true) {
      final service = SellerService();
      service.updateSellerLevel(sellerId, SellerLevel.bigSeller, 1.5);
      onRefresh();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('seller_upgraded')),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _forceDowngrade(BuildContext context, String sellerId, VoidCallback onRefresh) async {
    final loc = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('force_downgrade')),
        content: const Text('Downgrade this seller to Basic Seller?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(loc.translate('downgrade')),
          ),
        ],
      ),
    );

    if (result == true) {
      final service = SellerService();
      service.updateSellerLevel(sellerId, SellerLevel.basic, 3.0);
      onRefresh();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('seller_downgraded'))),
      );
    }
  }

  String _getSellerTypeName(SellerType type) {
    switch (type) {
      case SellerType.farmer:
        return 'Farmer';
      case SellerType.shop:
        return 'Shop/Store';
      case SellerType.mill:
        return 'Mill/Processing';
      case SellerType.individual:
        return 'Individual';
    }
  }
}

class _LevelBadge extends StatelessWidget {
  final SellerLevel level;

  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final isBig = level == SellerLevel.bigSeller;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isBig ? Colors.amber.withValues(alpha: 0.2) : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isBig ? 'Big Seller' : 'Basic',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isBig ? Colors.amber[700] : Colors.grey[700],
        ),
      ),
    );
  }
}

class _KYCStatusBadge extends StatelessWidget {
  final KYCStatus status;

  const _KYCStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case KYCStatus.notSubmitted:
        color = Colors.grey;
        text = 'No KYC';
        break;
      case KYCStatus.pending:
        color = Colors.orange;
        text = 'KYC Pending';
        break;
      case KYCStatus.approved:
        color = Colors.green;
        text = 'KYC ✓';
        break;
      case KYCStatus.rejected:
        color = Colors.red;
        text = 'KYC ✗';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
