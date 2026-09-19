import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('PhoneNumberFormatterApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PhoneNumberFormatterApp());
    await tester.pumpAndSettle();

    // Verify main components are present
    expect(find.text('Phone Number Formatter'), findsOneWidget);
    expect(find.text('1. PhoneInputField Widget'), findsOneWidget);
    expect(find.text('2. Standalone TextInputFormatter'), findsOneWidget);
    expect(find.text('+880'), findsOneWidget);
  });

  testWidgets('Can open country picker and select another country', (WidgetTester tester) async {
    await tester.pumpWidget(const PhoneNumberFormatterApp());
    await tester.pumpAndSettle();

    // Tap on the country picker (dial code / flag)
    await tester.tap(find.text('+880'));
    await tester.pumpAndSettle();

    // Verify modal bottom sheet opened
    expect(find.text('Search by country or dial code...'), findsOneWidget);

    // Tap on Afghanistan list tile
    await tester.tap(find.widgetWithText(ListTile, 'Afghanistan'));
    await tester.pumpAndSettle();

    // Verify country dial code updated
    expect(find.text('+93'), findsWidgets);
  });
}
