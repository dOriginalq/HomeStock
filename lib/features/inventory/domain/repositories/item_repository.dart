import '../../../../core/result/result.dart';
import '../entities/item.dart';

/// Contract for inventory Item CRUD operations.
abstract interface class ItemRepository {
  /// Stream of items currently in a specific storage unit.
  Stream<List<Item>> watchItemsForStorage({
    required String homeId,
    required String storageId,
  });

  /// Stream of all items in a home.
  Stream<List<Item>> watchAllItems(String homeId);

  /// Gets single item by ID.
  Future<Result<Item>> getItem({
    required String homeId,
    required String itemId,
  });

  /// Creates a new item inside a storage unit.
  Future<Result<Item>> createItem({
    required String homeId,
    required String storageId,
    required String name,
    int quantity = 1,
    String? category,
    String? description,
    String? imageUrl,
    List<String> tags = const [],
  });

  /// Updates existing item.
  Future<Result<Item>> updateItem(Item item);

  /// Deletes an item from inventory.
  Future<Result<void>> deleteItem({
    required String homeId,
    required String itemId,
  });
}
