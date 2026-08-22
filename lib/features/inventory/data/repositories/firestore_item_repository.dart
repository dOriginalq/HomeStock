import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../models/item_model.dart';

/// Cloud Firestore implementation of [ItemRepository].
class FirestoreItemRepository implements ItemRepository {
  FirestoreItemRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

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
  Stream<List<Item>> watchItemsForStorage({
    required String homeId,
    required String storageId,
  }) {
    return _itemsCol(homeId)
        .where('current_storage_id', isEqualTo: storageId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemModel.fromFirestore(doc).toEntity())
            .toList());
  }

  @override
  Stream<List<Item>> watchAllItems(String homeId) {
    return _itemsCol(homeId).snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ItemModel.fromFirestore(doc).toEntity())
        .toList());
  }

  @override
  Future<Result<Item>> getItem({
    required String homeId,
    required String itemId,
  }) async {
    try {
      final doc = await _itemsCol(homeId).doc(itemId).get();
      if (!doc.exists) {
        return Result.failure(ItemNotFoundFailure(itemId: itemId));
      }
      return Result.success(ItemModel.fromFirestore(doc).toEntity());
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseFailure(message: e.message ?? 'Firestore error', code: e.code));
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Item>> createItem({
    required String homeId,
    required String storageId,
    required String name,
    int quantity = 1,
    String? category,
    String? description,
    String? imageUrl,
    List<String> tags = const [],
  }) async {
    try {
      final now = DateTime.now();
      final docRef = _itemsCol(homeId).doc();
      final item = Item(
        id: docRef.id,
        homeId: homeId,
        currentStorageId: storageId,
        name: name,
        quantity: quantity,
        category: category,
        description: description,
        imageUrl: imageUrl,
        tags: tags,
        createdAt: now,
        updatedAt: now,
      );

      final batch = _firestore.batch();
      batch.set(docRef, ItemModel.fromEntity(item).toFirestore());
      batch.update(_storageCol(homeId).doc(storageId), {
        'item_count': FieldValue.increment(quantity),
        'updated_at': Timestamp.fromDate(now),
      });

      await batch.commit();
      return Result.success(item);
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseFailure(message: e.message ?? 'Firestore error', code: e.code));
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Item>> updateItem(Item item) async {
    try {
      final updated = item.copyWith(updatedAt: DateTime.now());
      await _itemsCol(item.homeId)
          .doc(item.id)
          .update(ItemModel.fromEntity(updated).toFirestore());
      return Result.success(updated);
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseFailure(message: e.message ?? 'Firestore error', code: e.code));
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteItem({
    required String homeId,
    required String itemId,
  }) async {
    try {
      final doc = await _itemsCol(homeId).doc(itemId).get();
      if (!doc.exists) {
        return Result.success(null);
      }
      final item = ItemModel.fromFirestore(doc);

      final batch = _firestore.batch();
      batch.delete(_itemsCol(homeId).doc(itemId));
      batch.update(_storageCol(homeId).doc(item.currentStorageId), {
        'item_count': FieldValue.increment(-item.quantity),
      });

      await batch.commit();
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseFailure(message: e.message ?? 'Firestore error', code: e.code));
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }
}
