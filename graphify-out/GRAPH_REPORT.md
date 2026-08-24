# Graph Report - HomeStock  (2026-08-23)

## Corpus Check
- Corpus is ~32,704 words - fits in a single context window. You may not need a graph.

## Summary
- 1199 nodes · 1728 edges · 87 communities (78 shown, 9 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 37 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Home Screen & Dashboard
- Room & Spatial Management
- Room & Spatial Management
- Home Screen & Dashboard
- Home Screen & Dashboard
- Home Screen & Dashboard
- Authentication & User Accounts
- Home Screen & Dashboard
- Home Screen & Dashboard
- Home Screen & Dashboard
- Storage Unit Tracking
- Room & Spatial Management
- Home Screen & Dashboard
- Home Screen & Dashboard
- Room & Spatial Management
- Home Screen & Dashboard
- Storage Unit Tracking
- Home Screen & Dashboard
- Room & Spatial Management
- Home Screen & Dashboard
- Storage Unit Tracking
- Home Screen & Dashboard
- Home Screen & Dashboard
- Home Screen & Dashboard
- Home Screen & Dashboard
- Room & Spatial Management
- Home Screen & Dashboard
- Home Screen & Dashboard
- Home Screen & Dashboard
- Room & Spatial Management
- Home Screen & Dashboard
- Home Screen & Dashboard
- Room & Spatial Management
- Home Screen & Dashboard
- Room & Spatial Management
- Storage Unit Tracking
- Room & Spatial Management
- Room & Spatial Management
- Room & Spatial Management
- Room & Spatial Management
- Storage Unit Tracking
- Home Screen & Dashboard
- Home Screen & Dashboard
- Spatial & GeoJSON Services
- Module: double?
- Room & Spatial Management
- Storage Unit Tracking
- Home Screen & Dashboard
- Storage Unit Tracking
- Search & Query Engine
- UI Design System & Theme
- Storage Unit Tracking
- Module: DateTime
- Storage Unit Tracking
- Storage Unit Tracking
- Home Screen & Dashboard
- Room & Spatial Management
- Room & Spatial Management
- Storage Unit Tracking
- Storage Unit Tracking
- Home Screen & Dashboard
- Home Screen & Dashboard
- Inventory & Item Management
- Room & Spatial Management
- Home Screen & Dashboard
- Home Screen & Dashboard
- Home Screen & Dashboard
- Storage Unit Tracking
- Home Screen & Dashboard
- Architecture & Documentation
- Home Screen & Dashboard
- Home Screen & Dashboard
- Home Screen & Dashboard
- Home Screen & Dashboard
- Module: MainActivity.kt
- Room & Spatial Management
- Home Screen & Dashboard
- Architecture & Documentation
- Module: App Icon (mipmap-hdpi)
- Module: App Icon (mipmap-mdpi)
- Module: App Icon (mipmap-xhdpi)
- Module: App Icon (mipmap-xxhdpi)
- Module: App Icon (mipmap-xxxhdpi)
- Architecture & Documentation

## God Nodes (most connected - your core abstractions)
1. `HomeStockFailure` - 22 edges
2. `homeControllerProvider` - 19 edges
3. `Doc: README.md` - 16 edges
4. `MockDatabase` - 13 edges
5. `roomRepositoryProvider` - 9 edges
6. `storageRepositoryProvider` - 9 edges
7. `itemRepositoryProvider` - 9 edges
8. `_ItemDetailScreenState` - 8 edges
9. `StorageUnit` - 8 edges
10. `Doc: spatial_algorithms.md` - 7 edges

## Surprising Connections (you probably didn't know these)
- `_ItemDetailScreenState` --references--> `roomRepositoryProvider`  [EXTRACTED]
  lib/features/inventory/presentation/screens/item_detail_screen.dart → lib/features/home/presentation/controllers/home_controller.dart
- `_QrScannerScreenState` --references--> `roomRepositoryProvider`  [EXTRACTED]
  lib/features/qr/presentation/screens/qr_scanner_screen.dart → lib/features/home/presentation/controllers/home_controller.dart
- `_AddRoomScreenState` --references--> `roomRepositoryProvider`  [EXTRACTED]
  lib/features/rooms/presentation/screens/add_room_screen.dart → lib/features/home/presentation/controllers/home_controller.dart
- `_handleSave` --references--> `roomRepositoryProvider`  [EXTRACTED]
  lib/features/rooms/presentation/screens/add_room_screen.dart → lib/features/home/presentation/controllers/home_controller.dart
- `_BoundaryCaptureScreenState` --references--> `roomRepositoryProvider`  [EXTRACTED]
  lib/features/rooms/presentation/screens/boundary_capture_screen.dart → lib/features/home/presentation/controllers/home_controller.dart

## Import Cycles
- None detected.

## Communities (87 total, 9 thin omitted)

### Community 0 - "Home Screen & Dashboard"
Cohesion: 0.05
Nodes (43): app/app.dart, app/config/firebase_options.dart, build, HomeStockApp, android, DefaultFirebaseOptions, ios, web (+35 more)

### Community 1 - "Room & Spatial Management"
Cohesion: 0.05
Nodes (46): ../../data/repositories/mock_search_repository.dart, ../../domain/entities/item_search_result.dart, ../../domain/repositories/search_repository.dart, ../../features/authentication/data/repositories/firebase_auth_repository.dart, ../../features/authentication/data/repositories/mock_auth_repository.dart, ../../features/authentication/domain/repositories/auth_repository.dart, ../../features/inventory/data/repositories/firestore_item_repository.dart, ../../features/inventory/data/repositories/mock_item_repository.dart (+38 more)

### Community 2 - "Room & Spatial Management"
Cohesion: 0.05
Nodes (41): accent, AppColors, background, border, borderLight, cardBackground, divider, error (+33 more)

### Community 3 - "Home Screen & Dashboard"
Cohesion: 0.05
Nodes (38): int?, capacityItems, createdAt, description, expectedCategories, fromEntity, fromFirestore, homeId (+30 more)

### Community 4 - "Home Screen & Dashboard"
Cohesion: 0.06
Nodes (33): app_colors.dart, app_typography.dart, AppShadows, bottomNav, large, marker, medium, small (+25 more)

### Community 5 - "Home Screen & Dashboard"
Cohesion: 0.09
Nodes (33): AuthFailure, code, DestinationStorageNotFoundFailure, FirebaseFailure, HomeStockFailure, InsufficientBoundaryPointsFailure, InvalidItemDataFailure, InvalidPolygonFailure (+25 more)

### Community 6 - "Authentication & User Accounts"
Cohesion: 0.06
Nodes (32): ../../domain/entities/user_entity.dart, ../../domain/repositories/auth_repository.dart, ../entities/user_entity.dart, FirebaseAuth, _auth, FirebaseAuthRepository, getCurrentUser, registerWithEmail (+24 more)

### Community 7 - "Home Screen & Dashboard"
Cohesion: 0.06
Nodes (33): AppTypography, bodyLarge, bodyMedium, bodySmall, displayLarge, displayMedium, _fontFamily, headlineLarge (+25 more)

### Community 8 - "Home Screen & Dashboard"
Cohesion: 0.07
Nodes (30): bool get, dart:developer, HomeStockFailure? get, Failure, failureOrNull, isFailure, isSuccess, Result (+22 more)

### Community 9 - "Home Screen & Dashboard"
Cohesion: 0.07
Nodes (26): ../../features/authentication/domain/entities/user_entity.dart, ../../features/home/domain/entities/home_entity.dart, ../../features/storage/domain/entities/storage_position.dart, homes, _initializeData, instance, items, _itemsController (+18 more)

### Community 10 - "Storage Unit Tracking"
Cohesion: 0.07
Nodes (26): AppRadius, AppSpacing, bottomSheet, button, card, cardPadding, cardPaddingSmall, chip (+18 more)

### Community 11 - "Room & Spatial Management"
Cohesion: 0.10
Nodes (21): ../../../../app/theme/app_spacing.dart, ../../domain/entities/movement_record.dart, ../../../inventory/presentation/screens/item_detail_screen.dart, build, _buildBreadcrumbChip, createState, _currentRoom, _currentStorage (+13 more)

### Community 12 - "Home Screen & Dashboard"
Cohesion: 0.11
Nodes (21): ../../core/constants/route_names.dart, build, createState, dispose, _emailController, _handleSignIn, _isLoading, LoginScreen (+13 more)

### Community 13 - "Home Screen & Dashboard"
Cohesion: 0.09
Nodes (21): @riverpod, AutoDisposeProviderRef, appRouterProvider, AppRouterRef, ../../features/authentication/presentation/screens/login_screen.dart, ../../features/authentication/presentation/screens/register_screen.dart, ../../features/home/presentation/screens/home_screen.dart, ../../features/inventory/presentation/screens/add_item_screen.dart (+13 more)

### Community 14 - "Room & Spatial Management"
Cohesion: 0.09
Nodes (21): dart:io, bedroomBoundary, db, instrumentation, main, measure, moveRepo, now (+13 more)

### Community 15 - "Home Screen & Dashboard"
Cohesion: 0.10
Nodes (19): dart:async, home_state.dart, dispose, _homeId, _init, roomRepo, _roomRepository, _roomsSub (+11 more)

### Community 16 - "Storage Unit Tracking"
Cohesion: 0.12
Nodes (17): ../entities/movement_record.dart, FirebaseFirestore, ../../../inventory/domain/entities/item.dart, _firestore, FirestoreMovementRepository, _itemsCol, moveItem, _movementCol (+9 more)

### Community 17 - "Home Screen & Dashboard"
Cohesion: 0.14
Nodes (17): ../../../home/presentation/controllers/home_controller.dart, ../../../inventory/data/repositories/mock_item_repository.dart, ../../../inventory/domain/repositories/item_repository.dart, build, CategoryBreakdownWidget, _handleSave, createState, initState (+9 more)

### Community 18 - "Room & Spatial Management"
Cohesion: 0.12
Nodes (17): CustomPainter, boundaryPoints, _buildFloatingMapButton, _buildMapIconAction, createState, _defaultBoundaryPoints, _getStorageIcon, paint (+9 more)

### Community 19 - "Home Screen & Dashboard"
Cohesion: 0.11
Nodes (16): ../../domain/entities/home_entity.dart, ../../domain/repositories/home_repository.dart, ../entities/home_entity.dart, createHome, _db, deleteHome, getHome, MockHomeRepository (+8 more)

### Community 20 - "Storage Unit Tracking"
Cohesion: 0.12
Nodes (17): _showMoreActionsSheet, _StorageUnitCard, _MovementRecordCard, QrPrintCard, _SearchResultCard, HSIcon, build, _buildCenterAddButton (+9 more)

### Community 21 - "Home Screen & Dashboard"
Cohesion: 0.15
Nodes (16): ConsumerWidget, homeControllerProvider, _HomeBody, HomeScreen, QuickActionsBar, build, _buildStorageMarker, build (+8 more)

### Community 22 - "Home Screen & Dashboard"
Cohesion: 0.12
Nodes (16): category, createdAt, currentStorageId, description, fromEntity, fromFirestore, homeId, id (+8 more)

### Community 23 - "Home Screen & Dashboard"
Cohesion: 0.12
Nodes (16): boundary, createdAt, description, fromEntity, fromFirestore, homeId, id, name (+8 more)

### Community 24 - "Home Screen & Dashboard"
Cohesion: 0.23
Nodes (17): 1 Requirements, 2 Running the Application, Architecture  Technology Stack, Automated Test Suite 5959 Tests Passing, Core Concepts  Invariants, Empirical Results, Fetch dependencies, Getting Started (+9 more)

### Community 25 - "Room & Spatial Management"
Cohesion: 0.13
Nodes (14): ../entities/storage_position.dart, ../entities/storage_unit.dart, FirestoreStorageRepository, MockStorageRepository, createStorageUnit, deleteStorageUnit, generateNextQrId, getStorageUnit (+6 more)

### Community 26 - "Home Screen & Dashboard"
Cohesion: 0.13
Nodes (14): HomeController, copyWith, errorMessage, HomeState, isLoading, props, rooms, selectedRoom (+6 more)

### Community 27 - "Home Screen & Dashboard"
Cohesion: 0.13
Nodes (14): category, copyWith, createdAt, currentStorageId, description, homeId, id, imageUrl (+6 more)

### Community 28 - "Home Screen & Dashboard"
Cohesion: 0.13
Nodes (14): copyWith, createdAt, boundary, description, hasBoundary, homeId, id, name (+6 more)

### Community 29 - "Room & Spatial Management"
Cohesion: 0.14
Nodes (14): BoundaryCaptureScreen, _BoundaryCaptureScreenState, build, _capturedPoints, createState, _isCapturing, _isSaving, _locationService (+6 more)

### Community 30 - "Home Screen & Dashboard"
Cohesion: 0.19
Nodes (11): ../../app/theme/app_colors.dart, ../controllers/home_controller.dart, _buildActionButton, _getIconForType, unit, build, roomName, storageUnit (+3 more)

### Community 31 - "Home Screen & Dashboard"
Cohesion: 0.16
Nodes (12): dart:convert, ../../features/inventory/domain/entities/item.dart, ../../features/movement/domain/entities/movement_record.dart, ../../features/rooms/domain/entities/room_boundary.dart, ../../features/rooms/domain/entities/room.dart, ../../features/storage/domain/entities/storage_unit.dart, DatasetExporter, exportHomeToJson (+4 more)

### Community 32 - "Room & Spatial Management"
Cohesion: 0.14
Nodes (13): ../../domain/entities/storage_position.dart, ../../domain/entities/storage_unit.dart, ../../domain/repositories/storage_repository.dart, createStorageUnit, _db, deleteStorageUnit, generateNextQrId, getStorageUnit (+5 more)

### Community 33 - "Home Screen & Dashboard"
Cohesion: 0.16
Nodes (13): Equatable, HomeEntity, Item, MovementRecord, BoundaryPoint, RoomBoundary, Room, item (+5 more)

### Community 34 - "Room & Spatial Management"
Cohesion: 0.14
Nodes (13): createStorageUnit, deleteStorageUnit, _firestore, generateNextQrId, getStorageUnit, getStorageUnitByQrId, registerStoragePosition, _storageCol (+5 more)

### Community 35 - "Storage Unit Tracking"
Cohesion: 0.17
Nodes (12): ../../../../core/services/location_service.dart, ../../../../core/services/spatial_service.dart, ../../domain/services/qr_identity.dart, build, createState, _isProcessing, _locationService, QrScannerScreen (+4 more)

### Community 36 - "Room & Spatial Management"
Cohesion: 0.15
Nodes (12): _capacityController, createState, _descController, dispose, initState, _isSaving, _nameController, roomId (+4 more)

### Community 37 - "Room & Spatial Management"
Cohesion: 0.17
Nodes (11): boundary_point.dart, int get, capturedAt, copyWith, isComplete, isValid, pointCount, points (+3 more)

### Community 38 - "Room & Spatial Management"
Cohesion: 0.17
Nodes (11): ../../domain/entities/boundary_point.dart, createRoom, deleteRoom, _firestore, getRoom, getRooms, _roomsCol, saveRoomBoundary (+3 more)

### Community 39 - "Room & Spatial Management"
Cohesion: 0.17
Nodes (11): ../../domain/entities/room_boundary.dart, ../../domain/entities/room.dart, ../../domain/repositories/room_repository.dart, createRoom, _db, deleteRoom, getRoom, getRooms (+3 more)

### Community 40 - "Storage Unit Tracking"
Cohesion: 0.17
Nodes (11): createState, _descController, dispose, initState, _isSaving, _nameController, _quantity, _selectedCategory (+3 more)

### Community 41 - "Home Screen & Dashboard"
Cohesion: 0.17
Nodes (11): fromRoomId, fromStorageId, homeId, id, itemId, movedAt, note, props (+3 more)

### Community 42 - "Home Screen & Dashboard"
Cohesion: 0.18
Nodes (10): MockDatabase, package:homestock/features/authentication/data/repositories/mock_auth_repository.dart, package:homestock/features/rooms/data/repositories/mock_room_repository.dart, package:homestock/shared/data/mock_database.dart, db, main, repo, db (+2 more)

### Community 43 - "Spatial & GeoJSON Services"
Cohesion: 0.18
Nodes (10): dart:math, distanceMetres, _isDegenerate, isPointInBoundary, polygonAreaMetres, polygonCentroid, polygonPerimeterMetres, _rayCasting (+2 more)

### Community 44 - "Module: double?"
Cohesion: 0.18
Nodes (10): double?, accuracyMetres, capturedAt, copyWith, id, index, latitude, longitude (+2 more)

### Community 45 - "Room & Spatial Management"
Cohesion: 0.18
Nodes (10): ../entities/boundary_point.dart, ../entities/room_boundary.dart, ../entities/room.dart, createRoom, deleteRoom, getRoom, getRooms, saveRoomBoundary (+2 more)

### Community 46 - "Storage Unit Tracking"
Cohesion: 0.18
Nodes (10): ../entities/item.dart, FirestoreItemRepository, MockItemRepository, createItem, deleteItem, getItem, ItemRepository, updateItem (+2 more)

### Community 47 - "Home Screen & Dashboard"
Cohesion: 0.18
Nodes (10): address, copyWith, createdAt, id, name, ownerId, props, toString (+2 more)

### Community 48 - "Storage Unit Tracking"
Cohesion: 0.18
Nodes (10): createItem, deleteItem, _firestore, getItem, _itemsCol, _storageCol, updateItem, watchAllItems (+2 more)

### Community 49 - "Search & Query Engine"
Cohesion: 0.29
Nodes (9): ../../app/theme/app_typography.dart, ../../../../core/services/instrumentation_service.dart, build, _buildMetricRow, child, instrumentationServiceProvider, ResearchHudOverlay, showResearchHudProvider (+1 more)

### Community 50 - "UI Design System & Theme"
Cohesion: 0.20
Nodes (9): Color, IconData, backgroundColor, borderRadius, build, color, icon, padding (+1 more)

### Community 51 - "Storage Unit Tracking"
Cohesion: 0.20
Nodes (9): ../../../../core/constants/app_constants.dart, fromQrPayload, generateStorageId, id, _isValidStorageId, QrIdentity, toQrPayload, toString (+1 more)

### Community 52 - "Module: DateTime"
Cohesion: 0.20
Nodes (9): DateTime, copyWith, createdAt, displayName, email, id, photoUrl, props (+1 more)

### Community 53 - "Storage Unit Tracking"
Cohesion: 0.20
Nodes (9): ../../domain/entities/item.dart, ../../domain/repositories/item_repository.dart, createItem, _db, deleteItem, getItem, updateItem, watchAllItems (+1 more)

### Community 54 - "Storage Unit Tracking"
Cohesion: 0.20
Nodes (9): accuracyMetres, copyWith, latitude, longitude, props, registeredAt, storageId, StoragePosition (+1 more)

### Community 55 - "Home Screen & Dashboard"
Cohesion: 0.20
Nodes (9): package:homestock/features/search/data/repositories/mock_search_repository.dart, db, itemRepo, main, moveRepo, roomRepo, searchRepo, spatialService (+1 more)

### Community 56 - "Room & Spatial Management"
Cohesion: 0.25
Nodes (8): ../errors/failures.dart, ../../features/rooms/domain/entities/boundary_point.dart, checkPermissions, getCurrentLocation, LocationService, NativeLocationService, requestPermissions, ../result/result.dart

### Community 57 - "Room & Spatial Management"
Cohesion: 0.25
Nodes (8): AddRoomScreen, _AddRoomScreenState, build, createState, _descController, dispose, _isSubmitting, _nameController

### Community 58 - "Storage Unit Tracking"
Cohesion: 0.32
Nodes (8): ConsumerState, ConsumerStatefulWidget, AddItemScreen, _AddItemScreenState, ItemDetailScreen, _ItemDetailScreenState, AddStorageScreen, _AddStorageScreenState

### Community 59 - "Storage Unit Tracking"
Cohesion: 0.25
Nodes (6): ../../../../core/result/result.dart, ../entities/item_search_result.dart, QrScannerService, scanStorageQr, searchItems, qr_identity.dart

### Community 60 - "Home Screen & Dashboard"
Cohesion: 0.46
Nodes (8): 1 Room Boundary Polygon Construction, 2 Point-in-Polygon Ray-Casting Algorithm, 3 Haversine Distance, 4 GPS-to-Canvas Coordinate Normalization, Complexity, HomeStock Spatial Algorithms  Geospatial Engine, Doc: spatial_algorithms.md, Validation Invariants

### Community 61 - "Home Screen & Dashboard"
Cohesion: 0.25
Nodes (7): build, _buildAppBar, ../../../../shared/widgets/hs_icon.dart, ../widgets/quick_actions_bar.dart, ../widgets/room_map_widget.dart, ../widgets/room_selector.dart, ../widgets/storage_unit_list.dart

### Community 62 - "Inventory & Item Management"
Cohesion: 0.29
Nodes (6): ../../../../core/errors/failures.dart, ../../domain/repositories/movement_repository.dart, _db, moveItem, watchItemHistory, watchMovementHistory

### Community 63 - "Room & Spatial Management"
Cohesion: 0.33
Nodes (7): roomRepositoryProvider, storageRepositoryProvider, _loadData, _handleQrPayload, _handleSave, _finishBoundary, _handleSave

### Community 64 - "Home Screen & Dashboard"
Cohesion: 0.29
Nodes (6): package:homestock/core/utils/geojson_converter.dart, package:homestock/features/rooms/domain/entities/boundary_point.dart, package:homestock/features/rooms/domain/entities/room_boundary.dart, package:homestock/features/rooms/domain/entities/room.dart, package:homestock/features/storage/domain/entities/storage_unit.dart, main

### Community 65 - "Home Screen & Dashboard"
Cohesion: 0.29
Nodes (6): package:homestock/features/inventory/data/repositories/mock_item_repository.dart, package:homestock/features/movement/data/repositories/mock_movement_repository.dart, db, itemRepo, main, moveRepo

### Community 66 - "Home Screen & Dashboard"
Cohesion: 0.60
Nodes (6): 1 Overview  Core Concept, 2 Layered Architecture, 3 Dependency Isolation Pattern, Core Invariants, HomeStock System Architecture, Doc: system_architecture.md

### Community 67 - "Storage Unit Tracking"
Cohesion: 0.47
Nodes (6): build, build, _showAddOptionsSheet, RouteNames.addItem, RouteNames.addStorage, RouteNames.qrScanner

### Community 68 - "Home Screen & Dashboard"
Cohesion: 0.33
Nodes (5): package:homestock/features/storage/data/repositories/mock_storage_repository.dart, package:homestock/features/storage/domain/entities/storage_position.dart, db, main, repo

### Community 69 - "Architecture & Documentation"
Cohesion: 0.70
Nodes (5): Doc: adr_001_dependency_isolation.md, ADR 001 Third-Party Dependency Isolation  Minimization Strategy, Consequences, Context  Problem Statement, Decision

### Community 70 - "Home Screen & Dashboard"
Cohesion: 0.70
Nodes (5): 1 Research Objectives, 2 Instrumented Metrics, 3 Benchmark Datasets, Doc: experiment_protocol.md, HomeStock Research Protocol  Experiment Instrumentation

### Community 71 - "Home Screen & Dashboard"
Cohesion: 0.83
Nodes (4): 1 Top-Level Collections  Hierarchy, 2 Composite Indexes, Doc: firestore_schema.md, HomeStock Firestore Database Schema

### Community 72 - "Home Screen & Dashboard"
Cohesion: 0.83
Nodes (4): Doc: dependency_audit.md, Direct Production Dependencies, Features Implemented with ZERO External Dependencies Pure Dart, HomeStock Dependency Audit  Replacement Strategy

### Community 73 - "Home Screen & Dashboard"
Cohesion: 0.83
Nodes (4): 1 System  Toolchain, 2 Directory Structure, Doc: environment.md, HomeStock Development Environment Specification

### Community 75 - "Room & Spatial Management"
Cohesion: 0.67
Nodes (3): FirestoreRoomRepository, MockRoomRepository, RoomRepository

## Knowledge Gaps
- **688 isolated node(s):** `instrumentation`, `spatialService`, `db`, `searchRepo`, `moveRepo` (+683 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `MockDatabase` connect `Home Screen & Dashboard` to `Room & Spatial Management`, `Room & Spatial Management`, `Home Screen & Dashboard`, `Home Screen & Dashboard`, `Authentication & User Accounts`, `Room & Spatial Management`, `Home Screen & Dashboard`, `Home Screen & Dashboard`, `Storage Unit Tracking`, `Home Screen & Dashboard`, `Inventory & Item Management`?**
  _High betweenness centrality (0.041) - this node is a cross-community bridge._
- **Why does `RoomRepository` connect `Room & Spatial Management` to `Room & Spatial Management`, `Room & Spatial Management`, `Home Screen & Dashboard`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **Why does `StorageUnit` connect `Home Screen & Dashboard` to `Home Screen & Dashboard`, `Home Screen & Dashboard`, `Room & Spatial Management`, `Home Screen & Dashboard`, `Home Screen & Dashboard`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **What connects `instrumentation`, `spatialService`, `db` to the rest of the system?**
  _688 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Home Screen & Dashboard` be split into smaller, more focused modules?**
  _Cohesion score 0.05185185185185185 - nodes in this community are weakly interconnected._
- **Should `Room & Spatial Management` be split into smaller, more focused modules?**
  _Cohesion score 0.04591836734693878 - nodes in this community are weakly interconnected._
- **Should `Room & Spatial Management` be split into smaller, more focused modules?**
  _Cohesion score 0.047619047619047616 - nodes in this community are weakly interconnected._