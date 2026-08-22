import 'package:flutter_test/flutter_test.dart';
import 'package:homestock/core/services/spatial_service.dart';
import 'package:homestock/features/inventory/data/repositories/mock_item_repository.dart';
import 'package:homestock/features/movement/data/repositories/mock_movement_repository.dart';
import 'package:homestock/features/qr/domain/services/qr_identity.dart';
import 'package:homestock/features/rooms/data/repositories/mock_room_repository.dart';
import 'package:homestock/features/rooms/domain/entities/boundary_point.dart';
import 'package:homestock/features/search/data/repositories/mock_search_repository.dart';
import 'package:homestock/features/storage/data/repositories/mock_storage_repository.dart';
import 'package:homestock/features/storage/domain/entities/storage_position.dart';
import 'package:homestock/shared/data/mock_database.dart';

void main() {
  late MockDatabase db;
  late MockRoomRepository roomRepo;
  late MockStorageRepository storageRepo;
  late MockItemRepository itemRepo;
  late MockMovementRepository moveRepo;
  late MockSearchRepository searchRepo;
  late SpatialService spatialService;

  setUp(() {
    db = MockDatabase.instance;
    roomRepo = MockRoomRepository(db: db);
    storageRepo = MockStorageRepository(db: db);
    itemRepo = MockItemRepository(db: db);
    moveRepo = MockMovementRepository(db: db);
    searchRepo = MockSearchRepository(db: db);
    spatialService = const SpatialService();
  });

  test('Full HomeStock Research Flow: Room -> Boundary -> Storage -> QR -> Item -> Search -> Move -> History',
      () async {
    const homeId = 'home-001';
    final now = DateTime.now();

    // -----------------------------------------------------------------------
    // 1. Create a New Room
    // -----------------------------------------------------------------------
    final createRoomResult = await roomRepo.createRoom(
      homeId: homeId,
      name: 'Dining Hall',
      description: 'Main dining room with sideboard',
    );
    expect(createRoomResult.isSuccess, isTrue);
    final room = createRoomResult.valueOrNull!;
    expect(room.name, 'Dining Hall');

    // -----------------------------------------------------------------------
    // 2. Map 4-Corner GPS Boundary
    // -----------------------------------------------------------------------
    final boundaryPoints = [
      BoundaryPoint(id: 'dh-1', latitude: 37.7760, longitude: -122.4190, capturedAt: now, index: 0),
      BoundaryPoint(id: 'dh-2', latitude: 37.7760, longitude: -122.4180, capturedAt: now, index: 1),
      BoundaryPoint(id: 'dh-3', latitude: 37.7750, longitude: -122.4180, capturedAt: now, index: 2),
      BoundaryPoint(id: 'dh-4', latitude: 37.7750, longitude: -122.4190, capturedAt: now, index: 3),
    ];

    final saveBoundaryResult = await roomRepo.saveRoomBoundary(
      homeId: homeId,
      roomId: room.id,
      points: boundaryPoints,
    );
    expect(saveBoundaryResult.isSuccess, isTrue);
    final roomWithBoundary = saveBoundaryResult.valueOrNull!;
    expect(roomWithBoundary.hasBoundary, isTrue);

    // -----------------------------------------------------------------------
    // 3. Create Storage Unit inside Room (generates stable QR identifier)
    // -----------------------------------------------------------------------
    final createStorageResult = await storageRepo.createStorageUnit(
      homeId: homeId,
      roomId: room.id,
      name: 'Sideboard Cabinet',
      type: 'Cabinet',
      capacityItems: 40,
      expectedCategories: const ['Kitchen', 'Household'],
    );
    expect(createStorageResult.isSuccess, isTrue);
    final storageUnit = createStorageResult.valueOrNull!;
    expect(storageUnit.qrId.startsWith('HS-ST-'), isTrue);

    // -----------------------------------------------------------------------
    // 4. Validate QR Payload and Point-in-Polygon containment
    // -----------------------------------------------------------------------
    final qrPayload = QrIdentity(id: storageUnit.qrId).toQrPayload();
    final parseQr = QrIdentity.fromQrPayload(qrPayload);
    expect(parseQr.isSuccess, isTrue);
    expect(parseQr.valueOrNull!.id, storageUnit.qrId);

    // Physical position inside the Dining Hall polygon:
    const storageLat = 37.7755;
    const storageLng = -122.4185;

    final pipResult = spatialService.isPointInBoundary(
      latitude: storageLat,
      longitude: storageLng,
      boundary: roomWithBoundary.boundary!,
    );
    expect(pipResult.isSuccess, isTrue);

    // Register Position
    final registerResult = await storageRepo.registerStoragePosition(
      homeId: homeId,
      storageId: storageUnit.id,
      position: StoragePosition(
        storageId: storageUnit.id,
        latitude: storageLat,
        longitude: storageLng,
        accuracyMetres: 2.0,
        registeredAt: now,
      ),
    );
    expect(registerResult.isSuccess, isTrue);
    expect(registerResult.valueOrNull!.isPositionRegistered, isTrue);

    // -----------------------------------------------------------------------
    // 5. Add Household Item to Storage Unit (No individual QR codes)
    // -----------------------------------------------------------------------
    final addItemResult = await itemRepo.createItem(
      homeId: homeId,
      storageId: storageUnit.id,
      name: 'Porcelain Dinner Set',
      quantity: 12,
      category: 'Kitchen',
      description: '12-piece bone china tableware set',
    );
    expect(addItemResult.isSuccess, isTrue);
    final item = addItemResult.valueOrNull!;
    expect(item.name, 'Porcelain Dinner Set');
    expect(item.quantity, 12);
    expect(item.currentStorageId, storageUnit.id);

    // -----------------------------------------------------------------------
    // 6. Search for Item -> Resolves Full Spatial Hierarchy
    // -----------------------------------------------------------------------
    final searchResult = await searchRepo.searchItems(
      homeId: homeId,
      query: 'Porcelain',
    );
    expect(searchResult.isSuccess, isTrue);
    final results = searchResult.valueOrNull!;
    expect(results.length, 1);
    expect(results.first.item.id, item.id);
    expect(results.first.storageUnit.name, 'Sideboard Cabinet');
    expect(results.first.room.name, 'Dining Hall');

    // -----------------------------------------------------------------------
    // 7. Atomic Item Movement to Another Storage Unit
    // -----------------------------------------------------------------------
    final targetStorage = db.storageUnits.firstWhere((s) => s.name == 'Shelf A');
    final moveResult = await moveRepo.moveItem(
      homeId: homeId,
      itemId: item.id,
      fromStorageId: storageUnit.id,
      toStorageId: targetStorage.id,
      note: 'Moved tableware to study shelf for temporary event',
    );
    expect(moveResult.isSuccess, isTrue);
    final movedItem = moveResult.valueOrNull!;
    expect(movedItem.currentStorageId, targetStorage.id);

    // -----------------------------------------------------------------------
    // 8. Verify Immutable Audit Trail
    // -----------------------------------------------------------------------
    final historyResult = db.movementRecords.where((m) => m.itemId == item.id).toList();
    expect(historyResult.isNotEmpty, isTrue);
    expect(historyResult.first.fromStorageId, storageUnit.id);
    expect(historyResult.first.toStorageId, targetStorage.id);
    expect(historyResult.first.note, contains('temporary event'));
  });
}
