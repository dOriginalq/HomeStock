import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/data/mock_database.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/repositories/home_repository.dart';

class MockHomeRepository implements HomeRepository {
  MockHomeRepository({MockDatabase? db}) : _db = db ?? MockDatabase.instance;

  final MockDatabase _db;

  @override
  Stream<List<HomeEntity>> watchHomes(String userId) async* {
    yield _db.homes.where((h) => h.ownerId == userId).toList();
  }

  @override
  Future<Result<HomeEntity>> getHome(String homeId) async {
    try {
      final home = _db.homes.firstWhere((h) => h.id == homeId);
      return Result.success(home);
    } catch (_) {
      return Result.failure(UnexpectedFailure(message: 'Home not found: $homeId'));
    }
  }

  @override
  Future<Result<HomeEntity>> createHome({
    required String ownerId,
    required String name,
    String? address,
  }) async {
    final now = DateTime.now();
    final home = HomeEntity(
      id: 'home-${now.millisecondsSinceEpoch}',
      ownerId: ownerId,
      name: name,
      address: address,
      createdAt: now,
      updatedAt: now,
    );
    _db.homes.add(home);
    return Result.success(home);
  }

  @override
  Future<Result<HomeEntity>> updateHome(HomeEntity home) async {
    final index = _db.homes.indexWhere((h) => h.id == home.id);
    if (index == -1) {
      return Result.failure(UnexpectedFailure(message: 'Home not found: ${home.id}'));
    }
    _db.homes[index] = home;
    return Result.success(home);
  }

  @override
  Future<Result<void>> deleteHome(String homeId) async {
    _db.homes.removeWhere((h) => h.id == homeId);
    return Result.success(null);
  }
}
