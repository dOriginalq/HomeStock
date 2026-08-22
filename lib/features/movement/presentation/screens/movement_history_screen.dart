import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/entities/movement_record.dart';
import '../../inventory/presentation/screens/item_detail_screen.dart';

class MovementHistoryScreen extends ConsumerWidget {
  const MovementHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moveRepo = ref.watch(movementRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Movement History'),
      ),
      body: SafeArea(
        child: StreamBuilder<List<MovementRecord>>(
          stream: moveRepo.watchMovementHistory('home-001'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final records = snapshot.data ?? [];
            if (records.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.history_toggle_off_rounded,
                      size: 64,
                      color: AppColors.textDisabled,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No item movements recorded yet',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'When items are transferred between storage units, the audit trail appears here.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final rec = records[index];
                return _MovementRecordCard(record: rec);
              },
            );
          },
        ),
      ),
    );
  }
}

class _MovementRecordCard extends StatelessWidget {
  const _MovementRecordCard({required this.record});

  final MovementRecord record;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item Transfer: ${record.itemId}',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        record.movedAt.toLocal().toString().split('.')[0],
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Location Transition Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      record.fromStorageId,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      record.toStorageId,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (record.note != null && record.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Note: ${record.note}',
                style: AppTypography.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
