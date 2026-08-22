import '../../../../core/result/result.dart';
import '../entities/storage_position.dart';
import '../entities/storage_unit.dart';

/// Contract for Storage Unit operations.
abstract interface class StorageRepository {
  /// Stream of storage units for a given room.
  Stream<List<StorageUnit>> watchStorageUnitsForRoom({
    required String homeId,
    required String roomId,
  });

  /// Stream of all storage units in a home.
  Stream<List<StorageUnit>> watchAllStorageUnits(String homeId);

  /// Gets single storage unit by internal ID.
  Future<Result<StorageUnit>> getStorageUnit({
    required String homeId,
    required String storageId,
  });

  /// Resolves storage unit by its stable QR ID (e.g. HS-ST-00042).
  Future<Result<StorageUnit>> getStorageUnitByQrId({
    required String homeId,
    required String qrId,
  });

  /// Generates the next sequential unique QR ID for a storage unit.
  Future<Result<String>> generateNextQrId(String homeId);

  /// Creates a new storage unit.
  Future<Result<StorageUnit>> createStorageUnit({
    required String homeId,
    required String roomId,
    required String name,
    required String type,
    String? description,
    int? capacityItems,
    List<String> expectedCategories = const [],
  });

  /// Updates existing storage unit metadata.
  Future<Result<StorageUnit>> updateStorageUnit(StorageUnit storageUnit);

  /// Registers approximate physical GPS position after scanning QR code.
  Future<Result<StorageUnit>> registerStoragePosition({
    required String homeId,
    required String storageId,
    required StoragePosition position,
  });

  /// Deletes storage unit.
  Future<Result<void>> deleteStorageUnit({
    required String homeId,
    required String storageId,
  });
}
