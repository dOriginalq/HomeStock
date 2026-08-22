/// Application-wide string constants.
abstract final class AppConstants {
  // App metadata
  static const String appName = 'HomeStock';
  static const String appVersion = '0.1.0';

  // QR payload
  static const String qrPayloadVersion = '1';
  static const String qrIdPrefix = 'HS-ST-';

  // Storage types
  static const List<String> storageTypes = [
    'Shelf',
    'Cupboard',
    'Drawer',
    'Cabinet',
    'Wardrobe',
    'Rack',
    'Box',
    'Toolbox',
    'Other',
  ];

  // Item categories
  static const List<String> itemCategories = [
    'Books',
    'Documents',
    'Electronics',
    'Clothing',
    'Tools',
    'Kitchen',
    'Household',
    'Food',
    'Cleaning',
    'Sports',
    'Toys',
    'Medicine',
    'Other',
  ];

  // GPS
  /// Maximum acceptable GPS accuracy in metres for boundary capture.
  static const double maxAcceptableAccuracyMetres = 10.0;

  /// Warn user if accuracy is above this threshold but still allow capture.
  static const double accuracyWarningThresholdMetres = 5.0;

  /// Minimum boundary points required to form a valid polygon.
  static const int minBoundaryPoints = 3;

  // Firestore collection names
  static const String colUsers = 'users';
  static const String colHomes = 'homes';
  static const String colRooms = 'rooms';
  static const String colBoundaryPoints = 'boundary_points';
  static const String colStorageUnits = 'storage_units';
  static const String colItems = 'items';
  static const String colMovementRecords = 'movement_records';

  // Storage ID counter document
  static const String docIdCounter = '__counter__';
  static const String counterFieldNextId = 'next_id';
}
