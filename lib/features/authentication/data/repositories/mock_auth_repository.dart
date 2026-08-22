import '../../../../core/result/result.dart';
import '../../../../shared/data/mock_database.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({MockDatabase? db}) : _db = db ?? MockDatabase.instance;

  final MockDatabase _db;
  UserEntity? _currentUser;

  @override
  UserEntity? get currentUser => _currentUser ?? (_db.users.isNotEmpty ? _db.users.first : null);

  @override
  Stream<UserEntity?> authStateChanges() async* {
    yield currentUser;
  }

  @override
  Future<Result<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final user = UserEntity(
      id: 'user-${email.hashCode}',
      email: email,
      displayName: email.split('@').first,
      createdAt: DateTime.now(),
    );
    _currentUser = user;
    return Result.success(user);
  }

  @override
  Future<Result<UserEntity>> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final user = UserEntity(
      id: 'user-${email.hashCode}',
      email: email,
      displayName: displayName ?? email.split('@').first,
      createdAt: DateTime.now(),
    );
    _currentUser = user;
    _db.users.add(user);
    return Result.success(user);
  }

  @override
  Future<Result<UserEntity>> signInAnonymously() async {
    const user = UserEntity(
      id: 'guest-001',
      email: 'guest@homestock.io',
      displayName: 'Guest Explorer',
      createdAt: DateTime(2024),
    );
    _currentUser = user;
    return Result.success(user);
  }

  @override
  Future<Result<void>> signOut() async {
    _currentUser = null;
    return Result.success(null);
  }
}
