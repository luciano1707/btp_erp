<?php

namespace App\Controllers\Api;

use App\Core\Controller;
use App\Core\Access;
use App\Core\Database;
use App\Core\Request;
use App\Core\Response;

/**
 * API de statistiques et de suivi financier (Phase 7).
 * Agregations transverses : tableau de bord, rentabilite par chantier, tresorerie.
 * Lecture seule.
 */
final class StatistiquesController extends Controller
{
    /** GET /api/v1/stats/tableau-de-bord : indicateurs cles globaux. */
    public function tableauDeBord(Request $requete): void
    {
        $db = Database::connexion();

        $unique = static fn (string $sql): int => (int) $db->query($sql)->fetchColumn();

        $caFacture = $unique("SELECT COALESCE(SUM(montant_ttc),0) FROM factures WHERE statut IN ('emise','payee_partiel','payee')");
        $encaisse  = $unique("SELECT COALESCE(SUM(montant),0) FROM paiements");
        $resteAEncaisser = $unique("SELECT COALESCE(SUM(montant_ttc - montant_paye),0) FROM factures WHERE statut IN ('emise','payee_partiel')");

        $coutMo  = $unique("SELECT COALESCE(SUM(cout),0) FROM pointages");
        $coutMat = $unique("SELECT COALESCE(SUM(montant_total),0) FROM achats WHERE statut <> 'annule'");

        $alertesStock = $unique(
            "SELECT COUNT(*) FROM (
                SELECT m.id, m.seuil_alerte,
                       COALESCE(SUM(CASE WHEN mv.type='entree' THEN mv.quantite WHEN mv.type='sortie' THEN -mv.quantite ELSE mv.quantite END),0) AS stock
                FROM materiaux m LEFT JOIN mouvements_stock mv ON mv.materiau_id = m.id
                WHERE m.actif = 1 AND m.seuil_alerte IS NOT NULL
                GROUP BY m.id, m.seuil_alerte
             ) t WHERE t.stock <= t.seuil_alerte"
        );

        $donnees = [
            'chantiers_actifs'   => $unique("SELECT COUNT(*) FROM chantiers WHERE statut = 'en_cours'"),
            'chantiers_total'    => $unique('SELECT COUNT(*) FROM chantiers'),
            'ca_facture'         => $caFacture,
            'encaisse'           => $encaisse,
            'reste_a_encaisser'  => $resteAEncaisser,
            'cout_main_oeuvre'   => $coutMo,
            'cout_materiaux'     => $coutMat,
            'cout_total'         => $coutMo + $coutMat,
            'marge_brute'        => $caFacture - ($coutMo + $coutMat),
            'devis_en_attente'   => $unique("SELECT COUNT(*) FROM devis WHERE statut IN ('brouillon','envoye')"),
            'factures_impayees'  => $unique("SELECT COUNT(*) FROM factures WHERE statut IN ('emise','payee_partiel')"),
            'alertes_stock'      => $alertesStock,
        ];
        if (!Access::autorise($requete->auth['role'] ?? null, 'finances', 'view')) {
            $donnees = array_intersect_key(
                $donnees,
                array_flip(['chantiers_actifs', 'chantiers_total', 'alertes_stock'])
            );
        }
        Response::succes($donnees, 'Tableau de bord');
    }

    /** GET /api/v1/stats/chantiers : rentabilite par chantier. */
    public function rentabiliteChantiers(Request $requete): void
    {
        $sql = "SELECT c.id, c.nom, c.statut, c.budget_previsionnel,
                    COALESCE((SELECT CASE WHEN SUM(l.budget_previsionnel) > 0
                                THEN ROUND(SUM(l.avancement * l.budget_previsionnel) / SUM(l.budget_previsionnel))
                                ELSE ROUND(AVG(l.avancement)) END
                              FROM lots l WHERE l.chantier_id = c.id), 0) AS avancement,
                    COALESCE((SELECT SUM(p.cout) FROM pointages p WHERE p.chantier_id = c.id),0) AS cout_mo,
                    COALESCE((SELECT SUM(a.montant_total) FROM achats a WHERE a.chantier_id = c.id AND a.statut <> 'annule'),0) AS cout_mat,
                    COALESCE((SELECT SUM(f.montant_ttc) FROM factures f WHERE f.chantier_id = c.id AND f.statut IN ('emise','payee_partiel','payee')),0) AS facture,
                    COALESCE((SELECT SUM(f.montant_paye) FROM factures f WHERE f.chantier_id = c.id AND f.statut <> 'annulee'),0) AS encaisse
                FROM chantiers c
                ORDER BY c.id DESC";

        $lignes = Database::connexion()->query($sql)->fetchAll();
        foreach ($lignes as &$l) {
            $coutTotal = (int) $l['cout_mo'] + (int) $l['cout_mat'];
            $l['cout_total'] = $coutTotal;
            $l['marge'] = (int) $l['facture'] - $coutTotal;
            $l['budget_previsionnel'] = $l['budget_previsionnel'] !== null ? (int) $l['budget_previsionnel'] : null;
        }

        if (!Access::autorise($requete->auth['role'] ?? null, 'finances', 'view')) {
            $lignes = array_map(
                static fn (array $ligne): array => array_intersect_key(
                    $ligne,
                    array_flip(['id', 'nom', 'statut', 'avancement'])
                ),
                $lignes
            );
        }

        Response::succes($lignes, 'Rentabilite des chantiers');
    }

    /** GET /api/v1/stats/mensuel : facture vs encaisse sur les 6 derniers mois. */
    public function mensuel(Request $requete): void
    {
        $libelles = ['', 'Jan', 'Fev', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aou', 'Sep', 'Oct', 'Nov', 'Dec'];

        // Squelette des 6 derniers mois (du plus ancien au plus recent)
        $mois = [];
        for ($i = 5; $i >= 0; $i--) {
            $ts = strtotime("first day of -$i month");
            $cle = date('Y-m', $ts);
            $mois[$cle] = [
                'mois'     => $cle,
                'libelle'  => $libelles[(int) date('n', $ts)],
                'facture'  => 0,
                'encaisse' => 0,
            ];
        }
        $debut = array_key_first($mois) . '-01';
        $db = Database::connexion();

        $reqF = $db->prepare(
            "SELECT DATE_FORMAT(date_facture,'%Y-%m') AS m, COALESCE(SUM(montant_ttc),0) AS t
             FROM factures
             WHERE statut IN ('emise','payee_partiel','payee') AND date_facture >= :debut
             GROUP BY m"
        );
        $reqF->execute([':debut' => $debut]);
        foreach ($reqF->fetchAll() as $l) {
            if (isset($mois[$l['m']])) {
                $mois[$l['m']]['facture'] = (int) $l['t'];
            }
        }

        $reqE = $db->prepare(
            "SELECT DATE_FORMAT(date_paiement,'%Y-%m') AS m, COALESCE(SUM(montant),0) AS t
             FROM paiements
             WHERE date_paiement >= :debut
             GROUP BY m"
        );
        $reqE->execute([':debut' => $debut]);
        foreach ($reqE->fetchAll() as $l) {
            if (isset($mois[$l['m']])) {
                $mois[$l['m']]['encaisse'] = (int) $l['t'];
            }
        }

        Response::succes(array_values($mois), 'Facture vs encaisse (6 mois)');
    }

    /** GET /api/v1/stats/tresorerie?debut=&fin= : encaissements vs decaissements. */
    public function tresorerie(Request $requete): void
    {
        $db = Database::connexion();
        $debut = $requete->query('debut');
        $fin = $requete->query('fin');

        $encSql = 'SELECT COALESCE(SUM(montant),0) FROM paiements WHERE 1=1';
        $decSql = "SELECT COALESCE(SUM(montant_total),0) FROM achats WHERE statut = 'recu'";
        $params = [];
        if ($debut) {
            $encSql .= ' AND date_paiement >= :debut';
            $decSql .= ' AND date_achat >= :debut';
            $params[':debut'] = $debut;
        }
        if ($fin) {
            $encSql .= ' AND date_paiement <= :fin';
            $decSql .= ' AND date_achat <= :fin';
            $params[':fin'] = $fin;
        }

        $reqEnc = $db->prepare($encSql);
        $reqEnc->execute($params);
        $encaissements = (int) $reqEnc->fetchColumn();

        $reqDec = $db->prepare($decSql);
        $reqDec->execute($params);
        $decaissements = (int) $reqDec->fetchColumn();

        Response::succes([
            'debut'         => $debut,
            'fin'           => $fin,
            'encaissements' => $encaissements,
            'decaissements' => $decaissements,
            'solde'         => $encaissements - $decaissements,
        ], 'Tresorerie');
    }
}
