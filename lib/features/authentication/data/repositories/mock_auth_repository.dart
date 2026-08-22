import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/data/mock_database.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({MockDatabase? db}) : _db = db ?? MockDatabase.instance;

  final MockDatabase _db;
  UserEntity? _currentUser;
  bool _isSignedOut = false;

  @override
  UserEntity? get currentUser {
    if (_isSignedOut) return null;
    return _currentUser ?? (_db.users.isNotEmpty ? _db.users.first : null);
  }

  @override
  Future<Result<UserEntity>> getCurrentUser() async {
    final user = currentUser;
    if (user == null) {
      return Result.failure(
        AuthFailure(message: 'No user is currently signed in.'),
      );
    }
    return Result.success(user);
  }

  @override
  Stream<UserEntity?> authStateChanges() async* {
    yield currentUser;
  }

  @override
  Future<Result<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isSignedOut = false;
    final existing = _db.users.where((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    final user = existing.isNotEmpty
        ? existing.first
        : UserEntity(
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
    _isSignedOut = false;
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
    _isSignedOut = false;
    final user = UserEntity(
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
    _isSignedOut = true;
    return Result.success(null);
  }
}
