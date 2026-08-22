import 'package:flutter_test/flutter_test.dart';
import 'package:homestock/core/errors/failures.dart';
import 'package:homestock/core/result/result.dart';
import 'package:homestock/core/services/spatial_service.dart';
import 'package:homestock/features/rooms/domain/entities/boundary_point.dart';
import 'package:homestock/features/rooms/domain/entities/room_boundary.dart';

void main() {
  late SpatialService service;

  setUp(() {
    service = const SpatialService();
  });

  // -------------------------------------------------------------------------
  // Helper: Build a boundary from a list of (lat, lng) pairs.
  // -------------------------------------------------------------------------
  RoomBoundary _makeBoundary(List<(double, double)> coords) {
    final points = coords
        .asMap()
        .entries
        .map(
          (e) => BoundaryPoint(
            id: 'pt-${e.key}',
            latitude: e.value.$1,
            longitude: e.value.$2,
            capturedAt: DateTime(2024),
            index: e.key,
          ),
        )
        .toList();
    return RoomBoundary(
      roomId: 'room-1',
      points: points,
      capturedAt: DateTime(2024),
      isComplete: true,
    );
  }

  // -------------------------------------------------------------------------
  // validateBoundary
  // -------------------------------------------------------------------------
  group('validateBoundary', () {
    test('returns Success for a valid 4-point rectangle', () {
      final boundary = _makeBoundary([
        (0.0, 0.0),
        (0.0, 1.0),
        (1.0, 1.0),
        (1.0, 0.0),
      ]);
      final result = service.validateBoundary(boundary);
      expect(result.isSuccess, isTrue);
    });

    test('returns InsufficientBoundaryPointsFailure for 0 points', () {
      final boundary = _makeBoundary([]);
      final result = service.validateBoundary(boundary);
      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull,
        isA<InsufficientBoundaryPointsFailure>(),
      );
    });

    test('returns InsufficientBoundaryPointsFailure for 2 points', () {
      final boundary = _makeBoundary([(0.0, 0.0), (1.0, 1.0)]);
      final result = service.validateBoundary(boundary);
      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull,
        isA<InsufficientBoundaryPointsFailure>(),
      );
    });

    test('returns InvalidPolygonFailure for all-same points', () {
      final boundary = _makeBoundary([
        (1.0, 1.0),
        (1.0, 1.0),
        (1.0, 1.0),
      ]);
      final result = service.validateBoundary(boundary);
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<InvalidPolygonFailure>());
    });

    test('accepts a 3-point triangle', () {
      final boundary = _makeBoundary([
        (0.0, 0.0),
        (0.0, 1.0),
        (1.0, 0.5),
      ]);
      final result = service.validateBoundary(boundary);
      expect(result.isSuccess, isTrue);
    });

    test('accepts polygon with more than 4 points', () {
      final boundary = _makeBoundary([
        (0.0, 0.0),
        (0.0, 0.5),
        (0.0, 1.0),
        (0.5, 1.0),
        (1.0, 1.0),
        (1.0, 0.0),
      ]);
      final result = service.validateBoundary(boundary);
      expect(result.isSuccess, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // isPointInBoundary — square [0,0]–[1,1]
  // -------------------------------------------------------------------------
  group('isPointInBoundary — axis-aligned square', () {
    late RoomBoundary square;

    setUp(() {
      square = _makeBoundary([
        (0.0, 0.0),
        (0.0, 1.0),
        (1.0, 1.0),
        (1.0, 0.0),
      ]);
    });

    test('centre point is inside', () {
      final result = service.isPointInBoundary(
        latitude: 0.5,
        longitude: 0.5,
        boundary: square,
      );
      expect(result.isSuccess, isTrue);
    });

    test('point outside to the right is outside', () {
      final result = service.isPointInBoundary(
        latitude: 0.5,
        longitude: 2.0,
        boundary: square,
      );
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<StorageOutsideRoomFailure>());
    });

    test('point outside to the left is outside', () {
      final result = service.isPointInBoundary(
        latitude: 0.5,
        longitude: -0.5,
        boundary: square,
      );
      expect(result.isFailure, isTrue);
    });

    test('point above is outside', () {
      final result = service.isPointInBoundary(
        latitude: 1.5,
        longitude: 0.5,
        boundary: square,
      );
      expect(result.isFailure, isTrue);
    });

    test('point below is outside', () {
      final result = service.isPointInBoundary(
        latitude: -0.5,
        longitude: 0.5,
        boundary: square,
      );
      expect(result.isFailure, isTrue);
    });

    test('near-corner interior point is inside', () {
      final result = service.isPointInBoundary(
        latitude: 0.05,
        longitude: 0.05,
        boundary: square,
      );
      expect(result.isSuccess, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // isPointInBoundary — L-shaped polygon
  // -------------------------------------------------------------------------
  group('isPointInBoundary — L-shaped polygon', () {
    // L-shape:
    //  (0,0)-(0,2)-(1,2)-(1,1)-(2,1)-(2,0)
    late RoomBoundary lShape;

    setUp(() {
      lShape = _makeBoundary([
        (0.0, 0.0),
        (2.0, 0.0),
        (2.0, 1.0),
        (1.0, 1.0),
        (1.0, 2.0),
        (0.0, 2.0),
      ]);
    });

    test('bottom-left area is inside', () {
      final result = service.isPointInBoundary(
        latitude: 0.5,
        longitude: 0.5,
        boundary: lShape,
      );
      expect(result.isSuccess, isTrue);
    });

    test('top-right (missing) corner is outside', () {
      final result = service.isPointInBoundary(
        latitude: 1.5,
        longitude: 1.5,
        boundary: lShape,
      );
      expect(result.isFailure, isTrue);
    });

    test('top-left area is inside', () {
      final result = service.isPointInBoundary(
        latitude: 1.5,
        longitude: 0.5,
        boundary: lShape,
      );
      expect(result.isSuccess, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // distanceMetres
  // -------------------------------------------------------------------------
  group('distanceMetres', () {
    test('same point = 0 metres', () {
      final d = service.distanceMetres(
        lat1: 51.5, lng1: 0.1, lat2: 51.5, lng2: 0.1,
      );
      expect(d, closeTo(0, 0.001));
    });

    test('equator degree ≈ 111 km', () {
      final d = service.distanceMetres(
        lat1: 0.0, lng1: 0.0, lat2: 0.0, lng2: 1.0,
      );
      // 1 degree of longitude at equator ≈ 111,319 m
      expect(d, closeTo(111319, 200));
    });

    test('short indoor distance < 10m', () {
      // ~5m apart
      final d = service.distanceMetres(
        lat1: 51.50000, lng1: 0.10000,
        lat2: 51.50004, lng2: 0.10000,
      );
      expect(d, lessThan(10));
      expect(d, greaterThan(0));
    });
  });

  // -------------------------------------------------------------------------
  // polygonAreaMetres & polygonPerimeterMetres
  // -------------------------------------------------------------------------
  group('polygonAreaMetres & polygonPerimeterMetres', () {
    test('calculates area for a rectangular room', () {
      // ~10m x 10m room = ~100 m²
      final boundary = _makeBoundary([
        (37.77500, -122.41900),
        (37.77509, -122.41900),
        (37.77509, -122.41889),
        (37.77500, -122.41889),
      ]);
      final area = service.polygonAreaMetres(boundary.points);
      expect(area, greaterThan(40));
      expect(area, lessThan(200));
    });

    test('calculates perimeter for a rectangular room', () {
      final boundary = _makeBoundary([
        (37.77500, -122.41900),
        (37.77509, -122.41900),
        (37.77509, -122.41889),
        (37.77500, -122.41889),
      ]);
      final perimeter = service.polygonPerimeterMetres(boundary.points);
      expect(perimeter, greaterThan(20));
      expect(perimeter, lessThan(60));
    });

    test('returns 0 area for less than 3 points', () {
      expect(service.polygonAreaMetres([]), 0.0);
    });
  });

  // -------------------------------------------------------------------------
  // polygonCentroid
  // -------------------------------------------------------------------------
  group('polygonCentroid', () {
    test('centroid of unit square is (0.5, 0.5)', () {
      final pts = [
        BoundaryPoint(id: '0', latitude: 0.0, longitude: 0.0, capturedAt: DateTime(2024)),
        BoundaryPoint(id: '1', latitude: 0.0, longitude: 1.0, capturedAt: DateTime(2024)),
        BoundaryPoint(id: '2', latitude: 1.0, longitude: 1.0, capturedAt: DateTime(2024)),
        BoundaryPoint(id: '3', latitude: 1.0, longitude: 0.0, capturedAt: DateTime(2024)),
      ];
      final (lat, lng) = service.polygonCentroid(pts);
      expect(lat, closeTo(0.5, 0.001));
      expect(lng, closeTo(0.5, 0.001));
    });

    test('centroid of single point is that point', () {
      final pts = [
        BoundaryPoint(id: '0', latitude: 3.0, longitude: 7.0, capturedAt: DateTime(2024)),
      ];
      final (lat, lng) = service.polygonCentroid(pts);
      expect(lat, closeTo(3.0, 0.001));
      expect(lng, closeTo(7.0, 0.001));
    });
  });

  // -------------------------------------------------------------------------
  // normaliseToCanvas
  // -------------------------------------------------------------------------
  group('normaliseToCanvas', () {
    test('returns empty list for empty input', () {
      final result = service.normaliseToCanvas(
        points: [],
        canvasWidth: 300,
        canvasHeight: 300,
      );
      expect(result, isEmpty);
    });

    test('all points are within canvas bounds', () {
      final boundary = _makeBoundary([
        (0.0, 0.0),
        (0.0, 1.0),
        (1.0, 1.0),
        (1.0, 0.0),
      ]);
      final pts = service.normaliseToCanvas(
        points: boundary.points,
        canvasWidth: 300,
        canvasHeight: 300,
      );
      for (final (x, y) in pts) {
        expect(x, greaterThanOrEqualTo(0));
        expect(x, lessThanOrEqualTo(300));
        expect(y, greaterThanOrEqualTo(0));
        expect(y, lessThanOrEqualTo(300));
      }
    });
  });
}
