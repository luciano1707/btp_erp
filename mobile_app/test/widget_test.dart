// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:digital_chantier_mobile/main.dart';

void main() {
  testWidgets('permet de saisir le mot de passe masqué', (tester) async {
    await tester.pumpWidget(const MyApp(restoreSession: false));

    expect(find.text('Le terrain,\nà portée de main.'), findsOneWidget);
    expect(find.text('Adresse e-mail'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('login-email')), 'test@example.mg');
    await tester.enterText(find.byKey(const Key('login-password')), 'Demo@2026');
    await tester.pump();

    final passwordField = tester.widget<TextFormField>(find.byKey(const Key('login-password')));
    expect(passwordField.controller?.text, 'Demo@2026');
    EditableText editablePassword() => tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('login-password')),
        matching: find.byType(EditableText),
      ),
    );
    expect(editablePassword().obscureText, isTrue);

    await tester.tap(find.byTooltip('Afficher le mot de passe'));
    await tester.pump();
    expect(editablePassword().obscureText, isFalse);
  });
}
