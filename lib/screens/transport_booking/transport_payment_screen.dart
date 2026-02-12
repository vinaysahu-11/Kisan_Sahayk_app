import 'package:flutter/material.dart';
import 'transport_booking_models.dart';
import 'transport_rating_screen.dart';

class TransportPaymentScreen extends StatefulWidget {
  final TransportBooking booking;

  const TransportPaymentScreen({super.key, required this.booking});

  @override
  State<TransportPaymentScreen> createState() => _TransportPaymentScreenState();
}

class _TransportPaymentScreenState extends State<TransportPaymentScreen> {
  String selectedCard = 'UPI';
  bool isPaying = false;

  void _processPayment() async {
    setState(() => isPaying = true);
    
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      _showSuccessAnimation();
    }
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 80),
            const SizedBox(height: 24),
            const Text('Payment Successful', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Transaction ID: TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransportRatingScreen(booking: widget.booking),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fare = widget.booking.fare ?? 0.0;
    final baseFare = fare / 1.1;
    final platformFee = fare - baseFare;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment', style: TextStyle(color: Color(0xFF1B3D2A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Trip Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1B3D2A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text('Total Fare', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('₹${fare.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.white24, height: 32),
                  _SummaryRow(label: 'Distance', value: '${widget.booking.distance?.toStringAsFixed(1)} KM'),
                  _SummaryRow(label: 'Base Fare', value: '₹${baseFare.toStringAsFixed(2)}'),
                  _SummaryRow(label: 'Platform Fee', value: '₹${platformFee.toStringAsFixed(2)}'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Select Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B3D2A))),
            const SizedBox(height: 16),
            
            _PaymentOption(
              label: 'UPI (PhonePe / GPay)',
              icon: Icons.account_balance_wallet,
              isSelected: selectedCard == 'UPI',
              onTap: () => setState(() => selectedCard = 'UPI'),
            ),
            _PaymentOption(
              label: 'Credit / Debit Card',
              icon: Icons.credit_card,
              isSelected: selectedCard == 'Card',
              onTap: () => setState(() => selectedCard = 'Card'),
            ),
            _PaymentOption(
              label: 'Wallet',
              icon: Icons.wallet_giftcard,
              isSelected: selectedCard == 'Wallet',
              onTap: () => setState(() => selectedCard = 'Wallet'),
            ),
            
            const SizedBox(height: 48),
            
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: isPaying ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: isPaying 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Pay Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromRGBO(46, 125, 50, 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[200]!, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600]),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
          ],
        ),
      ),
    );
  }
}
