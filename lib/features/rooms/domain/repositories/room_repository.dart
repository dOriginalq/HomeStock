import '../../../../core/result/result.dart';
import '../entities/boundary_point.dart';
import '../entities/room.dart';
import '../entities/room_boundary.dart';

/// Contract for Room and Room Boundary operations.
abstract interface class RoomRepository {
  /// Stream of rooms in a specific home.
  Stream<List<Room>> watchRooms(String homeId);

  /// Gets all rooms in a specific home.
  Future<Result<List<Room>>> getRooms(String homeId);

  /// Gets single room by ID.
  Future<Result<Room>> getRoom({required String homeId, required String roomId});

  /// Creates a new room without boundary.
  Future<Result<Room>> createRoom({
    required String homeId,
    required String name,
    String? description,
  });

  /// Updates room metadata.
  Future<Result<Room>> updateRoom(Room room);

  /// Deletes room.
  Future<Result<void>> deleteRoom({required String homeId, required String roomId});

  /// Saves / completes a room boundary.
  Future<Result<Room>> saveRoomBoundary({
    required String homeId,
    required String roomId,
    required List<BoundaryPoint> points,
  });
}
