import 'package:equatable/equatable.dart';

/// Records the movement of an item from one storage unit to another.
///
/// Movement records are immutable audit trail entries.
/// The item's [currentStorageId] is updated in the same Firestore transaction
/// that creates this record, ensuring consistency.
final class MovementRecord extends Equatable {
  const MovementRecord({
    required this.id,
    required this.itemId,
    required this.homeId,
    required this.fromStorageId,
    required this.toStorageId,
    required this.movedAt,
    this.fromRoomId,
    this.toRoomId,
    this.note,
  });

  final String id;
  final String itemId;
  final String homeId;

  /// Storage unit the item was moved FROM.
  final String fromStorageId;

  /// Storage unit the item was moved TO.
  final String toStorageId;

  /// Room the item was moved FROM (denormalised for history display).
  final String? fromRoomId;

  /// Room the item was moved TO (denormalised for history display).
  final String? toRoomId;

  /// Optional note about why the item was moved.
  final String? note;

  final DateTime movedAt;

  @override
  List<Object?> get props => [
        id, itemId, homeId, fromStorageId, toStorageId,
        fromRoomId, toRoomId, note, movedAt,
      ];

  @override
  String toString() =>
      'MovementRecord(id: $id, item: $itemId, '
      'from: $fromStorageId → to: $toStorageId, at: $movedAt)';
}
