import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../inventory/domain/entities/item.dart';
import '../entities/movement_record.dart';
import '../domain/repositories/movement_repository.dart';

/// Cloud Firestore implementation of [MovementRepository].
///
/// Uses Firestore ACID transactions to ensure that item location updates,
/// origin storage unit count decrements, destination storage unit count increments,
/// and audit log creation NEVER become inconsistent.
class FirestoreMovementRepository implements MovementRepository {
  FirestoreMovementRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _movementCol(String homeId) =>
      _firestore
          .collection(AppConstants.colHomes)
          .doc(homeId)
          .collection(AppConstants.colMovementRecords);

  CollectionReference<Map<String, dynamic>> _itemsCol(String homeId) =>
      _firestore
          .collection(AppConstants.colHomes)
          .doc(homeId)
          .collection(AppConstants.colItems);

  CollectionReference<Map<String, dynamic>> _storageCol(String homeId) =>
      _firestore
          .collection(AppConstants.colHomes)
          .doc(homeId)
          .collection(AppConstants.colStorageUnits);

  @override
  Stream<List<MovementRecord>> watchMovementHistory(String homeId) {
    return _movementCol(homeId)
        .orderBy('moved_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return MovementRecord(
                id: doc.id,
                itemId: data['item_id'] as String? ?? '',
                homeId: data['home_id'] as String? ?? homeId,
                fromStorageId: data['from_storage_id'] as String? ?? '',
                toStorageId: data['to_storage_id'] as String? ?? '',
                fromRoomId: data['from_room_id'] as String?,
                toRoomId: data['to_room_id'] as String?,
                note: data['note'] as String?,
                movedAt: (data['moved_at'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
              );
            }).toList());
  }

  @override
  Stream<List<MovementRecord>> watchItemHistory({
    required String homeId,
    required String itemId,
  }) {
    return _movementCol(homeId)
        .where('item_id', isEqualTo: itemId)
        .orderBy('moved_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return MovementRecord(
                id: doc.id,
                itemId: itemId,
                homeId: homeId,
                fromStorageId: data['from_storage_id'] as String? ?? '',
                toStorageId: data['to_storage_id'] as String? ?? '',
                fromRoomId: data['from_room_id'] as String?,
                toRoomId: data['to_room_id'] as String?,
                note: data['note'] as String?,
                movedAt: (data['moved_at'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
              );
            }).toList());
  }

  @override
  Future<Result<Item>> moveItem({
    required String homeId,
    required String itemId,
    required String fromStorageId,
    required String toStorageId,
    String? fromRoomId,
    String? toRoomId,
    String? note,
  }) async {
    try {
      final now = DateTime.now();
      final itemRef = _itemsCol(homeId).doc(itemId);
      final fromStorageRef = _storageCol(homeId).doc(fromStorageId);
      final toStorageRef = _storageCol(homeId).doc(toStorageId);
      final movementDocRef = _movementCol(homeId).doc();

      final updatedItem = await _firestore.runTransaction<Item>((tx) async {
        // 1. Read item doc
        final itemSnap = await tx.get(itemRef);
        if (!itemSnap.exists) {
          throw Exception('Item $itemId not found.');
        }

        // 2. Read destination storage doc
        final toStorageSnap = await tx.get(toStorageRef);
        if (!toStorageSnap.exists) {
          throw Exception('Destination storage unit $toStorageId not found.');
        }

        final itemData = itemSnap.data()!;
        final quantity = (itemData['quantity'] as num?)?.toInt() ?? 1;

        // 3. Update item location
        tx.update(itemRef, {
          'current_storage_id': toStorageId,
          'updated_at': Timestamp.fromDate(now),
        });

        // 4. Update origin and destination storage counts
        tx.update(fromStorageRef, {
          'item_count': FieldValue.increment(-quantity),
          'updated_at': Timestamp.fromDate(now),
        });
        tx.update(toStorageRef, {
          'item_count': FieldValue.increment(quantity),
          'updated_at': Timestamp.fromDate(now),
        });

        // 5. Append immutable audit record
        tx.set(movementDocRef, {
          'home_id': homeId,
          'item_id': itemId,
          'from_storage_id': fromStorageId,
          'to_storage_id': toStorageId,
          if (fromRoomId != null) 'from_room_id': fromRoomId,
          if (toRoomId != null) 'to_room_id': toRoomId,
          if (note != null) 'note': note,
          'moved_at': Timestamp.fromDate(now),
        });

        return Item(
          id: itemId,
          homeId: homeId,
          currentStorageId: toStorageId,
          name: itemData['name'] as String? ?? '',
          quantity: quantity,
          category: itemData['category'] as String?,
          description: itemData['description'] as String?,
          imageUrl: itemData['image_url'] as String?,
          createdAt:
              (itemData['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: now,
        );
      });

      return Result.success(updatedItem);
    } on FirebaseException catch (e) {
      return Result.failure(
        MovementTransactionFailure(
          message: 'Movement transaction failed: ${e.message}',
        ),
      );
    } catch (e) {
      return Result.failure(
        MovementTransactionFailure(message: e.toString()),
      );
    }
  }
}
