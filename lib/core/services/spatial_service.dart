import 'dart:math' as math;

import '../../features/rooms/domain/entities/boundary_point.dart';
import '../../features/rooms/domain/entities/room_boundary.dart';
import '../errors/failures.dart';
import '../result/result.dart';

/// Pure-Dart spatial service for HomeStock.
///
/// Responsibilities:
/// - Construct and validate room boundary polygons.
/// - Perform point-in-polygon tests (ray-casting algorithm).
/// - Calculate distances between GPS coordinates.
///
/// This class has zero Flutter or Firebase dependencies.
/// Every method is independently unit-testable.
///
/// # Algorithm: Ray-casting (even-odd rule)
/// For a point P, cast a horizontal ray to the right.
/// Count polygon edge crossings. Odd count = inside; even count = outside.
/// Reference: W. Randolph Franklin, "PNPOLY" (1970).
final class SpatialService {
  const SpatialService();

  // ---------------------------------------------------------------------------
  // Polygon validation
  // ---------------------------------------------------------------------------

  /// Validates that [boundary] can form a usable polygon.
  ///
  /// Returns [Result.success] with the validated boundary,
  /// or [Result.failure] with a descriptive failure.
  Result<RoomBoundary> validateBoundary(RoomBoundary boundary) {
    const minPoints = 3;
    if (boundary.points.length < minPoints) {
      return Result.failure(
        InsufficientBoundaryPointsFailure(
          count: boundary.points.length,
          min: minPoints,
        ),
      );
    }

    // Check for degenerate polygons (all points identical or collinear).
    if (_isDegenerate(boundary.points)) {
      return Result.failure(
        const InvalidPolygonFailure(
          message:
              'Room boundary is degenerate (all points are the same or collinear). '
              'Capture points from different corners of the room.',
        ),
      );
    }

    return Result.success(boundary);
  }

  /// Returns true if all [points] are so close together that they cannot
  /// form a meaningful polygon (within ~10cm of each other).
  bool _isDegenerate(List<BoundaryPoint> points) {
    const threshold = 0.000001; // ~0.1m in decimal degrees
    final first = points.first;
    final allSame = points.every(
      (p) =>
          (p.latitude - first.latitude).abs() < threshold &&
          (p.longitude - first.longitude).abs() < threshold,
    );
    if (allSame) return true;

    // Check for collinearity using cross product of consecutive edges.
    if (points.length == 3) {
      final a = points[0];
      final b = points[1];
      final c = points[2];
      final cross = (b.latitude - a.latitude) * (c.longitude - a.longitude) -
          (b.longitude - a.longitude) * (c.latitude - a.latitude);
      return cross.abs() < threshold;
    }

    return false;
  }

  // ---------------------------------------------------------------------------
  // Point-in-polygon (ray-casting)
  // ---------------------------------------------------------------------------

  /// Determines whether the point ([latitude], [longitude]) lies inside
  /// the polygon defined by [boundary].
  ///
  /// Uses the ray-casting (even-odd) algorithm.
  /// Points exactly on the boundary edge may return either true or false
  /// (edge-case behaviour is acceptable given GPS imprecision).
  ///
  /// Returns [Result.failure] with [StorageOutsideRoomFailure] if outside,
  /// or [Result.failure] with [InvalidPolygonFailure] if the boundary is invalid.
  Result<bool> isPointInBoundary({
    required double latitude,
    required double longitude,
    required RoomBoundary boundary,
  }) {
    final validationResult = validateBoundary(boundary);
    if (validationResult.isFailure) {
      return Result.failure(validationResult.failureOrNull!);
    }

    final inside = _rayCasting(
      latitude: latitude,
      longitude: longitude,
      points: boundary.points,
    );

    if (!inside) {
      return Result.failure(const StorageOutsideRoomFailure());
    }

    return Result.success(true);
  }

  /// Raw ray-casting implementation.
  ///
  /// [latitude] / [longitude]: the test point.
  /// [points]: ordered polygon vertices.
  bool _rayCasting({
    required double latitude,
    required double longitude,
    required List<BoundaryPoint> points,
  }) {
    var inside = false;
    final n = points.length;

    var j = n - 1;
    for (var i = 0; i < n; i++) {
      final xi = points[i].longitude;
      final yi = points[i].latitude;
      final xj = points[j].longitude;
      final yj = points[j].latitude;

      // Does the ray from (longitude, latitude) cross this edge?
      final intersect = ((yi > latitude) != (yj > latitude)) &&
          (longitude < (xj - xi) * (latitude - yi) / (yj - yi) + xi);

      if (intersect) inside = !inside;
      j = i;
    }

    return inside;
  }

  // ---------------------------------------------------------------------------
  // Distance calculation (Haversine formula)
  // ---------------------------------------------------------------------------

  /// Calculates the great-circle distance in metres between two GPS points
  /// using the Haversine formula.
  ///
  /// Accurate to within ~0.5% for distances up to hundreds of kilometres.
  double distanceMetres({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    const earthRadiusM = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusM * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180.0;

  // ---------------------------------------------------------------------------
  // Polygon area & perimeter calculation (Geodesic / Shoelace formula)
  // ---------------------------------------------------------------------------

  /// Calculates the approximate planar surface area of the room boundary polygon
  /// in square metres using the Shoelace formula projected on spherical coordinates.
  double polygonAreaMetres(List<BoundaryPoint> points) {
    if (points.length < 3) return 0.0;
    const earthRadiusM = 6371000.0;
    double area = 0.0;
    final n = points.length;

    for (int i = 0; i < n; i++) {
      final j = (i + 1) % n;
      final lat1 = _toRadians(points[i].latitude);
      final lng1 = _toRadians(points[i].longitude);
      final lat2 = _toRadians(points[j].latitude);
      final lng2 = _toRadians(points[j].longitude);

      area += (lng2 - lng1) * (2.0 + math.sin(lat1) + math.sin(lat2));
    }

    area = (area * earthRadiusM * earthRadiusM / 4.0).abs();
    return area;
  }

  /// Calculates the total perimeter of the room boundary polygon in metres.
  double polygonPerimeterMetres(List<BoundaryPoint> points) {
    if (points.length < 2) return 0.0;
    double perimeter = 0.0;
    final n = points.length;

    for (int i = 0; i < n; i++) {
      final j = (i + 1) % n;
      perimeter += distanceMetres(
        lat1: points[i].latitude,
        lng1: points[i].longitude,
        lat2: points[j].latitude,
        lng2: points[j].longitude,
      );
    }

    return perimeter;
  }

  // ---------------------------------------------------------------------------
  // Polygon centroid (for map centering)
  // ---------------------------------------------------------------------------

  /// Calculates the arithmetic centroid of the polygon (not area-weighted).
  ///
  /// Used to centre the map view on the room.
  /// Returns (latitude, longitude) pair.
  (double latitude, double longitude) polygonCentroid(
    List<BoundaryPoint> points,
  ) {
    if (points.isEmpty) return (0, 0);
    final lat = points.map((p) => p.latitude).reduce((a, b) => a + b) /
        points.length;
    final lng = points.map((p) => p.longitude).reduce((a, b) => a + b) /
        points.length;
    return (lat, lng);
  }

  // ---------------------------------------------------------------------------
  // Coordinate normalisation (for map rendering)
  // ---------------------------------------------------------------------------

  /// Converts GPS [points] to normalised canvas coordinates within
  /// a [canvasWidth] × [canvasHeight] rectangle, with [paddingFraction] margin.
  ///
  /// Returns a list of (x, y) pairs in the same order as [points].
  ///
  /// Used by the room map [CustomPainter] to render the polygon.
  List<(double x, double y)> normaliseToCanvas({
    required List<BoundaryPoint> points,
    required double canvasWidth,
    required double canvasHeight,
    double paddingFraction = 0.1,
  }) {
    if (points.isEmpty) return [];
    if (points.length == 1) {
      return [(canvasWidth / 2, canvasHeight / 2)];
    }

    final lats = points.map((p) => p.latitude);
    final lngs = points.map((p) => p.longitude);

    final minLat = lats.reduce(math.min);
    final maxLat = lats.reduce(math.max);
    final minLng = lngs.reduce(math.min);
    final maxLng = lngs.reduce(math.max);

    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;

    // Avoid division by zero for single-latitude or single-longitude boundaries.
    final effectiveLat = latRange == 0 ? 1.0 : latRange;
    final effectiveLng = lngRange == 0 ? 1.0 : lngRange;

    final padW = canvasWidth * paddingFraction;
    final padH = canvasHeight * paddingFraction;
    final drawW = canvasWidth - 2 * padW;
    final drawH = canvasHeight - 2 * padH;

    return points.map((p) {
      final normLat = (p.latitude - minLat) / effectiveLat;
      final normLng = (p.longitude - minLng) / effectiveLng;

      // Latitude increases northward (up), but canvas y increases downward.
      final x = padW + normLng * drawW;
      final y = padH + (1.0 - normLat) * drawH;
      return (x, y);
    }).toList();
  }

  /// Converts a single GPS point to canvas coordinates using
  /// the same bounds as [polygonPoints].
  ///
  /// Used to place storage markers on the room map.
  (double x, double y)? normalisePointToCanvas({
    required double latitude,
    required double longitude,
    required List<BoundaryPoint> polygonPoints,
    required double canvasWidth,
    required double canvasHeight,
    double paddingFraction = 0.1,
  }) {
    if (polygonPoints.isEmpty) return null;

    final lats = polygonPoints.map((p) => p.latitude);
    final lngs = polygonPoints.map((p) => p.longitude);

    final minLat = lats.reduce(math.min);
    final maxLat = lats.reduce(math.max);
    final minLng = lngs.reduce(math.min);
    final maxLng = lngs.reduce(math.max);

    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;

    final effectiveLat = latRange == 0 ? 1.0 : latRange;
    final effectiveLng = lngRange == 0 ? 1.0 : lngRange;

    final padW = canvasWidth * paddingFraction;
    final padH = canvasHeight * paddingFraction;
    final drawW = canvasWidth - 2 * padW;
    final drawH = canvasHeight - 2 * padH;

    final normLat = (latitude - minLat) / effectiveLat;
    final normLng = (longitude - minLng) / effectiveLng;

    final x = padW + normLng * drawW;
    final y = padH + (1.0 - normLat) * drawH;
    return (x, y);
  }
}
