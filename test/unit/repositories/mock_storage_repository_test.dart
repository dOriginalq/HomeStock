import 'package:flutter_test/flutter_test.dart';
import 'package:homestock/features/storage/data/repositories/mock_storage_repository.dart';
import 'package:homestock/features/storage/domain/entities/storage_position.dart';
import 'package:homestock/shared/data/mock_database.dart';

void main() {
  late MockDatabase db;
  late MockStorageRepository repo;

  setUp(() {
    db = MockDatabase.instance;
    repo = MockStorageRepository(db: db);
  });

  test('getStorageUnitByQrId resolves Shelf A via stable QR identifier', () async {
    final result = await repo.getStorageUnitByQrId(
      homeId: 'home-001',
      qrId: 'HS-ST-00042',
    );
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull!.name, 'Shelf A');
    expect(result.valueOrNull!.type, 'Shelf');
  });

  test('generateNextQrId increments sequence format correctly', () async {
    final nextId = await repo.generateNextQrId('home-001');
    expect(nextId.isSuccess, isTrue);
    expect(nextId.valueOrNull!.startsWith('HS-ST-'), isTrue);
  });

  test('registerStoragePosition records GPS location', () async {
    final create = await repo.createStorageUnit(
      homeId: 'home-001',
      roomId: 'room-bedroom',
      name: 'Nightstand',
      type: 'Drawer',
    );
    final unit = create.valueOrNull!;

    final pos = StoragePosition(
      storageId: unit.id,
      latitude: 37.7749,
      longitude: -122.4192,
      accuracyMetres: 2.1,
      registeredAt: DateTime.now(),
    );

    final updated = await repo.registerStoragePosition(
      homeId: 'home-001',
      storageId: unit.id,
      position: pos,
    );
    expect(updated.isSuccess, isTrue);
    expect(updated.valueOrNull!.isPositionRegistered, isTrue);
    expect(updated.valueOrNull!.position!.latitude, 37.7749);
  });
}
