<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Database;
use App\Core\Env;
use App\Core\Jwt;
use App\Core\Logger;
use App\Core\Mailer;
use App\Core\Request;
use App\Core\Response;
use App\Models\RefreshToken;
use App\Models\PasswordReset;
use App\Models\Utilisateur;
use Throwable;

/**
 * Authentification JWT (Phase 1).
 *
 * Strategie de tokens :
 *  - access token (courte duree) : renvoye dans le corps JSON, garde en memoire cote client.
 *  - refresh token (longue duree) :
 *      * WEB    -> depose en cookie httpOnly (invisible au JavaScript, protege du XSS)
 *      * MOBILE -> renvoye dans le corps JSON (stockage securise cote application)
 *  Les refresh tokens sont stockes hashes en base pour permettre revocation et rotation.
 */
final class AuthController extends Controller
{
    /** Nombre max d'echecs de connexion par IP avant blocage temporaire. */
    private const MAX_TENTATIVES = 10;

    /** POST /api/v1/auth/login */
    public function login(Request $requete): void
    {
        $this->verifierTentatives();

        $donnees = $this->valider($requete->tout(), [
            'email'        => 'requis|email',
            'mot_de_passe' => 'requis',
        ]);

        $client = $requete->input('client', 'web') === 'mobile' ? 'mobile' : 'web';

        $modele = new Utilisateur();
        $utilisateur = $modele->trouverParEmail((string) $donnees['email']);

        if ($utilisateur === null || !password_verify((string) $donnees['mot_de_passe'], $utilisateur['mot_de_passe'])) {
            Audit::enregistrer('connexion.echec', 'utilisateur', null, ['email' => $donnees['email']]);
            Response::erreur('Identifiants incorrects.', 401);
        }

        if (!(bool) $utilisateur['actif']) {
            Response::erreur('Ce compte est desactive. Contactez la direction.', 403);
        }

        $modele->marquerConnexion((int) $utilisateur['id']);
        Audit::enregistrer('connexion', 'utilisateur', (int) $utilisateur['id'], ['client' => $client], (int) $utilisateur['id']);

        $this->emettreTokens($utilisateur, $client, 'Connexion reussie');
    }

    /** POST /api/v1/auth/mot-de-passe-oublie */
    public function motDePasseOublie(Request $requete): void
    {
        $donnees = $this->valider($requete->tout(), ['email' => 'requis|email']);
        $email = strtolower(trim((string) $donnees['email']));
        $message = 'Si un compte correspond a cette adresse, un code a ete envoye.';
        $utilisateur = (new Utilisateur())->trouverParEmail($email);

        if ($utilisateur === null || !(bool) $utilisateur['actif']) {
            Response::succes(null, $message);
        }

        $reset = new PasswordReset();
        if ($reset->aDemandeRecente($email)) {
            Response::succes(null, $message);
        }

        $code = (string) random_int(100000, 999999);
        $reset->invaliderAnciennes((int) $utilisateur['id']);
        $demandeId = $reset->creerDemande((int) $utilisateur['id'], $email, $code, time() + 900);
        if (!Mailer::envoyerCodeOtp($email, $code)) {
            $reset->marquerUtilise($demandeId);
            Response::erreur('Impossible d’envoyer le code pour le moment. Veuillez réessayer.', 503);
        }

        Response::succes(null, $message);
    }

    /** POST /api/v1/auth/reinitialiser-mot-de-passe */
    public function reinitialiserMotDePasse(Request $requete): void
    {
        $donnees = $this->valider($requete->tout(), [
            'email' => 'requis|email', 'code' => 'requis',
            'nouveau_mot_de_passe' => 'requis|longueur_min:8|confirme',
        ]);
        $reset = new PasswordReset();
        $demande = $reset->trouverValide((string) $donnees['email']);
        if ($demande === null || !hash_equals($demande['code_hash'], PasswordReset::empreinte((string) $donnees['code']))) {
            if ($demande !== null) {
                $reset->incrementerTentatives((int) $demande['id']);
            }
            Response::erreur('Code invalide ou expire.', 422);
        }

        $utilisateur = (new Utilisateur())->trouver((int) $demande['utilisateur_id']);
        if ($utilisateur === null || !(bool) $utilisateur['actif']) {
            Response::erreur('Code invalide ou expire.', 422);
        }
        $modele = new Utilisateur();
        $modele->definirMotDePasse((int) $utilisateur['id'], password_hash((string) $donnees['nouveau_mot_de_passe'], PASSWORD_DEFAULT));
        $reset->marquerUtilise((int) $demande['id']);
        (new RefreshToken())->revoquerTous((int) $utilisateur['id']);
        Audit::enregistrer('mot_de_passe.reinitialise', 'utilisateur', (int) $utilisateur['id'], [], (int) $utilisateur['id']);

        Response::succes(null, 'Mot de passe reinitialise. Vous pouvez vous connecter.');
    }

    /** POST /api/v1/auth/refresh */
    public function refresh(Request $requete): void
    {
        $depuisCookie = $requete->cookie('refresh_token');
        $token = $depuisCookie ?? (string) $requete->input('refresh_token', '');
        $client = $depuisCookie !== null ? 'web' : 'mobile';

        if ($token === '' || $token === null) {
            Response::erreur('Refresh token manquant.', 401);
        }

        try {
            $charge = Jwt::decoder($token);
        } catch (Throwable $e) {
            $this->supprimerCookieRefresh();
            Response::erreur('Refresh token invalide ou expire.', 401);
        }

        if (($charge['type'] ?? null) !== 'refresh') {
            Response::erreur('Type de token invalide.', 401);
        }

        $modeleToken = new RefreshToken();
        if ($modeleToken->trouverValide($token) === null) {
            Response::erreur('Refresh token revoque ou inconnu. Reconnexion requise.', 401);
        }

        // Rotation : l'ancien refresh token est immediatement revoque
        $modeleToken->revoquer($token);

        $utilisateur = (new Utilisateur())->trouver((int) $charge['sub']);
        if ($utilisateur === null || !(bool) $utilisateur['actif']) {
            Response::erreur('Compte introuvable ou desactive.', 403);
        }

        Audit::enregistrer('token.refresh', 'utilisateur', (int) $utilisateur['id'], [], (int) $utilisateur['id']);
        $this->emettreTokens($utilisateur, $client, 'Token rafraichi');
    }

    /** POST /api/v1/auth/logout */
    public function logout(Request $requete): void
    {
        $token = $requete->cookie('refresh_token') ?? (string) $requete->input('refresh_token', '');
        if ($token !== '' && $token !== null) {
            (new RefreshToken())->revoquer($token);
        }
        $this->supprimerCookieRefresh();

        // Recuperer l'auteur pour l'audit, si un access token est present
        $uid = null;
        $bearer = $requete->tokenBearer();
        if ($bearer !== null) {
            try {
                $uid = (int) (Jwt::decoder($bearer)['sub'] ?? 0) ?: null;
            } catch (Throwable $e) {
                // token deja expire : sans importance pour la deconnexion
            }
        }
        Audit::enregistrer('deconnexion', 'utilisateur', $uid, [], $uid);

        Response::succes(null, 'Deconnexion reussie');
    }

    /** GET /api/v1/auth/me  (protege par AuthMiddleware) */
    public function moi(Request $requete): void
    {
        $utilisateur = (new Utilisateur())->trouver((int) $requete->auth['sub']);
        if ($utilisateur === null) {
            Response::erreur('Utilisateur introuvable.', 404);
        }
        Response::succes(Utilisateur::versPublic($utilisateur), 'Profil utilisateur');
    }

    /** PUT /api/v1/auth/me : modifie les informations personnelles uniquement. */
    public function modifierProfil(Request $requete): void
    {
        $donnees = $this->valider($requete->tout(), [
            'nom' => 'requis', 'prenom' => 'requis', 'email' => 'requis|email',
        ]);
        $id = (int) $requete->auth['sub'];
        $modele = new Utilisateur();
        $existant = $modele->trouverParEmail((string) $donnees['email']);
        if ($existant !== null && (int) $existant['id'] !== $id) {
            Response::erreur('Cette adresse e-mail est deja utilisee.', 422);
        }

        $modele->definirProfil(
            $id,
            trim((string) $donnees['nom']),
            trim((string) $donnees['prenom']),
            (string) $donnees['email'],
            trim((string) $requete->input('telephone', ''))
        );
        $utilisateur = $modele->trouver($id);
        Audit::enregistrer('profil.modifie', 'utilisateur', $id, [], $id);
        Response::succes(Utilisateur::versPublic($utilisateur), 'Profil modifie.');
    }

    /** POST /api/v1/auth/mot-de-passe  (protege par AuthMiddleware) */
    public function changerMotDePasse(Request $requete): void
    {
        $donnees = $this->valider($requete->tout(), [
            'mot_de_passe_actuel'  => 'requis',
            'nouveau_mot_de_passe' => 'requis|longueur_min:8|confirme',
        ]);

        $modele = new Utilisateur();
        $utilisateur = $modele->trouver((int) $requete->auth['sub']);

        if ($utilisateur === null || !password_verify((string) $donnees['mot_de_passe_actuel'], $utilisateur['mot_de_passe'])) {
            Response::erreur('Le mot de passe actuel est incorrect.', 422);
        }

        $modele->definirMotDePasse(
            (int) $utilisateur['id'],
            password_hash((string) $donnees['nouveau_mot_de_passe'], PASSWORD_DEFAULT)
        );

        // Securite : invalider toutes les sessions existantes apres changement de mot de passe
        (new RefreshToken())->revoquerTous((int) $utilisateur['id']);
        $this->supprimerCookieRefresh();
        Audit::enregistrer('mot_de_passe.change', 'utilisateur', (int) $utilisateur['id'], [], (int) $utilisateur['id']);

        Response::succes(null, 'Mot de passe modifie. Merci de vous reconnecter.');
    }

    // ------------------------------------------------------------------
    //  Helpers internes
    // ------------------------------------------------------------------

    /**
     * Genere la paire de tokens, stocke le refresh (hashe), et repond.
     *
     * @param array<string,mixed> $utilisateur
     */
    private function emettreTokens(array $utilisateur, string $client, string $message): void
    {
        $id = (int) $utilisateur['id'];
        $accessTtl  = (int) Env::get('JWT_ACCESS_TTL', 900);
        $refreshTtl = (int) Env::get('JWT_REFRESH_TTL', 604800);

        $accessToken  = Jwt::encoder(['sub' => $id, 'role' => $utilisateur['role']], $accessTtl, 'access');
        $refreshToken = Jwt::encoder(['sub' => $id], $refreshTtl, 'refresh');

        (new RefreshToken())->enregistrer($id, $refreshToken, time() + $refreshTtl);

        $donnees = [
            'access_token' => $accessToken,
            'type_token'   => 'Bearer',
            'expire_dans'  => $accessTtl,
            'utilisateur'  => Utilisateur::versPublic($utilisateur),
        ];

        if ($client === 'mobile') {
            // Le mobile gere lui-meme le stockage securise du refresh token
            $donnees['refresh_token'] = $refreshToken;
        } else {
            // Web : refresh token en cookie httpOnly, inaccessible au JavaScript
            $this->poserCookieRefresh($refreshToken, $refreshTtl);
        }

        Response::succes($donnees, $message);
    }

    /**
     * Anti-bruteforce : bloque temporairement une IP apres trop d'echecs recents.
     * S'appuie sur le journal d'audit (evenements connexion.echec des 15 dernieres minutes).
     */
    private function verifierTentatives(): void
    {
        $ip = $_SERVER['REMOTE_ADDR'] ?? null;
        if ($ip === null) {
            return;
        }
        $req = Database::connexion()->prepare(
            "SELECT COUNT(*) FROM journal_audit
             WHERE action = 'connexion.echec' AND adresse_ip = :ip
               AND cree_le > (NOW() - INTERVAL 15 MINUTE)"
        );
        $req->execute([':ip' => $ip]);
        if ((int) $req->fetchColumn() >= self::MAX_TENTATIVES) {
            Response::erreur('Trop de tentatives de connexion. Reessayez dans quelques minutes.', 429);
        }
    }

    private function poserCookieRefresh(string $token, int $ttl): void
    {
        setcookie('refresh_token', $token, [
            'expires'  => time() + $ttl,
            'path'     => '/',
            'httponly' => true,
            'samesite' => 'Lax',
            'secure'   => Env::get('APP_ENV', 'local') !== 'local',
        ]);
    }

    private function supprimerCookieRefresh(): void
    {
        setcookie('refresh_token', '', [
            'expires'  => time() - 3600,
            'path'     => '/',
            'httponly' => true,
            'samesite' => 'Lax',
            'secure'   => Env::get('APP_ENV', 'local') !== 'local',
        ]);
    }
}
