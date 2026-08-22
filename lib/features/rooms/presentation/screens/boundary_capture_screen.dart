import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/spatial_service.dart';
import '../../domain/entities/boundary_point.dart';
import '../../domain/entities/room_boundary.dart';
import '../../../home/presentation/controllers/home_controller.dart';

/// Screen allowing the user to map a room's physical boundary by walking
/// to each corner and pressing "Mark Point" on demand (no continuous tracking).
class BoundaryCaptureScreen extends ConsumerStatefulWidget {
  const BoundaryCaptureScreen({required this.roomId, super.key});

  final String roomId;

  @override
  ConsumerState<BoundaryCaptureScreen> createState() =>
      _BoundaryCaptureScreenState();
}

class _BoundaryCaptureScreenState extends ConsumerState<BoundaryCaptureScreen> {
  final List<BoundaryPoint> _capturedPoints = [];
  final _locationService = const NativeLocationService();
  final _spatialService = const SpatialService();

  bool _isCapturing = false;
  bool _isSaving = false;
  String? _statusMessage;

  Future<void> _markCurrentCorner() async {
    setState(() {
      _isCapturing = true;
      _statusMessage = 'Acquiring GPS location...';
    });

    final nextIndex = _capturedPoints.length;
    final result = await _locationService.getCurrentLocation(
      index: nextIndex,
      pointId: 'bp-${widget.roomId}-$nextIndex',
    );

    setState(() => _isCapturing = false);

    result.when(
      success: (point) {
        setState(() {
          _capturedPoints.add(point);
          _statusMessage = 'Corner ${point.index + 1} marked (Accuracy: ${point.accuracyMetres?.toStringAsFixed(1)}m)';
        });
      },
      failure: (failure) {
        setState(() => _statusMessage = 'Error: ${failure.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: AppColors.error),
        );
      },
    );
  }

  void _undoLastPoint() {
    if (_capturedPoints.isNotEmpty) {
      setState(() {
        final removed = _capturedPoints.removeLast();
        _statusMessage = 'Removed Corner ${removed.index + 1}';
      });
    }
  }

  void _resetPoints() {
    setState(() {
      _capturedPoints.clear();
      _statusMessage = 'Boundary reset. Walk to Corner 1 and press Mark Point.';
    });
  }

  Future<void> _finishBoundary() async {
    if (_capturedPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least 3 corners are required to construct a room polygon.'),
        ),
      );
      return;
    }

    final boundary = RoomBoundary(
      roomId: widget.roomId,
      points: _capturedPoints,
      capturedAt: DateTime.now(),
      isComplete: true,
    );

    // Validate polygon mathematically
    final validation = _spatialService.validateBoundary(boundary);
    if (validation.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validation.failureOrNull?.message ?? 'Invalid polygon'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final roomRepo = ref.read(roomRepositoryProvider);
    final result = await roomRepo.saveRoomBoundary(
      homeId: 'home-001',
      roomId: widget.roomId,
      points: _capturedPoints,
    );
    setState(() => _isSaving = false);

    result.when(
      success: (room) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Boundary saved for ${room.name}!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      },
      failure: (failure) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: AppColors.error),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pointCount = _capturedPoints.length;
    final canFinish = pointCount >= 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Map Room Boundary'),
        actions: [
          if (pointCount > 0)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Reset Points',
              onPressed: _resetPoints,
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.explore_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Step ${pointCount + 1}: Walk to Corner ${pointCount + 1}',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Stand at the corner and press "Mark Point". Capture at least 3 points to form a polygon.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Status and Point Counter Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Captured Corners ($pointCount)',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (pointCount > 0)
                    TextButton.icon(
                      onPressed: _undoLastPoint,
                      icon: const Icon(Icons.undo_rounded, size: 18),
                      label: const Text('Undo Last'),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Points List or Empty Illustration
              Expanded(
                child: pointCount == 0
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.pin_drop_outlined,
                              size: 64,
                              color: AppColors.textDisabled,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No boundary points captured yet.',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Walk to the first corner of the room to begin.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _capturedPoints.length,
                        itemBuilder: (context, index) {
                          final p = _capturedPoints[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                child: Text('${index + 1}'),
                              ),
                              title: Text(
                                'Corner ${index + 1}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                'Lat: ${p.latitude.toStringAsFixed(5)}, Lng: ${p.longitude.toStringAsFixed(5)}\nAccuracy: ±${p.accuracyMetres?.toStringAsFixed(1) ?? "?"}m',
                              ),
                              trailing: const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                      ),
              ),

              if (_statusMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _statusMessage!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              // Action Buttons
              const SizedBox(height: 8),
              Row(
                children: [
                  // Mark Point CTA
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: _isCapturing ? null : _markCurrentCorner,
                      icon: _isCapturing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.add_location_alt_rounded),
                      label: Text(
                        _isCapturing ? 'Locating...' : 'Mark Corner ${pointCount + 1}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Finish Boundary CTA
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: canFinish && !_isSaving ? _finishBoundary : null,
                      icon: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.done_all_rounded),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
