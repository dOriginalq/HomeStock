import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/route_names.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/inventory/presentation/screens/add_item_screen.dart';
import '../../features/inventory/presentation/screens/item_detail_screen.dart';
import '../../features/movement/presentation/screens/movement_history_screen.dart';
import '../../features/qr/presentation/screens/qr_scanner_screen.dart';
import '../../features/rooms/presentation/screens/add_room_screen.dart';
import '../../features/rooms/presentation/screens/boundary_capture_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/storage/presentation/screens/add_storage_screen.dart';
import '../../features/storage/presentation/screens/storage_detail_screen.dart';
import '../../shared/widgets/main_shell.dart';

/// Provides the GoRouter instance for the application.
/// Uses Riverpod for access to auth state to handle redirects.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.home,
    debugLogDiagnostics: true,
    routes: [
        // Auth routes (no shell)
        GoRoute(
          path: RouteNames.login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RouteNames.register,
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // Main shell with bottom navigation
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: RouteNames.home,
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: RouteNames.search,
              name: 'search',
              builder: (context, state) => const SearchScreen(),
            ),
            GoRoute(
              path: RouteNames.history,
              name: 'history',
              builder: (context, state) => const MovementHistoryScreen(),
            ),
          ],
        ),

        // Feature routes (full-screen, no shell)
        GoRoute(
          path: RouteNames.addRoom,
          name: 'add-room',
          builder: (context, state) => const AddRoomScreen(),
          routes: [
            GoRoute(
              path: 'boundary',
              name: 'boundary-capture',
              builder: (context, state) {
                final roomId = state.extra as String?;
                return BoundaryCaptureScreen(roomId: roomId ?? '');
              },
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.addStorage,
          name: 'add-storage',
          builder: (context, state) {
            final roomId = state.extra as String?;
            return AddStorageScreen(roomId: roomId ?? '');
          },
        ),
        GoRoute(
          path: '${RouteNames.storageDetail}/:storageId',
          name: 'storage-detail',
          builder: (context, state) {
            final storageId = state.pathParameters['storageId']!;
            return StorageDetailScreen(storageId: storageId);
          },
        ),
        GoRoute(
          path: RouteNames.addItem,
          name: 'add-item',
          builder: (context, state) {
            final storageId = state.extra as String?;
            return AddItemScreen(storageId: storageId);
          },
        ),
        GoRoute(
          path: '${RouteNames.itemDetail}/:itemId',
          name: 'item-detail',
          builder: (context, state) {
            final itemId = state.pathParameters['itemId']!;
            return ItemDetailScreen(itemId: itemId);
          },
        ),
        GoRoute(
          path: RouteNames.qrScanner,
          name: 'qr-scanner',
          builder: (context, state) => const QrScannerScreen(),
        ),
      ],

      // TODO(auth): Uncomment and wire to auth state once Firebase is configured.
      // redirect: (context, state) {
      //   final isAuthenticated = ref.read(authStateProvider).valueOrNull != null;
      //   final isAuthRoute = state.matchedLocation == RouteNames.login ||
      //       state.matchedLocation == RouteNames.register;
      //   if (!isAuthenticated && !isAuthRoute) return RouteNames.login;
      //   if (isAuthenticated && isAuthRoute) return RouteNames.home;
      //   return null;
      // },

      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.error}'),
        ),
      ),
    );
});
