import 'package:flutter/material.dart';
import '../services/buyer_service.dart';

class BuyerRatingScreen extends StatefulWidget {
  final String orderId;

  const BuyerRatingScreen({super.key, required this.orderId});

  @override
  State<BuyerRatingScreen> createState() => _BuyerRatingScreenState();
}

class _BuyerRatingScreenState extends State<BuyerRatingScreen> {
  final _service = BuyerService();
  int _productRating = 0;
  int _sellerRating = 0;
  final _reviewCtrl = TextEditingController();

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = _service.getOrders().where((o) => o.id == widget.orderId).firstOrNull;
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rate Order'), backgroundColor: const Color(0xFF2E7D32)),
        body: const Center(child: Text('Order not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Rate Order'), backgroundColor: const Color(0xFF2E7D32)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(color: const Color(0xFF2E7D32).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.agriculture, color: Color(0xFF2E7D32)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('by ${order.sellerName}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Product Rating
            const Text('Rate Product', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('How was the product quality?', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => setState(() => _productRating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    i < _productRating ? Icons.star : Icons.star_border,
                    size: 44,
                    color: i < _productRating ? Colors.amber[700] : Colors.grey[300],
                  ),
                ),
              )),
            ),
            if (_productRating > 0)
              Center(child: Text(_ratingLabel(_productRating), style: TextStyle(fontSize: 14, color: Colors.amber[700], fontWeight: FontWeight.w500))),
            const SizedBox(height: 24),

            // Seller Rating
            const Text('Rate Seller', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('How was the seller experience?', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => setState(() => _sellerRating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    i < _sellerRating ? Icons.star : Icons.star_border,
                    size: 44,
                    color: i < _sellerRating ? Colors.amber[700] : Colors.grey[300],
                  ),
                ),
              )),
            ),
            if (_sellerRating > 0)
              Center(child: Text(_ratingLabel(_sellerRating), style: TextStyle(fontSize: 14, color: Colors.amber[700], fontWeight: FontWeight.w500))),
            const SizedBox(height: 24),

            // Review
            const Text('Write a Review (optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: (_productRating > 0 && _sellerRating > 0) ? () {
                  _service.submitRating(
                    orderId: order.id,
                    productId: order.productId,
                    sellerId: order.sellerId,
                    productRating: _productRating,
                    sellerRating: _sellerRating,
                    review: _reviewCtrl.text.trim(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for your rating!'), backgroundColor: Color(0xFF2E7D32)),
                  );
                  Navigator.pop(context);
                } : null,
                child: const Text('Submit Rating', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1: return 'Poor';
      case 2: return 'Below Average';
      case 3: return 'Average';
      case 4: return 'Good';
      case 5: return 'Excellent';
      default: return '';
    }
  }
}
