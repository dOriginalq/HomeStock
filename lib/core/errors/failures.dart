/// Base class for all domain-level failures in HomeStock.
/// These are returned by repositories via [Result] rather than thrown.
sealed class HomeStockFailure {
  const HomeStockFailure({required this.message, this.code});

  /// A human-readable description of the failure (for logging/debugging).
  final String message;

  /// An optional machine-readable error code.
  final String? code;

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

// ---------------------------------------------------------------------------
// Authentication failures
// ---------------------------------------------------------------------------

final class AuthFailure extends HomeStockFailure {
  const AuthFailure({required super.message, super.code});
}

final class NotAuthenticatedFailure extends HomeStockFailure {
  const NotAuthenticatedFailure()
      : super(message: 'User is not authenticated.');
}

// ---------------------------------------------------------------------------
// Network / Firebase failures
// ---------------------------------------------------------------------------

final class NetworkFailure extends HomeStockFailure {
  const NetworkFailure({required super.message, super.code});
}

final class FirebaseFailure extends HomeStockFailure {
  const FirebaseFailure({required super.message, super.code});
}

final class PermissionFailure extends HomeStockFailure {
  const PermissionFailure({required super.message, super.code});
}

// ---------------------------------------------------------------------------
// Location failures
// ---------------------------------------------------------------------------

final class LocationPermissionDeniedFailure extends HomeStockFailure {
  const LocationPermissionDeniedFailure()
      : super(message: 'Location permission denied.');
}

final class LocationServiceDisabledFailure extends HomeStockFailure {
  const LocationServiceDisabledFailure()
      : super(message: 'Location service is disabled.');
}

final class LocationUnavailableFailure extends HomeStockFailure {
  const LocationUnavailableFailure({required super.message});
}

final class LocationAccuracyFailure extends HomeStockFailure {
  const LocationAccuracyFailure({required double accuracyMetres})
      : super(
          message:
              'GPS accuracy too low: ${accuracyMetres}m. Move to an open area.',
        );
}

// ---------------------------------------------------------------------------
// Spatial / boundary failures
// ---------------------------------------------------------------------------

final class InsufficientBoundaryPointsFailure extends HomeStockFailure {
  const InsufficientBoundaryPointsFailure({required int count, required int min})
      : super(
          message: 'Need at least $min boundary points; only $count captured.',
        );
}

final class InvalidPolygonFailure extends HomeStockFailure {
  const InvalidPolygonFailure({required super.message});
}

final class StorageOutsideRoomFailure extends HomeStockFailure {
  const StorageOutsideRoomFailure()
      : super(
          message:
              'Storage position is outside the room boundary. '
              'Make sure you are standing next to the storage unit and try again.',
        );
}

// ---------------------------------------------------------------------------
// QR failures
// ---------------------------------------------------------------------------

final class InvalidQrPayloadFailure extends HomeStockFailure {
  const InvalidQrPayloadFailure({required super.message});
}

final class QrScanFailure extends HomeStockFailure {
  const QrScanFailure({required super.message});
}

final class StorageNotFoundFailure extends HomeStockFailure {
  const StorageNotFoundFailure({required String storageId})
      : super(message: 'Storage unit not found: $storageId');
}

// ---------------------------------------------------------------------------
// Inventory / item failures
// ---------------------------------------------------------------------------

final class ItemNotFoundFailure extends HomeStockFailure {
  const ItemNotFoundFailure({required String itemId})
      : super(message: 'Item not found: $itemId');
}

final class InvalidItemDataFailure extends HomeStockFailure {
  const InvalidItemDataFailure({required super.message});
}

// ---------------------------------------------------------------------------
// Movement failures
// ---------------------------------------------------------------------------

final class MovementTransactionFailure extends HomeStockFailure {
  const MovementTransactionFailure({required super.message});
}

final class DestinationStorageNotFoundFailure extends HomeStockFailure {
  const DestinationStorageNotFoundFailure({required String storageId})
      : super(message: 'Destination storage not found: $storageId');
}

// ---------------------------------------------------------------------------
// Generic failures
// ---------------------------------------------------------------------------

final class UnexpectedFailure extends HomeStockFailure {
  const UnexpectedFailure({required super.message, super.code});
}
