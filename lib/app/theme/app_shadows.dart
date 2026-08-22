import 'package:flutter/material.dart';

import 'app_colors.dart';

/// HomeStock design system — box shadow presets.
abstract final class AppShadows {
  /// Very subtle shadow — used on cards, list items.
  static const List<BoxShadow> small = [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Standard card shadow.
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Elevated shadow — modals, bottom sheets, popovers.
  static const List<BoxShadow> large = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Storage marker shadow on the room map.
  static const List<BoxShadow> marker = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
  ];

  /// Bottom navigation bar shadow.
  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 12,
      offset: Offset(0, -2),
    ),
  ];
}
