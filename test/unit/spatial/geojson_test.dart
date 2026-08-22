import 'package:flutter_test/flutter_test.dart';
import 'package:homestock/core/utils/geojson_converter.dart';
import 'package:homestock/features/rooms/domain/entities/boundary_point.dart';
import 'package:homestock/features/rooms/domain/entities/room.dart';
import 'package:homestock/features/rooms/domain/entities/room_boundary.dart';
import 'package:homestock/features/storage/domain/entities/storage_position.dart';
import 'package:homestock/features/storage/domain/entities/storage_unit.dart';

void main() {
  test('roomToGeoJson exports valid GeoJSON FeatureCollection with polygon and points', () {
    final now = DateTime(2024, 1, 1);
    final room = Room(
      id: 'room-01',
      homeId: 'home-001',
      name: 'Bedroom',
      boundary: RoomBoundary(
        roomId: 'room-01',
        points: [
          BoundaryPoint(id: '1', latitude: 37.7755, longitude: -122.4195, capturedAt: now, index: 0),
          BoundaryPoint(id: '2', latitude: 37.7755, longitude: -122.4184, capturedAt: now, index: 1),
          BoundaryPoint(id: '3', latitude: 37.7745, longitude: -122.4184, capturedAt: now, index: 2),
          BoundaryPoint(id: '4', latitude: 37.7745, longitude: -122.4195, capturedAt: now, index: 3),
        ],
        capturedAt: now,
        isComplete: true,
      ),
      createdAt: now,
      updatedAt: now,
    );

    final storage = StorageUnit(
      id: 'st-01',
      homeId: 'home-001',
      roomId: room.id,
      qrId: 'HS-ST-00042',
      name: 'Shelf A',
      type: 'Shelf',
      position: StoragePosition(
        storageId: 'st-01',
        latitude: 37.7750,
        longitude: -122.4190,
        registeredAt: now,
      ),
      createdAt: now,
      updatedAt: now,
    );

    final geoJson = GeoJsonConverter.roomToGeoJson(
      room: room,
      storageUnits: [storage],
    );

    expect(geoJson, contains('FeatureCollection'));
    expect(geoJson, contains('room_boundary'));
    expect(geoJson, contains('storage_unit'));
    expect(geoJson, contains('HS-ST-00042'));
  });

  test('boundaryFromGeoJson parses GeoJSON polygon back into BoundaryPoints', () {
    const rawGeoJson = '''
    {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "geometry": {
            "type": "Polygon",
            "coordinates": [
              [
                [-122.4195, 37.7755],
                [-122.4184, 37.7755],
                [-122.4184, 37.7745],
                [-122.4195, 37.7745],
                [-122.4195, 37.7755]
              ]
            ]
          }
        }
      ]
    }
    ''';

    final points = GeoJsonConverter.boundaryFromGeoJson(rawGeoJson);
    expect(points.length, 4);
    expect(points[0].latitude, 37.7755);
    expect(points[0].longitude, -122.4195);
    expect(points[1].latitude, 37.7755);
    expect(points[1].longitude, -122.4184);
  });
}
