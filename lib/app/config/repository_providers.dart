import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/authentication/data/repositories/firebase_auth_repository.dart';
import '../../features/authentication/data/repositories/mock_auth_repository.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/inventory/data/repositories/firestore_item_repository.dart';
import '../../features/inventory/data/repositories/mock_item_repository.dart';
import '../../features/inventory/domain/repositories/item_repository.dart';
import '../../features/movement/data/repositories/firestore_movement_repository.dart';
import '../../features/movement/data/repositories/mock_movement_repository.dart';
import '../../features/movement/domain/repositories/movement_repository.dart';
import '../../features/rooms/data/repositories/firestore_room_repository.dart';
import '../../features/rooms/data/repositories/mock_room_repository.dart';
import '../../features/rooms/domain/repositories/room_repository.dart';
import '../../features/search/data/repositories/mock_search_repository.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/storage/data/repositories/firestore_storage_repository.dart';
import '../../features/storage/data/repositories/mock_storage_repository.dart';
import '../../features/storage/domain/repositories/storage_repository.dart';
import '../../shared/data/mock_database.dart';

/// Global configuration flag: Set to true when connected to live Firebase.
/// Defaults to false (in-memory mock mode) for rapid testing and prototype execution.
final useFirebaseBackendProvider = StateProvider<bool>((ref) => false);

/// Provides the active [RoomRepository].
final appRoomRepositoryProvider = Provider<RoomRepository>((ref) {
  final useFirebase = ref.watch(useFirebaseBackendProvider);
  if (useFirebase) {
    return FirestoreRoomRepository();
  }
  return MockRoomRepository(db: MockDatabase.instance);
});

/// Provides the active [StorageRepository].
final appStorageRepositoryProvider = Provider<StorageRepository>((ref) {
  final useFirebase = ref.watch(useFirebaseBackendProvider);
  if (useFirebase) {
    return FirestoreStorageRepository();
  }
  return MockStorageRepository(db: MockDatabase.instance);
});

/// Provides the active [ItemRepository].
final appItemRepositoryProvider = Provider<ItemRepository>((ref) {
  final useFirebase = ref.watch(useFirebaseBackendProvider);
  if (useFirebase) {
    return FirestoreItemRepository();
  }
  return MockItemRepository(db: MockDatabase.instance);
});

/// Provides the active [MovementRepository].
final appMovementRepositoryProvider = Provider<MovementRepository>((ref) {
  final useFirebase = ref.watch(useFirebaseBackendProvider);
  if (useFirebase) {
    return FirestoreMovementRepository();
  }
  return MockMovementRepository(db: MockDatabase.instance);
});

/// Provides the active [SearchRepository].
final appSearchRepositoryProvider = Provider<SearchRepository>((ref) {
  return MockSearchRepository(db: MockDatabase.instance);
});

/// Provides the active [AuthRepository].
final appAuthRepositoryProvider = Provider<AuthRepository>((ref) {
  final useFirebase = ref.watch(useFirebaseBackendProvider);
  if (useFirebase) {
    return FirebaseAuthRepository();
  }
  return MockAuthRepository(db: MockDatabase.instance);
});
