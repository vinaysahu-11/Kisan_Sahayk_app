import 'package:flutter/material.dart';
import 'transport_booking_models.dart';
import 'transport_driver_matched_screen.dart';

class TransportLoadDetailsScreen extends StatefulWidget {
  final Vehicle vehicle;
  final String pickupLocation;
  final String dropLocation;

  const TransportLoadDetailsScreen({
    super.key,
    required this.vehicle,
    required this.pickupLocation,
    required this.dropLocation,
  });

  @override
  State<TransportLoadDetailsScreen> createState() => _TransportLoadDetailsScreenState();
}

class _TransportLoadDetailsScreenState extends State<TransportLoadDetailsScreen> {
  LoadType selectedLoadType = LoadType.crops;
  final weightController = TextEditingController();
  final notesController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isSearching = false;

  @override
  void dispose() {
    weightController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _findDriver() async {
    setState(() {
      isSearching = true;
    });

    // Simulated driver search animation (3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      final pickup = DemoDataGenerator.getRandomLocation('pickup');
      final drop = DemoDataGenerator.getRandomLocation('drop');
      final distance = DemoDataGenerator.calculateDistance(pickup, drop);
      
      final booking = TransportBooking(
        id: 'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        pickupLocation: Location(latitude: pickup.latitude, longitude: pickup.longitude, address: widget.pickupLocation),
        dropLocation: Location(latitude: drop.latitude, longitude: drop.longitude, address: widget.dropLocation),
        vehicle: widget.vehicle,
        loadType: selectedLoadType,
        weight: double.tryParse(weightController.text) ?? 1.0,
        pickupDateTime: DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        ),
        notes: notesController.text,
        distance: distance,
      );
      
      booking.fare = booking.calculateFare();
      booking.driver = Driver.generateRandomDriver(widget.vehicle.type, widget.vehicle.loadCapacity);
      booking.status = BookingStatus.driverAccepted;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TransportDriverMatchedScreen(booking: booking),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Load Details', style: TextStyle(color: Color(0xFF1B3D2A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B3D2A)),
      ),
      body: isSearching ? _buildSearchingView() : _buildLoadDetailsForm(),
    );
  }

  Widget _buildSearchingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              strokeWidth: 8,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'Searching nearby transport partners...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B3D2A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Matching you with the best ${widget.vehicle.name} driver',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadDetailsForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Vehicle Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(46, 125, 50, 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color.fromRGBO(46, 125, 50, 0.2)),
            ),
            child: Row(
              children: [
                Text(widget.vehicle.icon, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vehicle.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B3D2A)),
                    ),
                    Text(
                      'Price: ₹${widget.vehicle.pricePerKm}/km',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Load Type
          const Text('Load Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1B3D2A))),
          const SizedBox(height: 12),
          DropdownButtonFormField<LoadType>(
            initialValue: selectedLoadType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            items: LoadType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) => setState(() => selectedLoadType = value!),
          ),
          const SizedBox(height: 24),
          
          // Weight
          const Text('Approx Weight (Tons)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1B3D2A))),
          const SizedBox(height: 12),
          TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'e.g. 2.5',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              suffixText: 'Ton',
            ),
          ),
          const SizedBox(height: 24),
          
          // Date & Time
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pickup Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1B3D2A))),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: Color(0xFF2E7D32)),
                            const SizedBox(width: 8),
                            Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pickup Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1B3D2A))),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 18, color: Color(0xFF2E7D32)),
                            const SizedBox(width: 8),
                            Text(selectedTime.format(context)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Notes
          const Text('Notes (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1B3D2A))),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any special instructions for the driver',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 40),
          
          // Find Driver Button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _findDriver,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Find Driver', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
