import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/data/mock_database.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';

class MockItemRepository implements ItemRepository {
  MockItemRepository({MockDatabase? db}) : _db = db ?? MockDatabase.instance;

  final MockDatabase _db;

  @override
  Stream<List<Item>> watchItemsForStorage({
    required String homeId,
    required String storageId,
  }) async* {
    yield _db.items
        .where((i) => i.homeId == homeId && i.currentStorageId == storageId)
        .toList();
    yield* _db.watchItems().map(
          (list) => list
              .where((i) => i.homeId == homeId && i.currentStorageId == storageId)
              .toList(),
        );
  }

  @override
  Stream<List<Item>> watchAllItems(String homeId) async* {
    yield _db.items.where((i) => i.homeId == homeId).toList();
    yield* _db.watchItems().map(
          (list) => list.where((i) => i.homeId == homeId).toList(),
        );
  }

  @override
  Future<Result<Item>> getItem({
    required String homeId,
    required String itemId,
  }) async {
    try {
      final item = _db.items.firstWhere(
        (i) => i.id == itemId && i.homeId == homeId,
      );
      return Result.success(item);
    } catch (_) {
      return Result.failure(ItemNotFoundFailure(itemId: itemId));
    }
  }

  @override
  Future<Result<Item>> createItem({
    required String homeId,
    required String storageId,
    required String name,
    int quantity = 1,
    String? category,
    String? description,
    String? imageUrl,
    List<String> tags = const [],
  }) async {
    final now = DateTime.now();
    final item = Item(
      id: 'item-${now.millisecondsSinceEpoch}',
      homeId: homeId,
      currentStorageId: storageId,
      name: name,
      quantity: quantity,
      category: category,
      description: description,
      imageUrl: imageUrl,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );
    _db.items.add(item);

    // Update storage unit count
    final sIdx = _db.storageUnits.indexWhere((s) => s.id == storageId);
    if (sIdx != -1) {
      _db.storageUnits[sIdx] = _db.storageUnits[sIdx].copyWith(
        itemCount: _db.storageUnits[sIdx].itemCount + quantity,
      );
      _db.notifyStorageChanged();
    }

    _db.notifyItemsChanged();
    return Result.success(item);
  }

  @override
  Future<Result<Item>> updateItem(Item item) async {
    final index = _db.items.indexWhere((i) => i.id == item.id);
    if (index == -1) {
      return Result.failure(ItemNotFoundFailure(itemId: item.id));
    }
    _db.items[index] = item;
    _db.notifyItemsChanged();
    return Result.success(item);
  }

  @override
  Future<Result<void>> deleteItem({
    required String homeId,
    required String itemId,
  }) async {
    final item = _db.items.firstWhere(
      (i) => i.id == itemId && i.homeId == homeId,
      orElse: () => throw Exception('Item not found'),
    );

    _db.items.removeWhere((i) => i.id == itemId && i.homeId == homeId);

    final sIdx = _db.storageUnits.indexWhere((s) => s.id == item.currentStorageId);
    if (sIdx != -1) {
      final current = _db.storageUnits[sIdx].itemCount;
      _db.storageUnits[sIdx] = _db.storageUnits[sIdx].copyWith(
        itemCount: (current - item.quantity).clamp(0, 99999),
      );
      _db.notifyStorageChanged();
    }

    _db.notifyItemsChanged();
    return Result.success(null);
  }
}
