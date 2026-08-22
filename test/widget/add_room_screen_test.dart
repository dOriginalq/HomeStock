import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homestock/app/theme/app_theme.dart';
import 'package:homestock/features/rooms/presentation/screens/add_room_screen.dart';

void main() {
  testWidgets('AddRoomScreen renders title, preset chips, and input fields',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AddRoomScreen(),
        ),
      ),
    );

    // Verify Title & Subtitle
    expect(find.text('Add Room'), findsOneWidget);
    expect(find.text('Room Information'), findsOneWidget);

    // Verify Preset Chips
    expect(find.text('Bedroom'), findsOneWidget);
    expect(find.text('Living Room'), findsOneWidget);
    expect(find.text('Kitchen'), findsOneWidget);

    // Tap 'Kitchen' preset chip
    await tester.tap(find.text('Kitchen'));
    await tester.pumpAndSettle();

    // Verify TextField received 'Kitchen'
    expect(find.text('Kitchen'), findsNWidgets(2)); // Chip and TextField text

    // Verify Create Room CTA
    expect(find.text('Create Room'), findsOneWidget);
  });
}
