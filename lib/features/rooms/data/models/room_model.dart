import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../rooms/domain/entities/boundary_point.dart';
import '../../../rooms/domain/entities/room.dart';
import '../../../rooms/domain/entities/room_boundary.dart';

/// Firestore serialization model for [Room].
class RoomModel {
  const RoomModel({
    required this.id,
    required this.homeId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.boundary,
    this.storageUnitCount = 0,
    this.totalItemCount = 0,
  });

  final String id;
  final String homeId;
  final String name;
  final String? description;
  final RoomBoundary? boundary;
  final int storageUnitCount;
  final int totalItemCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory RoomModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final boundaryData = data['boundary'] as Map<String, dynamic>?;

    RoomBoundary? boundary;
    if (boundaryData != null) {
      final rawPoints = (boundaryData['points'] as List<dynamic>?) ?? [];
      final points = rawPoints.map((p) {
        final pMap = p as Map<String, dynamic>;
        return BoundaryPoint(
          id: pMap['id'] as String? ?? '',
          latitude: (pMap['latitude'] as num).toDouble(),
          longitude: (pMap['longitude'] as num).toDouble(),
          accuracyMetres: (pMap['accuracy_metres'] as num?)?.toDouble(),
          index: (pMap['index'] as num?)?.toInt() ?? 0,
          capturedAt: (pMap['captured_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      boundary = RoomBoundary(
        roomId: doc.id,
        points: points,
        isComplete: boundaryData['is_complete'] as bool? ?? false,
        capturedAt: (boundaryData['captured_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }

    return RoomModel(
      id: doc.id,
      homeId: data['home_id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      storageUnitCount: (data['storage_unit_count'] as num?)?.toInt() ?? 0,
      totalItemCount: (data['total_item_count'] as num?)?.toInt() ?? 0,
      boundary: boundary,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'home_id': homeId,
      'name': name,
      if (description != null) 'description': description,
      'storage_unit_count': storageUnitCount,
      'total_item_count': totalItemCount,
      if (boundary != null)
        'boundary': {
          'is_complete': boundary!.isComplete,
          'captured_at': Timestamp.fromDate(boundary!.capturedAt),
          'points': boundary!.points
              .map((p) => {
                    'id': p.id,
                    'latitude': p.latitude,
                    'longitude': p.longitude,
                    if (p.accuracyMetres != null)
                      'accuracy_metres': p.accuracyMetres,
                    'index': p.index,
                    'captured_at': Timestamp.fromDate(p.capturedAt),
                  })
              .toList(),
        },
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  Room toEntity() => Room(
        id: id,
        homeId: homeId,
        name: name,
        description: description,
        boundary: boundary,
        storageUnitCount: storageUnitCount,
        totalItemCount: totalItemCount,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory RoomModel.fromEntity(Room room) => RoomModel(
        id: room.id,
        homeId: room.homeId,
        name: room.name,
        description: room.description,
        boundary: room.boundary,
        storageUnitCount: room.storageUnitCount,
        totalItemCount: room.totalItemCount,
        createdAt: room.createdAt,
        updatedAt: room.updatedAt,
      );
}
