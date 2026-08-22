import 'package:equatable/equatable.dart';

import 'storage_position.dart';

/// A storage unit within a room (e.g. Shelf, Drawer, Cabinet).
///
/// Each storage unit:
/// - Has a stable unique [qrId] (format: HS-ST-NNNNN)
/// - Belongs to one [roomId]
/// - Can optionally have a registered [position] (set after QR scan)
/// - Contains items (tracked separately in the items sub-collection)
final class StorageUnit extends Equatable {
  const StorageUnit({
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

  /// Firestore document ID.
  final String id;

  /// Home this storage unit belongs to.
  final String homeId;

  /// Room this storage unit belongs to.
  final String roomId;

  /// Stable QR identifier, format: HS-ST-00042.
  /// This is what the QR code encodes — never changes after creation.
  final String qrId;

  final String name;

  /// One of the predefined types or a user-defined custom type.
  final String type;

  final String? description;

  /// User-defined maximum item capacity (not physical volume).
  final int? capacityItems;

  /// Categories of items this storage unit is intended for.
  final List<String> expectedCategories;

  /// Approximate physical location, set after the user scans the QR code
  /// while standing next to the storage unit.
  final StoragePosition? position;

  /// Denormalised item count for fast display.
  final int itemCount;

  /// Whether the physical position has been registered via QR scan.
  final bool isPositionRegistered;

  final DateTime createdAt;
  final DateTime updatedAt;

  StorageUnit copyWith({
    String? id,
    String? homeId,
    String? roomId,
    String? qrId,
    String? name,
    String? type,
    String? description,
    int? capacityItems,
    List<String>? expectedCategories,
    StoragePosition? position,
    int? itemCount,
    bool? isPositionRegistered,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      StorageUnit(
        id: id ?? this.id,
        homeId: homeId ?? this.homeId,
        roomId: roomId ?? this.roomId,
        qrId: qrId ?? this.qrId,
        name: name ?? this.name,
        type: type ?? this.type,
        description: description ?? this.description,
        capacityItems: capacityItems ?? this.capacityItems,
        expectedCategories: expectedCategories ?? this.expectedCategories,
        position: position ?? this.position,
        itemCount: itemCount ?? this.itemCount,
        isPositionRegistered: isPositionRegistered ?? this.isPositionRegistered,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        id, homeId, roomId, qrId, name, type, description,
        capacityItems, expectedCategories, position,
        itemCount, isPositionRegistered, createdAt, updatedAt,
      ];

  @override
  String toString() =>
      'StorageUnit(id: $id, qrId: $qrId, name: $name, type: $type, '
      'room: $roomId, items: $itemCount, positioned: $isPositionRegistered)';
}
