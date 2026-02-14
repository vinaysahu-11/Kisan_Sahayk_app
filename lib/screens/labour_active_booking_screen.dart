import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/labour_models.dart';
import '../services/labour_booking_service.dart';
import '../utils/app_localizations.dart';

class LabourActiveBookingScreen extends StatefulWidget {
  final String bookingId;

  const LabourActiveBookingScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<LabourActiveBookingScreen> createState() =>
      _LabourActiveBookingScreenState();
}

class _LabourActiveBookingScreenState
    extends State<LabourActiveBookingScreen> {
  final _bookingService = LabourBookingService();
  LabourBooking? _booking;
  StreamSubscription<LabourBooking>? _bookingSubscription;

  @override
  void initState() {
    super.initState();
    _loadBooking();
    _listenToUpdates();
  }

  void _loadBooking() {
    _bookingService.getBookingById(widget.bookingId).then((result) {
      if (result['booking'] != null) {
        setState(() {
          _booking = LabourBooking.fromJson(result['booking']);
        });
      }
    });
  }

  void _listenToUpdates() {
    // TODO: Implement real-time updates using WebSocket or polling
    // For now, we'll just refresh periodically
    // _bookingSubscription =
    //     _bookingService.bookingUpdates.listen((updatedBooking) {
    //   if (updatedBooking.bookingId == widget.bookingId) {
    //     setState(() {
    //       _booking = updatedBooking;
    //     });

    //     // Auto navigate to payment when work is completed
    //     if (updatedBooking.status == LabourBookingStatus.workCompleted) {
    //       Future.delayed(const Duration(seconds: 2), () {
    //         if (mounted) {
    //           Navigator.pushReplacement(
    //             context,
    //             MaterialPageRoute(
    //               builder: (context) => LabourPaymentScreen(
    //                 bookingId: widget.bookingId,
    //               ),
    //             ),
    //           );
    //         }
    //       });
    //     }
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_booking == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.translate('labour_booking')),
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
        title: Text(loc.translate('active_labour_booking')),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBooking,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          _buildStatusBar(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Work info
                  _buildWorkInfo(),
                  const SizedBox(height: 20),

                  // Workers list
                  _buildWorkersList(),
                  const SizedBox(height: 20),

                  // Work location
                  _buildLocationCard(),
                  const SizedBox(height: 20),

                  // Cost breakdown
                  _buildCostCard(),
                  const SizedBox(height: 20),

                  // Demo controls
                  if (_booking!.status != LabourBookingStatus.workCompleted &&
                      _booking!.status != LabourBookingStatus.paymentReleased)
                    _buildDemoControls(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (_booking!.status) {
      case LabourBookingStatus.searching:
        statusColor = Colors.blue;
        statusText = 'Searching for workers...';
        statusIcon = Icons.search;
        break;
      case LabourBookingStatus.labourAssigned:
        statusColor = Colors.orange;
        statusText = 'Workers assigned';
        statusIcon = Icons.assignment_turned_in;
        break;
      case LabourBookingStatus.workConfirmed:
        statusColor = const Color(0xFF2E7D32);
        statusText = 'Work confirmed';
        statusIcon = Icons.check_circle;
        break;
      case LabourBookingStatus.workStarted:
        statusColor = Colors.purple;
        statusText = 'Work in progress';
        statusIcon = Icons.work;
        break;
      case LabourBookingStatus.workCompleted:
        statusColor = Colors.teal;
        statusText = 'Work completed';
        statusIcon = Icons.done_all;
        break;
      case LabourBookingStatus.paymentReleased:
        statusColor = Colors.green;
        statusText = 'Payment released';
        statusIcon = Icons.payment;
        break;
      case LabourBookingStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Cancelled';
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: statusColor.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                Text(
                  'Booking ID: ${_booking!.bookingId}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.agriculture,
                    color: const Color(0xFF2E7D32), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getSkillDisplayName(_booking!.labourType),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_booking!.workersRequired} workers • ${_booking!.duration == WorkDuration.fullDay ? 'Full Day' : 'Half Day'}',
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Work Date',
              value: DateFormat('EEEE, d MMMM y').format(_booking!.workDate),
            ),
            if (_booking!.workNotes != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.note,
                label: 'Notes',
                value: _booking!.workNotes!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWorkersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workers Assigned',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (_booking!.assignedLabourers.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Searching for workers...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          )
        else
          ...List.generate(
            _booking!.assignedLabourers.length,
            (index) => _WorkerCard(
              worker: _booking!.assignedLabourers[index],
              onCall: () => _callWorker(_booking!.assignedLabourers[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text(
                  'Work Location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _booking!.workLocation.address,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, color: Colors.grey.shade400, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Map View',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _CostRow(
              label: 'Labour Cost',
              value: '₹${_booking!.costBreakdown.subtotal.toInt()}',
            ),
            _CostRow(
              label: 'Platform Fee',
              value: '₹${_booking!.costBreakdown.platformFee.toInt()}',
            ),
            const Divider(height: 20),
            _CostRow(
              label: 'Total Amount',
              value: '₹${_booking!.costBreakdown.totalCost.toInt()}',
              isBold: true,
              color: const Color(0xFF2E7D32),
            ),
            if (_booking!.paymentOption == PaymentOption.partialAdvance) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _CostRow(
                      label: 'Advance Paid',
                      value:
                          '₹${_booking!.costBreakdown.advanceAmount?.toInt() ?? 0}',
                      color: Colors.green,
                    ),
                    _CostRow(
                      label: 'Remaining',
                      value:
                          '₹${_booking!.costBreakdown.remainingAmount?.toInt() ?? 0}',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDemoControls() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Demo Controls',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_booking!.status == LabourBookingStatus.workConfirmed)
                  _DemoButton(
                    label: 'Start Work',
                    onPressed: () => _bookingService.updateBookingStatus(
                      widget.bookingId,
                      LabourBookingStatus.workStarted.name,
                    ),
                  ),
                if (_booking!.status == LabourBookingStatus.workStarted)
                  _DemoButton(
                    label: 'Complete Work',
                    onPressed: () => _bookingService.updateBookingStatus(
                      widget.bookingId,
                      LabourBookingStatus.workCompleted.name,
                    ),
                  ),
                _DemoButton(
                  label: 'Refresh',
                  icon: Icons.refresh,
                  onPressed: _loadBooking,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _callWorker(LabourPartner worker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${AppLocalizations.of(context)!.translate('call')} ${worker.name}'),
        content: Text('Would you like to call ${worker.phone}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In real app: launch phone dialer
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${worker.phone}...')),
              );
            },
            child: Text(AppLocalizations.of(context)!.translate('call')),
          ),
        ],
      ),
    );
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

  @override
  void dispose() {
    _bookingSubscription?.cancel();
    super.dispose();
  }
}

class _WorkerCard extends StatelessWidget {
  final LabourPartner worker;
  final VoidCallback onCall;

  const _WorkerCard({
    required this.worker,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              child: Text(
                worker.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        worker.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${worker.experienceYears}y exp',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onCall,
              icon: const Icon(Icons.phone),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
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

class _DemoButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  const _DemoButton({
    required this.label,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.touch_app, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
