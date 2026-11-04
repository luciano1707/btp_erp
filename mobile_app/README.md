# Digital Chantier Mobile

Application Flutter Android et Web pour accéder aux fonctions de Digital Chantier via la même API REST PHP que le site. L’interface utilise la palette bleue du projet et les autorisations restent contrôlées par l’API.

## Développement local

1. Démarrer Apache et MySQL dans XAMPP.
2. À la racine `mobile_app`, exécuter `flutter pub get`.
3. Lancer `flutter run -d chrome` pour le Web ou `flutter run` avec un émulateur Android démarré.
4. Se connecter avec un compte ERP existant.

L’URL par défaut est `http://localhost/BTP_ERP/api/v1` dans Chrome et `http://10.0.2.2/BTP_ERP/api/v1` dans l’émulateur Android. Pour un serveur de test accessible sur le réseau, passer son URL avec `--dart-define=API_BASE_URL=http://adresse-du-serveur/BTP_ERP/api/v1`.

## Production Android

L’API de production doit être accessible en HTTPS. Construire l’APK de test avec :

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=https://votre-domaine.mg/api/v1
```

Pour livrer une version, configurer au préalable la signature Android dans `android/key.properties` et `android/app/build.gradle`, puis construire :

```powershell
flutter build appbundle --release --dart-define=API_BASE_URL=https://votre-domaine.mg/api/v1
```

Ne pas ajouter les clés de signature ou leurs mots de passe au dépôt. L’AAB se trouve dans `build/app/outputs/bundle/release/`.

## Vérifications

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

## Structure

- `lib/core` : client API, authentification et session sécurisée
- `lib/features` : connexion, accueil, chantiers, modules métier, notifications et profil
- `lib/shared` : thème bleu, libellés et composants partagés
- `lib/app` : orchestration et navigation

Les modules affichés dépendent du rôle connecté. Les actions d’approbation suivent l’étape indiquée par l’API; la visibilité dans l’application ne remplace jamais le contrôle des permissions côté serveur.
