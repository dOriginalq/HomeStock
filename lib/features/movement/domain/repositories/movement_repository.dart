import '../../../../core/result/result.dart';
import '../../inventory/domain/entities/item.dart';
import '../entities/movement_record.dart';

/// Contract for Item Movement and atomic location update operations.
abstract interface class MovementRepository {
  /// Stream of movement records for a home.
  Stream<List<MovementRecord>> watchMovementHistory(String homeId);

  /// Stream of movement records for a specific item.
  Stream<List<MovementRecord>> watchItemHistory({
    required String homeId,
    required String itemId,
  });

  /// Atomically moves an item from [fromStorageId] to [toStorageId],
  /// updating the item record and appending an immutable [MovementRecord].
  Future<Result<Item>> moveItem({
    required String homeId,
    required String itemId,
    required String fromStorageId,
    required String toStorageId,
    String? fromRoomId,
    String? toRoomId,
    String? note,
  });
}
