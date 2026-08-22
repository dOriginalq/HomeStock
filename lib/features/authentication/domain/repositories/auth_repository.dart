import '../../../../core/result/result.dart';
import '../entities/user_entity.dart';

/// Contract for authentication data operations.
abstract interface class AuthRepository {
  /// Stream of current auth state. Emits null when logged out.
  Stream<UserEntity?> authStateChanges();

  /// Gets current authenticated user or null.
  UserEntity? get currentUser;

  /// Signs in using email and password.
  Future<Result<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Registers a new user with email and password.
  Future<Result<UserEntity>> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Signs in anonymously (useful for development and quick prototype testing).
  Future<Result<UserEntity>> signInAnonymously();

  /// Signs out current user.
  Future<Result<void>> signOut();
}
