import 'dart:convert';

import '../../features/rooms/domain/entities/boundary_point.dart';
import '../../features/rooms/domain/entities/room.dart';
import '../../features/rooms/domain/entities/room_boundary.dart';
import '../../features/storage/domain/entities/storage_unit.dart';

/// Utility to export and import HomeStock rooms and storage units to/from standard
/// RFC 7946 GeoJSON format for compatibility with GIS tools (QGIS, ArcGIS, GeoJSON.io).
abstract final class GeoJsonConverter {
  /// Converts a [Room] with boundary and its [StorageUnit]s to a GeoJSON FeatureCollection.
  static String roomToGeoJson({
    required Room room,
    List<StorageUnit> storageUnits = const [],
  }) {
    final features = <Map<String, dynamic>>[];

    // 1. Room Polygon Feature
    if (room.boundary != null && room.boundary!.points.isNotEmpty) {
      final coordinates = <List<double>>[];
      for (final p in room.boundary!.points) {
        // GeoJSON standard is [longitude, latitude]
        coordinates.add([p.longitude, p.latitude]);
      }
      // Close the ring if not already closed
      if (coordinates.isNotEmpty &&
          (coordinates.first[0] != coordinates.last[0] ||
              coordinates.first[1] != coordinates.last[1])) {
        coordinates.add([coordinates.first[0], coordinates.first[1]]);
      }

      features.add({
        'type': 'Feature',
        'id': room.id,
        'properties': {
          'feature_type': 'room_boundary',
          'name': room.name,
          'description': room.description,
          'storage_unit_count': room.storageUnitCount,
          'total_item_count': room.totalItemCount,
        },
        'geometry': {
          'type': 'Polygon',
          'coordinates': [coordinates],
        },
      });
    }

    // 2. Storage Unit Point Features
    for (final unit in storageUnits) {
      if (unit.position != null) {
        features.add({
          'type': 'Feature',
          'id': unit.id,
          'properties': {
            'feature_type': 'storage_unit',
            'name': unit.name,
            'qr_id': unit.qrId,
            'type': unit.type,
            'item_count': unit.itemCount,
            'room_id': unit.roomId,
          },
          'geometry': {
            'type': 'Point',
            'coordinates': [
              unit.position!.longitude,
              unit.position!.latitude,
            ],
          },
        });
      }
    }

    final collection = {
      'type': 'FeatureCollection',
      'features': features,
    };

    return const JsonEncoder.withIndent('  ').convert(collection);
  }

  /// Parses GeoJSON polygon coordinates into a list of [BoundaryPoint]s.
  static List<BoundaryPoint> boundaryFromGeoJson(String geoJsonString) {
    final parsed = jsonDecode(geoJsonString) as Map<String, dynamic>;
    final points = <BoundaryPoint>[];
    final now = DateTime.now();

    List<dynamic>? coordsList;
    if (parsed['type'] == 'FeatureCollection') {
      final features = parsed['features'] as List<dynamic>? ?? [];
      for (final f in features) {
        final geom = (f as Map<String, dynamic>)['geometry'] as Map<String, dynamic>?;
        if (geom != null && geom['type'] == 'Polygon') {
          coordsList = (geom['coordinates'] as List<dynamic>?)?.first as List<dynamic>?;
          break;
        }
      }
    } else if (parsed['type'] == 'Feature') {
      final geom = parsed['geometry'] as Map<String, dynamic>?;
      if (geom != null && geom['type'] == 'Polygon') {
        coordsList = (geom['coordinates'] as List<dynamic>?)?.first as List<dynamic>?;
      }
    } else if (parsed['type'] == 'Polygon') {
      coordsList = (parsed['coordinates'] as List<dynamic>?)?.first as List<dynamic>?;
    }

    if (coordsList != null) {
      // Exclude closing vertex if duplicate of first
      final count = coordsList.length > 3 &&
              coordsList.first[0] == coordsList.last[0] &&
              coordsList.first[1] == coordsList.last[1]
          ? coordsList.length - 1
          : coordsList.length;

      for (int i = 0; i < count; i++) {
        final pair = coordsList[i] as List<dynamic>;
        final lng = (pair[0] as num).toDouble();
        final lat = (pair[1] as num).toDouble();
        points.add(
          BoundaryPoint(
            id: 'geojson-pt-$i',
            latitude: lat,
            longitude: lng,
            index: i,
            capturedAt: now,
          ),
        );
      }
    }

    return points;
  }
}
