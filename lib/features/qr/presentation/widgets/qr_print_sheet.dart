import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../storage/domain/entities/storage_unit.dart';

/// Printable physical label card widget for a storage unit.
class QrPrintCard extends StatelessWidget {
  const QrPrintCard({
    required this.storageUnit,
    this.roomName,
    super.key,
  });

  final StorageUnit storageUnit;
  final String? roomName;

  @override
  Widget build(BuildContext context) {
    final qrPayload = '{"id":"${storageUnit.qrId}","v":"1"}';

    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HomeStock Header Branding
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home_outlined, color: Colors.black, size: 20),
              const SizedBox(width: 6),
              Text(
                'HomeStock Storage Label',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.black, thickness: 1.5, height: 20),

          // Storage Name
          Text(
            storageUnit.name.toUpperCase(),
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),

          // Room & Type info
          Text(
            '${roomName ?? "Home"}  •  ${storageUnit.type}',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // High Contrast QR Code
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: QrImageView(
              data: qrPayload,
              version: QrVersions.auto,
              size: 160,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Stable QR ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              storageUnit.qrId,
              style: AppTypography.titleSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Text(
            'Attach to physical storage unit. Do not cover QR code.',
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.black54,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
