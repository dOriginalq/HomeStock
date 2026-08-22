import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_names.dart';
import '../../../rooms/domain/entities/room.dart';
import '../../home/presentation/controllers/home_controller.dart';

class AddStorageScreen extends ConsumerStatefulWidget {
  const AddStorageScreen({this.roomId = '', super.key});

  final String roomId;

  @override
  ConsumerState<AddStorageScreen> createState() => _AddStorageScreenState();
}

class _AddStorageScreenState extends ConsumerState<AddStorageScreen> {
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController(text: '50');
  final _descController = TextEditingController();

  String _selectedType = 'Shelf';
  String _selectedRoomId = '';
  final Set<String> _selectedCategories = {'Books', 'Documents', 'Electronics'};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedRoomId = widget.roomId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a storage name')),
      );
      return;
    }

    if (_selectedRoomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a room for this storage unit')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final storageRepo = ref.read(storageRepositoryProvider);
    final capacity = int.tryParse(_capacityController.text.trim());

    final result = await storageRepo.createStorageUnit(
      homeId: 'home-001',
      roomId: _selectedRoomId,
      name: name,
      type: _selectedType,
      capacityItems: capacity,
      expectedCategories: _selectedCategories.toList(),
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : null,
    );

    setState(() => _isSaving = false);

    result.when(
      success: (storageUnit) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created ${storageUnit.name} (${storageUnit.qrId})'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pushReplacement('${RouteNames.storageDetail}/${storageUnit.id}');
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
    final rooms = homeState.rooms;

    if (_selectedRoomId.isEmpty && rooms.isNotEmpty) {
      _selectedRoomId = rooms.first.id;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Storage Unit'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Storage Characteristics',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Every storage unit receives a stable QR code for physical location registration and item lookup.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Room Selector
              DropdownButtonFormField<String>(
                value: _selectedRoomId.isNotEmpty ? _selectedRoomId : null,
                decoration: const InputDecoration(
                  labelText: 'Room *',
                  prefixIcon: Icon(Icons.meeting_room_outlined),
                ),
                items: rooms.map((r) {
                  return DropdownMenuItem(value: r.id, child: Text(r.name));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRoomId = val);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Storage Name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Storage Name *',
                  hintText: 'e.g. Shelf A, Nightstand Drawer, Bookshelf',
                  prefixIcon: Icon(Icons.label_outline_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Storage Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Storage Type *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppConstants.storageTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Capacity
              TextField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Approximate Item Capacity',
                  hintText: 'e.g. 50 items',
                  prefixIcon: Icon(Icons.format_list_numbered_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Expected Categories Chip Filter
              Text(
                'Expected Item Categories',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.itemCategories.map((cat) {
                  final isSelected = _selectedCategories.contains(cat);
                  return FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primaryContainer,
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(cat);
                        } else {
                          _selectedCategories.remove(cat);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Description
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'e.g. Wooden wall shelf above study desk',
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
                      : const Text('Create Storage Unit & Generate QR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
