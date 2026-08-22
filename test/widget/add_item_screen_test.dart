import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homestock/app/theme/app_theme.dart';
import 'package:homestock/features/inventory/presentation/screens/add_item_screen.dart';

void main() {
  testWidgets('AddItemScreen renders title, storage unit picker, quantity stepper, and category chips',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AddItemScreen(storageId: 'storage-shelf-a'),
        ),
      ),
    );

    // Verify Title & Sections
    expect(find.text('Add Inventory Item'), findsOneWidget);
    expect(find.text('Manual Item Registration'), findsOneWidget);

    // Verify Form Fields
    expect(find.text('Item Name *'), findsOneWidget);
    expect(find.text('Storage Unit *'), findsOneWidget);
    expect(find.text('Quantity'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);

    // Verify Quantity Stepper buttons
    expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);

    // Verify Save CTA
    expect(find.text('Add Item to Storage'), findsOneWidget);
  });
}
