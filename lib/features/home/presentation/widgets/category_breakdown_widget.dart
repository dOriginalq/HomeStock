import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../inventory/data/repositories/mock_item_repository.dart';
import '../../../inventory/domain/entities/item.dart';
import '../../../inventory/presentation/screens/item_detail_screen.dart';
import '../../home/presentation/controllers/home_controller.dart';

/// Renders a category summary of items stored in the currently selected room.
class CategoryBreakdownWidget extends ConsumerWidget {
  const CategoryBreakdownWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final storageUnits = homeState.storageUnits;
    final itemRepo = ref.watch(itemRepositoryProvider);

    return StreamBuilder<List<Item>>(
      stream: itemRepo.watchAllItems('home-001'),
      builder: (context, snapshot) {
        final allItems = snapshot.data ?? [];
        final roomStorageIds = storageUnits.map((s) => s.id).toSet();
        final roomItems =
            allItems.where((i) => roomStorageIds.contains(i.currentStorageId)).toList();

        if (roomItems.isEmpty) return const SizedBox.shrink();

        final categoryCounts = <String, int>{};
        for (final item in roomItems) {
          final cat = item.category ?? 'Other';
          categoryCounts[cat] = (categoryCounts[cat] ?? 0) + item.quantity;
        }

        final sortedCategories = categoryCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Item Categories',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${sortedCategories.length} Categories',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sortedCategories.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6FAF6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2EFE3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.key,
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${entry.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
