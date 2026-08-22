import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homestock/app/theme/app_theme.dart';
import 'package:homestock/features/search/presentation/screens/search_screen.dart';

void main() {
  testWidgets('SearchScreen renders search input, category filters, and search results',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SearchScreen(),
        ),
      ),
    );

    // Verify Title & Search Bar
    expect(find.text('Search Inventory'), findsOneWidget);
    expect(find.textContaining('Search items'), findsOneWidget);

    // Verify Category Filter Chips
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Books'), findsOneWidget);
    expect(find.text('Electronics'), findsOneWidget);

    // Enter Search Query
    await tester.enterText(find.byType(TextField), 'Camera');
    await tester.pumpAndSettle();

    // Verify Resolved Result with hierarchy
    expect(find.textContaining('Digital SLR Camera'), findsOneWidget);
  });
}
