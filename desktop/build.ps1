param(
    [string]$OutputDirectory = "",
    [switch]$RunMigrations
)

$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$releaseUrl = "https://github.com/cztomczak/phpdesktop/releases/download/chrome-v130.1/phpdesktop-chrome-130.1-php-8.3.zip"
$releaseName = "phpdesktop-chrome-130.1-php-8.3"

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $OutputDirectory = Join-Path $PSScriptRoot "build\DigitalChantier-$timestamp"
} elseif (-not [System.IO.Path]::IsPathRooted($OutputDirectory)) {
    $OutputDirectory = Join-Path $projectRoot $OutputDirectory
}

$OutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
if (Test-Path $OutputDirectory) {
    throw "Le dossier de sortie existe déjà : $OutputDirectory"
}

$temporaryDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ("digital-chantier-" + [guid]::NewGuid().ToString("N"))
$archivePath = Join-Path $temporaryDirectory "$releaseName.zip"

try {
    New-Item -ItemType Directory -Path $temporaryDirectory | Out-Null
    Write-Host "Téléchargement du runtime PHP Desktop officiel..."
    Invoke-WebRequest -Uri $releaseUrl -OutFile $archivePath

    $extractionDirectory = Join-Path $temporaryDirectory "runtime"
    Expand-Archive -LiteralPath $archivePath -DestinationPath $extractionDirectory

    $executables = @(Get-ChildItem -Path $extractionDirectory -Filter "phpdesktop-chrome.exe" -File -Recurse)
    if ($executables.Count -ne 1) {
        throw "Le paquet téléchargé ne contient pas un unique phpdesktop-chrome.exe."
    }

    $packageRoot = $executables[0].Directory.FullName
    $webRoot = Join-Path $packageRoot "www"
    $settingsPath = Join-Path $packageRoot "settings.json"
    if (-not (Test-Path $webRoot -PathType Container) -or -not (Test-Path $settingsPath -PathType Leaf)) {
        throw "Structure du paquet PHP Desktop inattendue (www ou settings.json manquant)."
    }

    $settings = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json
    if ($null -eq $settings.web_server -or $null -eq $settings.main_window) {
        throw "Le fichier settings.json ne contient pas la configuration attendue."
    }
    $settings.web_server.listen_on = @("127.0.0.1", 0)
    $settings.web_server.'404_handler' = "/index.php"
    $settings.web_server.hide_files = @(".*", "*.sql", "*.md", "*.log", "cli.php", "composer.*")
    $settings.main_window.title = "Digital Chantier"
    $settingsJson = ConvertTo-Json -InputObject $settings -Depth 100
    [System.IO.File]::WriteAllText($settingsPath, $settingsJson, [System.Text.UTF8Encoding]::new($false))

    Remove-Item -LiteralPath $webRoot -Recurse -Force
    New-Item -ItemType Directory -Path $webRoot | Out-Null
    $stagedProjectFiles = @(
        "app",
        "assets\css",
        "assets\js",
        "assets\uploads\.htaccess",
        "assets\uploads\.gitkeep",
        "database\.htaccess",
        "database\migrations",
        "routes",
        "storage\.htaccess",
        "index.php",
        "cli.php",
        "composer.json",
        "composer.lock",
        ".env.example"
    )
    foreach ($relativePath in $stagedProjectFiles) {
        $sourcePath = Join-Path $projectRoot $relativePath
        if (-not (Test-Path $sourcePath)) {
            throw "Fichier requis introuvable : $relativePath"
        }

        $destinationPath = Join-Path $webRoot $relativePath
        if (Test-Path $sourcePath -PathType Container) {
            New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
            Get-ChildItem -LiteralPath $sourcePath -Force | Copy-Item -Destination $destinationPath -Recurse -Force
        } else {
            $destinationParent = Split-Path -Parent $destinationPath
            New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
            Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Force
        }
    }

    $envPath = Join-Path $webRoot ".env"
    $envContent = [System.IO.File]::ReadAllText((Join-Path $webRoot ".env.example"))
    $envContent = [System.Text.RegularExpressions.Regex]::Replace(
        $envContent,
        "(?m)^APP_ENV=.*$",
        "APP_ENV=local`r`nAPP_DESKTOP=true"
    )
    [System.IO.File]::WriteAllText($envPath, $envContent, [System.Text.UTF8Encoding]::new($false))

    $phpPath = Join-Path $packageRoot "php\php.exe"
    if (-not (Test-Path $phpPath -PathType Leaf)) {
        throw "PHP Desktop ne contient pas php\php.exe."
    }

    $phpIniPath = Join-Path $packageRoot "php\php.ini"
    $fileInfoExtension = Join-Path $packageRoot "php\ext\php_fileinfo.dll"
    $mbStringExtension = Join-Path $packageRoot "php\ext\php_mbstring.dll"
    if (-not (Test-Path $phpIniPath -PathType Leaf) -or -not (Test-Path $fileInfoExtension -PathType Leaf) -or -not (Test-Path $mbStringExtension -PathType Leaf)) {
        throw "Le runtime PHP Desktop doit fournir php.ini ainsi que les extensions fileinfo et mbstring."
    }
    $phpIni = [System.IO.File]::ReadAllText($phpIniPath)
    $phpIni = [System.Text.RegularExpressions.Regex]::Replace($phpIni, "(?im)^\s*extension\s*=\s*php_gd2\.dll\s*$", "; extension=php_gd2.dll")
    $phpIni = [System.Text.RegularExpressions.Regex]::Replace($phpIni, "(?im)^\s*extension\s*=\s*php_mysql\.dll\s*$", "; extension=php_mysql.dll")
    foreach ($extension in @("fileinfo", "mbstring")) {
        $line = "extension=php_$extension.dll"
        if ($phpIni -match "(?im)^\s*;?\s*extension\s*=\s*php_$extension\.dll\s*$") {
            $phpIni = [System.Text.RegularExpressions.Regex]::Replace(
                $phpIni,
                "(?im)^\s*;?\s*extension\s*=\s*php_$extension\.dll\s*$",
                $line
            )
        } else {
            $phpIni = [System.Text.RegularExpressions.Regex]::Replace(
                $phpIni,
                "(?im)^extension_dir\s*=.*$",
                '$0' + "`r`n$line"
            )
        }
    }
    [System.IO.File]::WriteAllText($phpIniPath, $phpIni, [System.Text.UTF8Encoding]::new($false))

    $phpModules = @(& $phpPath -m)
    if ($LASTEXITCODE -ne 0 -or $phpModules -notcontains "pdo_mysql" -or $phpModules -notcontains "fileinfo" -or $phpModules -notcontains "mbstring") {
        throw "Le runtime PHP Desktop doit charger PDO MySQL, fileinfo et mbstring sans erreur."
    }

    if (-not (Get-Command composer -ErrorAction SilentlyContinue)) {
        throw "Composer est requis pour installer les dépendances dans le paquet."
    }
    & composer install --working-dir="$webRoot" --no-dev --optimize-autoloader --no-interaction
    if ($LASTEXITCODE -ne 0) {
        throw "L'installation des dépendances Composer a échoué."
    }

    New-Item -ItemType Directory -Path (Split-Path -Parent $OutputDirectory) -Force | Out-Null
    Move-Item -LiteralPath $packageRoot -Destination $OutputDirectory

    $builtWebRoot = Join-Path $OutputDirectory "www"
    if ($RunMigrations) {
        Push-Location $builtWebRoot
        try {
            & (Join-Path $OutputDirectory "php\php.exe") "cli.php" "migrate"
            if ($LASTEXITCODE -ne 0) {
                throw "Les migrations de la base locale ont échoué."
            }
            & (Join-Path $OutputDirectory "php\php.exe") "cli.php" "seed"
            if ($LASTEXITCODE -ne 0) {
                throw "La création du compte de démonstration a échoué."
            }
        } finally {
            Pop-Location
        }
    }

    Write-Host ""
    Write-Host "Paquet PHP Desktop créé : $OutputDirectory"
    Write-Host "Vérifiez les paramètres MySQL dans $builtWebRoot\.env"
    if (-not $RunMigrations) {
        Write-Host "Puis exécutez les migrations et le compte de démonstration selon README.md."
    }
} finally {
    if (Test-Path $temporaryDirectory) {
        Remove-Item -LiteralPath $temporaryDirectory -Recurse -Force
    }
}
