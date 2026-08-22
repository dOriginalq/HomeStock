# HomeStock Firestore Database Schema

## 1. Top-Level Collections & Hierarchy

```text
users/{userId}
  ├── displayName: String
  ├── email: String
  └── createdAt: Timestamp

homes/{homeId}
  ├── ownerId: String (references users/{userId})
  ├── name: String
  ├── address: String?
  ├── createdAt: Timestamp
  └── updatedAt: Timestamp

  ├── rooms/{roomId}
  │     ├── homeId: String
  │     ├── name: String
  │     ├── description: String?
  │     ├── storageUnitCount: Number
  │     ├── totalItemCount: Number
  │     ├── boundary: Map (or subcollection boundary_points)
  │     │     ├── isComplete: Boolean
  │     │     ├── capturedAt: Timestamp
  │     │     └── points: Array<Map>
  │     │           ├── latitude: Number
  │     │           ├── longitude: Number
  │     │           ├── accuracyMetres: Number?
  │     │           ├── index: Number
  │     │           └── capturedAt: Timestamp
  │     ├── createdAt: Timestamp
  │     └── updatedAt: Timestamp
  │
  ├── storage_units/{storageId}
  │     ├── homeId: String
  │     ├── roomId: String (references rooms/{roomId})
  │     ├── qrId: String (unique index e.g. "HS-ST-00042")
  │     ├── name: String
  │     ├── type: String ("Shelf" | "Drawer" | "Wardrobe" | etc.)
  │     ├── description: String?
  │     ├── capacityItems: Number?
  │     ├── expectedCategories: Array<String>
  │     ├── itemCount: Number
  │     ├── isPositionRegistered: Boolean
  │     ├── position: Map?
  │     │     ├── latitude: Number
  │     │     ├── longitude: Number
  │     │     ├── accuracyMetres: Number?
  │     │     └── registeredAt: Timestamp
  │     ├── createdAt: Timestamp
  │     └── updatedAt: Timestamp
  │
  ├── items/{itemId}
  │     ├── homeId: String
  │     ├── currentStorageId: String (references storage_units/{storageId})
  │     ├── name: String
  │     ├── category: String?
  │     ├── quantity: Number
  │     ├── description: String?
  │     ├── imageUrl: String?
  │     ├── tags: Array<String>
  │     ├── createdAt: Timestamp
  │     └── updatedAt: Timestamp
  │
  └── movement_records/{recordId}
        ├── homeId: String
        ├── itemId: String (references items/{itemId})
        ├── fromStorageId: String
        ├── toStorageId: String
        ├── fromRoomId: String?
        ├── toRoomId: String?
        ├── note: String?
        └── movedAt: Timestamp
```

---

## 2. Composite Indexes

1. `items`: `homeId` (Ascending) + `currentStorageId` (Ascending) + `name` (Ascending)
2. `storage_units`: `homeId` (Ascending) + `roomId` (Ascending) + `name` (Ascending)
3. `storage_units`: `homeId` (Ascending) + `qrId` (Ascending) [Unique]
4. `movement_records`: `homeId` (Ascending) + `itemId` (Ascending) + `movedAt` (Descending)
