import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/labour_models.dart';
import '../services/labour_booking_service.dart';
import '../utils/app_localizations.dart';
import 'labour_active_booking_screen.dart';

class LabourConfirmationScreen extends StatefulWidget {
  final LabourSkillType skillType;
  final int workersCount;
  final DateTime workDate;
  final WorkDuration duration;
  final double wagePerWorker;
  final Location workLocation;
  final String? workNotes;
  final LabourCostBreakdown costBreakdown;
  final PaymentOption paymentOption;

  const LabourConfirmationScreen({
    super.key,
    required this.skillType,
    required this.workersCount,
    required this.workDate,
    required this.duration,
    required this.wagePerWorker,
    required this.workLocation,
    this.workNotes,
    required this.costBreakdown,
    required this.paymentOption,
  });

  @override
  State<LabourConfirmationScreen> createState() =>
      _LabourConfirmationScreenState();
}

class _LabourConfirmationScreenState extends State<LabourConfirmationScreen> {
  final _bookingService = LabourBookingService();
  bool _isSearching = false;
  List<LabourPartner>? _availableWorkers;

  @override
  void initState() {
    super.initState();
    _searchWorkers();
  }

  Future<void> _searchWorkers() async {
    setState(() {
      _isSearching = true;
    });

    final workers = await _bookingService.findAvailableLabour(
      skillType: widget.skillType,
      workLocation: widget.workLocation,
      workDate: widget.workDate,
      workersRequired: widget.workersCount,
    );

    setState(() {
      _availableWorkers = workers;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('confirm_booking')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: _isSearching
          ? _buildSearchingState()
          : _availableWorkers == null || _availableWorkers!.isEmpty
              ? _buildNoWorkersState()
              : _buildWorkersFoundState(),
    );
  }

  Widget _buildSearchingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Finding Available Workers...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Searching within 20km radius',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoWorkersState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'No Workers Available',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'No workers available for the selected date and location. Try different date or increase service area.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _searchWorkers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkersFoundState() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green.shade700, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_availableWorkers!.length} Workers Found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                            Text(
                              'Ready for ${DateFormat('d MMM').format(widget.workDate)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Workers list
                const Text(
                  'Assigned Workers',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  _availableWorkers!.length,
                  (index) => _WorkerCard(worker: _availableWorkers![index]),
                ),
                const SizedBox(height: 20),

                // Booking summary
                _buildBookingSummary(),
                const SizedBox(height: 20),

                // Cost breakdown
                _buildCostBreakdown(),
              ],
            ),
          ),
        ),

        // Bottom button
        _buildBottomButton(),
      ],
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.agriculture,
            label: 'Labour Type',
            value: _getSkillDisplayName(widget.skillType),
          ),
          _SummaryRow(
            icon: Icons.people,
            label: 'Workers',
            value: '${widget.workersCount}',
          ),
          _SummaryRow(
            icon: Icons.calendar_today,
            label: 'Date',
            value: DateFormat('d MMM y').format(widget.workDate),
          ),
          _SummaryRow(
            icon: Icons.schedule,
            label: 'Duration',
            value: widget.duration == WorkDuration.fullDay
                ? 'Full Day (8 hours)'
                : 'Half Day (4 hours)',
          ),
          _SummaryRow(
            icon: Icons.location_on,
            label: 'Location',
            value: widget.workLocation.address,
          ),
          if (widget.workNotes != null)
            _SummaryRow(
              icon: Icons.note,
              label: 'Notes',
              value: widget.workNotes!,
            ),
        ],
      ),
    );
  }

  Widget _buildCostBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _CostRow(
            label: 'Labour Cost',
            value: '₹${widget.costBreakdown.subtotal.toInt()}',
          ),
          _CostRow(
            label: 'Platform Fee',
            value: '₹${widget.costBreakdown.platformFee.toInt()}',
          ),
          const Divider(height: 20),
          _CostRow(
            label: 'Total Amount',
            value: '₹${widget.costBreakdown.totalCost.toInt()}',
            isBold: true,
          ),
          if (widget.paymentOption == PaymentOption.partialAdvance) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _CostRow(
                    label: 'Pay Now (30%)',
                    value:
                        '₹${widget.costBreakdown.advanceAmount?.toInt() ?? 0}',
                    color: const Color(0xFF2E7D32),
                  ),
                  _CostRow(
                    label: 'After Work',
                    value:
                        '₹${widget.costBreakdown.remainingAmount?.toInt() ?? 0}',
                    color: Colors.grey[700]!,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
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
        onPressed: _confirmBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          AppLocalizations.of(context)!.translate('confirm_booking'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _confirmBooking() async {
    final loc = AppLocalizations.of(context)!;
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('confirm_booking')),
        content: Text(
          widget.paymentOption == PaymentOption.partialAdvance
              ? 'You will pay ₹${widget.costBreakdown.advanceAmount?.toInt()} now and ₹${widget.costBreakdown.remainingAmount?.toInt()} after work completion.'
              : 'You will pay ₹${widget.costBreakdown.totalCost.toInt()} after work completion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: Text(loc.translate('confirm')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Create booking
      final booking = await _bookingService.createBooking(
        farmerId: 'FARMER001',
        farmerName: 'Current User',
        farmerPhone: '9876543210',
        labourType: widget.skillType,
        workersRequired: widget.workersCount,
        workDate: widget.workDate,
        duration: widget.duration,
        wagePerWorker: widget.wagePerWorker,
        workLocation: widget.workLocation,
        workNotes: widget.workNotes,
        paymentOption: widget.paymentOption,
      );

      // Navigate to active booking
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LabourActiveBookingScreen(
              bookingId: booking.bookingId,
            ),
          ),
        );
      }
    }
  }

  String _getSkillDisplayName(LabourSkillType type) {
    switch (type) {
      case LabourSkillType.harvesting:
        return 'Harvesting';
      case LabourSkillType.loadingUnloading:
        return 'Loading & Unloading';
      case LabourSkillType.fieldWorker:
        return 'Field Worker';
      case LabourSkillType.irrigation:
        return 'Irrigation';
      case LabourSkillType.constructionHelper:
        return 'Construction Helper';
      case LabourSkillType.generalFarm:
        return 'General Farm Work';
    }
  }
}

class _WorkerCard extends StatelessWidget {
  final LabourPartner worker;

  const _WorkerCard({required this.worker});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              child: Text(
                worker.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Worker info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        worker.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.work, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${worker.totalJobsCompleted} jobs',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${worker.distanceFromWork?.toStringAsFixed(1) ?? 0} km away',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Verified badge
            if (worker.isVerified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
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
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _CostRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
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
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
