// Example: Transport Screen with Voice Form Fill

// This is an example showing how to integrate voice form filling

/* 
USAGE IN TRANSPORT SCREEN:

import '../services/form_fill_handler.dart';

class TransportScreen extends StatefulWidget {
  @override
  _TransportScreenState createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> with VoiceFormMixin {
  // Controllers
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  final _dateController = TextEditingController();
  String? _vehicleType;
  
  @override
  String get screenName => 'transport';
  
  @override
  Map<String, TextEditingController> get formControllers => {
    'pickup_location': _pickupController,
    'drop_location': _dropController,
    'date': _dateController,
  };
  
  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    _dateController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transport Booking')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Vehicle type dropdown
            DropdownButton<String>(
              value: _vehicleType,
              hint: Text('Vehicle Type'),
              items: [
                DropdownMenuItem(value: 'mini_truck', child: Text('Mini Truck')),
                DropdownMenuItem(value: 'tractor', child: Text('Tractor')),
                DropdownMenuItem(value: 'tempo', child: Text('Tempo')),
              ],
              onChanged: (value) {
                setState(() {
                  _vehicleType = value;
                });
              },
            ),
            
            // Pickup location
            TextField(
              controller: _pickupController,
              decoration: InputDecoration(
                labelText: 'Pickup Location',
                hintText: 'Kaha se uthana hai?',
              ),
            ),
            
            // Drop location
            TextField(
              controller: _dropController,
              decoration: InputDecoration(
                labelText: 'Drop Location',
                hintText: 'Kaha pahunchana hai?',
              ),
            ),
            
            // Date
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Date',
                hintText: 'Kab chahiye?',
              ),
            ),
            
            SizedBox(height: 20),
            
            // Booking button
            ElevatedButton(
              onPressed: () {
                // Handle booking
              },
              child: Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}

// VOICE COMMANDS THAT WORK:
// - "Mini truck chahiye Raipur se Durg"
//   → Sets: vehicle_type='mini_truck', pickup='Raipur', drop='Durg'
//
// - "Tractor book karo kal ke liye"
//   → Sets: vehicle_type='tractor', date='tomorrow'
//
// - "Transport chahiye Bilaspur to Raipur aaj"
//   → Sets: pickup='Bilaspur', drop='Raipur', date='today'

*/

// BUY PRODUCT SCREEN EXAMPLE:
/*
class BuyProductScreenState extends State<BuyProductScreen> with VoiceFormMixin {
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  
  @override
  String get screenName => 'buy_product';
  
  @override
  Map<String, TextEditingController> get formControllers => {
    'search_query': _searchController,
    'quantity': _quantityController,
  };
  
  // Voice commands:
  // - "Beej kharidna hai" → Sets search_query='beej'
  // - "10 kg khaad chahiye" → Sets search_query='khaad', quantity='10'
}
*/

// SELL PRODUCT SCREEN EXAMPLE:
/*
class SellProductScreenState extends State<SellProductScreen> with VoiceFormMixin {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  
  @override
  String get screenName => 'sell_product';
  
  @override
  Map<String, TextEditingController> get formControllers => {
    'product_name': _nameController,
    'price': _priceController,
    'quantity': _quantityController,
  };
  
  // Voice commands:
  // - "Dhan bechna hai 50 quintal 2000 rupay kg" 
  //   → Sets: product_name='dhan', quantity='50', price='2000'
}
*/

// LABOUR SCREEN EXAMPLE:
/*
class LabourScreenState extends State<LabourScreen> with VoiceFormMixin {
  final _locationController = TextEditingController();
  final _countController = TextEditingController();
  final _dateController = TextEditingController();
  
  @override
  String get screenName => 'labour';
  
  @override
  Map<String, TextEditingController> get formControllers => {
    'location': _locationController,
    'labour_count': _countController,
    'date': _dateController,
  };
  
  // Voice commands:
  // - "5 majdoor chahiye katai ke liye Raipur me"
  //   → Sets: labour_count='5', skill='harvesting', location='Raipur'
}
*/
