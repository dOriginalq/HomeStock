import 'package:flutter_test/flutter_test.dart';
import 'package:homestock/features/rooms/data/repositories/mock_room_repository.dart';
import 'package:homestock/features/rooms/domain/entities/boundary_point.dart';
import 'package:homestock/shared/data/mock_database.dart';

void main() {
  late MockDatabase db;
  late MockRoomRepository repo;

  setUp(() {
    db = MockDatabase.instance;
    repo = MockRoomRepository(db: db);
  });

  test('getRooms returns all initialized rooms for home', () async {
    final result = await repo.getRooms('home-001');
    expect(result.isSuccess, isTrue);
    final rooms = result.valueOrNull!;
    expect(rooms.any((r) => r.name == 'Bedroom'), isTrue);
    expect(rooms.any((r) => r.name == 'Living Room'), isTrue);
  });

  test('createRoom adds new room to repository', () async {
    final result = await repo.createRoom(
      homeId: 'home-001',
      name: 'Balcony',
      description: 'Outdoor patio balcony',
    );
    expect(result.isSuccess, isTrue);
    final room = result.valueOrNull!;
    expect(room.name, 'Balcony');
    expect(room.storageUnitCount, 0);

    final all = await repo.getRooms('home-001');
    expect(all.valueOrNull!.any((r) => r.name == 'Balcony'), isTrue);
  });

  test('saveRoomBoundary updates room with completed boundary', () async {
    final create = await repo.createRoom(homeId: 'home-001', name: 'Attic');
    final room = create.valueOrNull!;

    final points = [
      BoundaryPoint(id: '1', latitude: 37.0, longitude: -122.0, capturedAt: DateTime.now(), index: 0),
      BoundaryPoint(id: '2', latitude: 37.0, longitude: -121.9, capturedAt: DateTime.now(), index: 1),
      BoundaryPoint(id: '3', latitude: 36.9, longitude: -121.9, capturedAt: DateTime.now(), index: 2),
      BoundaryPoint(id: '4', latitude: 36.9, longitude: -122.0, capturedAt: DateTime.now(), index: 3),
    ];

    final updated = await repo.saveRoomBoundary(
      homeId: 'home-001',
      roomId: room.id,
      points: points,
    );
    expect(updated.isSuccess, isTrue);
    expect(updated.valueOrNull!.hasBoundary, isTrue);
    expect(updated.valueOrNull!.boundary!.pointCount, 4);
  });
}
