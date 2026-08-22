# HomeStock Dependency Audit & Replacement Strategy

This audit documents every external dependency used in HomeStock, its exact purpose, its architectural boundary, and its replacement or removal strategy.

---

## 📋 Direct Production Dependencies

| Package | Version | Purpose | Used In | Required? | Replacement Strategy |
|---|---|---|---|---|---|
| `flutter` | SDK | Core UI rendering engine | All widgets | **Yes** | Fundamental framework |
| `flutter_riverpod` | `^2.5.1` | Compile-safe state management & DI | Controllers, Providers | **Yes** | Standard `ChangeNotifier` / `InheritedWidget` if package count minimization is mandated |
| `riverpod_annotation` | `^2.3.5` | Code generation annotations for Riverpod | Router, Providers | **Optional** | Can use manual `Provider` declarations |
| `go_router` | `^14.3.0` | Declarative routing & deep linking | `app_router.dart`, `MainShell` | **Yes** | Vanilla `Navigator 2.0` (more boilerplate) |
| `firebase_core` | `^3.6.0` | Firebase initialization | `main.dart` | **Yes (for Firebase)** | Mock database for offline/local research |
| `firebase_auth` | `^5.3.1` | User identity & authentication | `FirestoreAuthRepository` | **Yes (for Firebase)** | OAuth / custom backend |
| `cloud_firestore` | `^5.4.4` | NoSQL document database | Firestore Repositories | **Yes (for Firebase)** | SQLite (`sqflite`) or pure local memory |
| `firebase_storage` | `^12.3.4` | Item photo storage | Image uploads | **Optional** | Local file storage (`path_provider`) |
| `qr_flutter` | `^4.1.0` | Vector QR code image rendering | `StorageDetailScreen`, `QrPrintCard` | **Yes** | Custom `CustomPainter` with QR matrix algorithm |
| `mobile_scanner` | `^5.2.3` | Camera preview & barcode detection | `QrScannerScreen` | **Yes** | Native platform channels to Google ML Kit |
| `geolocator` | `^13.0.2` | Single-shot GPS location capture | `NativeLocationService` | **Yes** | Native platform channels to FusedLocationProvider / CoreLocation |
| `image_picker` | `^1.1.2` | Camera / gallery photo selection | Item photo picker | **Optional** | Platform file picker |
| `cached_network_image`| `^3.4.1`| Async network image caching | Item photo tiles | **Optional** | `Image.network` with Flutter cache |
| `uuid` | `^4.5.1` | UUID v4 generation for points/records | Data models | **Optional** | Simple timestamp + random generator |
| `intl` | `^0.19.0` | Date formatting | History & detail screens | **Optional** | Pure Dart `DateTime.toString()` slicing |
| `equatable` | `^2.0.5` | Value equality for entities & states | Domain entities | **Optional** | Manual `operator ==` and `hashCode` overrides |
| `cupertino_icons` | `^1.0.8` | iOS icon assets | UI elements | **Optional** | Material icons |

---

## 🚫 Features Implemented with ZERO External Dependencies (Pure Dart)

To avoid dependency bloat, the following core features were developed in pure Dart:
1. **Ray-Casting Point-in-Polygon Engine** (`SpatialService`): Zero dependencies.
2. **Haversine Distance Calculator**: Pure trigonometry via `dart:math`.
3. **GPS-to-Canvas Normalization**: Pure geometric scaling.
4. **Room Boundary CustomPainter**: Native Flutter canvas drawing.
5. **QR Payload Serialization & Validation** (`QrIdentity`): Pure `dart:convert`.
6. **Result Type & Error Architecture** (`Result<T>`): Pure Dart sealed class hierarchy.
7. **Research Latency Benchmark Logger** (`InstrumentationService`): Pure `dart:developer` and `Stopwatch`.
