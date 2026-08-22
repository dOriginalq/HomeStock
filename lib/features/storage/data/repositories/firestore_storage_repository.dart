import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/storage_position.dart';
import '../../domain/entities/storage_unit.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../qr/domain/services/qr_identity.dart';
import '../models/storage_model.dart';

/// Cloud Firestore implementation of [StorageRepository].
class FirestoreStorageRepository implements StorageRepository {
  FirestoreStorageRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _storageCol(String homeId) =>
      _firestore
          .collection(AppConstants.colHomes)
          .doc(homeId)
          .collection(AppConstants.colStorageUnits);

  @override
  Stream<List<StorageUnit>> watchStorageUnitsForRoom({
    required String homeId,
    required String roomId,
  }) {
    return _storageCol(homeId)
        .where('room_id', isEqualTo: roomId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StorageUnitModel.fromFirestore(doc).toEntity())
            .toList());
  }

  @override
  Stream<List<StorageUnit>> watchAllStorageUnits(String homeId) {
    return _storageCol(homeId).snapshots().map((snapshot) => snapshot.docs
        .map((doc) => StorageUnitModel.fromFirestore(doc).toEntity())
        .toList());
  }

  @override
  Future<Result<StorageUnit>> getStorageUnit({
    required String homeId,
    required String storageId,
  }) async {
    try {
      final doc = await _storageCol(homeId).doc(storageId).get();
      if (!doc.exists) {
        return Result.failure(StorageNotFoundFailure(storageId: storageId));
      }
      return Result.success(StorageUnitModel.fromFirestore(doc).toEntity());
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseFailure(message: e.message ?? 'Firestore error', code: e.code));
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<StorageUnit>> getStorageUnitByQrId({
    required String homeId,
    required String qrId,
  }) async {
    try {
      final query = await _storageCol(homeId)
          .where('qr_id', isEqualTo: qrId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return Result.failure(StorageNotFoundFailure(storageId: qrId));
      }
      return Result.success(
        StorageUnitModel.fromFirestore(query.docs.first).toEntity(),
      );
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseFailure(message: e.message ?? 'Firestore error', code: e.code));
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<String>> generateNextQrId(String homeId) async {
    try {
      final counterRef = _firestore
          .collection(AppConstants.colHomes)
          .doc(homeId)
          .collection(AppConstants.colStorageUnits)
          .doc(AppConstants.docIdCounter);

      final nextNumber = await _firestore.runTransaction<int>((tx) async {
        final doc = await tx.get(counterRef);
        int current = 0;
        if (doc.exists) {
          current = (doc.data()?[AppConstants.counterFieldNextId] as num?)?.toInt() ?? 0;
        }
        final next = current + 1;
        tx.set(counterRef, {AppConstants.counterFieldNextId: next}, SetOptions(merge: true));
        return next;
      });

      return Result.success(QrIdentity.generateStorageId(nextNumber));
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseFailure(message: e.message ?? 'Firestore error', code: e.code));
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<StorageUnit>> createStorageUnit({
    required String homeId,
    required String roomId,
    required String name,
    required String type,
    String? description,
    int? capacityItems,
    List<String> expectedCategories = const [],
  }) async {
    try {
      final qrIdResult = await generateNextQrId(homeId);
      final qrId = qrIdResult.when(
        success: (id) => id,
        failure: (_) => 'HS-ST-${DateTime.now().millisecondsSinceEpoch % 100000}',
      );

      final now = DateTime.now();
      final docRef = _storageCol(homeId).doc();
      final storageUnit = StorageUnit(
        id: docRef.id,
        homeId: homeId,
        roomId: roomId,
        qrId: qrId,
        name: name,
        type: type,
        description: description,
        capacityItems: capacityItems,
        expectedCategories: expectedCategories,
        itemCount: 0,
        isPositionRegistered: false,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(StorageUnitModel.fromEntity(storageUnit).toFirestore());
      return Result.success(storageUnit);
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseFailure(message: e.message ?? 'Firestore error', code: e.code));
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<StorageUnit>> updateStorageUnit(StorageUnit storageUnit) async {
    try {
      final updated = storageUnit.copyWith(updatedAt: DateTime.now());
      await _storageCol(storageUnit.homeId)
          .doc(storageUnit.id)
          .update(StorageUnitModel.fromEntity(updated).toFirestore());
      return Result.success(updated);
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseFailure(message: e.message ?? 'Firestore error', code: e.code));
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<StorageUnit>> registerStoragePosition({
    required String homeId,
    required String storageId,
    required StoragePosition position,
  }) async {
    try {
      final now = DateTime.now();
      final docRef = _storageCol(homeId).doc(storageId);
      await docRef.update({
        'position': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          if (position.accuracyMetres != null)
            'accuracy_metres': position.accuracyMetres,
          'registered_at': Timestamp.fromDate(position.registeredAt),
        },
        'is_position_registered': true,
        'updated_at': Timestamp.fromDate(now),
      });

      final updatedDoc = await docRef.get();
      return Result.success(
        StorageUnitModel.fromFirestore(updatedDoc).toEntity(),
      );
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseFailure(message: e.message ?? 'Firestore error', code: e.code));
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteStorageUnit({
    required String homeId,
    required String storageId,
  }) async {
    try {
      await _storageCol(homeId).doc(storageId).delete();
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseFailure(message: e.message ?? 'Firestore error', code: e.code));
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }
}
