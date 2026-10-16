import 'package:digital_chantier_mobile/core/api_client.dart';
import 'package:digital_chantier_mobile/features/home/dashboard_screen.dart';
import 'package:digital_chantier_mobile/features/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';

void main() {
  testWidgets('Le profil affiche les champs dans un contexte Material', (
    tester,
  ) async {
    final api = ApiClient(
      baseUrl: 'http://localhost/BTP_ERP/api/v1',
      client: MockClient((_) async => throw StateError('Requête inattendue')),
      storage: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          api: api,
          user: const {
            'prenom': 'Paul',
            'nom': 'Randrianja',
            'email': 'paul@example.mg',
            'telephone': '0340000000',
            'role': 'magasinier',
          },
          onLogout: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mon profil'), findsOneWidget);
    expect(find.text('Informations personnelles'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
    await tester.scrollUntilVisible(
      find.text('Sécurité'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Mot de passe actuel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Le tableau de bord affiche les lignes de rentabilité sans erreur',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardScreen(
              user: const {'prenom': 'Paul'},
              data: const {},
              canViewFinances: true,
              canReadDevis: true,
              chantierStats: const [
                {
                  'nom': 'Chantier test',
                  'cout_total': 1000,
                  'avancement': 50,
                  'marge': 500,
                },
              ],
              monthlyStats: const [],
              stock: const [],
              loading: false,
              error: null,
              onRefresh: () async {},
              onRetry: () {},
              onOpenTab: (_) {},
              onOpenModule: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Rentabilité par chantier'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Chantier test'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
