import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homestock/app/theme/app_theme.dart';
import 'package:homestock/features/movement/presentation/screens/movement_history_screen.dart';

void main() {
  testWidgets('MovementHistoryScreen renders title and historical audit records',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MovementHistoryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Movement History'), findsOneWidget);

    // Verify Audit Entries are present
    expect(find.byType(Card), findsWidgets);
  });
}
