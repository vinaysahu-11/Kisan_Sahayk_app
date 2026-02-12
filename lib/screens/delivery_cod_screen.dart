import 'package:flutter/material.dart';
import '../services/delivery_service.dart';

class DeliveryCODScreen extends StatelessWidget {
  const DeliveryCODScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deliveryService = DeliveryService();
    final partner = deliveryService.getCurrentPartner();

    if (partner == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    final transactions = deliveryService.getWalletTransactions(partner.id);
    final codCollected = transactions
        .where((t) => t.type == 'cod_collected')
        .fold(0.0, (sum, t) => sum + t.amount);
    final codSettled = transactions
        .where((t) => t.type == 'cod_settled')
        .fold(0.0, (sum, t) => sum + t.amount);
    final codPending = codCollected - codSettled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('COD Management'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCODSummary(codPending, codCollected, codSettled),
            const SizedBox(height: 24),
            _buildInstructions(),
            const SizedBox(height: 24),
            const Text('COD Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...transactions
                .where((t) => t.type == 'cod_collected' || t.type == 'cod_settled')
                .map((txn) => _buildCODTransactionCard(txn)),
          ],
        ),
      ),
    );
  }

  Widget _buildCODSummary(double pending, double collected, double settled) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('COD Pending Settlement', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              '₹${pending.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Total Collected', collected),
                _buildStatColumn('Settled', settled),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, double amount) {
    return Column(
      children: [
        Text(
          '₹${amount.toInt()}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text('COD Settlement Process', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            _buildInstructionStep('1', 'Collect cash from customer at delivery'),
            _buildInstructionStep('2', 'Amount is tracked in your COD pending balance'),
            _buildInstructionStep('3', 'Admin reviews and approves settlement weekly'),
            _buildInstructionStep('4', 'Approved amount is transferred to your wallet'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keep COD cash safe. Settlements are processed every Friday.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFF2E7D32),
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildCODTransactionCard(txn) {
    final isSettled = txn.type == 'cod_settled';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSettled ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
          child: Icon(
            isSettled ? Icons.check_circle : Icons.pending,
            color: isSettled ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(txn.description),
        subtitle: Text(
          '${txn.date.day}/${txn.date.month}/${txn.date.year}',
        ),
        trailing: Text(
          '₹${txn.amount.toInt()}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSettled ? Colors.green : Colors.orange,
          ),
        ),
      ),
    );
  }
}
