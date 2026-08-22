import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../shared/widgets/hs_icon.dart';
import '../widgets/quick_actions_bar.dart';
import '../widgets/room_map_widget.dart';
import '../widgets/room_selector.dart';
import '../widgets/storage_unit_list.dart';

/// The main HomeStock dashboard screen.
///
/// Layout (top to bottom):
///   1. AppBar — HomeStock branding + QR scan shortcut
///   2. Room selector + summary + Add Room
///   3. Spatial room map with storage markers
///   4. Quick actions (Scan QR, Add Storage, Add Item, More)
///   5. Storage unit list
///   6. (Bottom navigation handled by [MainShell])
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: const SafeArea(
          child: _HomeBody(),
        ),
      );

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: AppSpacing.lg,
        title: Row(
          children: [
            // HomeStock house icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.home_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'HomeStock',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          // QR scan shortcut in header
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: GestureDetector(
              onTap: () => context.push(RouteNames.qrScanner),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      );
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) => CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Room selector card
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: RoomSelectorWidget(),
            ),
          ),

          // Room map
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: RoomMapWidget(),
            ),
          ),

          // Quick actions
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: QuickActionsBar(),
            ),
          ),

          // Storage units header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl2,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                'Storage Units',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // Storage unit list
          const StorageUnitListSliver(),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xl5),
          ),
        ],
      );
}
