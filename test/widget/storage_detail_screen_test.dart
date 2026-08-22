import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homestock/app/theme/app_theme.dart';
import 'package:homestock/features/storage/presentation/screens/storage_detail_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets('StorageDetailScreen renders storage name, QR code, and item list',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const StorageDetailScreen(storageId: 'storage-shelf-a'),
        ),
      ),
    );

    // Pump to resolve stream/state
    await tester.pumpAndSettle();

    // Verify Storage Name is rendered
    expect(find.text('Shelf A'), findsWidgets);

    // Verify Add Item button exists
    expect(find.text('Add Item'), findsOneWidget);

    // Tap QR code icon in AppBar to open QR dialog
    await tester.tap(find.byTooltip('View QR Code'));
    await tester.pumpAndSettle();

    // Verify QR code image is rendered inside dialog
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.textContaining('HS-ST-00042'), findsWidgets);
  });
}
