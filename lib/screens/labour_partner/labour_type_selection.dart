import 'package:flutter/material.dart';
import '../../utils/app_localizations.dart';
import 'labour_work_details.dart';

class LabourTypeSelection extends StatefulWidget {
  const LabourTypeSelection({super.key});

  @override
  State<LabourTypeSelection> createState() => _LabourTypeSelectionState();
}

class _LabourTypeSelectionState extends State<LabourTypeSelection> {
  final List<String> selectedSkills = [];
  String skillLevel = 'Experienced';
  int yearsOfExperience = 2;

  final List<Map<String, dynamic>> skills = [
    {'icon': Icons.grass, 'name': 'Harvesting Worker'},
    {'icon': Icons.inventory_2, 'name': 'Loading/Unloading'},
    {'icon': Icons.agriculture, 'name': 'Field Worker'},
    {'icon': Icons.water_drop, 'name': 'Irrigation Worker'},
    {'icon': Icons.construction, 'name': 'Construction Helper'},
    {'icon': Icons.person, 'name': 'General Farm Labour'},
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(loc.translate('select_skills'), style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            const Text(
              'What type of work can you do?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'Select all that apply',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            
            const SizedBox(height: 24),
            
            // Skills Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: skills.length,
              itemBuilder: (context, index) {
                final skill = skills[index];
                final isSelected = selectedSkills.contains(skill['name']);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedSkills.remove(skill['name']);
                      } else {
                        selectedSkills.add(skill['name']);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          skill['icon'],
                          size: 40,
                          color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade600,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          skill['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                          ),
                        ),
                        if (isSelected)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Skill Level
            const Text(
              'Skill Level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildSkillLevelButton('Beginner'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSkillLevelButton('Experienced'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Years of Experience
            const Text(
              'Years of Experience',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButton<int>(
                value: yearsOfExperience,
                isExpanded: true,
                underline: const SizedBox(),
                style: const TextStyle(fontSize: 18, color: Colors.black87),
                items: List.generate(20, (index) => index + 1)
                    .map((year) => DropdownMenuItem(
                          value: year,
                          child: Text('$year ${year == 1 ? 'Year' : 'Years'}'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => yearsOfExperience = value!);
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: selectedSkills.isEmpty
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LabourWorkDetails()),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(loc.translate('next'), style: const TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillLevelButton(String level) {
    final isSelected = skillLevel == level;
    return GestureDetector(
      onTap: () => setState(() => skillLevel = level),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            level,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
