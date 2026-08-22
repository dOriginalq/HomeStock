/// Route path constants for the HomeStock application.
/// All navigation must use these constants — never inline strings.
abstract final class RouteNames {
  // Shell routes (bottom navigation)
  static const String home = '/';
  static const String search = '/search';
  static const String history = '/history';

  // Auth
  static const String login = '/login';
  static const String register = '/register';

  // Rooms
  static const String addRoom = '/rooms/add';
  static const String editRoom = '/rooms/edit';

  // Storage
  static const String addStorage = '/storage/add';
  static const String storageDetail = '/storage';

  // Items
  static const String addItem = '/items/add';
  static const String itemDetail = '/items';

  // QR
  static const String qrScanner = '/qr/scan';
  static const String qrView = '/qr/view';

  // Profile
  static const String profile = '/profile';
}
