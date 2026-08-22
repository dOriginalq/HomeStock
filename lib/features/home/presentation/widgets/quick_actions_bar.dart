import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../controllers/home_controller.dart';

/// Quick actions bar matching the reference design:
/// [ Scan QR ]   [ Add Storage ]   [ Add Item ]   [ More ]
class QuickActionsBar extends ConsumerWidget {
  const QuickActionsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final selectedRoom = state.selectedRoom;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            context: context,
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scan QR',
            onTap: () => context.push(RouteNames.qrScanner),
          ),
          _buildActionButton(
            context: context,
            icon: Icons.inventory_2_outlined,
            label: 'Add Storage',
            onTap: () => context.push(
              RouteNames.addStorage,
              extra: selectedRoom?.id,
            ),
          ),
          _buildActionButton(
            context: context,
            icon: Icons.category_outlined,
            label: 'Add Item',
            onTap: () => context.push(
              RouteNames.addItem,
              extra: state.storageUnits.isNotEmpty
                  ? state.storageUnits.first.id
                  : null,
            ),
          ),
          _buildActionButton(
            context: context,
            icon: Icons.more_horiz_rounded,
            label: 'More',
            onTap: () => _showMoreActionsSheet(context, selectedRoom?.id),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF7FBF7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2EFE3),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreActionsSheet(BuildContext context, String? roomId) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Room Actions',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: const Icon(Icons.crop_free_rounded, color: AppColors.primary),
                title: const Text('Capture / Edit Room Boundary'),
                subtitle: const Text('Walk the room corners with GPS'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(
                    '${RouteNames.addRoom}/boundary',
                    extra: roomId,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.history_rounded, color: AppColors.primary),
                title: const Text('View Movement History'),
                subtitle: const Text('See recent item location transfers'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteNames.history);
                },
              ),
              ListTile(
                leading: const Icon(Icons.search_rounded, color: AppColors.primary),
                title: const Text('Search All Inventory'),
                subtitle: const Text('Find any item across your home'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteNames.search);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
