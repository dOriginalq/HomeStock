import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../storage/domain/entities/storage_unit.dart';
import '../controllers/home_controller.dart';

/// Sliver rendering the list of storage units for the selected room,
/// matching the visual reference design.
class StorageUnitListSliver extends ConsumerWidget {
  const StorageUnitListSliver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final storageUnits = state.storageUnits;

    if (storageUnits.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAF9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8EFE8)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 44,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No Storage Units in this Room',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap "+ Add Storage" to register a shelf, cupboard, or drawer.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final unit = storageUnits[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StorageUnitCard(unit: unit),
            );
          },
          childCount: storageUnits.length,
        ),
      ),
    );
  }
}

class _StorageUnitCard extends StatelessWidget {
  const _StorageUnitCard({required this.unit});

  final StorageUnit unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F4F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push('${RouteNames.storageDetail}/${unit.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                // Circular icon with light green background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF7EC),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD3EDD5),
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _getIconForType(unit.type),
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Name and item count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.name,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${unit.itemCount} items',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // More options button (horizontal 3 dots inside subtle rounded box)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),

                // Chevron right
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB0B8B0),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'shelf':
        return Icons.shelves;
      case 'drawer':
        return Icons.inbox_outlined;
      case 'wardrobe':
        return Icons.door_sliding_outlined;
      case 'cupboard':
      case 'cabinet':
        return Icons.kitchen_outlined;
      case 'box':
      case 'toolbox':
        return Icons.inventory_2_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}
