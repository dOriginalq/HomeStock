import 'package:equatable/equatable.dart';

import 'room_boundary.dart';

/// A room within a home.
///
/// Each room has a name, an optional [RoomBoundary] polygon, and
/// belongs to a specific home.
final class Room extends Equatable {
  const Room({
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

  /// GPS polygon boundary. Null until the user completes boundary capture.
  final RoomBoundary? boundary;

  /// Denormalised count for fast display; updated on storage/item changes.
  final int storageUnitCount;

  /// Denormalised total item count across all storage units in this room.
  final int totalItemCount;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Whether this room has a completed boundary polygon.
  bool get hasBoundary =>
      boundary != null && boundary!.isComplete && boundary!.isValid;

  Room copyWith({
    String? id,
    String? homeId,
    String? name,
    String? description,
    RoomBoundary? boundary,
    int? storageUnitCount,
    int? totalItemCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Room(
        id: id ?? this.id,
        homeId: homeId ?? this.homeId,
        name: name ?? this.name,
        description: description ?? this.description,
        boundary: boundary ?? this.boundary,
        storageUnitCount: storageUnitCount ?? this.storageUnitCount,
        totalItemCount: totalItemCount ?? this.totalItemCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [id, homeId, name, description, boundary,
        storageUnitCount, totalItemCount, createdAt, updatedAt];

  @override
  String toString() =>
      'Room(id: $id, name: $name, hasBoundary: $hasBoundary, '
      'storage: $storageUnitCount, items: $totalItemCount)';
}
