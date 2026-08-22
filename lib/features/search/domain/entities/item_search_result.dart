import 'package:equatable/equatable.dart';

import '../../../inventory/domain/entities/item.dart';
import '../../../rooms/domain/entities/room.dart';
import '../../../storage/domain/entities/storage_unit.dart';

/// Resolved search result with full spatial hierarchy:
/// Item -> Storage Unit -> Room -> Storage Position
final class ItemSearchResult extends Equatable {
  const ItemSearchResult({
    required this.item,
    required this.storageUnit,
    required this.room,
  });

  final Item item;
  final StorageUnit storageUnit;
  final Room room;

  @override
  List<Object?> get props => [item, storageUnit, room];
}
