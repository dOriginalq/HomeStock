import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homestock/app/theme/app_theme.dart';
import 'package:homestock/features/inventory/presentation/screens/item_detail_screen.dart';

void main() {
  testWidgets('ItemDetailScreen renders item name, current storage, and move action',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ItemDetailScreen(itemId: 'item-001'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Item Details
    expect(find.text('Data Structures & Algorithms Book'), findsWidgets);
    expect(find.textContaining('Books'), findsWidgets);

    // Verify Move CTA button exists
    expect(find.text('Move to Another Storage Unit'), findsOneWidget);
  });
}
