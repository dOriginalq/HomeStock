import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/constants/route_names.dart';

/// Main application shell providing the bottom navigation bar matching the
/// visual reference UI.
class MainShell extends StatelessWidget {
  const MainShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _calculateSelectedIndex(location);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  onTap: () => context.go(RouteNames.home),
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.search_rounded,
                  label: 'Search',
                  isSelected: currentIndex == 1,
                  onTap: () => context.go(RouteNames.search),
                ),
                _buildCenterAddButton(context),
                _buildNavItem(
                  context: context,
                  icon: Icons.history_rounded,
                  label: 'History',
                  isSelected: currentIndex == 3,
                  onTap: () => context.go(RouteNames.history),
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  isSelected: currentIndex == 4,
                  onTap: () => _showProfileDialog(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            // Active underline indicator
            Container(
              width: 16,
              height: 2,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddOptionsSheet(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x302E7D32),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  void _showAddOptionsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Create',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.meeting_room_outlined, color: AppColors.primary),
                ),
                title: const Text('Add Room'),
                subtitle: const Text('Create a new room with GPS boundary'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteNames.addRoom);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                ),
                title: const Text('Add Storage Unit'),
                subtitle: const Text('Register a shelf, drawer, or cabinet'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteNames.addStorage);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.category_outlined, color: AppColors.primary),
                ),
                title: const Text('Add Inventory Item'),
                subtitle: const Text('Register a new item inside a storage unit'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteNames.addItem);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.person_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('User Profile'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Signed in as:', style: TextStyle(color: AppColors.textTertiary)),
            SizedBox(height: 4),
            Text('Alex Rivers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('alex@homestock.io', style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 12),
            Text('Current Residence:', style: TextStyle(color: AppColors.textTertiary)),
            Text('Oakwood Residence (home-001)', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith(RouteNames.search)) return 1;
    if (location.startsWith(RouteNames.history)) return 3;
    if (location.startsWith(RouteNames.profile)) return 4;
    return 0;
  }
}
