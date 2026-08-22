import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../rooms/domain/entities/room.dart';
import '../controllers/home_controller.dart';

/// Top room selector card matching the visual reference:
///
/// ```text
/// Bedroom ⌵                      [+] Add Room
/// 3 Storage Units • 12 Items
/// ```
class RoomSelectorWidget extends ConsumerWidget {
  const RoomSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final selectedRoom = state.selectedRoom;
    final rooms = state.rooms;

    if (state.isLoading) {
      return const SizedBox(
        height: 60,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final roomName = selectedRoom?.name ?? 'Select Room';
    final storageCount = state.storageUnitCount;
    final itemCount = state.totalItemCount;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Room dropdown trigger + counts
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _showRoomPicker(context, ref, rooms, selectedRoom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        roomName,
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$storageCount Storage Units  •  $itemCount Items',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right: "+ Add Room" green button
          InkWell(
            onTap: () => context.push(RouteNames.addRoom),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.crop_free_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Add Room',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRoomPicker(
    BuildContext context,
    WidgetRef ref,
    List<Room> rooms,
    Room? currentRoom,
  ) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Room',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...rooms.map(
                (room) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: room.id == currentRoom?.id
                          ? AppColors.primaryLighter
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.meeting_room_outlined,
                      color: room.id == currentRoom?.id
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  title: Text(
                    room.name,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: room.id == currentRoom?.id
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: room.id == currentRoom?.id
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${room.storageUnitCount} units  •  ${room.totalItemCount} items',
                    style: AppTypography.bodySmall,
                  ),
                  trailing: room.id == currentRoom?.id
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    ref.read(homeControllerProvider.notifier).selectRoom(room);
                    Navigator.pop(ctx);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.push(RouteNames.addRoom);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Room'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
