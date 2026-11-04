import 'dart:convert';

import 'package:digital_chantier_mobile/core/api_client.dart';
import 'package:digital_chantier_mobile/features/billing/billing_screen.dart';
import 'package:digital_chantier_mobile/features/modules/api_module_screen.dart';
import 'package:digital_chantier_mobile/features/modules/module_catalog.dart';
import 'package:digital_chantier_mobile/features/stock/stock_screen.dart';
import 'package:digital_chantier_mobile/shared/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

/// Repond au format attendu par l'API (enveloppe `succes` / `donnees`).
http.Response _ok(dynamic donnees) => http.Response(
  jsonEncode({'succes': true, 'message': 'ok', 'donnees': donnees}),
  200,
  headers: {'content-type': 'application/json'},
);

ApiClient _api(Future<http.Response> Function(http.Request) handler) =>
    ApiClient(
      baseUrl: 'http://localhost/BTP_ERP/api/v1',
      client: MockClient((request) => handler(request)),
      storage: null,
    );

void main() {
  testWidgets('Stock liste les materiaux et signale ceux sous seuil', (
    tester,
  ) async {
    final api = _api((request) async {
      if (request.url.path.endsWith('/stock')) {
        return _ok([
          {
            'id': 1,
            'code': 'MAT-001',
            'designation': 'Ciment',
            'unite': 'sac',
            'stock': 4,
            'seuil_alerte': 10,
            'sous_seuil': true,
          },
          {
            'id': 2,
            'code': 'MAT-002',
            'designation': 'Sable',
            'unite': 'm3',
            'stock': 120,
            'seuil_alerte': 20,
            'sous_seuil': false,
          },
        ]);
      }
      return _ok([]);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StockScreen(api: api, role: 'magasinier'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ciment'), findsOneWidget);
    expect(find.text('Sable'), findsOneWidget);
    expect(find.textContaining('1 sous seuil'), findsOneWidget);
    expect(find.text('Sortie'), findsNWidgets(2));
  });

  testWidgets('Stock ouvre la feuille de mouvement', (tester) async {
    final api = _api((request) async {
      if (request.url.path.endsWith('/stock')) {
        return _ok([
          {
            'id': 7,
            'code': 'MAT-007',
            'designation': 'Brique',
            'unite': 'unité',
            'stock': 500,
            'seuil_alerte': null,
            'sous_seuil': false,
          },
        ]);
      }
      return _ok([]);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StockScreen(api: api, role: 'magasinier'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sortie'));
    await tester.pumpAndSettle();

    expect(find.text('Mouvement de stock'), findsOneWidget);
    expect(find.text('Stock actuel : 500 unité'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Quantité (unité)'),
      findsOneWidget,
    );
  });

  testWidgets('Facturation synthese les montants et filtre par statut', (
    tester,
  ) async {
    final api = _api((request) async {
      if (request.url.path.endsWith('/devis')) {
        return _ok({
          'elements': [
            {
              'id': 1,
              'reference': 'DEV-001',
              'client_nom': 'SARL Ny Hasina',
              'date_devis': '2026-01-12',
              'montant_ttc': 1200000,
              'montant_paye': 0,
              'statut': 'accepte',
            },
            {
              'id': 2,
              'reference': 'DEV-002',
              'client_nom': 'Client Test',
              'date_devis': '2026-02-02',
              'montant_ttc': 300000,
              'montant_paye': 0,
              'statut': 'brouillon',
            },
          ],
          'total': 2,
        });
      }
      return _ok({'elements': [], 'total': 0});
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingScreen(api: api, role: 'comptable'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('DEV-001'), findsOneWidget);
    expect(find.text('DEV-002'), findsOneWidget);
    expect(find.text('1\u202f500\u202f000\u202fAr'), findsWidgets);

    // Le libelle "Brouillon" apparait aussi sur la carte du document :
    // on cible la puce de filtre pour lever l'ambiguite du tap().
    final puceBrouillon = find.descendant(
      of: find.byType(Scrollable).last,
      matching: find.text('Brouillon'),
    );
    await tester.tap(puceBrouillon.first);
    await tester.pumpAndSettle();

    expect(find.text('DEV-001'), findsNothing);
    expect(find.text('DEV-002'), findsOneWidget);
  });

  testWidgets('Facturation ne demande que les documents autorises', (
    tester,
  ) async {
    final requestedPaths = <String>[];
    final api = _api((request) async {
      requestedPaths.add(request.url.path);
      return _ok({'elements': [], 'total': 0});
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingScreen(api: api, role: 'chef_chantier'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(requestedPaths, ['/BTP_ERP/api/v1/devis']);
    // Le chef de chantier ne lit que les devis : l'onglet Factures est masque.
    expect(find.text('Devis (0)'), findsOneWidget);
    expect(find.text('Factures (0)'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Les listes mobiles affichent le nom métier de chaque élément', (
    tester,
  ) async {
    final cases = [
      (
        module: referentialModules.firstWhere((item) => item.id == 'employes'),
        record: {'id': 8, 'prenom': 'Miora', 'nom': 'Rakoto'},
        expectedTitle: 'Miora Rakoto',
      ),
      (
        module: appModules.firstWhere((item) => item.id == 'demandes-materiel'),
        record: {
          'id': 9,
          'numero': 'DM-009',
          'objet': 'Ciment pour fondations',
          'chantier_nom': 'Résidence Ivandry',
          'statut': 'en_attente',
        },
        expectedTitle: 'Ciment pour fondations',
      ),
      (
        module: appModules.firstWhere(
          (item) => item.id == 'rapports-journaliers',
        ),
        record: {
          'id': 10,
          'chantier_nom': 'Résidence Ivandry',
          'date_rapport': '2026-11-04',
        },
        expectedTitle: 'Résidence Ivandry · 04/11/2026',
      ),
      (
        module: appModules.firstWhere((item) => item.id == 'depenses'),
        record: {
          'id': 11,
          'numero': 'DEP-011',
          'libelle': 'Achat de sable',
          'chantier_nom': 'Résidence Ivandry',
        },
        expectedTitle: 'Achat de sable',
      ),
      (
        module: appModules.firstWhere((item) => item.id == 'budgets'),
        record: {'id': 12, 'chantier_nom': 'Résidence Ivandry', 'annee': 2026},
        expectedTitle: 'Résidence Ivandry · 2026',
      ),
    ];

    for (final item in cases) {
      final api = _api((request) async => _ok([item.record]));
      await tester.pumpWidget(
        MaterialApp(
          home: ApiModuleScreen(
            api: api,
            module: item.module,
            role: 'directeur',
            key: ValueKey(item.module.id),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(item.expectedTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('La liste des demandes affiche le tableau et garde le détail', (
    tester,
  ) async {
    final api = _api((request) async {
      if (request.url.path.endsWith('/demandes-materiel/3')) {
        return _ok({
          'id': 3,
          'numero': 'DM-003',
          'objet': 'Fer à béton 12 mm',
          'chantier_nom': 'Immeuble Galaxy Andraharo',
          'demandeur_nom': 'Rakotoarisoa',
          'demandeur_prenom': 'Hery',
          'urgence': 'urgente',
          'statut': 'valide',
          'date_demande': '2026-10-25',
          'notes': 'Livrer au dépôt nord.',
          'lignes': [
            {
              'designation': 'Fer à béton 12 mm',
              'unite': 'barre',
              'quantite_demandee': 25,
            },
          ],
        });
      }
      return _ok([
        {
          'id': 3,
          'numero': 'DM-003',
          'objet': 'Fer à béton 12 mm',
          'chantier_nom': 'Immeuble Galaxy Andraharo',
          'demandeur_nom': 'Rakotoarisoa',
          'demandeur_prenom': 'Hery',
          'urgence': 'urgente',
          'statut': 'valide',
          'date_demande': '2026-10-25',
        },
        {
          'id': 4,
          'numero': 'DM-004',
          'objet': 'Sable et gravillon',
          'chantier_nom': 'Réhabilitation RN2 PK12-PK20',
          'demandeur_nom': 'Rakotoarisoa',
          'demandeur_prenom': 'Hery',
          'urgence': 'normale',
          'statut': 'en_attente',
          'date_demande': '2026-10-22',
        },
        {
          'id': 5,
          'numero': 'DM-005',
          'objet': 'Parpaings 20',
          'chantier_nom': 'Résidence Ivandry',
          'demandeur_nom': 'Rakotoarisoa',
          'demandeur_prenom': 'Hery',
          'urgence': 'normale',
          'statut': 'traite',
          'date_demande': '2026-10-28',
        },
      ]);
    });
    final module = appModules.firstWhere(
      (item) => item.id == 'demandes-materiel',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ApiModuleScreen(api: api, module: module, role: 'directeur'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsOneWidget);
    for (final heading in [
      'N°',
      'Objet',
      'Chantier',
      'Demandeur',
      'Urgence',
      'Statut',
      'Date',
      'Actions',
    ]) {
      expect(find.text(heading), findsOneWidget);
    }
    expect(find.text('DM-003'), findsOneWidget);
    expect(find.text('Fer à béton 12 mm'), findsOneWidget);
    expect(find.text('Immeuble Galaxy Andraharo'), findsOneWidget);
    expect(find.text('Hery Rakotoarisoa'), findsNWidgets(3));
    expect(find.text('Urgente'), findsOneWidget);
    expect(find.text('25/10/2026'), findsOneWidget);
    expect(find.text('Sable et gravillon'), findsOneWidget);
    expect(find.text('Parpaings 20'), findsOneWidget);
    expect(find.text('Validée'), findsOneWidget);
    expect(find.text('En attente'), findsOneWidget);
    expect(find.text('Traitée'), findsOneWidget);
    expect(find.text('en_attente'), findsNothing);

    await tester.tap(find.text('Fer à béton 12 mm').first);
    await tester.pumpAndSettle();

    expect(find.text('Détail'), findsNothing);
    expect(find.text('Livrer au dépôt nord.'), findsOneWidget);
    expect(find.text('Fer à béton 12 mm'), findsOneWidget);
  });

  testWidgets('Les actions d’approbation apparaissent en tête du détail', (
    tester,
  ) async {
    final requests = <http.Request>[];
    var status = 'en_attente';
    final api = _api((request) async {
      requests.add(request);
      if (request.method == 'POST' &&
          request.url.path.endsWith('/demandes-materiel/3/approuver')) {
        status = 'valide';
        return _ok({});
      }
      if (request.method == 'GET' &&
          request.url.path.endsWith('/demandes-materiel/3')) {
        return _ok({
          'id': 3,
          'numero': 'DM-003',
          'objet': 'Fer à béton 12 mm',
          'statut': status,
          'date_demande': '2026-10-25',
          'lignes': [
            {
              'designation': 'Fer à béton 12 mm',
              'unite': 'barre',
              'quantite_demandee': 25,
            },
          ],
        });
      }
      return _ok([]);
    });
    final module = appModules.firstWhere(
      (item) => item.id == 'demandes-materiel',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RecordDetailScreen(
          api: api,
          module: module,
          role: 'directeur',
          item: const {'id': 3},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final approveButton = find.widgetWithText(FilledButton, 'Approuver');
    final rejectButton = find.widgetWithText(OutlinedButton, 'Refuser');
    expect(approveButton, findsOneWidget);
    expect(rejectButton, findsOneWidget);
    expect(
      tester.getTopLeft(approveButton).dy,
      lessThan(tester.getTopLeft(find.text('Lignes')).dy),
    );

    await tester.tap(approveButton);
    await tester.pumpAndSettle();

    expect(
      requests.any(
        (request) =>
            request.method == 'POST' &&
            request.url.path.endsWith('/demandes-materiel/3/approuver'),
      ),
      isTrue,
    );
    expect(find.text('Approuver'), findsNothing);
  });

  testWidgets('La recherche des demandes interroge l’API en temps réel', (
    tester,
  ) async {
    final requestedUris = <Uri>[];
    final api = _api((request) async {
      requestedUris.add(request.url);
      final records = [
        {
          'id': 3,
          'numero': 'DM-003',
          'objet': 'Fer à béton 12 mm',
          'chantier_nom': 'Immeuble Galaxy Andraharo',
          'demandeur_nom': 'Rakotoarisoa',
          'demandeur_prenom': 'Hery',
          'urgence': 'urgente',
          'statut': 'valide',
          'date_demande': '2026-10-25',
        },
        {
          'id': 4,
          'numero': 'DM-004',
          'objet': 'Sable et gravillon',
          'chantier_nom': 'Réhabilitation RN2 PK12-PK20',
          'demandeur_nom': 'Rakotoarisoa',
          'demandeur_prenom': 'Hery',
          'urgence': 'normale',
          'statut': 'en_attente',
          'date_demande': '2026-10-22',
        },
      ];
      final query = request.url.queryParameters['recherche']?.toLowerCase();
      return _ok(
        query == null || query.isEmpty
            ? records
            : records
                  .where(
                    (item) =>
                        item['objet'].toString().toLowerCase().contains(query),
                  )
                  .toList(),
      );
    });
    final module = appModules.firstWhere(
      (item) => item.id == 'demandes-materiel',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ApiModuleScreen(api: api, module: module, role: 'directeur'),
      ),
    );
    await tester.pumpAndSettle();
    expect(requestedUris, hasLength(1));
    expect(requestedUris.first.queryParameters, isEmpty);

    await tester.enterText(find.byType(TextField), 'Fer');
    await tester.pump(const Duration(milliseconds: 200));
    expect(requestedUris, hasLength(1));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();

    expect(find.text('Fer à béton 12 mm'), findsOneWidget);
    expect(find.text('Sable et gravillon'), findsNothing);
    expect(requestedUris, hasLength(2));
    expect(requestedUris.last.queryParameters['recherche'], 'Fer');

    await tester.enterText(find.byType(TextField), 'recherche inconnue');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('Aucun résultat pour cette recherche.'), findsOneWidget);
    expect(requestedUris, hasLength(3));
    expect(
      requestedUris.last.queryParameters['recherche'],
      'recherche inconnue',
    );
  });

  testWidgets('Le détail client affiche une fiche mobile structurée', (
    tester,
  ) async {
    final api = _api((request) async {
      return _ok({
        'id': 4,
        'nom': 'Galaxy Andraharo SA',
        'contact': 'M. Ralaivao',
        'telephone': '0340000000',
        'actif': 1,
      });
    });
    final module = referentialModules.firstWhere(
      (item) => item.id == 'clients',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RecordDetailScreen(
          api: api,
          module: module,
          role: 'magasinier',
          item: const {'id': 4, 'nom': 'Galaxy Andraharo SA'},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Galaxy Andraharo SA'), findsOneWidget);
    expect(find.text('Informations'), findsOneWidget);
    expect(find.text('Nom / raison sociale'), findsNothing);
    expect(find.text('Contact'), findsOneWidget);
    expect(find.text('Oui'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Le détail achat affiche les noms des relations', (tester) async {
    final api = _api((request) async {
      return _ok({
        'id': 42,
        'reference': 'ACH-042',
        'fournisseur_id': 3,
        'fournisseur_nom': 'Location Engins Boeny',
        'chantier_id': 5,
        'chantier_nom': 'Residence Ivandry Park',
        'cree_par': 9,
        'cree_par_nom': 'Miora Rakoto',
        'statut': 'recu',
        'montant_total': 380000,
        'lignes': [],
      });
    });
    final module = appModules.firstWhere((item) => item.id == 'achats');

    await tester.pumpWidget(
      MaterialApp(
        home: RecordDetailScreen(
          api: api,
          module: module,
          role: 'comptable',
          item: const {'id': 42},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Location Engins Boeny'), findsOneWidget);
    expect(find.text('Residence Ivandry Park'), findsOneWidget);
    expect(find.text('Miora Rakoto'), findsOneWidget);
    expect(find.text('3'), findsNothing);
    expect(find.text('5'), findsNothing);
    expect(find.text('9'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Le rechargement du chantier après le pointage reste synchrone', (
    tester,
  ) async {
    final api = _api((request) async {
      if (request.url.path.endsWith('/employes')) {
        return _ok({'elements': []});
      }
      if (request.url.path.endsWith('/pointages')) return _ok([]);
      return _ok({
        'id': 7,
        'nom': 'Chantier test',
        'stats': {'avancement_global': 0, 'nb_lots': 0},
        'lots': [],
      });
    });
    final module = appModules.firstWhere((item) => item.id == 'chantiers');

    await tester.pumpWidget(
      MaterialApp(
        home: RecordDetailScreen(
          api: api,
          module: module,
          role: 'comptable',
          item: const {'id': 7, 'nom': 'Chantier test'},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Consulter la feuille de pointage'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Consulter la feuille de pointage'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Chantier test'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Les graphiques se dessinent sans debordement', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: Column(
              children: [
                AreaChart(
                  labels: const ['Jan', 'Fev', 'Mar'],
                  series: const [
                    ChartSeries(
                      name: 'Facture',
                      color: Color(0xFF2C6EA4),
                      values: [10, 40, 25],
                    ),
                    ChartSeries(
                      name: 'Encaisse',
                      color: Color(0xFF2F9E6F),
                      values: [5, 20, 30],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 140,
                  child: DonutChart(
                    segments: [
                      DonutSegment(name: 'Alpha', value: 60),
                      DonutSegment(name: 'Beta', value: 40),
                    ],
                    centerSubLabel: 'CA total',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
