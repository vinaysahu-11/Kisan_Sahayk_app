import 'package:flutter/material.dart';
import '../services/delivery_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_localizations.dart';

class DeliveryWalletScreen extends StatefulWidget {
  const DeliveryWalletScreen({super.key});

  @override
  State<DeliveryWalletScreen> createState() => _DeliveryWalletScreenState();
}

class _DeliveryWalletScreenState extends State<DeliveryWalletScreen> {
  final _deliveryService = DeliveryService();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _withdrawBalance(String partnerId, double availableBalance) async {
    final loc = AppLocalizations.of(context)!;
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('withdraw_balance')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Available: ₹${availableBalance.toInt()}'),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Withdrawal Amount',
                prefixText: '₹',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(_amountController.text);
              Navigator.pop(context, val);
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (amount != null) {
      final success = await _deliveryService.withdrawBalance(partnerId, amount);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('₹$amount withdrawn successfully')),
        );
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('insufficient_balance'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final partner = _deliveryService.getCurrentPartner();
    if (partner == null) {
      return Scaffold(body: Center(child: Text(loc.translate('not_logged_in'))));
    }

    final transactions = _deliveryService.getWalletTransactions(partner.id);
    final balance = _deliveryService.getWalletBalance(partner.id);
    final codPending = _deliveryService.getCODPending(partner.id);
    final incentiveTotal = _deliveryService.getTotalIncentivesEarned(partner.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('my_wallet')),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient(context),
            ),
            child: Column(
              children: [
                Text(
                  loc.translate('available_balance'),
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBalanceCard('COD Pending', codPending, Icons.pending),
                    _buildBalanceCard('Total Incentives', incentiveTotal, Icons.card_giftcard),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _withdrawBalance(partner.id, balance),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  icon: const Icon(Icons.account_balance),
                  label: Text(loc.translate('withdraw_to_bank')),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                loc.translate('transaction_history'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? Center(child: Text(loc.translate('no_transactions')))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final txn = transactions[index];
                      final config = _getTransactionConfig(txn.type);
                      final isCredit = txn.type == 'earning' || txn.type == 'incentive';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: config['color'].withValues(alpha: 0.2),
                            child: Icon(config['icon'], color: config['color']),
                          ),
                          title: Text(txn.description),
                          subtitle: Text(
                            '${txn.date.day}/${txn.date.month}/${txn.date.year} ${txn.date.hour}:${txn.date.minute.toString().padLeft(2, '0')}',
                          ),
                          trailing: Text(
                            '${isCredit ? '+' : '-'}₹${txn.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCredit ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String label, double amount, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toInt()}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Map<String, dynamic> _getTransactionConfig(String type) {
    switch (type) {
      case 'earning':
        return {'icon': Icons.currency_rupee, 'color': Colors.green};
      case 'cod_collected':
        return {'icon': Icons.money, 'color': Colors.orange};
      case 'cod_settled':
        return {'icon': Icons.check_circle, 'color': Colors.blue};
      case 'incentive':
        return {'icon': Icons.card_giftcard, 'color': Colors.purple};
      case 'withdrawal':
        return {'icon': Icons.account_balance, 'color': Colors.red};
      case 'commission':
        return {'icon': Icons.receipt, 'color': Colors.red};
      default:
        return {'icon': Icons.circle, 'color': Colors.grey};
    }
  }
}
