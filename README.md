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
- **State Management**: `flutter_riverpod`
- **Navigation**: `go_router`
- **Spatial Engine**: Pure Dart ray-casting PNPOLY point-in-polygon & Haversine distance
- **QR Engine**: `qr_flutter` & `mobile_scanner` isolated behind domain interfaces
- **Database**: Cloud Firestore with complete ownership-based security rules
- **Research Instrumentation**: Built-in latency & throughput metric collection

---

## 🚀 Getting Started

### 1. Requirements
- Flutter 3.22+ (`flutter doctor`)
- Android Studio / Android SDK (or Chrome for Web preview)
- Git 2.40+

### 2. Running the Application
```bash
# Fetch dependencies
flutter pub get

# Run tests
flutter test

# Launch on connected device or emulator
flutter run
```

---

## 📁 Repository Structure

```text
HomeStock/
├── lib/
│   ├── main.dart
│   ├── app/                # Theme, Router, Configuration
│   ├── core/               # Result, Failures, SpatialService, LocationService
│   ├── features/
│   │   ├── authentication/ # User model, Auth repository
│   │   ├── home/           # Dashboard screen, Map widget, Room selector
│   │   ├── inventory/      # Item models, Add/Detail screens
│   │   ├── movement/       # Atomic movement repository, History screen
│   │   ├── qr/             # QrIdentity, Scanner screen
│   │   ├── rooms/          # Room entities, Boundary capture screen
│   │   ├── search/         # Full-text hierarchical search
│   │   └── storage/        # Storage unit entities, Detail screens
│   └── shared/             # Mock database, Reusable widgets
├── test/
│   ├── unit/               # Spatial algorithm & QR identity tests
│   └── widget/
├── docs/                   # Architecture, Algorithms, Database, Research docs
└── pubspec.yaml
```
