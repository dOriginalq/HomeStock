import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../movement/data/repositories/mock_movement_repository.dart';
import '../../../movement/domain/entities/movement_record.dart';
import '../../../movement/domain/repositories/movement_repository.dart';
import '../../../rooms/domain/entities/room.dart';
import '../../../storage/domain/entities/storage_unit.dart';
import '../../domain/entities/item.dart';
import '../../home/presentation/controllers/home_controller.dart';
import '../../storage/presentation/screens/storage_detail_screen.dart';

final movementRepositoryProvider = Provider<MovementRepository>((ref) {
  return MockMovementRepository();
});

class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({required this.itemId, super.key});

  final String itemId;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  Item? _item;
  StorageUnit? _currentStorage;
  Room? _currentRoom;
  List<MovementRecord> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final itemRepo = ref.read(itemRepositoryProvider);
    final storageRepo = ref.read(storageRepositoryProvider);
    final roomRepo = ref.read(roomRepositoryProvider);
    final moveRepo = ref.read(movementRepositoryProvider);

    final itemRes = await itemRepo.getItem(
      homeId: 'home-001',
      itemId: widget.itemId,
    );

    itemRes.when(
      success: (item) async {
        setState(() => _item = item);

        final sRes = await storageRepo.getStorageUnit(
          homeId: 'home-001',
          storageId: item.currentStorageId,
        );
        sRes.when(
          success: (storage) async {
            setState(() => _currentStorage = storage);
            final rRes = await roomRepo.getRoom(
              homeId: 'home-001',
              roomId: storage.roomId,
            );
            rRes.when(
              success: (room) => setState(() => _currentRoom = room),
              failure: (_) {},
            );
          },
          failure: (_) {},
        );

        moveRepo
            .watchItemHistory(homeId: 'home-001', itemId: item.id)
            .listen((history) {
          if (mounted) setState(() => _history = history);
        });
      },
      failure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );

    setState(() => _isLoading = false);
  }

  void _showMoveDialog(BuildContext context, Item item) {
    final homeState = ref.read(homeControllerProvider);
    final availableStorage = homeState.storageUnits
        .where((s) => s.id != item.currentStorageId)
        .toList();

    if (availableStorage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other storage units available to move this item to.')),
      );
      return;
    }

    String selectedDest = availableStorage.first.id;
    final noteController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Move Item',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Transfer "${item.name}" to another storage unit.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedDest,
                decoration: const InputDecoration(
                  labelText: 'Destination Storage Unit',
                  prefixIcon: Icon(Icons.drive_file_move_outline),
                ),
                items: availableStorage.map((s) {
                  return DropdownMenuItem(
                    value: s.id,
                    child: Text('${s.name} (${s.qrId})'),
                  );
                }).toList>,
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedDest = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Movement Note (Optional)',
                  hintText: 'e.g. Moved to study desk for remote work',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final moveRepo = ref.read(movementRepositoryProvider);
                    final result = await moveRepo.moveItem(
                      homeId: 'home-001',
                      itemId: item.id,
                      fromStorageId: item.currentStorageId,
                      toStorageId: selectedDest,
                      note: noteController.text.trim().isNotEmpty
                          ? noteController.text.trim()
                          : null,
                    );
                    result.when(
                      success: (updated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Item successfully moved!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        _loadData();
                      },
                      failure: (failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(failure.message), backgroundColor: AppColors.error),
                        );
                      },
                    );
                  },
                  child: const Text('Confirm Move'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final item = _item;
    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Item Details')),
        body: const Center(child: Text('Item not found.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(item.name),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Location Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Current Location',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildBreadcrumbChip(
                          icon: Icons.meeting_room_outlined,
                          label: _currentRoom?.name ?? 'Room',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                        ),
                        _buildBreadcrumbChip(
                          icon: Icons.inventory_2_outlined,
                          label: _currentStorage?.name ?? 'Storage',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Item Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${item.category ?? "General"}  •  Quantity: ${item.quantity}',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      if (item.description != null && item.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          item.description!,
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Move Item Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showMoveDialog(context, item),
                  icon: const Icon(Icons.drive_file_move_outlined),
                  label: const Text('Move to Another Storage Unit'),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Movement History Audit Trail
              Text(
                'Movement History',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              if (_history.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('No location transfers recorded for this item yet.'),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final rec = _history[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.history_rounded, color: AppColors.primary),
                        title: Text('Moved to ${rec.toStorageId}'),
                        subtitle: Text(
                          '${rec.note ?? "Transfer"}\n${rec.movedAt.toLocal().toString().split('.')[0]}',
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumbChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
