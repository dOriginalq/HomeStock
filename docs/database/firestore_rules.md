# HomeStock Cloud Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function isHomeOwner(homeId) {
      return isAuthenticated() && 
        request.auth.uid == get(/databases/$(database)/documents/homes/$(homeId)).data.ownerId;
    }

    // Users Collection
    match /users/{userId} {
      allow read, write: if isOwner(userId);
    }

    // Homes Collection
    match /homes/{homeId} {
      allow read, update, delete: if isHomeOwner(homeId);
      allow create: if isAuthenticated() && request.resource.data.ownerId == request.auth.uid;

      // Rooms subcollection
      match /rooms/{roomId} {
        allow read, write: if isHomeOwner(homeId);
      }

      // Storage Units subcollection
      match /storage_units/{storageId} {
        allow read, write: if isHomeOwner(homeId);
      }

      // Items subcollection
      match /items/{itemId} {
        allow read, write: if isHomeOwner(homeId);
      }

      // Movement Records subcollection (Audit trail is immutable)
      match /movement_records/{recordId} {
        allow read: if isHomeOwner(homeId);
        allow create: if isHomeOwner(homeId);
        allow update, delete: if false; // Immutable audit records
      }
    }
  }
}
```
