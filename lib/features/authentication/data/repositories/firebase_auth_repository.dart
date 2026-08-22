import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Firebase Authentication implementation of [AuthRepository].
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Stream<UserEntity?> watchAuthState() {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserEntity(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    });
  }

  @override
  Future<Result<UserEntity>> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      return Result.failure(
        AuthFailure(message: 'No user is currently signed in.'),
      );
    }
    return Result.success(
      UserEntity(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      ),
    );
  }

  @override
  Future<Result<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        return Result.failure(
          AuthFailure(message: 'Sign in failed: user object null'),
        );
      }
      return Result.success(
        UserEntity(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          createdAt: user.metadata.creationTime ?? DateTime.now(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AuthFailure(
          message: e.message ?? 'Authentication error',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        return Result.failure(
          AuthFailure(message: 'Registration failed: user object null'),
        );
      }
      await user.updateDisplayName(displayName.trim());
      return Result.success(
        UserEntity(
          id: user.uid,
          email: user.email ?? '',
          displayName: displayName.trim(),
          createdAt: user.metadata.creationTime ?? DateTime.now(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AuthFailure(
          message: e.message ?? 'Registration error',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AuthFailure(message: e.message ?? 'Sign out error', code: e.code),
      );
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }
}
