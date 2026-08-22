import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/data/mock_database.dart';
import '../../domain/entities/storage_position.dart';
import '../../domain/entities/storage_unit.dart';
import '../../domain/repositories/storage_repository.dart';

class MockStorageRepository implements StorageRepository {
  MockStorageRepository({MockDatabase? db}) : _db = db ?? MockDatabase.instance;

  final MockDatabase _db;

  @override
  Stream<List<StorageUnit>> watchStorageUnitsForRoom({
    required String homeId,
    required String roomId,
  }) async* {
    yield _db.storageUnits
        .where((s) => s.homeId == homeId && s.roomId == roomId)
        .toList();
    yield* _db.watchStorageUnits().map(
          (list) => list
              .where((s) => s.homeId == homeId && s.roomId == roomId)
              .toList(),
        );
  }

  @override
  Stream<List<StorageUnit>> watchAllStorageUnits(String homeId) async* {
    yield _db.storageUnits.where((s) => s.homeId == homeId).toList();
    yield* _db.watchStorageUnits().map(
          (list) => list.where((s) => s.homeId == homeId).toList(),
        );
  }

  @override
  Future<Result<StorageUnit>> getStorageUnit({
    required String homeId,
    required String storageId,
  }) async {
    try {
      final unit = _db.storageUnits.firstWhere(
        (s) => s.id == storageId && s.homeId == homeId,
      );
      return Result.success(unit);
    } catch (_) {
      return Result.failure(
        StorageNotFoundFailure(storageId: storageId),
      );
    }
  }

  @override
  Future<Result<StorageUnit>> getStorageUnitByQrId({
    required String homeId,
    required String qrId,
  }) async {
    try {
      final unit = _db.storageUnits.firstWhere(
        (s) => s.qrId == qrId && s.homeId == homeId,
      );
      return Result.success(unit);
    } catch (_) {
      return Result.failure(
        StorageNotFoundFailure(storageId: qrId),
      );
    }
  }

  @override
  Future<Result<String>> generateNextQrId(String homeId) async {
    return Result.success(_db.nextStorageQrId());
  }

  @override
  Future<Result<StorageUnit>> createStorageUnit({
    required String homeId,
    required String roomId,
    required String name,
    required String type,
    String? description,
    int? capacityItems,
    List<String> expectedCategories = const [],
  }) async {
    final now = DateTime.now();
    final qrId = _db.nextStorageQrId();
    final unit = StorageUnit(
      id: 'storage-${now.millisecondsSinceEpoch}',
      homeId: homeId,
      roomId: roomId,
      qrId: qrId,
      name: name,
      type: type,
      description: description,
      capacityItems: capacityItems,
      expectedCategories: expectedCategories,
      itemCount: 0,
      isPositionRegistered: false,
      createdAt: now,
      updatedAt: now,
    );
    _db.storageUnits.add(unit);
    _db.notifyStorageChanged();
    return Result.success(unit);
  }

  @override
  Future<Result<StorageUnit>> updateStorageUnit(StorageUnit storageUnit) async {
    final index = _db.storageUnits.indexWhere((s) => s.id == storageUnit.id);
    if (index == -1) {
      return Result.failure(
        StorageNotFoundFailure(storageId: storageUnit.id),
      );
    }
    _db.storageUnits[index] = storageUnit;
    _db.notifyStorageChanged();
    return Result.success(storageUnit);
  }

  @override
  Future<Result<StorageUnit>> registerStoragePosition({
    required String homeId,
    required String storageId,
    required StoragePosition position,
  }) async {
    final index = _db.storageUnits.indexWhere(
      (s) => s.id == storageId && s.homeId == homeId,
    );
    if (index == -1) {
      return Result.failure(
        StorageNotFoundFailure(storageId: storageId),
      );
    }
    final updated = _db.storageUnits[index].copyWith(
      position: position,
      isPositionRegistered: true,
      updatedAt: DateTime.now(),
    );
    _db.storageUnits[index] = updated;
    _db.notifyStorageChanged();
    return Result.success(updated);
  }

  @override
  Future<Result<void>> deleteStorageUnit({
    required String homeId,
    required String storageId,
  }) async {
    _db.storageUnits.removeWhere(
      (s) => s.id == storageId && s.homeId == homeId,
    );
    _db.notifyStorageChanged();
    return Result.success(null);
  }
}
