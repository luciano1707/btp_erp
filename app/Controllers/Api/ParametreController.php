<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Env;
use App\Core\Request;
use App\Core\Response;
use App\Models\Parametre;

/**
 * API des parametres de l'entreprise (Phase parametres).
 * Lecture : tout utilisateur connecte (necessaire pour l'en-tete des documents imprimes).
 * Ecriture : directeur uniquement (garde par RoleMiddleware sur la route).
 */
final class ParametreController extends Controller
{
    /** Cles de reglages editables de l'entreprise. */
    private const CLES = [
        'entreprise_nom', 'entreprise_adresse', 'entreprise_telephone',
        'entreprise_email', 'entreprise_nif', 'entreprise_stat',
    ];

    /** Types d'images acceptes pour le logo. */
    private const TYPES_LOGO = [
        'image/png'  => 'png',
        'image/jpeg' => 'jpg',
        'image/webp' => 'webp',
    ];

    /** GET /api/v1/parametres */
    public function index(Request $requete): void
    {
        $modele = new Parametre();
        $tous = $modele->tous();

        $donnees = [];
        foreach (self::CLES as $cle) {
            $donnees[$cle] = $tous[$cle] ?? null;
        }

        $logo = $tous['entreprise_logo'] ?? null;
        $donnees['entreprise_logo'] = $logo;
        $donnees['logo_url'] = $logo ? rtrim((string) Env::get('APP_URL', ''), '/') . '/assets/' . ltrim($logo, '/') : null;

        Response::succes($donnees, 'Parametres de l\'entreprise');
    }

    /** PUT /api/v1/parametres */
    public function update(Request $requete): void
    {
        $modele = new Parametre();
        foreach (self::CLES as $cle) {
            $valeur = $requete->input($cle);
            if ($valeur !== null) {
                $modele->definir($cle, trim((string) $valeur));
            }
        }
        Audit::enregistrer('parametres.modification', 'parametres', null, [], $this->uid($requete));
        Response::succes(null, 'Parametres enregistres.');
    }

    /** POST /api/v1/parametres/logo  (multipart/form-data, champ "logo") */
    public function televerserLogo(Request $requete): void
    {
        if (!isset($_FILES['logo']) || $_FILES['logo']['error'] !== UPLOAD_ERR_OK) {
            Response::erreur('Aucun fichier recu ou televersement echoue.', 422);
        }

        $fichier = $_FILES['logo'];
        if ($fichier['size'] > 2 * 1024 * 1024) {
            Response::erreur('Le logo ne doit pas depasser 2 Mo.', 422);
        }

        // Detection du type reel (pas seulement l'extension annoncee)
        $type = (new \finfo(FILEINFO_MIME_TYPE))->file($fichier['tmp_name']);
        if (!isset(self::TYPES_LOGO[$type])) {
            Response::erreur('Format non supporte. Utilisez PNG, JPG ou WEBP.', 422);
        }
        $extension = self::TYPES_LOGO[$type];

        $racine = dirname(__DIR__, 3);
        $dossier = $racine . '/assets/uploads';
        if (!is_dir($dossier)) {
            @mkdir($dossier, 0775, true);
        }

        $nomFichier = 'logo-' . bin2hex(random_bytes(6)) . '.' . $extension;
        $destination = $dossier . '/' . $nomFichier;

        if (!move_uploaded_file($fichier['tmp_name'], $destination)) {
            Response::erreur('Impossible d\'enregistrer le fichier.', 500);
        }

        $modele = new Parametre();

        // Supprimer l'ancien logo pour ne pas accumuler les fichiers
        $ancien = $modele->obtenir('entreprise_logo');
        if ($ancien) {
            $cheminAncien = $racine . '/assets/' . ltrim($ancien, '/');
            if (is_file($cheminAncien)) {
                @unlink($cheminAncien);
            }
        }

        $relatif = 'uploads/' . $nomFichier;
        $modele->definir('entreprise_logo', $relatif);
        Audit::enregistrer('parametres.logo', 'parametres', null, ['fichier' => $relatif], $this->uid($requete));

        Response::succes([
            'entreprise_logo' => $relatif,
            'logo_url'        => rtrim((string) Env::get('APP_URL', ''), '/') . '/assets/' . $relatif,
        ], 'Logo mis a jour.');
    }

    private function uid(Request $requete): ?int
    {
        return isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null;
    }
}
