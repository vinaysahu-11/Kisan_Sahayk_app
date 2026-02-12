import 'package:flutter/material.dart';
import '../models/labour_models.dart';
import '../utils/app_localizations.dart';
import 'labour_booking_details_screen.dart';

class LabourSkillSelectionScreen extends StatefulWidget {
  const LabourSkillSelectionScreen({super.key});

  @override
  State<LabourSkillSelectionScreen> createState() =>
      _LabourSkillSelectionScreenState();
}

class _LabourSkillSelectionScreenState
    extends State<LabourSkillSelectionScreen> {
  final List<LabourSkillInfo> availableSkills =
      LabourSkillInfo.getAvailableSkills();
  LabourSkillType? _selectedSkill;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('select_labour_type')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.group_work,
                        color: Color(0xFF2E7D32), size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Skilled Labour Available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose the type of work you need',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Skill cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availableSkills.length,
              itemBuilder: (context, index) {
                final skill = availableSkills[index];
                final isSelected = _selectedSkill == skill.skillType;

                return _SkillCard(
                  skill: skill,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedSkill = skill.skillType;
                    });
                    _proceedToBooking(skill);
                  },
                );
              },
            ),
          ),

          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'All workers are verified with experience tracking',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToBooking(LabourSkillInfo skill) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LabourBookingDetailsScreen(
          selectedSkill: skill,
        ),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final LabourSkillInfo skill;
  final bool isSelected;
  final VoidCallback onTap;

  const _SkillCard({
    required this.skill,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getSkillIcon(LabourSkillType type) {
    switch (type) {
      case LabourSkillType.harvesting:
        return Icons.agriculture;
      case LabourSkillType.loadingUnloading:
        return Icons.local_shipping;
      case LabourSkillType.fieldWorker:
        return Icons.grass;
      case LabourSkillType.irrigation:
        return Icons.water_drop;
      case LabourSkillType.constructionHelper:
        return Icons.construction;
      case LabourSkillType.generalFarm:
        return Icons.handyman;
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

  String _getSkillDescription(LabourSkillType type) {
    switch (type) {
      case LabourSkillType.harvesting:
        return 'Crop cutting, collection, bundling';
      case LabourSkillType.loadingUnloading:
        return 'Loading/unloading goods, shifting';
      case LabourSkillType.fieldWorker:
        return 'Plowing, sowing, weeding, hoeing';
      case LabourSkillType.irrigation:
        return 'Water management, pipe fitting';
      case LabourSkillType.constructionHelper:
        return 'Farm building, shed construction';
      case LabourSkillType.generalFarm:
        return 'General farm maintenance work';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getSkillIcon(skill.skillType),
                      color: const Color(0xFF2E7D32),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Skill info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getSkillDisplayName(skill.skillType),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getSkillDescription(skill.skillType),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios,
                    color: isSelected
                        ? const Color(0xFF2E7D32)
                        : Colors.grey[400],
                    size: 18,
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Wage and availability info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Wage range
                  Row(
                    children: [
                      Icon(Icons.currency_rupee,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '₹${skill.minWagePerDay.toInt()}-${skill.maxWagePerDay.toInt()}/day',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),

                  // Available workers
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${skill.availableWorkers} available',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        skill.averageRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
