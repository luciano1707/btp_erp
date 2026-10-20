# Digital Chantier Desktop (Windows)

Cette version ouvre l'application PHP dans une fenetre Windows avec PHP Desktop.
Ce n'est pas un installateur : l'application utilise une base MySQL/MariaDB locale
et les fichiers du paquet doivent rester ensemble.

## Lancer un paquet deja genere

1. Demarrez **MySQL** dans le panneau de controle XAMPP. Apache n'est pas necessaire
   pour la version Desktop.
2. Ouvrez le dossier du paquet, par exemple
   `desktop\build\DigitalChantier-20261020-152909`.
3. Double-cliquez sur `phpdesktop-chrome.exe`, a la racine de ce dossier
   (pas dans le sous-dossier `www`).
4. Connectez-vous avec un compte de l'application.

Le paquet genere contient son propre PHP et son navigateur ; ne les lancez pas
separement. L'ordinateur doit aussi avoir acces a la base configuree dans
`www\.env`. Par defaut, le script de construction configure MySQL local sur
`127.0.0.1:3306`, base `btp_erp`, utilisateur `root` sans mot de passe.

## Construire un nouveau paquet

Prerequis : Windows 10 ou plus recent, XAMPP avec MySQL, Composer, une connexion
Internet pour telecharger PHP Desktop et les dependances.

Depuis PowerShell, a la racine du depot :

```powershell
.\desktop\build.ps1 -RunMigrations
```

Le paquet est cree dans un nouveau dossier
`desktop\build\DigitalChantier-<date>`. Le script applique les migrations en
attente et cree le compte de demonstration s'il n'existe pas deja. Il ne supprime
pas les donnees de la base existante.

Pour construire sans appliquer les migrations ni creer le compte de demonstration :

```powershell
.\desktop\build.ps1
```

Pour choisir un dossier de sortie qui n'existe pas encore :

```powershell
.\desktop\build.ps1 -OutputDirectory "desktop\build\DigitalChantier-test" -RunMigrations
```

## Base de donnees et comptes

- La base n'est pas incluse dans le paquet : chaque ordinateur doit disposer de
  MySQL/MariaDB et d'une base configuree.
- Pour un autre ordinateur, adaptez les valeurs `DB_HOST`, `DB_PORT`, `DB_NAME`,
  `DB_USER` et `DB_PASS` dans `www\.env`, puis appliquez les migrations avec le
  PHP embarque, depuis PowerShell :

  ```powershell
  Set-Location "CHEMIN\VERS\DigitalChantier-<date>\www"
  ..\php\php.exe cli.php migrate
  ..\php\php.exe cli.php seed
  ```

- Si le compte de demonstration a ete cree, ses identifiants initiaux sont
  `directeur@digitalchantier.mg` et `Directeur@2026`. Changez le mot de passe
  provisoire apres la premiere connexion.
- Ne partagez pas le fichier `www\.env` s'il contient des mots de passe ou des
  identifiants propres a votre ordinateur.

## Depannage rapide

### L'application ne demarre pas

- Verifiez que vous lancez `phpdesktop-chrome.exe` depuis le dossier complet du
  paquet, sans separer ou deplacer ses fichiers.
- Si Windows affiche un avertissement de securite, verifiez l'origine du paquet
  avant d'autoriser son execution.
- Pour reconstruire le paquet, utilisez le script `desktop\build.ps1` depuis le
  depot et consultez les erreurs affichees dans PowerShell.

### Erreur de connexion a la base

- Demarrez MySQL dans XAMPP.
- Verifiez les parametres `DB_*` dans `www\.env` et assurez-vous que la base existe.
- Depuis `www`, relancez les migrations avec `..\php\php.exe cli.php migrate`.

### Connexion impossible

Verifiez que le compte existe et qu'il est actif. Le compte de demonstration peut
etre cree avec `..\php\php.exe cli.php seed` depuis `www`.

### Les boutons Entrer / Sortie du stock sont absents

Le compte connecte doit avoir le droit de creer des mouvements de stock. Verifiez
egalement que le paquet a ete construit depuis une version recente du depot.

## Journaux

Les messages du runtime PHP Desktop sont ecrits dans `debug.log` a la racine du
paquet. Les erreurs applicatives PHP sont journalisees sous `www\storage\logs`.
