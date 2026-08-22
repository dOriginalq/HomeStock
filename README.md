# HomeStock 🏠📦

**HomeStock** is a spatial residential inventory management research prototype built in Flutter. It digitally represents the physical storage structure of a home using GPS-derived room boundaries, QR-identified storage units, and manual item registration.

![HomeStock Banner](assets/images/homestock_preview.png)

---

## 🔑 Core Concepts & Invariants

```text
User  →  Home  →  Rooms  →  Room Boundaries (GPS Polygon)
                 └── Storage Units (Stable QR Identity + Physical Position)
                        └── Items (Manual Registration)
                               └── Movement Records (Audit Trail)
```

1. **Individual Household Items DO NOT receive QR codes**: Users register items manually inside physical storage units.
2. **QR codes identify physical storage units**: Every shelf, drawer, or wardrobe has a unique stable identifier (`HS-ST-NNNNN`).
3. **Rooms possess GPS polygon boundaries**: Captured on demand by physically walking to room corners.
4. **Zero Continuous GPS Tracking**: GPS is accessed exclusively on user action (marking boundary or registering storage unit position).
5. **Point-In-Polygon Validation**: Storage positions are mathematically validated to fall inside the room boundary polygon.

---

## 📱 Visual Reference & First-Page Implementation

The initial dashboard strictly implements the clean design specification:
- **Header**: HomeStock branding + Quick QR Scanner shortcut
- **Room Selector Card**: Selected room dropdown + Storage & item count summary + `[+ Add Room]` action
- **Spatial Room Map**: Clean light-green polygon with green boundary line, corner vertex handles, zoom/pan controls, and interactive storage markers with badge icons and item count tags
- **Quick Actions Bar**: `Scan QR`, `Add Storage`, `Add Item`, `More`
- **Storage Units List**: Card list with custom silhouette icons, count badges, and item drill-down
- **Bottom Navigation**: Home, Search, Add (Center FAB), History, Profile

---

## 🛠️ Architecture & Technology Stack

- **Framework**: Flutter & Dart (Stable Channel)
- **State Management**: `flutter_riverpod` (Domain repositories & state notifiers)
- **Navigation**: `go_router`
- **Spatial Engine**: Pure Dart ray-casting PNPOLY point-in-polygon, spherical Shoelace area ($m^2$), and Haversine geodesic distance
- **GIS Standards**: RFC 7946 GeoJSON export and import (`GeoJsonConverter`)
- **QR Engine**: `qr_flutter` & `mobile_scanner` isolated behind domain interfaces (`QrIdentity`)
- **Backend Architecture**: Dual-mode data access layer (In-memory mock database for offline evaluation + Cloud Firestore with ownership-based security rules)
- **Research Instrumentation**: Built-in latency HUD overlay, JSON/CSV Dataset Exporter, and automated benchmark runner

---

## 🧪 Automated Test Suite (59/59 Tests Passing)

All tests are verified and can be executed via:
```bash
flutter test
```

### Test Suite Structure:
- `test/unit/spatial/spatial_service_test.dart` (25 tests): PNPOLY containment, Shoelace area, Haversine distance, canvas normalisation
- `test/unit/spatial/geojson_test.dart` (2 tests): RFC 7946 GeoJSON FeatureCollection export and parsing
- `test/unit/domain/qr_identity_test.dart` (12 tests): QR identifier generation, padding, and round-trip payload parsing
- `test/unit/repositories/mock_auth_repository_test.dart` (4 tests): Authentication lifecycle and session state
- `test/unit/repositories/mock_room_repository_test.dart`, `mock_storage_repository_test.dart`, `mock_movement_repository_test.dart` (7 tests): Domain repositories & transactional movement
- `test/widget/`: Comprehensive widget tests for `HomeScreen`, `AddRoomScreen`, `AddStorageScreen`, `StorageDetailScreen`, `AddItemScreen`, `ItemDetailScreen`, `SearchScreen`, `MovementHistoryScreen` (8 tests)
- `test/integration/full_inventory_flow_test.dart`: Complete end-to-end user lifecycle integration test (1 test)

---

## 🔬 Research Benchmarks & Evaluation

Run the automated evaluation benchmark suite:
```bash
dart run experiments/scripts/run_benchmarks.dart
```

### Empirical Results:
| Benchmark Operation | Batch Size | Total Duration | Latency per Op | Status |
|---|---|---|---|---|
| **Point-in-Polygon (PNPOLY)** | 10,000 checks | **9 ms** | **0.90 µs** / op | ✅ PASSED |
| **QR Encode / Decode Cycle** | 5,000 cycles | **39 ms** | **7.80 µs** / op | ✅ PASSED |
| **Hierarchical Spatial Search** | 1,000 queries | **15 ms** | **15.00 µs** / op | ✅ PASSED |
| **Atomic Item Move Transaction** | 500 transfers | **7 ms** | **14.00 µs** / op | ✅ PASSED |

---

## 🚀 Getting Started

### 1. Requirements
- Flutter SDK 3.22+ (`flutter doctor`)
- Dart SDK 3.4+
- Android Studio / Android SDK (or Chrome for Web preview)
- Git 2.40+

### 2. Running the Application
```bash
# Fetch dependencies
flutter pub get

# Run complete test suite
flutter test

# Run research benchmark runner
dart run experiments/scripts/run_benchmarks.dart

# Launch application on connected device / emulator
flutter run
```

---

## 📁 Repository Structure

```text
HomeStock/
├── lib/
│   ├── main.dart
│   ├── app/                # Theme, Router, Repository Providers (Dual Backend)
│   ├── core/               # Result, Failures, SpatialService, GeoJsonConverter, DatasetExporter
│   ├── features/
│   │   ├── authentication/ # User entity, FirebaseAuthRepository, MockAuthRepository
│   │   ├── home/           # Dashboard screen, Map CustomPainter, Research HUD, Category Breakdown
│   │   ├── inventory/      # Item models, Add/Detail screens, FirestoreItemRepository
│   │   ├── movement/       # Atomic movement repository, History screen, FirestoreMovementRepository
│   │   ├── qr/             # QrIdentity, Scanner screen, Printable QR Card
│   │   ├── rooms/          # Room entities, Boundary capture screen, FirestoreRoomRepository
│   │   ├── search/         # Full-text hierarchical search
│   │   └── storage/        # Storage unit entities, Detail screen, FirestoreStorageRepository
│   └── shared/             # Mock database, Reusable UI widgets
├── test/
│   ├── unit/               # Spatial, QR, GeoJSON, and Repository unit tests
│   ├── widget/             # Widget tests across all features
│   └── integration/        # Full research prototype flow integration test
├── experiments/            # Benchmark scripts, JSON dataset, and performance logs
├── docs/                   # Architecture, Spatial algorithms, Firestore schema & rules, ADRs
└── pubspec.yaml
```

