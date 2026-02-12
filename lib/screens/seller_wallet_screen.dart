import 'package:flutter/material.dart';
import '../models/seller_models.dart';
import '../services/seller_service.dart';
import '../utils/app_localizations.dart';

class SellerWalletScreen extends StatefulWidget {
  const SellerWalletScreen({super.key});

  @override
  State<SellerWalletScreen> createState() => _SellerWalletScreenState();
}

class _SellerWalletScreenState extends State<SellerWalletScreen> {
  final _service = SellerService();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final seller = _service.getCurrentSeller();
    if (seller == null) return const Scaffold();

    final transactions = _service.getTransactions(seller.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('seller_wallet')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Column(
        children: [
          // Balance Cards
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2E7D32),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Available Balance',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${seller.walletBalance.toInt()}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: seller.walletBalance >= 500
                            ? () => _showWithdrawDialog(context, seller)
                            : null,
                        icon: const Icon(Icons.currency_rupee),
                        label: Text(loc.translate('withdraw')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      if (seller.walletBalance < 500) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Minimum withdrawal: ₹500',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pending Settlement (COD)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '₹${seller.pendingSettlement.toInt()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Transactions Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Filter transactions
                  },
                  child: const Text('Filter'),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return _TransactionTile(transaction: transactions[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showWithdrawDialog(BuildContext context, Seller seller) async {
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('withdraw_funds')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available: ₹${seller.walletBalance.toInt()}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹',
                border: OutlineInputBorder(),
                helperText: 'Minimum: ₹500',
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
            child: Text(loc.translate('withdraw')),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final amount = double.tryParse(result);
      if (amount != null && amount >= 500 && amount <= seller.walletBalance) {
        final service = SellerService();
        await service.withdrawFunds(seller.id, amount);
        setState(() {});
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('withdrawal_successful')),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              amount == null
                  ? 'Invalid amount'
                  : amount < 500
                      ? 'Minimum withdrawal is ₹500'
                      : 'Insufficient balance',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _TransactionTile extends StatelessWidget {
  final SellerWalletTransaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (transaction.type) {
      case 'credit':
        icon = Icons.add_circle;
        color = Colors.green;
        break;
      case 'debit':
      case 'withdrawal':
        icon = Icons.remove_circle;
        color = Colors.orange;
        break;
      case 'commission':
        icon = Icons.percent;
        color = Colors.red;
        break;
      case 'settlement':
        icon = Icons.account_balance;
        color = Colors.blue;
        break;
      default:
        icon = Icons.currency_rupee;
        color = Colors.grey;
    }

    final isCredit = transaction.type == 'credit' || transaction.type == 'settlement';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _formatDate(transaction.date),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Text(
          '${isCredit ? '+' : '-'}₹${transaction.amount.toInt()}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isCredit ? Colors.green : color,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
