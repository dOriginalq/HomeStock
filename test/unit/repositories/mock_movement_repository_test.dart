import 'package:flutter_test/flutter_test.dart';
import 'package:homestock/features/inventory/data/repositories/mock_item_repository.dart';
import 'package:homestock/features/movement/data/repositories/mock_movement_repository.dart';
import 'package:homestock/shared/data/mock_database.dart';

void main() {
  late MockDatabase db;
  late MockItemRepository itemRepo;
  late MockMovementRepository moveRepo;

  setUp(() {
    db = MockDatabase.instance;
    itemRepo = MockItemRepository(db: db);
    moveRepo = MockMovementRepository(db: db);
  });

  test('moveItem updates item storage reference and creates movement record',
      () async {
    const homeId = 'home-001';
    final create = await itemRepo.createItem(
      homeId: homeId,
      storageId: 'storage-shelf-a',
      name: 'Wireless Mouse',
      quantity: 1,
    );
    final item = create.valueOrNull!;

    final moveResult = await moveRepo.moveItem(
      homeId: homeId,
      itemId: item.id,
      fromStorageId: 'storage-shelf-a',
      toStorageId: 'storage-drawer-1',
      note: 'Moved to nightstand drawer',
    );

    expect(moveResult.isSuccess, isTrue);
    expect(moveResult.valueOrNull!.currentStorageId, 'storage-drawer-1');

    final history = await moveRepo.watchItemHistory(homeId: homeId, itemId: item.id).first;
    expect(history.any((m) => m.toStorageId == 'storage-drawer-1'), isTrue);
  });
}
