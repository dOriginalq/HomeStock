import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Reusable icon container with consistent padding and theme colors.
class HSIcon extends StatelessWidget {
  const HSIcon({
    required this.icon,
    super.key,
    this.color = AppColors.primary,
    this.backgroundColor = AppColors.primaryLighter,
    this.size = 20,
    this.padding = 8,
    this.borderRadius = 8,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;
  final double padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }
}
