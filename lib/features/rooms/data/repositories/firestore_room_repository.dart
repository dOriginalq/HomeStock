import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/boundary_point.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/room_boundary.dart';
import '../../domain/repositories/room_repository.dart';
import '../models/room_model.dart';

/// Cloud Firestore implementation of [RoomRepository].
class FirestoreRoomRepository implements RoomRepository {
  FirestoreRoomRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _roomsCol(String homeId) =>
      _firestore
          .collection(AppConstants.colHomes)
          .doc(homeId)
          .collection(AppConstants.colRooms);

  @override
  Stream<List<Room>> watchRooms(String homeId) {
    return _roomsCol(homeId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoomModel.fromFirestore(doc).toEntity())
            .toList());
  }

  @override
  Future<Result<List<Room>>> getRooms(String homeId) async {
    try {
      final snapshot = await _roomsCol(homeId).orderBy('name').get();
      final list = snapshot.docs
          .map((doc) => RoomModel.fromFirestore(doc).toEntity())
          .toList();
      return Result.success(list);
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseFailure(message: e.message ?? 'Firestore error', code: e.code));
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Room>> getRoom({
    required String homeId,
    required String roomId,
  }) async {
    try {
      final doc = await _roomsCol(homeId).doc(roomId).get();
      if (!doc.exists) {
        return Result.failure(UnexpectedFailure(message: 'Room not found: $roomId'));
      }
      return Result.success(RoomModel.fromFirestore(doc).toEntity());
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseFailure(message: e.message ?? 'Firestore error', code: e.code));
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Room>> createRoom({
    required String homeId,
    required String name,
    String? description,
  }) async {
    try {
      final now = DateTime.now();
      final docRef = _roomsCol(homeId).doc();
      final room = Room(
        id: docRef.id,
        homeId: homeId,
        name: name,
        description: description,
        storageUnitCount: 0,
        totalItemCount: 0,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(RoomModel.fromEntity(room).toFirestore());
      return Result.success(room);
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseFailure(message: e.message ?? 'Firestore error', code: e.code));
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Room>> updateRoom(Room room) async {
    try {
      final updated = room.copyWith(updatedAt: DateTime.now());
      await _roomsCol(room.homeId)
          .doc(room.id)
          .update(RoomModel.fromEntity(updated).toFirestore());
      return Result.success(updated);
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseFailure(message: e.message ?? 'Firestore error', code: e.code));
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteRoom({
    required String homeId,
    required String roomId,
  }) async {
    try {
      await _roomsCol(homeId).doc(roomId).delete();
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseFailure(message: e.message ?? 'Firestore error', code: e.code));
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Room>> saveRoomBoundary({
    required String homeId,
    required String roomId,
    required List<BoundaryPoint> points,
  }) async {
    try {
      final now = DateTime.now();
      final boundary = RoomBoundary(
        roomId: roomId,
        points: points,
        isComplete: true,
        capturedAt: now,
      );

      final docRef = _roomsCol(homeId).doc(roomId);
      await docRef.update({
        'boundary': {
          'is_complete': true,
          'captured_at': Timestamp.fromDate(now),
          'points': points
              .map((p) => {
                    'id': p.id,
                    'latitude': p.latitude,
                    'longitude': p.longitude,
                    if (p.accuracyMetres != null)
                      'accuracy_metres': p.accuracyMetres,
                    'index': p.index,
                    'captured_at': Timestamp.fromDate(p.capturedAt),
                  })
              .toList(),
        },
        'updated_at': Timestamp.fromDate(now),
      });

      final updatedDoc = await docRef.get();
      return Result.success(RoomModel.fromFirestore(updatedDoc).toEntity());
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseFailure(message: e.message ?? 'Firestore error', code: e.code));
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }
}
