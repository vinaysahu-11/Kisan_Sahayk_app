import 'package:flutter/material.dart';
import '../services/buyer_service.dart';

class BuyerWalletScreen extends StatelessWidget {
  const BuyerWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = BuyerService();
    final balance = service.walletBalance;
    final transactions = service.getWalletTransactions();

    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet'), backgroundColor: const Color(0xFF2E7D32)),
      body: Column(
        children: [
          // Wallet Balance Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF43A047)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('Wallet Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text('₹${balance.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, color: Colors.white70, size: 14),
                      SizedBox(width: 6),
                      Text('Use at checkout to save more', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Transactions Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Transaction History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${transactions.length} transactions', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('No transactions yet', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final txn = transactions[index];
                      final isCredit = txn.type == 'refund' || txn.type == 'cashback' || txn.type == 'credit';
                      final icons = {'refund': Icons.replay, 'cashback': Icons.card_giftcard, 'used': Icons.shopping_cart, 'credit': Icons.add_circle_outline};
                      final colors = {'refund': Colors.green, 'cashback': Colors.purple, 'used': Colors.red, 'credit': Colors.blue};

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: (colors[txn.type] ?? Colors.grey).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icons[txn.type] ?? Icons.monetization_on, color: colors[txn.type] ?? Colors.grey, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(txn.description, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${txn.date.day}/${txn.date.month}/${txn.date.year}${txn.orderId != null ? ' • Order #${txn.orderId}' : ''}',
                                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isCredit ? '+' : '-'}₹${txn.amount.toInt()}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isCredit ? Colors.green[700] : Colors.red[700]),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
