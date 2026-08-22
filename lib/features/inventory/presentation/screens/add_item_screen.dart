import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../storage/domain/entities/storage_unit.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../storage/presentation/screens/storage_detail_screen.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({this.storageId, super.key});

  final String? storageId;

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  int _quantity = 1;
  String _selectedCategory = 'Books';
  String? _selectedStorageId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedStorageId = widget.storageId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an item name')),
      );
      return;
    }

    if (_selectedStorageId == null || _selectedStorageId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a storage unit')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final itemRepo = ref.read(itemRepositoryProvider);

    final result = await itemRepo.createItem(
      homeId: 'home-001',
      storageId: _selectedStorageId!,
      name: name,
      quantity: _quantity,
      category: _selectedCategory,
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : null,
    );

    setState(() => _isSaving = false);

    result.when(
      success: (item) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${item.name}" to storage unit!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      },
      failure: (failure) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: AppColors.error),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeControllerProvider);
    final storageUnits = homeState.storageUnits;

    if (_selectedStorageId == null && storageUnits.isNotEmpty) {
      _selectedStorageId = storageUnits.first.id;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Inventory Item'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manual Item Registration',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Individual items do NOT receive QR codes. They are assigned to a QR-identified storage unit.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Storage Unit Selector
              DropdownButtonFormField<String>(
                value: _selectedStorageId,
                decoration: const InputDecoration(
                  labelText: 'Storage Unit *',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                items: storageUnits.map((u) {
                  return DropdownMenuItem(
                    value: u.id,
                    child: Text('${u.name} (${u.qrId})'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStorageId = val);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Item Name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name *',
                  hintText: 'e.g. Digital SLR Camera, Passport',
                  prefixIcon: Icon(Icons.label_outline_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Quantity Stepper
              Row(
                children: [
                  Text(
                    'Quantity',
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: AppColors.primary,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_quantity',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppConstants.itemCategories.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Description
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'e.g. Canon EOS with 50mm lens',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.xl2),

              // Save CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Add Item to Storage'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
