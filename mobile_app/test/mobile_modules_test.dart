import 'dart:convert';

import 'package:digital_chantier_mobile/core/api_client.dart';
import 'package:digital_chantier_mobile/features/modules/module_catalog.dart';
import 'package:digital_chantier_mobile/features/modules/modules_hub.dart';
import 'package:digital_chantier_mobile/features/modules/notifications_screen.dart';
import 'package:digital_chantier_mobile/shared/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _ok(dynamic data) => http.Response(
  jsonEncode({'succes': true, 'message': 'ok', 'donnees': data}),
  200,
  headers: {'content-type': 'application/json'},
);

void main() {
  test('Le jeton d’accès est transmis aux requêtes authentifiées', () async {
    final requests = <http.Request>[];
    final api = ApiClient(
      baseUrl: 'http://localhost/BTP_ERP/api/v1',
      client: MockClient((request) async {
        requests.add(request);
        if (request.url.path.endsWith('/auth/login')) {
          return _ok({
            'access_token': 'access-token',
            'refresh_token': 'refresh-token',
            'utilisateur': {'id': 7, 'role': 'comptable'},
          });
        }
        return _ok({'id': 7});
      }),
      storage: null,
    );

    await api.login('compta@example.test', 'password');
    await api.getData('auth/me');

    expect(requests.last.headers['Authorization'], 'Bearer access-token');
  });

  test('Les nouveaux modules respectent les rôles et les routes API', () {
    final modules = {for (final module in appModules) module.id: module};

    expect(
      modules.keys,
      containsAll([
        'demandes-materiel',
        'rapports-journaliers',
        'depenses',
        'budgets',
        'rfi',
        'qualite',
        'securite',
        'incidents',
      ]),
    );
    expect(modules['depenses']!.endpoint, 'depenses');
    expect(modules['depenses']!.canWorkflow('comptable'), isTrue);
    expect(modules['depenses']!.canWorkflow('chef_chantier'), isTrue);
    expect(modules['devis']!.canWorkflow('comptable'), isTrue);
    expect(modules['factures']!.canWorkflow('comptable'), isTrue);
    expect(modules['demandes-materiel']!.canWorkflow('magasinier'), isTrue);
    expect(modules.containsKey('validations'), isFalse);
    expect(modules['demandes-materiel']!.lineMode, ModuleLineMode.materiel);
    expect(AppColors.forest, const Color(0xFF1769AA));
  });

  testWidgets('Les notifications peuvent être consultées et marquées lues', (
    tester,
  ) async {
    var markedRead = false;
    final api = ApiClient(
      baseUrl: 'http://localhost/BTP_ERP/api/v1',
      client: MockClient((request) async {
        if (request.method == 'GET' &&
            request.url.path.endsWith('/notifications')) {
          return _ok({
            'elements': [
              {
                'id': 42,
                'titre': 'Nouvelle demande',
                'message': 'Une demande attend votre approbation.',
                'lu': markedRead ? 1 : 0,
              },
            ],
            'non_lues': markedRead ? 0 : 1,
          });
        }
        if (request.method == 'POST' &&
            request.url.path.endsWith('/notifications/42/lue')) {
          markedRead = true;
          return _ok({'non_lues': 0});
        }
        return _ok({});
      }),
      storage: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: NotificationsScreen(api: api),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle demande'), findsOneWidget);
    await tester.tap(find.text('Nouvelle demande'));
    await tester.pumpAndSettle();

    expect(markedRead, isTrue);
    expect(
      find.text('Une demande attend votre approbation.'),
      findsNWidgets(2),
    );
    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();
    expect(find.text('Tout lire'), findsNothing);
  });

  testWidgets('Les paramètres peuvent être rechargés après une erreur API', (
    tester,
  ) async {
    var attempts = 0;
    final api = ApiClient(
      baseUrl: 'http://localhost/BTP_ERP/api/v1',
      client: MockClient((request) async {
        attempts++;
        if (attempts == 1) {
          return http.Response(
            jsonEncode({'succes': false, 'message': 'API indisponible'}),
            503,
          );
        }
        return _ok({
          'entreprise_nom': 'Digital Chantier',
          'entreprise_adresse': 'Antananarivo',
          'entreprise_telephone': '',
          'entreprise_email': '',
          'entreprise_nif': '',
          'entreprise_stat': '',
          'logo_url': null,
        });
      }),
      storage: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: SettingsScreen(api: api),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('API indisponible'), findsOneWidget);
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.text('Digital Chantier'), findsOneWidget);
  });
}
