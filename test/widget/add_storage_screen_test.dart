import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homestock/app/theme/app_theme.dart';
import 'package:homestock/features/storage/presentation/screens/add_storage_screen.dart';

void main() {
  testWidgets('AddStorageScreen renders title, room selector, type picker, and category chips',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AddStorageScreen(roomId: 'room-bedroom'),
        ),
      ),
    );

    // Verify Title
    expect(find.text('Add Storage Unit'), findsOneWidget);
    expect(find.text('Storage Characteristics'), findsOneWidget);

    // Verify Fields
    expect(find.text('Storage Name *'), findsOneWidget);
    expect(find.text('Storage Type *'), findsOneWidget);
    expect(find.text('Expected Item Categories'), findsOneWidget);

    // Verify Categories Filter Chips exist
    expect(find.text('Books'), findsOneWidget);
    expect(find.text('Electronics'), findsOneWidget);

    // Verify Create Storage CTA
    expect(find.text('Create Storage Unit & Generate QR'), findsOneWidget);
  });
}
