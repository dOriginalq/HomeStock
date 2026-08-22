import '../../../../core/result/result.dart';
import '../entities/home_entity.dart';

/// Contract for Home CRUD operations.
abstract interface class HomeRepository {
  /// Stream of homes owned by [userId].
  Stream<List<HomeEntity>> watchHomes(String userId);

  /// Gets single home by ID.
  Future<Result<HomeEntity>> getHome(String homeId);

  /// Creates a new home for user.
  Future<Result<HomeEntity>> createHome({
    required String ownerId,
    required String name,
    String? address,
  });

  /// Updates existing home.
  Future<Result<HomeEntity>> updateHome(HomeEntity home);

  /// Deletes a home and cascades associated structure.
  Future<Result<void>> deleteHome(String homeId);
}
