import 'package:equatable/equatable.dart';

/// A GPS coordinate used for room boundaries and storage positions.
///
/// Uses WGS84 decimal degrees (same as standard GPS output).
/// Accuracy is optional and expressed in metres.
final class BoundaryPoint extends Equatable {
  const BoundaryPoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    this.accuracyMetres,
    this.index = 0,
  });

  /// Firestore document ID.
  final String id;

  /// WGS84 latitude in decimal degrees.
  final double latitude;

  /// WGS84 longitude in decimal degrees.
  final double longitude;

  /// Optional GPS accuracy in metres at time of capture.
  final double? accuracyMetres;

  /// Sequential index of this point in the boundary polygon.
  final int index;

  /// When this point was captured.
  final DateTime capturedAt;

  BoundaryPoint copyWith({
    String? id,
    double? latitude,
    double? longitude,
    double? accuracyMetres,
    int? index,
    DateTime? capturedAt,
  }) =>
      BoundaryPoint(
        id: id ?? this.id,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        accuracyMetres: accuracyMetres ?? this.accuracyMetres,
        index: index ?? this.index,
        capturedAt: capturedAt ?? this.capturedAt,
      );

  @override
  List<Object?> get props => [id, latitude, longitude, index, capturedAt];

  @override
  String toString() =>
      'BoundaryPoint(id: $id, lat: $latitude, lng: $longitude, '
      'accuracy: ${accuracyMetres?.toStringAsFixed(1)}m, index: $index)';
}
