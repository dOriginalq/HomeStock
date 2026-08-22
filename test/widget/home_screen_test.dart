import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homestock/features/home/presentation/screens/home_screen.dart';
import 'package:homestock/features/home/presentation/widgets/quick_actions_bar.dart';
import 'package:homestock/features/home/presentation/widgets/room_map_widget.dart';
import 'package:homestock/features/home/presentation/widgets/room_selector.dart';

void main() {
  testWidgets('HomeScreen renders header, room selector, map, and quick actions',
      (tester) async {
    // Set a large enough surface size so all slivers render without scrolling issues
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Initial pump and settle
    await tester.pumpAndSettle();

    // 1. Verify HomeStock Header Branding
    expect(find.text('HomeStock'), findsOneWidget);

    // 2. Verify Room Selector Card
    expect(find.byType(RoomSelectorWidget), findsOneWidget);
    expect(find.text('Bedroom'), findsOneWidget);
    expect(find.text('Add Room'), findsOneWidget);

    // 3. Verify Spatial Room Map Widget
    expect(find.byType(RoomMapWidget), findsOneWidget);
    expect(find.text('Shelf A'), findsWidgets);
    expect(find.text('Drawer 1'), findsWidgets);
    expect(find.text('Wardrobe'), findsWidgets);

    // 4. Verify Quick Actions Bar
    expect(find.byType(QuickActionsBar), findsOneWidget);
    expect(find.text('Scan QR'), findsOneWidget);
    expect(find.text('Add Storage'), findsOneWidget);
    expect(find.text('Add Item'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);

    // 5. Verify Storage Units Header
    expect(find.text('Storage Units'), findsOneWidget);
  });
}
