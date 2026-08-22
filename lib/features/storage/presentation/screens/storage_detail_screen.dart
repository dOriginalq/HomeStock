import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../inventory/data/repositories/mock_item_repository.dart';
import '../../../inventory/domain/entities/item.dart';
import '../../../inventory/domain/repositories/item_repository.dart';
import '../../domain/entities/storage_unit.dart';
import '../../../home/presentation/controllers/home_controller.dart';

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return MockItemRepository();
});

class StorageDetailScreen extends ConsumerStatefulWidget {
  const StorageDetailScreen({required this.storageId, super.key});

  final String storageId;

  @override
  ConsumerState<StorageDetailScreen> createState() =>
      _StorageDetailScreenState();
}

class _StorageDetailScreenState extends ConsumerState<StorageDetailScreen> {
  StorageUnit? _storageUnit;
  List<Item> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final storageRepo = ref.read(storageRepositoryProvider);
    final itemRepo = ref.read(itemRepositoryProvider);

    final sResult = await storageRepo.getStorageUnit(
      homeId: 'home-001',
      storageId: widget.storageId,
    );

    sResult.when(
      success: (unit) {
        setState(() => _storageUnit = unit);
        itemRepo
            .watchItemsForStorage(homeId: 'home-001', storageId: unit.id)
            .listen((items) {
          if (mounted) setState(() => _items = items);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final unit = _storageUnit;
    if (unit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Storage Unit')),
        body: const Center(child: Text('Storage unit not found.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(unit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2_rounded),
            tooltip: 'View QR Code',
            onPressed: () => _showQrModal(context, unit),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unit.name,
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Stable QR ID: ${unit.qrId}',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'Type: ${unit.type}  •  Capacity: ${unit.capacityItems ?? 50} items',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Physical Position & QR Registration Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: unit.isPositionRegistered
                      ? const Color(0xFFF7FAF7)
                      : const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: unit.isPositionRegistered
                        ? const Color(0xFFE2EFE3)
                        : const Color(0xFFFFECC4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      unit.isPositionRegistered
                          ? Icons.location_on_rounded
                          : Icons.location_off_outlined,
                      color: unit.isPositionRegistered
                          ? AppColors.primary
                          : const Color(0xFFD9822B),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unit.isPositionRegistered
                                ? 'Physical Position Registered'
                                : 'Position Not Registered',
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: unit.isPositionRegistered
                                  ? AppColors.textPrimary
                                  : const Color(0xFF945200),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            unit.isPositionRegistered
                                ? 'Lat: ${unit.position?.latitude.toStringAsFixed(5)}, Lng: ${unit.position?.longitude.toStringAsFixed(5)}'
                                : 'Scan this storage unit QR while standing next to it to map its room position.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!unit.isPositionRegistered)
                      TextButton(
                        onPressed: () => context.push(RouteNames.qrScanner),
                        child: const Text('Scan QR'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Expected Categories
              if (unit.expectedCategories.isNotEmpty) ...[
                Text(
                  'Expected Categories',
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: unit.expectedCategories
                      .map((cat) => Chip(label: Text(cat)))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Items Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stored Items (${_items.length})',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push(
                      RouteNames.addItem,
                      extra: unit.id,
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Item'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Items List
              if (_items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('No items in this storage unit yet.'),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Card(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLighter,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.category_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Qty: ${item.quantity}  •  ${item.category ?? "General"}',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('${RouteNames.itemDetail}/${item.id}'),
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

  void _showQrModal(BuildContext context, StorageUnit unit) {
    final qrPayload = '{"id":"${unit.qrId}","v":"1"}';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                unit.name,
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                'QR Identifier: ${unit.qrId}',
                style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              QrImageView(
                data: qrPayload,
                version: QrVersions.auto,
                size: 180,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                'Attach this QR code to the physical ${unit.type.toLowerCase()}. Scanning it registers position and reveals inventory.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR Code exported for printing!')),
                  );
                },
                icon: const Icon(Icons.print_rounded),
                label: const Text('Print / Share QR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
