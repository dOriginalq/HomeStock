import 'package:equatable/equatable.dart';

import 'boundary_point.dart';

/// Represents the geographical boundary of a room as an ordered polygon.
///
/// The polygon is constructed from [BoundaryPoint] instances captured by
/// the user walking to each corner and pressing "Mark Point".
///
/// Invariants:
/// - [points] must be ordered consistently (clockwise or counter-clockwise).
/// - [points].length >= 3 to form a valid polygon.
final class RoomBoundary extends Equatable {
  const RoomBoundary({
    required this.roomId,
    required this.points,
    required this.capturedAt,
    this.isComplete = false,
  });

  /// The room this boundary belongs to.
  final String roomId;

  /// Ordered list of GPS points forming the polygon vertices.
  final List<BoundaryPoint> points;

  /// Whether the boundary capture process has been completed by the user.
  final bool isComplete;

  /// When the final boundary was captured.
  final DateTime capturedAt;

  /// Returns true if this boundary has enough points to form a polygon.
  bool get isValid => points.length >= 3;

  /// Returns the number of captured points.
  int get pointCount => points.length;

  RoomBoundary copyWith({
    String? roomId,
    List<BoundaryPoint>? points,
    bool? isComplete,
    DateTime? capturedAt,
  }) =>
      RoomBoundary(
        roomId: roomId ?? this.roomId,
        points: points ?? this.points,
        isComplete: isComplete ?? this.isComplete,
        capturedAt: capturedAt ?? this.capturedAt,
      );

  @override
  List<Object?> get props => [roomId, points, isComplete, capturedAt];

  @override
  String toString() =>
      'RoomBoundary(roomId: $roomId, points: ${points.length}, '
      'complete: $isComplete)';
}
