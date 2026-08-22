import 'package:equatable/equatable.dart';

/// Approximate physical location of a storage unit.
///
/// Captured by scanning the storage unit's QR code while standing next to it.
/// The coordinate is GPS-derived and represents an approximate position only.
final class StoragePosition extends Equatable {
  const StoragePosition({
    required this.storageId,
    required this.latitude,
    required this.longitude,
    required this.registeredAt,
    this.accuracyMetres,
  });

  final String storageId;
  final double latitude;
  final double longitude;

  /// GPS accuracy in metres at time of registration.
  final double? accuracyMetres;

  final DateTime registeredAt;

  StoragePosition copyWith({
    String? storageId,
    double? latitude,
    double? longitude,
    double? accuracyMetres,
    DateTime? registeredAt,
  }) =>
      StoragePosition(
        storageId: storageId ?? this.storageId,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        accuracyMetres: accuracyMetres ?? this.accuracyMetres,
        registeredAt: registeredAt ?? this.registeredAt,
      );

  @override
  List<Object?> get props =>
      [storageId, latitude, longitude, accuracyMetres, registeredAt];

  @override
  String toString() =>
      'StoragePosition(storageId: $storageId, lat: $latitude, '
      'lng: $longitude, accuracy: ${accuracyMetres?.toStringAsFixed(1)}m)';
}
