import 'package:flutter/material.dart';
import '../models/seller_models.dart';
import '../services/seller_service.dart';
import '../utils/app_localizations.dart';

class AdminCategoryScreen extends StatefulWidget {
  const AdminCategoryScreen({super.key});

  @override
  State<AdminCategoryScreen> createState() => _AdminCategoryScreenState();
}

class _AdminCategoryScreenState extends State<AdminCategoryScreen> {
  final _service = SellerService();
  bool _showDisabled = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    var categories = _service.getAllCategories();
    if (!_showDisabled) {
      categories = categories.where((c) => c.isEnabled).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('manage_categories')),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: Icon(_showDisabled ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _showDisabled = !_showDisabled),
            tooltip: _showDisabled ? 'Hide Disabled' : 'Show Disabled',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final subcategories = _service.getSubcategories(category.id);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: category.isEnabled
                    ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                child: Icon(
                  Icons.category,
                  color: category.isEnabled ? const Color(0xFF2E7D32) : Colors.grey,
                  size: 20,
                ),
              ),
              title: Text(
                category.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: category.isEnabled ? Colors.black : Colors.grey,
                ),
              ),
              subtitle: Text('Commission: ${category.commissionPercent}%'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: category.isEnabled,
                    onChanged: (value) => _toggleCategory(category.id, value),
                    activeThumbColor: const Color(0xFF2E7D32),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editCategory(category);
                      } else if (value == 'delete') {
                        _deleteCategory(category.id);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text(loc.translate('edit_category'))),
                      PopupMenuItem(value: 'delete', child: Text(loc.translate('delete_category'))),
                    ],
                  ),
                ],
              ),
              children: [
                if (subcategories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subcategories (${subcategories.length})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        ...subcategories.map((sub) => ListTile(
                              dense: true,
                              leading: Icon(Icons.subdirectory_arrow_right,
                                  size: 16, color: Colors.grey[600]),
                              title: Text(
                                sub.name,
                                style: const TextStyle(fontSize: 13),
                              ),
                              subtitle: Text(
                                'Commission: ${sub.commissionPercent}%',
                                style: const TextStyle(fontSize: 11),
                              ),
                            )),
                      ],
                    ),
                  ),
                if (category.dynamicFields?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Custom Fields',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...?category.dynamicFields?.entries.expand((entry) =>
                            entry.value.map((field) => Padding(
                                  padding: const EdgeInsets.only(left: 16, top: 4),
                                  child: Text('• $field',
                                      style: const TextStyle(fontSize: 12)),
                                ))),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCategory(),
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add),
        label: Text(loc.translate('add_category')),
      ),
    );
  }

  Future<void> _addCategory() async {
    final loc = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final commissionController = TextEditingController(text: '3.0');
    AgriCategory? selectedParent;
    double commissionValue = 3.0;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(loc.translate('add_category')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AgriCategory>(
                  initialValue: selectedParent,
                  decoration: const InputDecoration(
                    labelText: 'Parent Category (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<AgriCategory>(
                      value: null,
                      child: Text(loc.translate('none_root')),
                    ),
                    ..._service.getRootCategories().map(
                          (cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat.name),
                          ),
                        ),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedParent = value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commissionController,
                  decoration: const InputDecoration(
                    labelText: 'Commission %',
                    border: OutlineInputBorder(),
                    suffixText: '%',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    commissionValue = double.tryParse(value) ?? 3.0;
                  },
                ),
                const SizedBox(height: 8),
                Slider(
                  value: commissionValue,
                  min: 0,
                  max: 10,
                  divisions: 20,
                  label: '${commissionValue.toStringAsFixed(1)}%',
                  activeColor: const Color(0xFF2E7D32),
                  onChanged: (value) {
                    setDialogState(() {
                      commissionValue = value;
                      commissionController.text = value.toStringAsFixed(1);
                    });
                  },
                ),
              ],
            ),
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
              child: Text(loc.translate('add')),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final newCategory = AgriCategory(
        id: 'CAT${DateTime.now().millisecondsSinceEpoch}',
        name: nameController.text,
        parentId: selectedParent?.id,
        commissionPercent: commissionValue,
        isEnabled: true,
        dynamicFields: {},
      );
      
      _service.addCategory(newCategory);
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('category_added')),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _editCategory(AgriCategory category) async {
    final loc = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: category.name);
    final commissionController =
        TextEditingController(text: category.commissionPercent.toString());
    double commissionValue = category.commissionPercent;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(loc.translate('edit_category')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commissionController,
                  decoration: const InputDecoration(
                    labelText: 'Commission %',
                    border: OutlineInputBorder(),
                    suffixText: '%',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    commissionValue = double.tryParse(value) ?? category.commissionPercent;
                  },
                ),
                const SizedBox(height: 8),
                Slider(
                  value: commissionValue,
                  min: 0,
                  max: 10,
                  divisions: 20,
                  label: '${commissionValue.toStringAsFixed(1)}%',
                  activeColor: const Color(0xFF2E7D32),
                  onChanged: (value) {
                    setDialogState(() {
                      commissionValue = value;
                      commissionController.text = value.toStringAsFixed(1);
                    });
                  },
                ),
              ],
            ),
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
              child: Text(loc.translate('save')),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final updatedCategory = category.copyWith(
        name: nameController.text,
        commissionPercent: commissionValue,
      );
      
      _service.updateCategory(updatedCategory);
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('category_updated')),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _toggleCategory(String categoryId, bool isEnabled) async {
    final category = _service.getAllCategories().firstWhere((c) => c.id == categoryId);
    final updatedCategory = category.copyWith(isEnabled: isEnabled);
    _service.updateCategory(updatedCategory);
    setState(() {});
  }

  Future<void> _deleteCategory(String categoryId) async {
    final loc = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('delete_category')),
        content: const Text(
          'Are you sure you want to delete this category? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(loc.translate('delete')),
          ),
        ],
      ),
    );

    if (result == true) {
      _service.deleteCategory(categoryId);
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('category_deleted')),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
