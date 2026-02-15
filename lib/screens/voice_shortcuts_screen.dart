// Voice Shortcuts Screen - Shows available voice commands

import 'package:flutter/material.dart';

class VoiceShortcutsScreen extends StatelessWidget {
  const VoiceShortcutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Commands'),
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : const Color(0xFF2E6B3F),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.green.shade500],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.mic, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Voice Commands Guide',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mic button dabao aur niche diye commands bolo',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Quick Commands
          _buildSection(
            context,
            'Quick Navigate',
            [
              CommandItem(
                command: 'Dashboard pe jao',
                description: 'Open dashboard',
                icon: Icons.home,
              ),
              CommandItem(
                command: 'Transport chahiye',
                description: 'Book transport',
                icon: Icons.local_shipping,
              ),
              CommandItem(
                command: 'Beej kharidna hai',
                description: 'Buy products',
                icon: Icons.shopping_cart,
              ),
              CommandItem(
                command: 'Bechna hai',
                description: 'Sell products',
                icon: Icons.inventory,
              ),
              CommandItem(
                command: 'Majdoor chahiye',
                description: 'Hire labour',
                icon: Icons.people,
              ),
              CommandItem(
                command: 'Mausam dikhao',
                description: 'Weather forecast',
                icon: Icons.wb_cloudy,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Transport Commands
          _buildSection(
            context,
            'Transport Screen',
            [
              CommandItem(
                command: 'Mini truck select karo',
                description: 'Select vehicle type',
                icon: Icons.directions_car,
              ),
              CommandItem(
                command: 'Pickup location Raipur',
                description: 'Set pickup point',
                icon: Icons.location_on,
              ),
              CommandItem(
                command: 'Drop location Durg',
                description: 'Set drop point',
                icon: Icons.place,
              ),
              CommandItem(
                command: 'Booking confirm karo',
                description: 'Confirm booking',
                icon: Icons.check_circle,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Buy/Sell Commands
          _buildSection(
            context,
            'Shopping Commands',
            [
              CommandItem(
                command: 'Beej dhundo',
                description: 'Search seeds',
                icon: Icons.search,
              ),
              CommandItem(
                command: 'Cart me dalo',
                description: 'Add to cart',
                icon: Icons.add_shopping_cart,
              ),
              CommandItem(
                command: 'Cart dikhao',
                description: 'View cart',
                icon: Icons.shopping_cart,
              ),
              CommandItem(
                command: 'Order karo',
                description: 'Place order',
                icon: Icons.shopping_bag,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Other Commands
          _buildSection(
            context,
            'Other Actions',
            [
              CommandItem(
                command: 'Profile dikhao',
                description: 'View profile',
                icon: Icons.person,
              ),
              CommandItem(
                command: 'Orders dikhao',
                description: 'View orders',
                icon: Icons.list_alt,
              ),
              CommandItem(
                command: 'Wallet kholo',
                description: 'Open wallet',
                icon: Icons.account_balance_wallet,
              ),
              CommandItem(
                command: 'Back jao',
                description: 'Go back',
                icon: Icons.arrow_back,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Tips',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTip('Aap Hindi, English ya Hinglish me bol sakte ho'),
                _buildTip('Learning Mode ON karke step-by-step seekh sakte ho'),
                _buildTip('Mic button floating mic se kahin se bhi access kar sakte ho'),
                _buildTip('Natural language me bolo, exact commands zaruri nahi'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<CommandItem> commands) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...commands.map((cmd) => _buildCommandCard(context, cmd)),
      ],
    );
  }

  Widget _buildCommandCard(BuildContext context, CommandItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(item.icon, color: Colors.green.shade700, size: 22),
        ),
        title: Text(
          item.command,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          item.description,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.blue.shade700, fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.blue.shade900, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class CommandItem {
  final String command;
  final String description;
  final IconData icon;

  CommandItem({
    required this.command,
    required this.description,
    required this.icon,
  });
}
