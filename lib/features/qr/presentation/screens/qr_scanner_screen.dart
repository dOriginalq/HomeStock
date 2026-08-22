import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/spatial_service.dart';
import '../../../storage/domain/entities/storage_position.dart';
import '../../domain/services/qr_identity.dart';
import '../../home/presentation/controllers/home_controller.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final _locationService = const NativeLocationService();
  final _spatialService = const SpatialService();

  bool _isProcessing = false;
  String _statusText = 'Align storage QR code within frame';

  Future<void> _handleQrPayload(String rawPayload) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _statusText = 'Validating QR code...';
    });

    // 1. Parse QR payload
    final parseResult = QrIdentity.fromQrPayload(rawPayload);
    if (parseResult.isFailure) {
      setState(() {
        _isProcessing = false;
        _statusText = parseResult.failureOrNull?.message ?? 'Invalid QR payload';
      });
      return;
    }

    final qrId = parseResult.valueOrNull!.id;
    setState(() => _statusText = 'Resolving storage unit $qrId...');

    // 2. Resolve storage unit in database
    final storageRepo = ref.read(storageRepositoryProvider);
    final storageResult = await storageRepo.getStorageUnitByQrId(
      homeId: 'home-001',
      qrId: qrId,
    );

    if (storageResult.isFailure) {
      setState(() {
        _isProcessing = false;
        _statusText = 'Storage unit ($qrId) not found in system.';
      });
      return;
    }

    final storageUnit = storageResult.valueOrNull!;

    // 3. Capture GPS position at scan time
    setState(() => _statusText = 'Capturing current physical position...');
    final locResult = await _locationService.getCurrentLocation();
    if (locResult.isFailure) {
      setState(() {
        _isProcessing = false;
        _statusText = locResult.failureOrNull?.message ?? 'GPS unavailable';
      });
      return;
    }

    final point = locResult.valueOrNull!;

    // 4. Point-In-Polygon containment check
    final roomRepo = ref.read(roomRepositoryProvider);
    final roomResult = await roomRepo.getRoom(
      homeId: 'home-001',
      roomId: storageUnit.roomId,
    );

    if (roomResult.isSuccess && roomResult.valueOrNull!.boundary != null) {
      final room = roomResult.valueOrNull!;
      final pipResult = _spatialService.isPointInBoundary(
        latitude: point.latitude,
        longitude: point.longitude,
        boundary: room.boundary!,
      );

      if (pipResult.isFailure) {
        // Point is outside room polygon warning
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Notice: Position registered slightly outside room polygon boundary.',
              ),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    }

    // 5. Register physical position
    setState(() => _statusText = 'Registering spatial position...');
    final pos = StoragePosition(
      storageId: storageUnit.id,
      latitude: point.latitude,
      longitude: point.longitude,
      accuracyMetres: point.accuracyMetres,
      registeredAt: DateTime.now(),
    );

    await storageRepo.registerStoragePosition(
      homeId: 'home-001',
      storageId: storageUnit.id,
      position: pos,
    );

    setState(() => _isProcessing = false);

    // 6. Navigate to storage details
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Position registered for ${storageUnit.name}!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pushReplacement('${RouteNames.storageDetail}/${storageUnit.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Scan Storage QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Viewfinder simulation
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary, width: 3),
            ),
            child: const Center(
              child: Icon(
                Icons.qr_code_2_rounded,
                size: 80,
                color: Color(0x60FFFFFF),
              ),
            ),
          ),

          // Status & Helper Message
          Positioned(
            bottom: 120,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xCC1C1B1F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusText,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Prototype Scan Trigger (Simulates scanning Shelf A / Drawer 1)
                Wrap(
                  spacing: 12,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                      onPressed: _isProcessing
                          ? null
                          : () => _handleQrPayload('{"id":"HS-ST-00042","v":"1"}'),
                      child: const Text('Simulate Scan: Shelf A'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                      onPressed: _isProcessing
                          ? null
                          : () => _handleQrPayload('{"id":"HS-ST-00043","v":"1"}'),
                      child: const Text('Scan: Drawer 1'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
