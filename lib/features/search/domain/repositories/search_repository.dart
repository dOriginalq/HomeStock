import '../../../../core/result/result.dart';
import '../entities/item_search_result.dart';

/// Contract for inventory Search operations.
abstract interface class SearchRepository {
  /// Searches for items matching [query] within [homeId], resolving
  /// their storage units and rooms for full spatial context.
  Future<Result<List<ItemSearchResult>>> searchItems({
    required String homeId,
    required String query,
    String? categoryFilter,
    String? roomIdFilter,
  });
}
