import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/labour_models.dart';
import '../services/labour_booking_service.dart';
import '../utils/app_localizations.dart';
import 'labour_confirmation_screen.dart';

class LabourBookingDetailsScreen extends StatefulWidget {
  final LabourSkillInfo selectedSkill;

  const LabourBookingDetailsScreen({
    super.key,
    required this.selectedSkill,
  });

  @override
  State<LabourBookingDetailsScreen> createState() =>
      _LabourBookingDetailsScreenState();
}

class _LabourBookingDetailsScreenState
    extends State<LabourBookingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _workNotesController = TextEditingController();
  final _bookingService = LabourBookingService();

  int _workersCount = 1;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  WorkDuration _selectedDuration = WorkDuration.fullDay;
  double _wagePerWorker = 0;
  PaymentOption _paymentOption = PaymentOption.payAfterWork;
  Location? _workLocation;
  LabourCostBreakdown? _costBreakdown;

  @override
  void initState() {
    super.initState();
    _wagePerWorker = widget.selectedSkill.minWagePerDay + 50;
    _calculateCost();
  }

  void _calculateCost() {
    setState(() {
      _costBreakdown = _bookingService.calculateCost(
        workersCount: _workersCount,
        wagePerWorker: _wagePerWorker,
        duration: _selectedDuration,
        paymentOption: _paymentOption,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('booking_details')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Skill summary
                    _buildSkillSummary(),
                    const SizedBox(height: 20),

                    // Number of workers
                    _buildWorkersCountSection(),
                    const SizedBox(height: 20),

                    // Work date
                    _buildDateSection(),
                    const SizedBox(height: 20),

                    // Work duration
                    _buildDurationSection(),
                    const SizedBox(height: 20),

                    // Wage per worker
                    _buildWageSection(),
                    const SizedBox(height: 20),

                    // Work location
                    _buildLocationSection(),
                    const SizedBox(height: 20),

                    // Work notes
                    _buildNotesSection(),
                    const SizedBox(height: 20),

                    // Payment option
                    _buildPaymentOptionSection(),
                    const SizedBox(height: 20),

                    // Cost breakdown
                    if (_costBreakdown != null) _buildCostBreakdown(),
                  ],
                ),
              ),
            ),

            // Bottom action button
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.agriculture, color: const Color(0xFF2E7D32), size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getSkillDisplayName(widget.selectedSkill.skillType),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${widget.selectedSkill.minWagePerDay.toInt()}-${widget.selectedSkill.maxWagePerDay.toInt()}/day • ${widget.selectedSkill.availableWorkers} available',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkersCountSection() {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('workers_needed'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: _workersCount > 1
                  ? () {
                      setState(() {
                        _workersCount--;
                      });
                      _calculateCost();
                    }
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: const Color(0xFF2E7D32),
              iconSize: 36,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_workersCount worker${_workersCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _workersCount < 20
                  ? () {
                      setState(() {
                        _workersCount++;
                      });
                      _calculateCost();
                    }
                  : null,
              icon: const Icon(Icons.add_circle_outline),
              color: const Color(0xFF2E7D32),
              iconSize: 36,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('work_date'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormat('EEEE, d MMMM y').format(_selectedDate),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Work Duration',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DurationChip(
                label: 'Half Day (4 hours)',
                isSelected: _selectedDuration == WorkDuration.halfDay,
                onTap: () {
                  setState(() {
                    _selectedDuration = WorkDuration.halfDay;
                    _wagePerWorker = _wagePerWorker / 2;
                  });
                  _calculateCost();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DurationChip(
                label: 'Full Day (8 hours)',
                isSelected: _selectedDuration == WorkDuration.fullDay,
                onTap: () {
                  setState(() {
                    _selectedDuration = WorkDuration.fullDay;
                    if (_selectedDuration == WorkDuration.halfDay) {
                      _wagePerWorker = _wagePerWorker * 2;
                    }
                  });
                  _calculateCost();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.translate('daily_wage'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              '₹${_wagePerWorker.toInt()}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF2E7D32),
            thumbColor: const Color(0xFF2E7D32),
            overlayColor: const Color(0xFF2E7D32).withValues(alpha: 0.2),
          ),
          child: Slider(
            value: _wagePerWorker,
            min: widget.selectedSkill.minWagePerDay,
            max: widget.selectedSkill.maxWagePerDay,
            divisions: ((widget.selectedSkill.maxWagePerDay -
                        widget.selectedSkill.minWagePerDay) /
                    50)
                .toInt(),
            onChanged: (value) {
              setState(() {
                _wagePerWorker = value;
              });
              _calculateCost();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${widget.selectedSkill.minWagePerDay.toInt()}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '₹${widget.selectedSkill.maxWagePerDay.toInt()}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('work_location'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: loc.translate('enter_work_location'),
            prefixIcon: const Icon(Icons.location_on, color: Color(0xFF2E7D32)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.my_location, color: Color(0xFF2E7D32)),
              onPressed: _useCurrentLocation,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter work location';
            }
            return null;
          },
          onChanged: (value) {
            if (value.isNotEmpty) {
              // Simulate location selection
              _workLocation = Location(
                latitude: 21.2514,
                longitude: 81.6296,
                address: value,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Notes (Optional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _workNotesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
                'E.g., specific instructions, tools required, safety concerns...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Option',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _PaymentOptionCard(
          icon: Icons.schedule,
          title: 'Pay After Work',
          subtitle: 'Pay full amount after work completion',
          isSelected: _paymentOption == PaymentOption.payAfterWork,
          onTap: () {
            setState(() {
              _paymentOption = PaymentOption.payAfterWork;
            });
            _calculateCost();
          },
        ),
        const SizedBox(height: 12),
        _PaymentOptionCard(
          icon: Icons.payments,
          title: 'Partial Advance (30%)',
          subtitle: 'Pay 30% now, remaining after work',
          isSelected: _paymentOption == PaymentOption.partialAdvance,
          onTap: () {
            setState(() {
              _paymentOption = PaymentOption.partialAdvance;
            });
            _calculateCost();
          },
        ),
      ],
    );
  }

  Widget _buildCostBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cost Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _CostRow(
            label: 'Workers (${_costBreakdown!.workersCount})',
            value: '₹${_costBreakdown!.wagePerWorker.toInt()} × ${_costBreakdown!.workersCount}',
          ),
          _CostRow(
            label: 'Subtotal',
            value: '₹${_costBreakdown!.subtotal.toInt()}',
          ),
          _CostRow(
            label: 'Platform Fee (5%)',
            value: '₹${_costBreakdown!.platformFee.toInt()}',
          ),
          const Divider(height: 20),
          _CostRow(
            label: 'Total Amount',
            value: '₹${_costBreakdown!.totalCost.toInt()}',
            isBold: true,
          ),
          if (_paymentOption == PaymentOption.partialAdvance) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _CostRow(
                    label: 'Advance (30%)',
                    value:
                        '₹${_costBreakdown!.advanceAmount?.toInt() ?? 0}',
                    color: const Color(0xFF2E7D32),
                  ),
                  _CostRow(
                    label: 'Pay After Work',
                    value:
                        '₹${_costBreakdown!.remainingAmount?.toInt() ?? 0}',
                    color: const Color(0xFF2E7D32),
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
        onPressed: _proceedToConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Find Workers',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _useCurrentLocation() {
    // Simulate GPS location
    _locationController.text = 'My Current Location (GPS)';
    _workLocation = Location(
      latitude: 21.2514,
      longitude: 81.6296,
      address: 'My Current Location (GPS)',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.translate('location_detected'))),
    );
  }

  void _proceedToConfirmation() {
    if (_formKey.currentState!.validate() && _workLocation != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LabourConfirmationScreen(
            skillType: widget.selectedSkill.skillType,
            workersCount: _workersCount,
            workDate: _selectedDate,
            duration: _selectedDuration,
            wagePerWorker: _wagePerWorker,
            workLocation: _workLocation!,
            workNotes: _workNotesController.text.isEmpty
                ? null
                : _workNotesController.text,
            costBreakdown: _costBreakdown!,
            paymentOption: _paymentOption,
          ),
        ),
      );
    } else if (_workLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.translate('enter_work_location'))),
      );
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

  @override
  void dispose() {
    _locationController.dispose();
    _workNotesController.dispose();
    super.dispose();
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? const Color(0xFF2E7D32).withValues(alpha: 0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
          ],
        ),
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
