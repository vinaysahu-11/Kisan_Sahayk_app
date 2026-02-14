import 'package:flutter/material.dart';
import '../models/labour_models.dart';
import '../services/labour_booking_service.dart';
import '../utils/app_localizations.dart';
import 'labour_rating_screen.dart';

class LabourPaymentScreen extends StatefulWidget {
  final String bookingId;

  const LabourPaymentScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<LabourPaymentScreen> createState() => _LabourPaymentScreenState();
}

class _LabourPaymentScreenState extends State<LabourPaymentScreen> {
  final _bookingService = LabourBookingService();
  LabourBooking? _booking;
  PaymentMethod _selectedMethod = PaymentMethod.upi;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  void _loadBooking() async {
    try {
      final result = await _bookingService.getBookingById(widget.bookingId);
      if (result['booking'] != null) {
        setState(() {
          _booking = LabourBooking.fromJson(result['booking']);
        });
      }
    } catch (e) {
      print('Error loading booking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_booking == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.translate('payment')),
          backgroundColor: const Color(0xFF2E7D32),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
        ),
      );
    }

    // Calculate amount to pay
    final amountToPay = _booking!.paymentOption == PaymentOption.partialAdvance
        ? (_booking!.costBreakdown.remainingAmount ?? 0)
        : _booking!.costBreakdown.totalCost;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('payment')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Column(
        children: [
          // Amount to pay
          Container(
            padding: const EdgeInsets.all(24),
            color: const Color(0xFF2E7D32),
            child: Column(
              children: [
                const Text(
                  'Amount to Pay',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${amountToPay.toInt()}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (_booking!.paymentOption == PaymentOption.partialAdvance)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Advance ₹${_booking!.costBreakdown.advanceAmount?.toInt()} already paid',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Payment methods
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // UPI
                  _PaymentMethodCard(
                    icon: Icons.phone_android,
                    title: 'UPI',
                    subtitle: 'Google Pay, PhonePe, Paytm',
                    method: PaymentMethod.upi,
                    selectedMethod: _selectedMethod,
                    onTap: () {
                      setState(() {
                        _selectedMethod = PaymentMethod.upi;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Card
                  _PaymentMethodCard(
                    icon: Icons.credit_card,
                    title: 'Card',
                    subtitle: 'Debit / Credit Card',
                    method: PaymentMethod.card,
                    selectedMethod: _selectedMethod,
                    onTap: () {
                      setState(() {
                        _selectedMethod = PaymentMethod.card;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Wallet
                  _PaymentMethodCard(
                    icon: Icons.account_balance_wallet,
                    title: 'Wallet',
                    subtitle: 'Paytm, Mobikwik, FreeCharge',
                    method: PaymentMethod.wallet,
                    selectedMethod: _selectedMethod,
                    onTap: () {
                      setState(() {
                        _selectedMethod = PaymentMethod.wallet;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Cash
                  _PaymentMethodCard(
                    icon: Icons.money,
                    title: 'Cash',
                    subtitle: 'Pay in cash to workers',
                    method: PaymentMethod.cash,
                    selectedMethod: _selectedMethod,
                    onTap: () {
                      setState(() {
                        _selectedMethod = PaymentMethod.cash;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Payment details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Breakdown',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _PaymentRow(
                          label: 'Workers earned',
                          value:
                              '₹${(_booking!.costBreakdown.totalCost * 0.95).toInt()}',
                        ),
                        _PaymentRow(
                          label: 'Platform fee (5%)',
                          value:
                              '₹${(_booking!.costBreakdown.totalCost * 0.05).toInt()}',
                        ),
                        const Divider(height: 20),
                        _PaymentRow(
                          label: 'You pay',
                          value: '₹${amountToPay.toInt()}',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pay button
          _buildBottomButton(amountToPay),
        ],
      ),
    );
  }

  Widget _buildBottomButton(double amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Pay ₹${amount.toInt()}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // Update payment status
    await _bookingService.updatePaymentStatus(
      widget.bookingId,
      PaymentStatus.completed,
    );

    // Update booking status to payment released
    await _bookingService.updateBookingStatus(
      widget.bookingId,
      LabourBookingStatus.paymentReleased.name,
    );

    setState(() {
      _isProcessing = false;
    });

    // Show success and navigate to rating
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 64,
          ),
          title: Text(AppLocalizations.of(context)!.translate('success')),
          content: Text(
            AppLocalizations.of(context)!.translate('thank_you'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LabourRatingScreen(
                      bookingId: widget.bookingId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final PaymentMethod method;
  final PaymentMethod selectedMethod;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.method,
    required this.selectedMethod,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = method == selectedMethod;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color:
              isSelected ? const Color(0xFF2E7D32).withValues(alpha: 0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D32),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _PaymentRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
