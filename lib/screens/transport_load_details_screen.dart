import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../models/transport_models.dart';
import 'transport_fare_breakdown_screen.dart';

class TransportLoadDetailsScreen extends StatefulWidget {
  final Location pickupLocation;
  final Location dropLocation;
  final double distance;
  final VehicleInfo vehicleInfo;

  const TransportLoadDetailsScreen({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
    required this.distance,
    required this.vehicleInfo,
  });

  @override
  State<TransportLoadDetailsScreen> createState() =>
      _TransportLoadDetailsScreenState();
}

class _TransportLoadDetailsScreenState
    extends State<TransportLoadDetailsScreen> {
  LoadType _selectedLoadType = LoadType.crop;
  double _loadWeight = 1.0;
  BookingType _bookingType = BookingType.instant;
  DateTime? _scheduledTime;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _selectScheduledTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
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

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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

      if (time != null) {
        setState(() {
          _scheduledTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _proceedToFareBreakdown() {
    if (_loadWeight > widget.vehicleInfo.capacityTon) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Load weight exceeds vehicle capacity of ${widget.vehicleInfo.capacityTon} Ton',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_bookingType == BookingType.scheduled && _scheduledTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.translate('select_scheduled_time')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransportFareBreakdownScreen(
          pickupLocation: widget.pickupLocation,
          dropLocation: widget.dropLocation,
          distance: widget.distance,
          vehicleInfo: widget.vehicleInfo,
          loadType: _selectedLoadType,
          loadWeightTon: _loadWeight,
          loadNotes: _notesController.text.isEmpty ? null : _notesController.text,
          bookingType: _bookingType,
          scheduledTime: _scheduledTime,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('load_details')),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected vehicle summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          widget.vehicleInfo.icon,
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.vehicleInfo.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${widget.distance.toStringAsFixed(1)} km • Max ${widget.vehicleInfo.capacityTon} Ton',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Load type
                  Text(
                    loc.translate('type_of_load'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: LoadType.values.map((type) {
                      final isSelected = _selectedLoadType == type;
                      return ChoiceChip(
                        label: Text(_getLoadTypeLabel(type)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedLoadType = type);
                          }
                        },
                        selectedColor: const Color(0xFF2E7D32),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: Colors.grey[100],
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Load weight
                  Text(
                    loc.translate('load_weight'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _loadWeight,
                          min: 0.5,
                          max: widget.vehicleInfo.capacityTon,
                          divisions: (widget.vehicleInfo.capacityTon * 2).toInt(),
                          activeColor: const Color(0xFF2E7D32),
                          label: '${_loadWeight.toStringAsFixed(1)} Ton',
                          onChanged: (value) {
                            setState(() => _loadWeight = value);
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_loadWeight.toStringAsFixed(1)} Ton',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Booking type
                  const Text(
                    'Booking Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _BookingTypeCard(
                          icon: Icons.bolt,
                          title: loc.translate('book_now'),
                          subtitle: loc.translate('book_now'),
                          isSelected: _bookingType == BookingType.instant,
                          onTap: () {
                            setState(() {
                              _bookingType = BookingType.instant;
                              _scheduledTime = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BookingTypeCard(
                          icon: Icons.schedule,
                          title: 'Scheduled',
                          subtitle: 'Book later',
                          isSelected: _bookingType == BookingType.scheduled,
                          onTap: () {
                            setState(() => _bookingType = BookingType.scheduled);
                            if (_scheduledTime == null) {
                              _selectScheduledTime();
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  // Scheduled time display
                  if (_bookingType == BookingType.scheduled) ...[
                    const SizedBox(height: 12),
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      elevation: 2,
                      shadowColor: Colors.black12,
                      child: InkWell(
                        onTap: _selectScheduledTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF2E7D32),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _scheduledTime != null
                                      ? '${_scheduledTime!.day}/${_scheduledTime!.month}/${_scheduledTime!.year} at ${_scheduledTime!.hour}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
                                      : 'Select date & time',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _scheduledTime != null
                                        ? Colors.black87
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: Colors.grey[400]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Additional notes
                  const Text(
                    'Additional Notes (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'E.g., Loading requirements, special instructions...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Continue button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _proceedToFareBreakdown,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  loc.translate('fare_breakdown'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLoadTypeLabel(LoadType type) {
    switch (type) {
      case LoadType.crop:
        return 'Crop';
      case LoadType.fertilizer:
        return 'Fertilizer';
      case LoadType.equipment:
        return 'Equipment';
      case LoadType.other:
        return 'Other';
    }
  }
}

class _BookingTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _BookingTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: isSelected ? 4 : 2,
      shadowColor: isSelected
          ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
          : Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
