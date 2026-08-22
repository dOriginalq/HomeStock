import 'package:flutter/material.dart';

/// HomeStock design system — color palette.
/// All colors are accessed through this class; never hardcode hex values in widgets.
abstract final class AppColors {
  // --- Primary Green ---
  static const Color primary = Color(0xFF2E7D32);         // Green 800
  static const Color primaryLight = Color(0xFF4CAF50);    // Green 500
  static const Color primaryLighter = Color(0xFFE8F5E9);  // Green 50
  static const Color primaryContainer = Color(0xFFC8E6C9); // Green 100

  // --- Secondary / Accent ---
  static const Color secondary = Color(0xFF388E3C);       // Green 700
  static const Color accent = Color(0xFF66BB6A);          // Green 400

  // --- Surface & Background ---
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // --- Map Visualization ---
  static const Color roomFill = Color(0xFFE8F5E9);        // Light green fill
  static const Color roomBorder = Color(0xFF2E7D32);      // Green border
  static const Color roomBorderPoint = Color(0xFF2E7D32); // Boundary point dots
  static const Color storageMarkerBg = Color(0xFF2E7D32); // Marker icon bg
  static const Color storageMarkerText = Color(0xFF1B5E20); // Marker label text
  static const Color storageMarkerCard = Color(0xFFFFFFFF); // Marker label card

  // --- Text ---
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color textTertiary = Color(0xFF79747E);
  static const Color textDisabled = Color(0xFFCAC4D0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // --- Borders ---
  static const Color border = Color(0xFFE7E0EC);
  static const Color borderLight = Color(0xFFF3EDF7);
  static const Color divider = Color(0xFFECE6F0);

  // --- Status ---
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF0277BD);

  // --- Icons ---
  static const Color iconPrimary = Color(0xFF2E7D32);
  static const Color iconSecondary = Color(0xFF49454F);
  static const Color iconOnPrimary = Color(0xFFFFFFFF);

  // --- Bottom Nav ---
  static const Color navSelected = Color(0xFF2E7D32);
  static const Color navUnselected = Color(0xFF79747E);
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navIndicator = Color(0xFFE8F5E9);

  // --- Shadows ---
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
}
