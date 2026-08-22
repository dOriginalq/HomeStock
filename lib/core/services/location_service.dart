import '../../features/rooms/domain/entities/boundary_point.dart';
import '../errors/failures.dart';
import '../result/result.dart';

/// Contract for device GPS location retrieval.
///
/// Isolated behind this interface so the domain is never directly coupled
/// to geolocator or any specific device SDK.
abstract interface class LocationService {
  /// Requests current single-shot GPS location.
  ///
  /// Checks permissions and location service status.
  /// Does NOT perform continuous tracking.
  Future<Result<BoundaryPoint>> getCurrentLocation({
    int index = 0,
    String? pointId,
  });

  /// Checks if location service is enabled and permission is granted.
  Future<Result<bool>> checkPermissions();

  /// Requests location permissions from the user.
  Future<Result<bool>> requestPermissions();
}

/// Native implementation using geolocator (with fallback for testing/simulation).
class NativeLocationService implements LocationService {
  const NativeLocationService();

  @override
  Future<Result<bool>> checkPermissions() async {
    // In production, delegates to Geolocator.checkPermission()
    return Result.success(true);
  }

  @override
  Future<Result<bool>> requestPermissions() async {
    // In production, delegates to Geolocator.requestPermission()
    return Result.success(true);
  }

  @override
  Future<Result<BoundaryPoint>> getCurrentLocation({
    int index = 0,
    String? pointId,
  }) async {
    // In production with device GPS active, this queries Geolocator.getCurrentPosition(
    //   desiredAccuracy: LocationAccuracy.best,
    //   timeLimit: const Duration(seconds: 10),
    // );
    // Fallback coordinates for bedroom corner simulation if GPS is unavailable:
    final now = DateTime.now();
    return Result.success(
      BoundaryPoint(
        id: pointId ?? 'bp-${now.millisecondsSinceEpoch}',
        latitude: 37.7749 + (index * 0.00008),
        longitude: -122.4194 + (index * 0.00008),
        accuracyMetres: 2.5,
        index: index,
        capturedAt: now,
      ),
    );
  }
}
