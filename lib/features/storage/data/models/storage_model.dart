import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../storage/domain/entities/storage_position.dart';
import '../../../storage/domain/entities/storage_unit.dart';

/// Firestore serialization model for [StorageUnit].
class StorageUnitModel {
  const StorageUnitModel({
    required this.id,
    required this.homeId,
    required this.roomId,
    required this.qrId,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.capacityItems,
    this.expectedCategories = const [],
    this.position,
    this.itemCount = 0,
    this.isPositionRegistered = false,
  });

  final String id;
  final String homeId;
  final String roomId;
  final String qrId;
  final String name;
  final String type;
  final String? description;
  final int? capacityItems;
  final List<String> expectedCategories;
  final StoragePosition? position;
  final int itemCount;
  final bool isPositionRegistered;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory StorageUnitModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final posData = data['position'] as Map<String, dynamic>?;

    StoragePosition? position;
    if (posData != null) {
      position = StoragePosition(
        storageId: doc.id,
        latitude: (posData['latitude'] as num).toDouble(),
        longitude: (posData['longitude'] as num).toDouble(),
        accuracyMetres: (posData['accuracy_metres'] as num?)?.toDouble(),
        registeredAt: (posData['registered_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }

    final rawCategories = data['expected_categories'] as List<dynamic>?;
    final categories = rawCategories != null
        ? rawCategories.map((e) => e.toString()).toList()
        : <String>[];

    return StorageUnitModel(
      id: doc.id,
      homeId: data['home_id'] as String? ?? '',
      roomId: data['room_id'] as String? ?? '',
      qrId: data['qr_id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      type: data['type'] as String? ?? 'Shelf',
      description: data['description'] as String?,
      capacityItems: (data['capacity_items'] as num?)?.toInt(),
      expectedCategories: categories,
      itemCount: (data['item_count'] as num?)?.toInt() ?? 0,
      isPositionRegistered: data['is_position_registered'] as bool? ?? false,
      position: position,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'home_id': homeId,
      'room_id': roomId,
      'qr_id': qrId,
      'name': name,
      'type': type,
      if (description != null) 'description': description,
      if (capacityItems != null) 'capacity_items': capacityItems,
      'expected_categories': expectedCategories,
      'item_count': itemCount,
      'is_position_registered': isPositionRegistered,
      if (position != null)
        'position': {
          'latitude': position!.latitude,
          'longitude': position!.longitude,
          if (position!.accuracyMetres != null)
            'accuracy_metres': position!.accuracyMetres,
          'registered_at': Timestamp.fromDate(position!.registeredAt),
        },
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  StorageUnit toEntity() => StorageUnit(
        id: id,
        homeId: homeId,
        roomId: roomId,
        qrId: qrId,
        name: name,
        type: type,
        description: description,
        capacityItems: capacityItems,
        expectedCategories: expectedCategories,
        position: position,
        itemCount: itemCount,
        isPositionRegistered: isPositionRegistered,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory StorageUnitModel.fromEntity(StorageUnit unit) => StorageUnitModel(
        id: unit.id,
        homeId: unit.homeId,
        roomId: unit.roomId,
        qrId: unit.qrId,
        name: unit.name,
        type: unit.type,
        description: unit.description,
        capacityItems: unit.capacityItems,
        expectedCategories: unit.expectedCategories,
        position: unit.position,
        itemCount: unit.itemCount,
        isPositionRegistered: unit.isPositionRegistered,
        createdAt: unit.createdAt,
        updatedAt: unit.updatedAt,
      );
}
