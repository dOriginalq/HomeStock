import 'dart:async';

import '../../features/authentication/domain/entities/user_entity.dart';
import '../../features/home/domain/entities/home_entity.dart';
import '../../features/inventory/domain/entities/item.dart';
import '../../features/movement/domain/entities/movement_record.dart';
import '../../features/rooms/domain/entities/boundary_point.dart';
import '../../features/rooms/domain/entities/room.dart';
import '../../features/rooms/domain/entities/room_boundary.dart';
import '../../features/storage/domain/entities/storage_position.dart';
import '../../features/storage/domain/entities/storage_unit.dart';

/// In-memory reactive database singleton used for rapid local development,
/// testing, and offline prototype execution.
///
/// Prepopulated with realistic residential data matching the HomeStock UI reference.
class MockDatabase {
  MockDatabase._() {
    _initializeData();
  }

  static final MockDatabase instance = MockDatabase._();

  // Streams / Controllers for reactive UI updates
  final _roomsController = StreamController<List<Room>>.broadcast();
  final _storageController = StreamController<List<StorageUnit>>.broadcast();
  final _itemsController = StreamController<List<Item>>.broadcast();
  final _movementController = StreamController<List<MovementRecord>>.broadcast();

  // Storage
  final List<UserEntity> users = [];
  final List<HomeEntity> homes = [];
  final List<Room> rooms = [];
  final List<StorageUnit> storageUnits = [];
  final List<Item> items = [];
  final List<MovementRecord> movementRecords = [];

  int _storageIdCounter = 42;

  Stream<List<Room>> watchRooms(String homeId) => _roomsController.stream;
  Stream<List<StorageUnit>> watchStorageUnits() => _storageController.stream;
  Stream<List<Item>> watchItems() => _itemsController.stream;
  Stream<List<MovementRecord>> watchMovement() => _movementController.stream;

  void notifyRoomsChanged() => _roomsController.add(List.unmodifiable(rooms));
  void notifyStorageChanged() =>
      _storageController.add(List.unmodifiable(storageUnits));
  void notifyItemsChanged() => _itemsController.add(List.unmodifiable(items));
  void notifyMovementChanged() =>
      _movementController.add(List.unmodifiable(movementRecords));

  String nextStorageQrId() {
    _storageIdCounter++;
    return 'HS-ST-${_storageIdCounter.toString().padLeft(5, '0')}';
  }

  void _initializeData() {
    final now = DateTime.now();

    // 1. Current Test User
    const currentUser = UserEntity(
      id: 'user-001',
      email: 'alex@homestock.io',
      displayName: 'Alex Rivers',
      createdAt: DateTime(2024, 1, 1),
    );
    users.add(currentUser);

    // 2. Default Home
    final defaultHome = HomeEntity(
      id: 'home-001',
      ownerId: currentUser.id,
      name: 'Oakwood Residence',
      address: '742 Evergreen Terrace',
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now,
    );
    homes.add(defaultHome);

    // 3. Bedroom Boundary Polygon (5 points matching reference UI)
    // Points forming the clean room polygon:
    final bedroomBoundaryPoints = [
      BoundaryPoint(
        id: 'pt-1',
        latitude: 37.7755,
        longitude: -122.4195,
        capturedAt: now.subtract(const Duration(days: 10)),
        accuracyMetres: 1.8,
        index: 0,
      ),
      BoundaryPoint(
        id: 'pt-2',
        latitude: 37.7755,
        longitude: -122.4184,
        capturedAt: now.subtract(const Duration(days: 10)),
        accuracyMetres: 1.9,
        index: 1,
      ),
      BoundaryPoint(
        id: 'pt-3',
        latitude: 37.7745,
        longitude: -122.4184,
        capturedAt: now.subtract(const Duration(days: 10)),
        accuracyMetres: 2.1,
        index: 2,
      ),
      BoundaryPoint(
        id: 'pt-4',
        latitude: 37.7745,
        longitude: -122.4190,
        capturedAt: now.subtract(const Duration(days: 10)),
        accuracyMetres: 2.0,
        index: 3,
      ),
      BoundaryPoint(
        id: 'pt-5',
        latitude: 37.7745,
        longitude: -122.4195,
        capturedAt: now.subtract(const Duration(days: 10)),
        accuracyMetres: 1.7,
        index: 4,
      ),
    ];

    final bedroomBoundary = RoomBoundary(
      roomId: 'room-bedroom',
      points: bedroomBoundaryPoints,
      capturedAt: now.subtract(const Duration(days: 10)),
      isComplete: true,
    );

    // 4. Rooms
    final bedroom = Room(
      id: 'room-bedroom',
      homeId: defaultHome.id,
      name: 'Bedroom',
      description: 'Primary master bedroom on 2nd floor',
      boundary: bedroomBoundary,
      storageUnitCount: 3,
      totalItemCount: 12,
      createdAt: now.subtract(const Duration(days: 10)),
      updatedAt: now,
    );

    final livingRoom = Room(
      id: 'room-living',
      homeId: defaultHome.id,
      name: 'Living Room',
      description: 'Main living area with media console',
      storageUnitCount: 2,
      totalItemCount: 15,
      createdAt: now.subtract(const Duration(days: 9)),
      updatedAt: now,
    );

    final studyRoom = Room(
      id: 'room-study',
      homeId: defaultHome.id,
      name: 'Study Room',
      description: 'Home office and library',
      storageUnitCount: 4,
      totalItemCount: 28,
      createdAt: now.subtract(const Duration(days: 8)),
      updatedAt: now,
    );

    rooms.addAll([bedroom, livingRoom, studyRoom]);

    // 5. Storage Units in Bedroom (Matching UI Screenshot)
    final shelfA = StorageUnit(
      id: 'storage-shelf-a',
      homeId: defaultHome.id,
      roomId: bedroom.id,
      qrId: 'HS-ST-00042',
      name: 'Shelf A',
      type: 'Shelf',
      description: 'Floating wooden wall shelf above desk',
      capacityItems: 50,
      expectedCategories: const ['Books', 'Documents', 'Electronics'],
      position: StoragePosition(
        storageId: 'storage-shelf-a',
        latitude: 37.7752,
        longitude: -122.4190,
        accuracyMetres: 2.2,
        registeredAt: now.subtract(const Duration(days: 5)),
      ),
      itemCount: 5,
      isPositionRegistered: true,
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now,
    );

    final drawer1 = StorageUnit(
      id: 'storage-drawer-1',
      homeId: defaultHome.id,
      roomId: bedroom.id,
      qrId: 'HS-ST-00043',
      name: 'Drawer 1',
      type: 'Drawer',
      description: 'Top drawer of bedside nightstand',
      capacityItems: 20,
      expectedCategories: const ['Electronics', 'Clothing'],
      position: StoragePosition(
        storageId: 'storage-drawer-1',
        latitude: 37.7747,
        longitude: -122.4194,
        accuracyMetres: 2.5,
        registeredAt: now.subtract(const Duration(days: 4)),
      ),
      itemCount: 3,
      isPositionRegistered: true,
      createdAt: now.subtract(const Duration(days: 4)),
      updatedAt: now,
    );

    final wardrobe = StorageUnit(
      id: 'storage-wardrobe',
      homeId: defaultHome.id,
      roomId: bedroom.id,
      qrId: 'HS-ST-00044',
      name: 'Wardrobe',
      type: 'Wardrobe',
      description: 'Double-door wooden wardrobe closet',
      capacityItems: 100,
      expectedCategories: const ['Clothing'],
      position: StoragePosition(
        storageId: 'storage-wardrobe',
        latitude: 37.7748,
        longitude: -122.4186,
        accuracyMetres: 2.0,
        registeredAt: now.subtract(const Duration(days: 3)),
      ),
      itemCount: 4,
      isPositionRegistered: true,
      createdAt: now.subtract(const Duration(days: 3)),
      updatedAt: now,
    );

    storageUnits.addAll([shelfA, drawer1, wardrobe]);

    // 6. Items inside Storage Units
    items.addAll([
      // Shelf A (5 items)
      Item(
        id: 'item-001',
        homeId: defaultHome.id,
        currentStorageId: shelfA.id,
        name: 'Data Structures & Algorithms Book',
        category: 'Books',
        quantity: 1,
        description: 'Hardcover university textbook',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
      ),
      Item(
        id: 'item-002',
        homeId: defaultHome.id,
        currentStorageId: shelfA.id,
        name: 'Digital SLR Camera',
        category: 'Electronics',
        quantity: 1,
        description: 'Canon EOS Rebel with 50mm lens',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
      ),
      Item(
        id: 'item-003',
        homeId: defaultHome.id,
        currentStorageId: shelfA.id,
        name: 'HDMI 2.1 Ultra High Speed Cable',
        category: 'Electronics',
        quantity: 2,
        description: 'Braided 2m 4K@120Hz cable',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
      ),
      Item(
        id: 'item-004',
        homeId: defaultHome.id,
        currentStorageId: shelfA.id,
        name: 'Grid Moleskine Notebook',
        category: 'Documents',
        quantity: 1,
        description: 'Black pocket journal',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now,
      ),
      Item(
        id: 'item-005',
        homeId: defaultHome.id,
        currentStorageId: shelfA.id,
        name: 'Passport & Travel Documents Folder',
        category: 'Documents',
        quantity: 1,
        description: 'Leather organizer with international documents',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now,
      ),

      // Drawer 1 (3 items)
      Item(
        id: 'item-006',
        homeId: defaultHome.id,
        currentStorageId: drawer1.id,
        name: '65W USB-C GaN Charger',
        category: 'Electronics',
        quantity: 1,
        description: 'Multi-port travel adapter',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now,
      ),
      Item(
        id: 'item-007',
        homeId: defaultHome.id,
        currentStorageId: drawer1.id,
        name: 'Noise Cancelling Earbuds',
        category: 'Electronics',
        quantity: 1,
        description: 'Wireless earbuds in charging case',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now,
      ),
      Item(
        id: 'item-008',
        homeId: defaultHome.id,
        currentStorageId: drawer1.id,
        name: 'Reading Glasses & Microfiber Cloth',
        category: 'Household',
        quantity: 1,
        description: '+1.50 diopter frame in hard case',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
      ),

      // Wardrobe (4 items)
      Item(
        id: 'item-009',
        homeId: defaultHome.id,
        currentStorageId: wardrobe.id,
        name: 'Wool Winter Coat',
        category: 'Clothing',
        quantity: 1,
        description: 'Charcoal grey overcoat',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
      ),
      Item(
        id: 'item-010',
        homeId: defaultHome.id,
        currentStorageId: wardrobe.id,
        name: 'Formal Navy Suit',
        category: 'Clothing',
        quantity: 1,
        description: 'Tailored 2-piece wool suit on garment hanger',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
      ),
      Item(
        id: 'item-011',
        homeId: defaultHome.id,
        currentStorageId: wardrobe.id,
        name: 'Cotton Oxford Button-Down Shirts',
        category: 'Clothing',
        quantity: 5,
        description: 'Assorted white and light blue shirts',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      ),
      Item(
        id: 'item-012',
        homeId: defaultHome.id,
        currentStorageId: wardrobe.id,
        name: 'Denim Jeans',
        category: 'Clothing',
        quantity: 3,
        description: 'Slim straight fit dark wash jeans',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      ),
    ]);

    // 7. Movement History Records
    movementRecords.add(
      MovementRecord(
        id: 'mov-001',
        itemId: 'item-002',
        homeId: defaultHome.id,
        fromStorageId: 'storage-study-cabinet',
        toStorageId: shelfA.id,
        fromRoomId: studyRoom.id,
        toRoomId: bedroom.id,
        note: 'Moved camera to bedroom shelf for upcoming trip packing',
        movedAt: now.subtract(const Duration(days: 1)),
      ),
    );
  }
}
