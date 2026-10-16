# Digital Chantier Mobile

Application Flutter Android/Web qui consomme la même API REST PHP que le site.

## Lancer sur le poste

1. Démarrer Apache et MySQL dans XAMPP.
2. Depuis `mobile_app`, lancer `flutter run -d chrome` pour le navigateur ou `flutter run` après avoir créé un émulateur Android dans Android Studio.
3. Sur l’écran de connexion, utiliser un compte existant de l’ERP.

L’URL locale par défaut est `http://localhost/BTP_ERP/api/v1` pour Chrome et `http://10.0.2.2/BTP_ERP/api/v1` pour l’émulateur Android. Pour une autre adresse, lancer Flutter avec `--dart-define=API_BASE_URL=https://votre-domaine.mg/api/v1`.

Les sessions utilisent l’API mobile existante. Le refresh token est conservé avec `flutter_secure_storage`; l’access token reste en mémoire et est renouvelé après une réponse 401. HTTP en clair est autorisé uniquement dans la configuration Android debug pour le XAMPP local; l’API de production doit utiliser HTTPS.

## Vérifications

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

## Structure

- `lib/core` : client et session API
- `lib/features` : écrans de connexion, tableau de bord, opérations et profil
- `lib/shared` : thème et composants partagés
- `lib/app` : orchestration et navigation# digital_chantier_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
