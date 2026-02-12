import 'package:flutter/material.dart';
import '../models/labour_models.dart';
import '../services/labour_booking_service.dart';
import '../utils/app_localizations.dart';

class LabourRatingScreen extends StatefulWidget {
  final String bookingId;

  const LabourRatingScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<LabourRatingScreen> createState() => _LabourRatingScreenState();
}

class _LabourRatingScreenState extends State<LabourRatingScreen> {
  final _bookingService = LabourBookingService();
  final _reviewController = TextEditingController();
  LabourBooking? _booking;
  double _rating = 5.0;
  final List<String> _selectedTags = [];

  final List<String> _quickTags = [
    'Punctual',
    'Hardworking',
    'Skilled',
    'Professional',
    'Friendly',
    'Good Quality',
    'Fast Worker',
    'Team Player',
  ];

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  void _loadBooking() {
    final booking = _bookingService.getBookingById(widget.bookingId);
    if (booking != null) {
      setState(() {
        _booking = booking;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_booking == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.translate('rate_workers')),
          backgroundColor: const Color(0xFF2E7D32),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('rate_workers')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green.shade500,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Work Completed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How was your experience with the workers?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Rating stars
            const Text(
              'Rate the Service',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1.0;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = starValue;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      _rating >= starValue ? Icons.star : Icons.star_border,
                      size: 48,
                      color: _rating >= starValue
                          ? Colors.amber
                          : Colors.grey.shade400,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _getRatingText(_rating),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getRatingColor(_rating),
              ),
            ),
            const SizedBox(height: 32),

            // Quick tags
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Quick Feedback',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2E7D32)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2E7D32)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Review text
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Write a Review (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reviewController,
              maxLines: 4,
              maxLength: 200,
              decoration: InputDecoration(
                hintText:
                    'Share your experience with the workers...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 24),

            // Workers list
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Workers',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    _booking!.assignedLabourers.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                const Color(0xFF2E7D32).withValues(alpha: 0.1),
                            child: Text(
                              _booking!.assignedLabourers[index].name
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _booking!.assignedLabourers[index].name,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.translate('submit'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                'Skip for now',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 5) return 'Excellent!';
    if (rating >= 4) return 'Very Good';
    if (rating >= 3) return 'Good';
    if (rating >= 2) return 'Fair';
    return 'Poor';
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4) return Colors.green;
    if (rating >= 3) return const Color(0xFF2E7D32);
    if (rating >= 2) return Colors.orange;
    return Colors.red;
  }

  void _submitRating() {
    // Combine review with tags
    final tags = _selectedTags.join(', ');
    final reviewText = _reviewController.text.trim();
    final fullReview = tags.isNotEmpty
        ? (reviewText.isNotEmpty ? '$reviewText\n\nTags: $tags' : tags)
        : reviewText;

    // Submit rating
    _bookingService.submitRating(
      widget.bookingId,
      _rating,
      fullReview,
    );

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.thumb_up,
          color: Color(0xFF2E7D32),
          size: 64,
        ),
        title: Text(AppLocalizations.of(context)!.translate('thank_you')),
        content: Text(
          AppLocalizations.of(context)!.translate('thank_you_feedback'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
