# HomeStock System Architecture

## 1. Overview & Core Concept

HomeStock is a **spatial residential inventory management system** that maps the physical storage hierarchy of a home:

```text
User  →  Home  →  Rooms  →  Room Boundaries (GPS Polygon)
                 └── Storage Units (Stable QR Identity + Physical Position)
                        └── Items (Manual Registration)
                               └── Movement Records (Audit Trail)
```

### Core Invariants
1. **Rooms** possess user-defined GPS polygon boundaries created by walking room corners on demand.
2. **Storage Units** possess stable QR identifiers (`HS-ST-NNNNN`) and approximate physical GPS coordinates captured at scan time.
3. **Household Items** are manually registered inside storage units and do **NOT** receive individual QR codes.
4. **GPS** is accessed strictly on-demand (zero continuous tracking).

---

## 2. Layered Architecture

HomeStock strictly follows Clean Architecture principles:

```text
┌───────────────────────────────────────────────────────────┐
│                    Presentation Layer                     │
│  - Widgets (RoomMapWidget, RoomSelector, StorageUnitList) │
│  - Controllers & Notifiers (HomeController, Riverpod)     │
│  - Router & Design System (AppTheme, AppColors, Router)   │
└─────────────────────────────┬─────────────────────────────┘
                              │
┌─────────────────────────────▼─────────────────────────────┐
│                       Domain Layer                        │
│  - Entities (Room, StorageUnit, Item, MovementRecord)     │
│  - Spatial Engine & Algorithms (SpatialService)           │
│  - QR Identity Engine (QrIdentity)                        │
│  - Repository Interfaces (RoomRepository, StorageRepo...) │
└─────────────────────────────┬─────────────────────────────┘
                              │
┌─────────────────────────────▼─────────────────────────────┐
│                        Data Layer                         │
│  - Data Models & Serializers (RoomModel, ItemModel...)    │
│  - Cloud Firestore Repositories                           │
│  - In-Memory Mock Database & Repositories                 │
│  - Device Adapters (LocationService, QrScannerService)    │
└───────────────────────────────────────────────────────────┘
```

---

## 3. Dependency Isolation Pattern

Third-party dependencies (such as Geolocator, Mobile Scanner, Firebase) are strictly isolated behind domain interfaces:

```text
Domain Interface:       LocationService
                                ▲
                                │ implements
Data Adapter:           NativeLocationService
                                │ calls
External SDK:           Geolocator Platform Channel
```

This guarantees that the core spatial engine and business logic remain completely testable without device hardware or platform dependencies.
