import 'dart:convert';
import 'dart:io';

import '../../lib/core/services/instrumentation_service.dart';
import '../../lib/core/services/spatial_service.dart';
import '../../lib/features/movement/data/repositories/mock_movement_repository.dart';
import '../../lib/features/qr/domain/services/qr_identity.dart';
import '../../lib/features/rooms/domain/entities/boundary_point.dart';
import '../../lib/features/rooms/domain/entities/room_boundary.dart';
import '../../lib/features/search/data/repositories/mock_search_repository.dart';
import '../../lib/shared/data/mock_database.dart';

void main() async {
  print('🔬 Running HomeStock Research Benchmark Suite...');
  final instrumentation = InstrumentationService(enabled: true);
  final spatialService = const SpatialService();
  final db = MockDatabase.instance;
  final searchRepo = MockSearchRepository(db: db);
  final moveRepo = MockMovementRepository(db: db);

  final now = DateTime.now();
  final bedroomBoundary = RoomBoundary(
    roomId: 'room-01',
    points: [
      BoundaryPoint(id: '1', latitude: 37.7755, longitude: -122.4195, capturedAt: now, index: 0),
      BoundaryPoint(id: '2', latitude: 37.7755, longitude: -122.4184, capturedAt: now, index: 1),
      BoundaryPoint(id: '3', latitude: 37.7745, longitude: -122.4184, capturedAt: now, index: 2),
      BoundaryPoint(id: '4', latitude: 37.7745, longitude: -122.4195, capturedAt: now, index: 3),
    ],
    capturedAt: now,
    isComplete: true,
  );

  // 1. Benchmark: Point-in-Polygon (10,000 iterations)
  await instrumentation.measure(
    name: 'PointInPolygon_10k_Batch',
    action: () async {
      for (int i = 0; i < 10000; i++) {
        spatialService.isPointInBoundary(
          latitude: 37.7750,
          longitude: -122.4190,
          boundary: bedroomBoundary,
        );
      }
    },
    metadata: {'iterations': 10000, 'polygon_vertices': 4},
  );

  // 2. Benchmark: QR Identity Encode & Decode (5,000 iterations)
  await instrumentation.measure(
    name: 'QrEncodeDecode_5k_Batch',
    action: () async {
      for (int i = 0; i < 5000; i++) {
        final id = QrIdentity.generateStorageId(i % 1000);
        final payload = QrIdentity(id: id).toQrPayload();
        QrIdentity.fromQrPayload(payload);
      }
    },
    metadata: {'iterations': 5000},
  );

  // 3. Benchmark: Hierarchical Search (1,000 queries)
  await instrumentation.measure(
    name: 'HierarchicalItemSearch_1k_Batch',
    action: () async {
      final queries = ['Camera', 'Book', 'Cable', 'Coat', 'Jeans'];
      for (int i = 0; i < 1000; i++) {
        final q = queries[i % queries.length];
        await searchRepo.searchItems(homeId: 'home-001', query: q);
      }
    },
    metadata: {'iterations': 1000, 'item_count': db.items.length},
  );

  // 4. Benchmark: Atomic Item Movement Transactions (500 moves)
  await instrumentation.measure(
    name: 'AtomicMovementTransactions_500_Batch',
    action: () async {
      for (int i = 0; i < 500; i++) {
        final fromStorage = (i % 2 == 0) ? 'storage-shelf-a' : 'storage-drawer-1';
        final toStorage = (i % 2 == 0) ? 'storage-drawer-1' : 'storage-shelf-a';
        await moveRepo.moveItem(
          homeId: 'home-001',
          itemId: 'item-002',
          fromStorageId: fromStorage,
          toStorageId: toStorage,
          note: 'Benchmark move iteration $i',
        );
      }
    },
    metadata: {'iterations': 500},
  );

  final results = instrumentation.exportJson();
  final outDir = Directory('experiments/results');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }
  final outFile = File('experiments/results/benchmark_results.json');
  outFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(results));

  print('✅ Benchmark complete! Exported results to ${outFile.path}');
}
