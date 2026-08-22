import '../../../../core/result/result.dart';
import '../../../../shared/data/mock_database.dart';
import '../../search/domain/entities/item_search_result.dart';
import '../../search/domain/repositories/search_repository.dart';

class MockSearchRepository implements SearchRepository {
  MockSearchRepository({MockDatabase? db}) : _db = db ?? MockDatabase.instance;

  final MockDatabase _db;

  @override
  Future<Result<List<ItemSearchResult>>> searchItems({
    required String homeId,
    required String query,
    String? categoryFilter,
    String? roomIdFilter,
  }) async {
    final lowerQuery = query.toLowerCase().trim();

    final matchingItems = _db.items.where((item) {
      if (item.homeId != homeId) return false;
      if (categoryFilter != null &&
          categoryFilter.isNotEmpty &&
          item.category != categoryFilter) {
        return false;
      }
      if (lowerQuery.isEmpty) return true;
      final matchName = item.name.toLowerCase().contains(lowerQuery);
      final matchDesc = item.description?.toLowerCase().contains(lowerQuery) ?? false;
      final matchCat = item.category?.toLowerCase().contains(lowerQuery) ?? false;
      final matchTag = item.tags.any((t) => t.toLowerCase().contains(lowerQuery));
      return matchName || matchDesc || matchCat || matchTag;
    }).toList();

    final results = <ItemSearchResult>[];
    for (final item in matchingItems) {
      final storageUnit = _db.storageUnits.firstWhere(
        (s) => s.id == item.currentStorageId,
        orElse: () => _db.storageUnits.first,
      );
      if (roomIdFilter != null &&
          roomIdFilter.isNotEmpty &&
          storageUnit.roomId != roomIdFilter) {
        continue;
      }
      final room = _db.rooms.firstWhere(
        (r) => r.id == storageUnit.roomId,
        orElse: () => _db.rooms.first,
      );

      results.add(
        ItemSearchResult(
          item: item,
          storageUnit: storageUnit,
          room: room,
        ),
      );
    }

    return Result.success(results);
  }
}
