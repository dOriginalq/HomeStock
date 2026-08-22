import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/data/mock_database.dart';
import '../../inventory/domain/entities/item.dart';
import '../entities/movement_record.dart';
import '../domain/repositories/movement_repository.dart';

class MockMovementRepository implements MovementRepository {
  MockMovementRepository({MockDatabase? db}) : _db = db ?? MockDatabase.instance;

  final MockDatabase _db;

  @override
  Stream<List<MovementRecord>> watchMovementHistory(String homeId) async* {
    yield _db.movementRecords.where((m) => m.homeId == homeId).toList();
    yield* _db.watchMovement().map(
          (list) => list.where((m) => m.homeId == homeId).toList(),
        );
  }

  @override
  Stream<List<MovementRecord>> watchItemHistory({
    required String homeId,
    required String itemId,
  }) async* {
    yield _db.movementRecords
        .where((m) => m.homeId == homeId && m.itemId == itemId)
        .toList();
    yield* _db.watchMovement().map(
          (list) => list
              .where((m) => m.homeId == homeId && m.itemId == itemId)
              .toList(),
        );
  }

  @override
  Future<Result<Item>> moveItem({
    required String homeId,
    required String itemId,
    required String fromStorageId,
    required String toStorageId,
    String? fromRoomId,
    String? toRoomId,
    String? note,
  }) async {
    // 1. Verify item exists
    final itemIdx = _db.items.indexWhere(
      (i) => i.id == itemId && i.homeId == homeId,
    );
    if (itemIdx == -1) {
      return Result.failure(ItemNotFoundFailure(itemId: itemId));
    }

    // 2. Verify destination storage exists
    final destStorageIdx = _db.storageUnits.indexWhere(
      (s) => s.id == toStorageId && s.homeId == homeId,
    );
    if (destStorageIdx == -1) {
      return Result.failure(
        DestinationStorageNotFoundFailure(storageId: toStorageId),
      );
    }

    final now = DateTime.now();
    final currentItem = _db.items[itemIdx];

    // 3. Create movement record
    final record = MovementRecord(
      id: 'mov-${now.millisecondsSinceEpoch}',
      itemId: itemId,
      homeId: homeId,
      fromStorageId: fromStorageId,
      toStorageId: toStorageId,
      fromRoomId: fromRoomId,
      toRoomId: toRoomId,
      note: note,
      movedAt: now,
    );
    _db.movementRecords.add(record);

    // 4. Update item storage location atomically
    final updatedItem = currentItem.copyWith(
      currentStorageId: toStorageId,
      updatedAt: now,
    );
    _db.items[itemIdx] = updatedItem;

    // 5. Update counts on both storage units
    final fromStorageIdx = _db.storageUnits.indexWhere(
      (s) => s.id == fromStorageId && s.homeId == homeId,
    );
    if (fromStorageIdx != -1) {
      final fromCount = _db.storageUnits[fromStorageIdx].itemCount;
      _db.storageUnits[fromStorageIdx] =
          _db.storageUnits[fromStorageIdx].copyWith(
        itemCount: (fromCount - currentItem.quantity).clamp(0, 99999),
      );
    }
    final toCount = _db.storageUnits[destStorageIdx].itemCount;
    _db.storageUnits[destStorageIdx] =
        _db.storageUnits[destStorageIdx].copyWith(
      itemCount: toCount + currentItem.quantity,
    );

    _db.notifyItemsChanged();
    _db.notifyStorageChanged();
    _db.notifyMovementChanged();

    return Result.success(updatedItem);
  }
}
