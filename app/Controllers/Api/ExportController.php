<?php

namespace App\Controllers\Api;

use App\Core\Access;
use App\Core\Audit;
use App\Core\Controller;
use App\Core\Database;
use App\Core\ExportService;
use App\Core\Request;
use App\Core\Response;
use App\Core\ValidationService;
use App\Models\Budget;
use App\Models\Depense;
use App\Models\Devis;
use App\Models\MouvementStock;
use App\Models\Parametre;
use App\Models\Paiement;
use PDO;

/** Exports PDF / Excel centralises, avec controle de permissions et portee des filtres. */
final class ExportController extends Controller
{
    private const PERMISSIONS = [
        'chantiers' => 'chantiers',
        'lots' => 'lots',
        'clients' => 'clients',
        'fournisseurs' => 'fournisseurs',
        'employes' => 'employes',
        'engins' => 'engins',
        'materiaux' => 'materiaux',
        'stock' => 'stock',
        'achats' => 'achats',
        'devis' => 'devis',
        'factures' => 'factures',
        'depenses' => 'depenses',
        'budgets' => 'budgets',
        'pointages' => 'pointages',
        'demandes_materiel' => 'demandes_materiel',
        'rapports_journaliers' => 'rapports_journaliers',
        'rfi' => 'rfi',
        'qualite' => 'qualite',
        'securite' => 'securite',
        'incidents' => 'incidents',
        'utilisateurs' => 'utilisateurs',
    ];

    /** POST /api/v1/export/xlsx */
    public function exportXLSX(Request $requete): void
    {
        $module = (string) $requete->input('module');
        $filtres = $this->filtres($requete);
        $this->autoriser($requete, $module);

        $donnees = $this->recupererDonnees($module, $filtres);
        $colonnes = $this->obtenirColonnes($module);
        $titre = (string) $requete->input('titre', 'Export ' . $module);
        $nomFichier = $this->genererNomFichier($module, 'xlsx');

        $options = [
            'titre' => $titre,
            'filtres' => $filtres,
            'entete' => true,
            'totaux' => $this->calculerTotaux($donnees, 'chantiers' === $module || 'stock' === $module ? [] : null),
        ];
        $contenu = ExportService::genererXLSX($donnees, $colonnes, $nomFichier, $options);
        $this->tracer($requete, 'export.xlsx', $module, $filtres, count($donnees));

        ExportService::telecharger(
            $contenu,
            $nomFichier,
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        );
    }

    /** POST /api/v1/export/csv (compatibilite) */
    public function exportCSV(Request $requete): void
    {
        $module = (string) $requete->input('module');
        $filtres = $this->filtres($requete);
        $this->autoriser($requete, $module);

        $donnees = $this->recupererDonnees($module, $filtres);
        $colonnes = $this->obtenirColonnes($module);
        $nomFichier = $this->genererNomFichier($module, 'csv');

        $sortie = fopen('php://temp', 'r+');
        fwrite($sortie, "\xEF\xBB\xBF");
        fputcsv($sortie, array_keys($colonnes), ';');
        foreach ($donnees as $ligne) {
            $valeurs = [];
            foreach (array_values($colonnes) as $cle) {
                $valeurs[] = $ligne[$cle] ?? '';
            }
            fputcsv($sortie, $valeurs, ';');
        }
        rewind($sortie);
        $contenu = (string) stream_get_contents($sortie);
        fclose($sortie);

        $this->tracer($requete, 'export.csv', $module, $filtres, count($donnees));
        ExportService::telecharger($contenu, $nomFichier, 'text/csv; charset=UTF-8');
    }

    /** POST /api/v1/export/pdf */
    public function exportPDF(Request $requete): void
    {
        $module = (string) $requete->input('module');
        $filtres = $this->filtres($requete);
        $titre = (string) $requete->input('titre', 'Export ' . $module);

        $this->genererExportPDF($requete, $module, $filtres, $titre);
    }

    /** POST /export/pdf/{module} : telechargement navigateur sans requete fetch. */
    public function exportPDFNavigateur(Request $requete): void
    {
        $module = (string) ($requete->params['module'] ?? '');
        $filtres = $requete->input('filtres', []);
        if (is_string($filtres)) {
            $filtres = json_decode($filtres, true);
        }
        if (!is_array($filtres)) {
            Response::erreur('Filtres d\'export invalides.', 422);
        }
        $titre = (string) $requete->input('titre', 'Export ' . $module);

        $this->genererExportPDF($requete, $module, $filtres, $titre);
    }

    /** @param array<string,mixed> $filtres */
    private function genererExportPDF(Request $requete, string $module, array $filtres, string $titre): void
    {
        $this->autoriser($requete, $module);

        $donnees = $this->recupererDonnees($module, $filtres);
        $colonnes = $this->obtenirColonnes($module);

        $contenu = ExportService::genererPDF($donnees, $colonnes, $titre, [
            'filtres' => $filtres,
            'totaux' => $this->calculerTotaux($donnees),
            'entreprise' => $this->entreprise(),
            'utilisateur' => $this->nomUtilisateur($requete),
        ]);
        $this->tracer($requete, 'export.pdf', $module, $filtres, count($donnees));

        ExportService::afficherPDF($contenu, $this->genererNomFichier($module, 'pdf'));
    }

    /** POST /api/v1/export/devis-pdf : uniquement un devis approuve par le directeur. */
    public function exportDevisPDF(Request $requete): void
    {
        $id = (int) $requete->input('id');
        $this->genererDevisPDF($requete, $id);
    }

    /** POST /export/devis/{id}/pdf : telechargement navigateur d'un devis valide. */
    public function exportDevisPDFNavigateur(Request $requete): void
    {
        $id = (int) ($requete->params['id'] ?? 0);
        $this->genererDevisPDF($requete, $id);
    }

    private function genererDevisPDF(Request $requete, int $id): void
    {
        if ($id <= 0) {
            Response::erreur('ID du devis requis', 422);
        }

        $devis = (new Devis())->trouverAvecLignes($id);
        if ($devis === null) {
            Response::erreur('Devis introuvable', 404);
        }

        $valide = ($devis['statut'] ?? '') === 'accepte'
            || (new ValidationService())->estValidee('devis', $id);
        if (!$valide) {
            Response::erreur('Seuls les devis valides par le directeur peuvent etre exportes.', 403);
        }

        $contenu = ExportService::genererDevisPDF($devis, $devis['lignes'] ?? [], $this->entreprise());
        Audit::enregistrer('export.devis_pdf', 'devis', $id, [], $this->uid($requete));
        ExportService::afficherPDF($contenu, 'devis_' . ($devis['reference'] ?? $id));
    }

    /** POST /api/v1/export/rapport-financier-pdf : directeur / comptable uniquement. */
    public function exportRapportFinancierPDF(Request $requete): void
    {
        $filtres = $this->filtres($requete);
        $titre = (string) $requete->input('titre', 'Rapport financier');
        $this->genererRapportFinancierPDF($requete, $filtres, $titre);
    }

    /** POST /export/rapport-financier/pdf : telechargement navigateur direct. */
    public function exportRapportFinancierPDFNavigateur(Request $requete): void
    {
        $filtres = $requete->input('filtres', []);
        if (is_string($filtres)) {
            $filtres = json_decode($filtres, true);
        }
        if (!is_array($filtres)) {
            Response::erreur('Filtres d\'export invalides.', 422);
        }
        $titre = (string) $requete->input('titre', 'Rapport financier');
        $this->genererRapportFinancierPDF($requete, $filtres, $titre);
    }

    /** @param array<string,mixed> $filtres */
    private function genererRapportFinancierPDF(Request $requete, array $filtres, string $titre): void
    {
        $this->autoriserFinances($requete);
        $donnees = $this->recupererDonneesRapportFinancier($filtres);
        $colonnes = $this->obtenirColonnesRapportFinancier();
        $totaux = $this->totauxFinanciers($donnees);

        $contenu = ExportService::genererPDF($donnees, $colonnes, $titre, [
            'filtres' => $filtres,
            'totaux' => $totaux,
            'entreprise' => $this->entreprise(),
            'utilisateur' => $this->nomUtilisateur($requete),
        ]);
        $this->tracer($requete, 'export.rapport_financier_pdf', 'finances', $filtres, count($donnees));
        ExportService::afficherPDF($contenu, 'rapport_financier_' . date('Ymd_His'));
    }

    /** POST /api/v1/export/rapport-financier-xlsx */
    public function exportRapportFinancierXLSX(Request $requete): void
    {
        $this->autoriserFinances($requete);
        $filtres = $this->filtres($requete);
        $donnees = $this->recupererDonneesRapportFinancier($filtres);
        $colonnes = $this->obtenirColonnesRapportFinancier();
        $nomFichier = 'rapport_financier_' . date('YmdHis') . '.xlsx';

        $contenu = ExportService::genererXLSX($donnees, $colonnes, $nomFichier, [
            'titre' => 'Rapport financier',
            'filtres' => $filtres,
            'entete' => true,
            'totaux' => $this->totauxFinanciers($donnees),
        ]);
        $this->tracer($requete, 'export.rapport_financier_xlsx', 'finances', $filtres, count($donnees));
        ExportService::telecharger(
            $contenu,
            $nomFichier,
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        );
    }

    /** @param array<string,mixed> $filtres @return array<int,array<string,mixed>> */
    private function recupererDonnees(string $module, array $filtres): array
    {
        $pdo = Database::connexion();
        $recherche = trim((string) ($filtres['recherche'] ?? ''));
        $like = '%' . $recherche . '%';
        $params = [];
        $where = '';

        switch ($module) {
            case 'chantiers':
                $sql = 'SELECT c.*, cl.nom AS client_nom,
                               NULLIF(TRIM(CONCAT(COALESCE(u.prenom,\'\'),\' \',COALESCE(u.nom,\'\'))), \'\') AS responsable_nom
                        FROM chantiers c
                        LEFT JOIN clients cl ON cl.id = c.client_id
                        LEFT JOIN utilisateurs u ON u.id = c.responsable_id WHERE 1=1';
                $sql = $this->appliquerFiltres($sql, $filtres, ['statut' => 'c.statut', 'client_id' => 'c.client_id', 'date' => 'c.date_debut'], $params);
                if ($recherche !== '') {
                    $sql .= ' AND (c.code LIKE :r1 OR c.nom LIKE :r2 OR cl.nom LIKE :r3 OR c.localisation LIKE :r4)';
                    $params += ['r1' => $like, 'r2' => $like, 'r3' => $like, 'r4' => $like];
                }
                return $this->executer($sql . ' ORDER BY c.id DESC', $params);

            case 'lots':
                $sql = 'SELECT l.*, c.nom AS chantier_nom, c.code AS chantier_code
                        FROM lots l JOIN chantiers c ON c.id = l.chantier_id WHERE 1=1';
                $sql = $this->appliquerFiltres($sql, $filtres, ['chantier_id' => 'l.chantier_id', 'statut' => 'l.statut'], $params);
                if ($recherche !== '') {
                    $sql .= ' AND (l.nom LIKE :r1 OR c.nom LIKE :r2)';
                    $params += ['r1' => $like, 'r2' => $like];
                }
                return $this->executer($sql . ' ORDER BY c.nom ASC, l.ordre ASC', $params);

            case 'clients':
                $sql = 'SELECT * FROM clients WHERE 1=1';
                if ($recherche !== '') {
                    $sql .= ' AND (nom LIKE :r1 OR contact LIKE :r2 OR telephone LIKE :r3 OR email LIKE :r4)';
                    $params += ['r1' => $like, 'r2' => $like, 'r3' => $like, 'r4' => $like];
                }
                return $this->executer($sql . ' ORDER BY nom ASC', $params);

            case 'fournisseurs':
                $sql = 'SELECT * FROM fournisseurs WHERE 1=1';
                if (!empty($filtres['categorie'])) {
                    $sql .= ' AND categorie = :categorie';
                    $params['categorie'] = $filtres['categorie'];
                }
                if ($recherche !== '') {
                    $sql .= ' AND (nom LIKE :r1 OR contact LIKE :r2 OR telephone LIKE :r3 OR email LIKE :r4)';
                    $params += ['r1' => $like, 'r2' => $like, 'r3' => $like, 'r4' => $like];
                }
                return $this->executer($sql . ' ORDER BY nom ASC', $params);

            case 'employes':
                $sql = 'SELECT * FROM employes WHERE 1=1';
                if ($recherche !== '') {
                    $sql .= ' AND (matricule LIKE :r1 OR nom LIKE :r2 OR prenom LIKE :r3 OR poste LIKE :r4)';
                    $params += ['r1' => $like, 'r2' => $like, 'r3' => $like, 'r4' => $like];
                }
                return $this->executer($sql . ' ORDER BY nom ASC, prenom ASC', $params);

            case 'engins':
                $sql = 'SELECT * FROM engins WHERE 1=1';
                if ($recherche !== '') {
                    $sql .= ' AND (code LIKE :r1 OR designation LIKE :r2 OR type LIKE :r3 OR immatriculation LIKE :r4)';
                    $params += ['r1' => $like, 'r2' => $like, 'r3' => $like, 'r4' => $like];
                }
                return $this->executer($sql . ' ORDER BY designation ASC', $params);

            case 'materiaux':
                $sql = 'SELECT * FROM materiaux WHERE 1=1';
                if ($recherche !== '') {
                    $sql .= ' AND (code LIKE :r1 OR designation LIKE :r2)';
                    $params += ['r1' => $like, 'r2' => $like];
                }
                return $this->executer($sql . ' ORDER BY designation ASC', $params);

            case 'stock':
                $donnees = (new MouvementStock())->etatStock();
                if ($recherche !== '') {
                    $donnees = array_values(array_filter($donnees, static function (array $ligne) use ($recherche): bool {
                        return mb_stripos((string) $ligne['code'], $recherche) !== false
                            || mb_stripos((string) $ligne['designation'], $recherche) !== false;
                    }));
                }
                return array_map(static function (array $ligne): array {
                    $ligne['statut'] = (float) $ligne['stock'] <= (float) $ligne['seuil_alerte'] ? 'Alerte' : 'Normal';
                    return $ligne;
                }, $donnees);

            case 'achats':
                $sql = 'SELECT a.*, f.nom AS fournisseur_nom, c.nom AS chantier_nom
                        FROM achats a
                        LEFT JOIN fournisseurs f ON f.id = a.fournisseur_id
                        LEFT JOIN chantiers c ON c.id = a.chantier_id WHERE 1=1';
                $sql = $this->appliquerFiltres($sql, $filtres, ['chantier_id' => 'a.chantier_id', 'statut' => 'a.statut', 'date' => 'a.date_achat'], $params);
                if ($recherche !== '') {
                    $sql .= ' AND (a.reference LIKE :r1 OR f.nom LIKE :r2 OR c.nom LIKE :r3)';
                    $params += ['r1' => $like, 'r2' => $like, 'r3' => $like];
                }
                return $this->executer($sql . ' ORDER BY a.id DESC', $params);

            case 'devis':
                $sql = 'SELECT d.*, cl.nom AS client_nom, ch.nom AS chantier_nom
                        FROM devis d
                        LEFT JOIN clients cl ON cl.id = d.client_id
                        LEFT JOIN chantiers ch ON ch.id = d.chantier_id WHERE 1=1';
                $sql = $this->appliquerFiltres($sql, $filtres, ['statut' => 'd.statut', 'date' => 'd.date_devis'], $params);
                if ($recherche !== '') {
                    $sql .= ' AND (d.reference LIKE :r1 OR cl.nom LIKE :r2)';
                    $params += ['r1' => $like, 'r2' => $like];
                }
                return $this->executer($sql . ' ORDER BY d.id DESC', $params);

            case 'factures':
                $sql = 'SELECT f.*, cl.nom AS client_nom, ch.nom AS chantier_nom
                        FROM factures f
                        LEFT JOIN clients cl ON cl.id = f.client_id
                        LEFT JOIN chantiers ch ON ch.id = f.chantier_id WHERE 1=1';
                $sql = $this->appliquerFiltres($sql, $filtres, ['statut' => 'f.statut', 'date' => 'f.date_facture'], $params);
                if ($recherche !== '') {
                    $sql .= ' AND (f.reference LIKE :r1 OR cl.nom LIKE :r2)';
                    $params += ['r1' => $like, 'r2' => $like];
                }
                return $this->executer($sql . ' ORDER BY f.id DESC', $params);

            case 'depenses':
                return (new Depense())->liste($filtres);

            case 'budgets':
                return (new Budget())->liste($filtres);

            case 'pointages':
                $sql = 'SELECT p.*, e.nom AS employe_nom, e.prenom AS employe_prenom,
                               c.nom AS chantier_nom, c.code AS chantier_code,
                               TRIM(CONCAT(COALESCE(e.prenom,\'\'),\' \',COALESCE(e.nom,\'\'))) AS employe_nom_complet
                        FROM pointages p
                        JOIN employes e ON e.id = p.employe_id
                        JOIN chantiers c ON c.id = p.chantier_id WHERE 1=1';
                $sql = $this->appliquerFiltres($sql, $filtres, ['chantier_id' => 'p.chantier_id'], $params);
                if (!empty($filtres['date_debut'])) {
                    $sql .= ' AND p.date_pointage >= :date_debut';
                    $params['date_debut'] = $filtres['date_debut'];
                }
                if (!empty($filtres['date_fin'])) {
                    $sql .= ' AND p.date_pointage <= :date_fin';
                    $params['date_fin'] = $filtres['date_fin'];
                }
                return $this->executer($sql . ' ORDER BY p.date_pointage DESC, c.nom ASC', $params);

            case 'demandes_materiel':
                $sql = 'SELECT dm.*, c.nom AS chantier_nom,
                               TRIM(CONCAT(COALESCE(u.prenom,\'\'),\' \',COALESCE(u.nom,\'\'))) AS demandeur_nom
                        FROM demandes_materiel dm
                        LEFT JOIN chantiers c ON c.id = dm.chantier_id
                        LEFT JOIN utilisateurs u ON u.id = dm.demandeur_id WHERE 1=1';
                $sql = $this->appliquerFiltres($sql, $filtres, ['chantier_id' => 'dm.chantier_id', 'statut' => 'dm.statut', 'urgence' => 'dm.urgence', 'date' => 'dm.date_demande'], $params);
                if ($recherche !== '') {
                    $sql .= ' AND (dm.numero LIKE :r1 OR dm.objet LIKE :r2 OR c.nom LIKE :r3)';
                    $params += ['r1' => $like, 'r2' => $like, 'r3' => $like];
                }
                return $this->executer($sql . ' ORDER BY dm.cree_le DESC', $params);

            case 'rapports_journaliers':
                $sql = 'SELECT rj.*, c.nom AS chantier_nom,
                               TRIM(CONCAT(COALESCE(u.prenom,\'\'),\' \',COALESCE(u.nom,\'\'))) AS chef_nom
                        FROM rapports_journaliers rj
                        LEFT JOIN chantiers c ON c.id = rj.chantier_id
                        LEFT JOIN utilisateurs u ON u.id = rj.chef_chantier_id WHERE 1=1';
                $sql = $this->appliquerFiltres($sql, $filtres, ['chantier_id' => 'rj.chantier_id', 'statut' => 'rj.statut', 'date' => 'rj.date_rapport'], $params);
                if ($recherche !== '') {
                    $sql .= ' AND (rj.numero LIKE :r1 OR c.nom LIKE :r2 OR rj.travaux_realises LIKE :r3)';
                    $params += ['r1' => $like, 'r2' => $like, 'r3' => $like];
                }
                return $this->executer($sql . ' ORDER BY rj.date_rapport DESC', $params);

            case 'utilisateurs':
                return $this->executer('SELECT id, nom, prenom, email, role, actif, cree_le FROM utilisateurs ORDER BY nom ASC', []);

            default:
                Response::erreur('Module d\'export inconnu.', 422);
        }
    }

    /** @param array<string,mixed> $filtres */
    private function autoriser(Request $requete, string $module): void
    {
        if ($module === '' || !isset(self::PERMISSIONS[$module])) {
            Response::erreur('Module d\'export inconnu.', 422);
        }
        $role = $requete->auth['role'] ?? null;
        if (!Access::autorise($role, self::PERMISSIONS[$module], 'view')) {
            Response::erreur('Acces refuse : vous ne pouvez pas exporter ce module.', 403);
        }
    }

    private function autoriserFinances(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        if (!in_array($role, ['directeur', 'comptable'], true)) {
            Response::erreur('Acces reserve au directeur et au comptable.', 403);
        }
    }

    /** @return array<string,mixed> */
    private function filtres(Request $requete): array
    {
        $filtres = $requete->input('filtres', []);
        if (!is_array($filtres)) {
            $filtres = [];
        }
        foreach (['recherche', 'statut', 'chantier_id', 'categorie', 'date_debut', 'date_fin', 'annee', 'urgence'] as $cle) {
            if (!array_key_exists($cle, $filtres) && $requete->input($cle) !== null) {
                $filtres[$cle] = $requete->input($cle);
            }
        }
        return $filtres;
    }

    /** @param array<string,mixed> $params */
    private function appliquerFiltres(string $sql, array $filtres, array $mapping, array &$params): string
    {
        foreach ($mapping as $cle => $colonne) {
            if (!empty($filtres[$cle])) {
                $sql .= " AND $colonne = :$cle";
                $params[$cle] = $filtres[$cle];
            }
        }
        if (!empty($filtres['date_debut']) && isset($mapping['date'])) {
            $sql .= ' AND ' . $mapping['date'] . ' >= :date_debut';
            $params['date_debut'] = $filtres['date_debut'];
        }
        if (!empty($filtres['date_fin']) && isset($mapping['date'])) {
            $sql .= ' AND ' . $mapping['date'] . ' <= :date_fin';
            $params['date_fin'] = $filtres['date_fin'];
        }
        return $sql;
    }

    /** @param array<string,mixed> $params @return array<int,array<string,mixed>> */
    private function executer(string $sql, array $params): array
    {
        $stmt = Database::connexion()->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    private function obtenirColonnes(string $module): array
    {
        $colonnes = [
            'chantiers' => ['Code' => 'code', 'Nom' => 'nom', 'Type' => 'type', 'Client' => 'client_nom', 'Responsable' => 'responsable_nom', 'Localisation' => 'localisation', 'Budget (Ar)' => 'budget_previsionnel', 'Statut' => 'statut'],
            'lots' => ['Chantier' => 'chantier_nom', 'Lot' => 'nom', 'Budget (Ar)' => 'budget_previsionnel', 'Avancement (%)' => 'avancement', 'Statut' => 'statut'],
            'clients' => ['Nom' => 'nom', 'Contact' => 'contact', 'Telephone' => 'telephone', 'Email' => 'email', 'Adresse' => 'adresse', 'NIF' => 'nif', 'STAT' => 'stat'],
            'fournisseurs' => ['Nom' => 'nom', 'Categorie' => 'categorie', 'Contact' => 'contact', 'Telephone' => 'telephone', 'Email' => 'email', 'Adresse' => 'adresse', 'NIF' => 'nif', 'STAT' => 'stat'],
            'employes' => ['Matricule' => 'matricule', 'Nom' => 'nom', 'Prenom' => 'prenom', 'Poste' => 'poste', 'Telephone' => 'telephone', 'Contrat' => 'type_contrat', 'Taux journalier' => 'taux_journalier'],
            'engins' => ['Code' => 'code', 'Designation' => 'designation', 'Type' => 'type', 'Immatriculation' => 'immatriculation', 'Etat' => 'etat', 'Cout horaire (Ar)' => 'cout_horaire'],
            'materiaux' => ['Code' => 'code', 'Designation' => 'designation', 'Unite' => 'unite', 'Prix unitaire' => 'prix_unitaire', 'Seuil alerte' => 'seuil_alerte', 'Actif' => 'actif'],
            'stock' => ['Code' => 'code', 'Materiau' => 'designation', 'Unite' => 'unite', 'Stock actuel' => 'stock', 'Seuil alerte' => 'seuil_alerte', 'Statut' => 'statut'],
            'achats' => ['Reference' => 'reference', 'Date' => 'date_achat', 'Fournisseur' => 'fournisseur_nom', 'Chantier' => 'chantier_nom', 'Montant (Ar)' => 'montant_total', 'Statut' => 'statut'],
            'devis' => ['Reference' => 'reference', 'Client' => 'client_nom', 'Chantier' => 'chantier_nom', 'Date' => 'date_devis', 'Montant HT (Ar)' => 'montant_ht', 'TVA (Ar)' => 'montant_tva', 'Montant TTC (Ar)' => 'montant_ttc', 'Statut' => 'statut'],
            'factures' => ['Reference' => 'reference', 'Client' => 'client_nom', 'Chantier' => 'chantier_nom', 'Date' => 'date_facture', 'Echeance' => 'echeance', 'Montant TTC (Ar)' => 'montant_ttc', 'Paye (Ar)' => 'montant_paye', 'Statut' => 'statut'],
            'depenses' => ['Numero' => 'numero', 'Date' => 'date_depense', 'Libelle' => 'libelle', 'Categorie' => 'categorie', 'Chantier' => 'chantier_nom', 'Montant (Ar)' => 'montant', 'Statut' => 'statut'],
            'budgets' => ['Chantier' => 'chantier_nom', 'Annee' => 'annee', 'Statut' => 'statut', 'Total prevu (Ar)' => 'total_lignes', 'Engage (Ar)' => 'total_engage', 'Reel (Ar)' => 'total_reel'],
            'pointages' => ['Date' => 'date_pointage', 'Employe' => 'employe_nom_complet', 'Chantier' => 'chantier_nom', 'Presence' => 'type_presence', 'Cout (Ar)' => 'cout'],
            'demandes_materiel' => ['Numero' => 'numero', 'Date' => 'date_demande', 'Objet' => 'objet', 'Chantier' => 'chantier_nom', 'Demandeur' => 'demandeur_nom', 'Urgence' => 'urgence', 'Statut' => 'statut'],
            'rapports_journaliers' => ['Numero' => 'numero', 'Date' => 'date_rapport', 'Chantier' => 'chantier_nom', 'Chef' => 'chef_nom', 'Meteo' => 'meteo', 'Avancement (%)' => 'avancement_pct', 'Statut' => 'statut'],
            'utilisateurs' => ['Nom' => 'nom', 'Prenom' => 'prenom', 'Email' => 'email', 'Role' => 'role', 'Actif' => 'actif'],
        ];
        return $colonnes[$module] ?? [];
    }

    private function obtenirColonnesRapportFinancier(): array
    {
        return [
            'Reference' => 'reference',
            'Date' => 'date',
            'Type' => 'type',
            'Description' => 'description',
            'Chantier' => 'chantier_nom',
            'Montant (Ar)' => 'montant',
            'Statut' => 'statut',
        ];
    }

    /** @param array<int,array<string,mixed>> $donnees @return array<string,string> */
    private function calculerTotaux(array $donnees, ?array $colonnesForces = null): array
    {
        if ($donnees === []) {
            return [];
        }
        $totaux = [];
        $exclues = ['id', 'chantier_id', 'client_id', 'fournisseur_id', 'materiau_id', 'employe_id', 'budget_id', 'annee'];
        foreach (array_keys($donnees[0]) as $cle) {
            if (in_array($cle, $exclues, true) || in_array($cle, ['montant_ht', 'montant_tva', 'montant_ttc', 'montant_paye'], true)) {
                continue;
            }
            $total = 0.0;
            $numerique = true;
            foreach ($donnees as $ligne) {
                $valeur = $ligne[$cle] ?? null;
                if ($valeur === null || $valeur === '') {
                    continue;
                }
                if (!is_numeric($valeur)) {
                    $numerique = false;
                    break;
                }
                $total += (float) $valeur;
            }
            if ($numerique && $total != 0.0) {
                $totaux[$cle] = number_format($total, 2, ',', ' ');
            }
        }
        return $totaux;
    }

    /** @param array<string,mixed> $filtres @return array<int,array<string,mixed>> */
    private function recupererDonneesRapportFinancier(array $filtres): array
    {
        $params = [];
        $whereDep = " WHERE d.statut IN ('valide', 'comptabilise')";
        $wherePai = " WHERE p.statut = 'valide'";

        if (!empty($filtres['chantier_id'])) {
            $whereDep .= ' AND d.chantier_id = :chantier_id';
            $wherePai .= ' AND f.chantier_id = :chantier_id';
            $params['chantier_id'] = (int) $filtres['chantier_id'];
        }
        if (!empty($filtres['date_debut'])) {
            $whereDep .= ' AND d.date_depense >= :date_debut';
            $wherePai .= ' AND p.date_paiement >= :date_debut';
            $params['date_debut'] = $filtres['date_debut'];
        }
        if (!empty($filtres['date_fin'])) {
            $whereDep .= ' AND d.date_depense <= :date_fin';
            $wherePai .= ' AND p.date_paiement <= :date_fin';
            $params['date_fin'] = $filtres['date_fin'];
        }

        $sql = "SELECT d.numero AS reference, d.date_depense AS date, 'Depense' AS type,
                       d.libelle AS description, c.nom AS chantier_nom, d.montant AS montant, d.statut AS statut
                FROM depenses d LEFT JOIN chantiers c ON c.id = d.chantier_id
                $whereDep
                UNION ALL
                SELECT COALESCE(p.reference_paiement, f.reference) AS reference,
                       p.date_paiement AS date, 'Recette' AS type,
                       CONCAT('Paiement facture ', f.reference) AS description,
                       c.nom AS chantier_nom, p.montant AS montant, 'encaisse' AS statut
                FROM paiements p
                JOIN factures f ON f.id = p.facture_id
                LEFT JOIN chantiers c ON c.id = f.chantier_id
                $wherePai
                ORDER BY date ASC";

        return $this->executer($sql, $params);
    }

    /** @param array<int,array<string,mixed>> $donnees @return array<string,string> */
    private function totauxFinanciers(array $donnees): array
    {
        $recettes = 0.0;
        $depenses = 0.0;
        foreach ($donnees as $ligne) {
            if (($ligne['type'] ?? '') === 'Recette') {
                $recettes += (float) $ligne['montant'];
            } elseif (($ligne['type'] ?? '') === 'Depense') {
                $depenses += (float) $ligne['montant'];
            }
        }
        return [
            'reference' => 'TOTAL',
            'date' => '',
            'type' => 'Solde',
            'description' => 'Recettes : ' . number_format($recettes, 0, ',', ' ')
                . ' Ar | Depenses : ' . number_format($depenses, 0, ',', ' ')
                . ' Ar | Solde : ' . number_format($recettes - $depenses, 0, ',', ' ') . ' Ar',
            'chantier_nom' => '',
            'montant' => number_format($recettes - $depenses, 2, ',', ' '),
            'statut' => '',
        ];
    }

    private function entreprise(): array
    {
        $parametres = (new Parametre())->tous();
        $parametres['entreprise_nom'] = $parametres['entreprise_nom'] ?? $parametres['nom_entreprise'] ?? null;
        return $parametres;
    }

    private function nomUtilisateur(Request $requete): string
    {
        $id = $this->uid($requete);
        if (!$id) {
            return '';
        }
        $stmt = Database::connexion()->prepare('SELECT nom, prenom FROM utilisateurs WHERE id = :id');
        $stmt->execute(['id' => $id]);
        $u = $stmt->fetch(PDO::FETCH_ASSOC);
        return $u ? trim(($u['prenom'] ?? '') . ' ' . ($u['nom'] ?? '')) : '';
    }

    private function tracer(Request $requete, string $action, string $module, array $filtres, int $nombre): void
    {
        Audit::enregistrer($action, 'export', 0, [
            'module' => $module,
            'filtres' => $filtres,
            'lignes' => $nombre,
        ], $this->uid($requete));
    }

    private function genererNomFichier(string $module, string $extension): string
    {
        $module = preg_replace('/[^a-z0-9_]+/i', '_', $module) ?: 'export';
        return 'export_' . $module . '_' . date('YmdHis') . '.' . $extension;
    }

    private function uid(Request $requete): ?int
    {
        return isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null;
    }
}
