import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/data/mock_database.dart';
import '../../domain/entities/boundary_point.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/room_boundary.dart';
import '../../domain/repositories/room_repository.dart';

class MockRoomRepository implements RoomRepository {
  MockRoomRepository({MockDatabase? db}) : _db = db ?? MockDatabase.instance;

  final MockDatabase _db;

  @override
  Stream<List<Room>> watchRooms(String homeId) async* {
    yield _db.rooms.where((r) => r.homeId == homeId).toList();
    yield* _db.watchRooms(homeId);
  }

  @override
  Future<Result<List<Room>>> getRooms(String homeId) async {
    final list = _db.rooms.where((r) => r.homeId == homeId).toList();
    return Result.success(list);
  }

  @override
  Future<Result<Room>> getRoom({
    required String homeId,
    required String roomId,
  }) async {
    try {
      final room = _db.rooms.firstWhere(
        (r) => r.id == roomId && r.homeId == homeId,
      );
      return Result.success(room);
    } catch (_) {
      return Result.failure(
        UnexpectedFailure(message: 'Room not found: $roomId in home $homeId'),
      );
    }
  }

  @override
  Future<Result<Room>> createRoom({
    required String homeId,
    required String name,
    String? description,
  }) async {
    final now = DateTime.now();
    final room = Room(
      id: 'room-${now.millisecondsSinceEpoch}',
      homeId: homeId,
      name: name,
      description: description,
      storageUnitCount: 0,
      totalItemCount: 0,
      createdAt: now,
      updatedAt: now,
    );
    _db.rooms.add(room);
    _db.notifyRoomsChanged();
    return Result.success(room);
  }

  @override
  Future<Result<Room>> updateRoom(Room room) async {
    final index = _db.rooms.indexWhere((r) => r.id == room.id);
    if (index == -1) {
      return Result.failure(
        UnexpectedFailure(message: 'Room not found: ${room.id}'),
      );
    }
    _db.rooms[index] = room;
    _db.notifyRoomsChanged();
    return Result.success(room);
  }

  @override
  Future<Result<void>> deleteRoom({
    required String homeId,
    required String roomId,
  }) async {
    _db.rooms.removeWhere((r) => r.id == roomId && r.homeId == homeId);
    _db.notifyRoomsChanged();
    return Result.success(null);
  }

  @override
  Future<Result<Room>> saveRoomBoundary({
    required String homeId,
    required String roomId,
    required List<BoundaryPoint> points,
  }) async {
    final index = _db.rooms.indexWhere(
      (r) => r.id == roomId && r.homeId == homeId,
    );
    if (index == -1) {
      return Result.failure(
        UnexpectedFailure(message: 'Room not found: $roomId'),
      );
    }

    final now = DateTime.now();
    final boundary = RoomBoundary(
      roomId: roomId,
      points: points,
      isComplete: true,
      capturedAt: now,
    );

    final updated = _db.rooms[index].copyWith(
      boundary: boundary,
      updatedAt: now,
    );
    _db.rooms[index] = updated;
    _db.notifyRoomsChanged();
    return Result.success(updated);
  }
}
