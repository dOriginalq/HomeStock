import 'package:flutter_test/flutter_test.dart';
import 'package:homestock/features/authentication/data/repositories/mock_auth_repository.dart';
import 'package:homestock/shared/data/mock_database.dart';

void main() {
  late MockDatabase db;
  late MockAuthRepository repo;

  setUp(() {
    db = MockDatabase.instance;
    repo = MockAuthRepository(db: db);
  });

  test('getCurrentUser returns initialized default test user', () async {
    final result = await repo.getCurrentUser();
    expect(result.isSuccess, isTrue);
    final user = result.valueOrNull!;
    expect(user.email, 'alex@homestock.io');
    expect(user.displayName, 'Alex Rivers');
  });

  test('signInWithEmail succeeds for existing user', () async {
    final result = await repo.signInWithEmail(
      email: 'alex@homestock.io',
      password: 'password123',
    );
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull!.displayName, 'Alex Rivers');
  });

  test('registerWithEmail creates and signs in new user', () async {
    final result = await repo.registerWithEmail(
      email: 'researcher@lab.org',
      password: 'securePassword!',
      displayName: 'Dr. Jane Smith',
    );
    expect(result.isSuccess, isTrue);
    final newUser = result.valueOrNull!;
    expect(newUser.email, 'researcher@lab.org');
    expect(newUser.displayName, 'Dr. Jane Smith');

    final current = await repo.getCurrentUser();
    expect(current.valueOrNull!.id, newUser.id);
  });

  test('signOut removes active session', () async {
    await repo.signOut();
    final result = await repo.getCurrentUser();
    expect(result.isFailure, isTrue);
  });
}
