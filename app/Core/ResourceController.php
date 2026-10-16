<?php

namespace App\Core;

use PDOException;

/**
 * Controleur REST generique pour les ressources CRUD (referentiels).
 * Les controleurs enfants configurent : $modele, $entite, les regles de validation,
 * la liste blanche de champs ($champs) et les colonnes de recherche.
 *
 * Fournit index / show / store / update / destroy avec pagination, recherche,
 * journalisation d'audit et gestion des erreurs SQL (doublons, contraintes).
 */
abstract class ResourceController extends Controller
{
    /** Instance du modele manipule (definie dans le constructeur enfant). */
    protected Model $modele;

    /** Libelle de l'entite (pour messages et audit), ex: 'client'. */
    protected string $entite = 'ressource';

    /** Module d'autorisation (identifiant du référentiel). */
    protected string $modulePermission = '';

    /** Regles de validation a la creation. @var array<string,string> */
    protected array $reglesCreation = [];

    /** Regles de validation a la modification (si vide, reutilise celles de creation). @var array<string,string> */
    protected array $reglesModification = [];

    /** Liste blanche des champs enregistrables (anti mass-assignment). @var string[] */
    protected array $champs = [];

    /** Colonnes prises en compte par la recherche. @var string[] */
    protected array $colonnesRecherche = [];

    /** GET liste : ?page=1&limite=50&recherche=terme */
    public function index(Request $requete): void
    {
        $limite   = max(1, min((int) $requete->query('limite', 50), 200));
        $page     = max(1, (int) $requete->query('page', 1));
        $decalage = ($page - 1) * $limite;
        $terme    = (string) $requete->query('recherche', '');

        $resultat = $this->modele->chercher($this->colonnesRecherche, $terme, $limite, $decalage);
        $elements = array_map(
            fn (array $ligne): array => $this->presenter($ligne, $requete),
            $resultat['lignes']
        );

        Response::succes([
            'elements' => $elements,
            'total'    => $resultat['total'],
            'page'     => $page,
            'limite'   => $limite,
        ], 'Liste des ' . $this->entite . 's');
    }

    /** GET un element par id */
    public function show(Request $requete): void
    {
        $ligne = $this->modele->trouver((int) $requete->params['id']);
        if ($ligne === null) {
            Response::erreur(ucfirst($this->entite) . ' introuvable.', 404);
        }
        Response::succes($this->presenter($ligne, $requete));
    }

    /** POST creation */
    public function store(Request $requete): void
    {
        $entree = $this->champsEntrants($requete, 'create');
        $donnees = $this->valider($entree, $this->reglesPourChamps($this->reglesCreation, $entree));
        $valeurs = $this->avantEnregistrement($this->filtrer($donnees), $requete);

        try {
            $id = $this->modele->creer($valeurs);
        } catch (PDOException $e) {
            $this->gererErreurSql($e);
        }

        Audit::enregistrer($this->entite . '.creation', $this->entite, $id, $valeurs, $this->utilisateurId($requete));
        Response::succes($this->presenter($this->modele->trouver($id), $requete), ucfirst($this->entite) . ' enregistre(e).', 201);
    }

    /** PUT modification */
    public function update(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        if ($this->modele->trouver($id) === null) {
            Response::erreur(ucfirst($this->entite) . ' introuvable.', 404);
        }

        $regles = $this->reglesModification !== [] ? $this->reglesModification : $this->reglesCreation;
        $entree = $this->champsEntrants($requete, 'edit');
        $donnees = $this->valider($entree, $this->reglesPourChamps($regles, $entree, true));
        $valeurs = $this->avantEnregistrement($this->filtrer($donnees), $requete);

        try {
            $this->modele->modifier($id, $valeurs);
        } catch (PDOException $e) {
            $this->gererErreurSql($e);
        }

        Audit::enregistrer($this->entite . '.modification', $this->entite, $id, $valeurs, $this->utilisateurId($requete));
        Response::succes($this->presenter($this->modele->trouver($id), $requete), ucfirst($this->entite) . ' modifie(e).');
    }

    /** DELETE suppression */
    public function destroy(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        if ($this->modele->trouver($id) === null) {
            Response::erreur(ucfirst($this->entite) . ' introuvable.', 404);
        }

        try {
            $this->modele->supprimer($id);
        } catch (PDOException $e) {
            // Contrainte de cle etrangere : l'element est reference ailleurs
            Response::erreur('Suppression impossible : cet element est utilise ailleurs.', 409);
        }

        Audit::enregistrer($this->entite . '.suppression', $this->entite, $id, [], $this->utilisateurId($requete));
        Response::succes(null, ucfirst($this->entite) . ' supprime(e).');
    }

    // ------------------------------------------------------------------
    //  Utilitaires
    // ------------------------------------------------------------------

    /** Point d'extension : transformer les donnees avant enregistrement. */
    protected function avantEnregistrement(array $donnees, Request $requete): array
    {
        return $donnees;
    }

    /** Ne conserve que les champs autorises ; convertit les chaines vides en NULL. */
    protected function filtrer(array $donnees): array
    {
        $valeurs = array_intersect_key($donnees, array_flip($this->champs));
        foreach ($valeurs as $cle => $valeur) {
            if ($valeur === '') {
                $valeurs[$cle] = null;
            }
        }
        return $valeurs;
    }

    protected function utilisateurId(Request $requete): ?int
    {
        return isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null;
    }

    /** Retire des donnees exposees les champs confidentiels du rôle. */
    protected function presenter(array $ligne, Request $requete): array
    {
        $champs = Access::champsReferentiel(
            $requete->auth['role'] ?? null,
            $this->modulePermission
        );
        return $champs === null ? $ligne : array_intersect_key($ligne, array_flip($champs));
    }

    /** Refuse explicitement les champs non autorises pour le rôle courant. */
    private function champsEntrants(Request $requete, string $action): array
    {
        $donnees = $requete->tout();
        $autorises = Access::champsReferentiel(
            $requete->auth['role'] ?? null,
            $this->modulePermission,
            $action
        );
        if ($autorises !== null) {
            $interdits = array_diff(array_keys($donnees), $autorises);
            if ($interdits !== []) {
                Response::erreur('Un ou plusieurs champs ne sont pas autorisés pour votre rôle.', 403, [
                    'champs' => array_values($interdits),
                ]);
            }
        }
        $champs = $autorises === null ? $this->champs : array_intersect($this->champs, $autorises);
        $donnees = array_intersect_key($donnees, array_flip($champs));
        if ($donnees === []) {
            Response::erreur('Aucune donnée modifiable n’a été transmise.', 422);
        }
        return $donnees;
    }

    /**
     * Applique les règles uniquement aux champs transmis. En édition, un champ
     * normalement obligatoire à la création reste facultatif pour les mises à jour partielles.
     *
     * @param array<string,string> $regles
     * @param array<string,mixed> $donnees
     * @return array<string,string>
     */
    private function reglesPourChamps(array $regles, array $donnees, bool $partiel = false): array
    {
        $regles = array_intersect_key($regles, $donnees);
        if ($partiel) {
            foreach ($regles as $champ => $regle) {
                $regles[$champ] = implode('|', array_filter(
                    explode('|', $regle),
                    static fn (string $element): bool => $element !== 'requis'
                ));
            }
        }
        return $regles;
    }

    protected function gererErreurSql(PDOException $e): void
    {
        // 23000 = violation de contrainte d'integrite (doublon d'unicite, etc.)
        if ($e->getCode() === '23000') {
            Response::erreur('Doublon : un enregistrement avec cette valeur unique existe deja.', 422);
        }
        throw $e;
    }
}
