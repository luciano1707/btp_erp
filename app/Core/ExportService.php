<?php

namespace App\Core;

use Dompdf\Dompdf;
use Dompdf\Options;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

/**
 * Service d'exportation centralise.
 * Genere des PDFs (Dompdf) et des fichiers Excel (.xlsx) professionnels.
 */
final class ExportService
{
    /**
     * Generer un fichier Excel (.xlsx)
     *
     * @param array<int,array<string,mixed>> $donnees
     * @param array<string,string> $colonnes ['Libelle' => 'cle']
     */
    public static function genererXLSX(array $donnees, array $colonnes, string $nomFichier, array $options = []): string
    {
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->setTitle(mb_substr((string) ($options['titre'] ?? 'Export'), 0, 31));

        $ligne = 1;
        if (!empty($options['entete'])) {
            $sheet->setCellValue('A1', (string) Env::get('APP_NAME', 'Digital Chantier'));
            $sheet->mergeCells('A1:' . self::colonne(count($colonnes)) . '1');
            $sheet->getStyle('A1')->getFont()->setBold(true)->setSize(16);
            $sheet->getStyle('A1')->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
            $ligne = 2;
            $sheet->setCellValue('A2', (string) ($options['titre'] ?? 'Export'));
            $sheet->mergeCells('A2:' . self::colonne(count($colonnes)) . '2');
            $sheet->getStyle('A2')->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
            $ligne = 3;
            $sheet->setCellValue('A3', 'Genere le : ' . date('d/m/Y H:i'));
            $sheet->mergeCells('A3:' . self::colonne(count($colonnes)) . '3');
            $sheet->getStyle('A3')->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
            $ligne = 5;
        }

        // Filtres
        if (!empty($options['filtres']) && is_array($options['filtres'])) {
            $sheet->setCellValue(self::colonne(1) . $ligne, 'Filtres appliques');
            $sheet->getStyle(self::colonne(1) . $ligne)->getFont()->setBold(true);
            $ligne++;
            foreach ($options['filtres'] as $libelle => $valeur) {
                if ($valeur === null || $valeur === '') {
                    continue;
                }
                $sheet->setCellValue(self::colonne(1) . $ligne, (string) $libelle);
                $sheet->setCellValue(self::colonne(2) . $ligne, is_array($valeur) ? json_encode($valeur) : (string) $valeur);
                $ligne++;
            }
            $ligne++;
        }

        // En-tetes
        $col = 1;
        foreach ($colonnes as $libelle => $cle) {
            $lettre = self::colonne($col);
            $sheet->setCellValue($lettre . $ligne, (string) $libelle);
            $sheet->getStyle($lettre . $ligne)->getFont()->setBold(true);
            $sheet->getStyle($lettre . $ligne)->getFill()
                ->setFillType(Fill::FILL_SOLID)
                ->getStartColor()->setRGB('1F4E79');
            $sheet->getStyle($lettre . $ligne)->getFont()->getColor()->setRGB('FFFFFF');
            $sheet->getStyle($lettre . $ligne)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
            $sheet->getStyle($lettre . $ligne)->getBorders()->getAllBorders()->setBorderStyle(Border::BORDER_THIN);
            $col++;
        }
        $ligne++;

        $clefs = array_values($colonnes);
        foreach ($donnees as $ligneDonnee) {
            $col = 1;
            foreach ($clefs as $cle) {
                $valeur = $ligneDonnee[$cle] ?? '';
                $lettre = self::colonne($col);
                if (is_numeric($valeur) && !preg_match('/^0[0-9]/', (string) $valeur)) {
                    $sheet->setCellValueExplicit($lettre . $ligne, (float) $valeur, \PhpOffice\PhpSpreadsheet\Cell\DataType::TYPE_NUMERIC);
                } else {
                    $sheet->setCellValue($lettre . $ligne, (string) $valeur);
                }
                $sheet->getStyle($lettre . $ligne)->getBorders()->getAllBorders()->setBorderStyle(Border::BORDER_THIN);
                $col++;
            }
            $ligne++;
        }

        // Totaux
        if (!empty($options['totaux']) && is_array($options['totaux'])) {
            $col = 1;
            foreach ($clefs as $cle) {
                $lettre = self::colonne($col);
                if (isset($options['totaux'][$cle])) {
                    $sheet->setCellValue($lettre . $ligne, (string) $options['totaux'][$cle]);
                    $sheet->getStyle($lettre . $ligne)->getFont()->setBold(true);
                    $sheet->getStyle($lettre . $ligne)->getFill()
                        ->setFillType(Fill::FILL_SOLID)
                        ->getStartColor()->setRGB('E8F5E9');
                    $sheet->getStyle($lettre . $ligne)->getBorders()->getAllBorders()->setBorderStyle(Border::BORDER_THIN);
                }
                $col++;
            }
            $ligne++;
        }

        foreach (range(1, count($colonnes)) as $c) {
            $sheet->getColumnDimension(self::colonne($c))->setAutoSize(true);
        }
        $sheet->setAutoFilter(self::colonne(1) . ($ligne - (empty($options['totaux']) ? 1 : 2)) . ':' . self::colonne(count($colonnes)) . ($ligne - (empty($options['totaux']) ? 1 : 2)));

        ob_start();
        (new Xlsx($spreadsheet))->save('php://output');
        $contenu = ob_get_clean();
        $spreadsheet->disconnectWorksheets();
        unset($spreadsheet);

        return $contenu ?: '';
    }

    /**
     * Generer un PDF professionnel via Dompdf
     *
     * @param array<int,array<string,mixed>> $donnees
     * @param array<string,string> $colonnes
     */
    public static function genererPDF(array $donnees, array $colonnes, string $titre, array $options = []): string
    {
        $nomApp = (string) Env::get('APP_NAME', 'Digital Chantier');
        $entreprise = $options['entreprise'] ?? [];
        $logo = (string) ($entreprise['logo_url'] ?? '');
        $filtres = $options['filtres'] ?? [];
        $totaux = $options['totaux'] ?? [];

        $html = '<!DOCTYPE html><html lang="fr"><head><meta charset="UTF-8"><style>
            @page { margin: 20mm 15mm; }
            body { font-family: DejaVu Sans, Arial, sans-serif; font-size: 9pt; color: #1a1a1a; }
            .header { border-bottom: 2px solid #1F4E79; padding-bottom: 10px; margin-bottom: 15px; }
            .header-table { width: 100%; }
            .header-table td { vertical-align: top; }
            .logo { max-height: 60px; max-width: 150px; }
            .entreprise { font-size: 8pt; color: #444; }
            .titre { font-size: 16pt; font-weight: bold; color: #1F4E79; text-align: right; }
            .meta { font-size: 8pt; color: #666; text-align: right; }
            .filtres { background: #f5f7fa; border: 1px solid #e0e0e0; padding: 8px; margin: 10px 0; font-size: 8pt; }
            table.data { width: 100%; border-collapse: collapse; margin-top: 12px; }
            table.data th { background: #1F4E79; color: #fff; padding: 6px 4px; text-align: left; font-size: 8pt; border: 1px solid #1F4E79; }
            table.data td { border: 1px solid #ddd; padding: 5px 4px; font-size: 8pt; }
            table.data tr:nth-child(even) { background: #f9fbfd; }
            table.data tfoot td { background: #e8f5e9; font-weight: bold; border-top: 2px solid #2e7d32; }
            .footer { position: fixed; bottom: -10mm; left: 0; right: 0; text-align: center; font-size: 7pt; color: #666; border-top: 1px solid #ddd; padding-top: 4px; }
            .page-break { page-break-after: always; }
        </style></head><body>';

        $html .= '<div class="footer">Document genere automatiquement par ' . self::h($nomApp) . ' - ' . date('d/m/Y H:i') . '</div>';
        $html .= '<div class="header"><table class="header-table"><tr><td>';
        if ($logo !== '') {
            $html .= '<img class="logo" src="' . self::h($logo) . '"><br>';
        }
        $html .= '<strong>' . self::h((string) ($entreprise['entreprise_nom'] ?? $nomApp)) . '</strong><br><span class="entreprise">';
        foreach (['entreprise_adresse', 'entreprise_telephone', 'entreprise_email'] as $k) {
            if (!empty($entreprise[$k])) {
                $html .= self::h((string) $entreprise[$k]) . '<br>';
            }
        }
        $fisc = [];
        if (!empty($entreprise['entreprise_nif'])) {
            $fisc[] = 'NIF : ' . $entreprise['entreprise_nif'];
        }
        if (!empty($entreprise['entreprise_stat'])) {
            $fisc[] = 'STAT : ' . $entreprise['entreprise_stat'];
        }
        if ($fisc !== []) {
            $html .= implode(' | ', array_map([self::class, 'h'], $fisc));
        }
        $html .= '</span></td><td style="text-align:right;"><div class="titre">' . self::h($titre) . '</div>';
        $html .= '<div class="meta">Genere le ' . date('d/m/Y H:i') . '<br>Utilisateur : ' . self::h((string) ($options['utilisateur'] ?? '')) . '</div></td></tr></table></div>';

        if (!empty($filtres) && is_array($filtres)) {
            $html .= '<div class="filtres"><strong>Filtres appliques :</strong> ';
            $parts = [];
            foreach ($filtres as $lib => $val) {
                if ($val === null || $val === '' || (is_array($val) && $val === [])) {
                    continue;
                }
                if (is_array($val)) {
                    $val = implode(', ', array_map('strval', $val));
                }
                $parts[] = self::h((string) $lib) . ' : ' . self::h((string) $val);
            }
            $html .= implode(' | ', $parts) . '</div>';
        }

        $html .= '<table class="data"><thead><tr>';
        foreach ($colonnes as $lib => $cle) {
            $html .= '<th>' . self::h((string) $lib) . '</th>';
        }
        $html .= '</tr></thead><tbody>';
        foreach ($donnees as $ligne) {
            $html .= '<tr>';
            foreach (array_values($colonnes) as $cle) {
                $val = $ligne[$cle] ?? '';
                $html .= '<td>' . self::h((string) $val) . '</td>';
            }
            $html .= '</tr>';
        }
        $html .= '</tbody>';
        if (!empty($totaux)) {
            $html .= '<tfoot><tr>';
            foreach (array_values($colonnes) as $cle) {
                $html .= '<td>' . self::h((string) ($totaux[$cle] ?? '')) . '</td>';
            }
            $html .= '</tr></tfoot>';
        }
        $html .= '</table></body></html>';

        $optionsPdf = new Options();
        $optionsPdf->set('isRemoteEnabled', true);
        $optionsPdf->set('defaultFont', 'DejaVu Sans');
        $dompdf = new Dompdf($optionsPdf);
        $dompdf->loadHtml($html, 'UTF-8');
        $dompdf->setPaper('A4', 'landscape');
        $dompdf->render();
        return $dompdf->output() ?: '';
    }

    public static function genererDevisPDF(array $devis, array $lignes, array $entreprise): string
    {
        $nomApp = (string) Env::get('APP_NAME', 'Digital Chantier');
        $logo = (string) ($entreprise['logo_url'] ?? '');
        $conditions = (string) ((new Parametre())->obtenir('conditions_paiement_devis', 'Paiement a 30 jours date de facture') ?? '');

        $html = '<!DOCTYPE html><html lang="fr"><head><meta charset="UTF-8"><style>
            @page { margin: 18mm; }
            body { font-family: DejaVu Sans, Arial, sans-serif; font-size: 9pt; }
            .top { width: 100%; }
            .titre { font-size: 22pt; color: #1F4E79; font-weight: bold; }
            .logo { max-height: 65px; }
            .bloc { margin-top: 12px; }
            .client { background: #f7f9fc; padding: 10px; border: 1px solid #dfe6ef; }
            table.lignes { width: 100%; border-collapse: collapse; margin-top: 18px; }
            table.lignes th { background: #1F4E79; color: #fff; padding: 7px; border: 1px solid #1F4E79; }
            table.lignes td { border: 1px solid #ddd; padding: 6px; }
            table.lignes tr:nth-child(even) { background: #fbfdff; }
            .totaux { width: 280px; margin-left: auto; margin-top: 12px; }
            .totaux td { padding: 4px 6px; }
            .ttc { font-size: 11pt; font-weight: bold; background: #e8f5e9; }
            .footer { margin-top: 25px; font-size: 8pt; color: #555; }
        </style></head><body>';

        $html .= '<table class="top"><tr><td>';
        if ($logo !== '') {
            $html .= '<img class="logo" src="' . self::h($logo) . '"><br>';
        }
        $html .= '<strong>' . self::h((string) ($entreprise['entreprise_nom'] ?? $nomApp)) . '</strong><br>';
        foreach (['entreprise_adresse', 'entreprise_telephone', 'entreprise_email'] as $k) {
            if (!empty($entreprise[$k])) {
                $html .= self::h((string) $entreprise[$k]) . '<br>';
            }
        }
        if (!empty($entreprise['entreprise_nif'])) {
            $html .= 'NIF : ' . self::h((string) $entreprise['entreprise_nif']);
        }
        if (!empty($entreprise['entreprise_stat'])) {
            $html .= ' | STAT : ' . self::h((string) $entreprise['entreprise_stat']);
        }
        $html .= '</td><td style="text-align:right;"><div class="titre">DEVIS</div><br>';
        $html .= '<strong>NÂ° ' . self::h((string) ($devis['reference'] ?? $devis['id'])) . '</strong><br>';
        $html .= 'Date d\'emission : ' . self::h(date('d/m/Y', strtotime((string) ($devis['date_devis'] ?? date('Y-m-d'))))) . '<br>';
        if (!empty($devis['validite'])) {
            $html .= 'Valide jusqu\'au : ' . self::h(date('d/m/Y', strtotime((string) $devis['validite']))) . '<br>';
        }
        $html .= '</td></tr></table>';

        $html .= '<div class="bloc client"><strong>Destinataire</strong><br>';
        $html .= self::h((string) ($devis['client_nom'] ?? '')) . '<br>';
        if (!empty($devis['chantier_nom'])) {
            $html .= 'Chantier concernÃ© : ' . self::h((string) $devis['chantier_nom']) . '<br>';
        }
        $html .= '</div>';

        $html .= '<table class="lignes"><thead><tr><th>DÃ©signation</th><th style="width:70px;">QtÃ©</th><th style="width:110px;">Prix unitaire</th><th style="width:110px;">Montant</th></tr></thead><tbody>';
        foreach ($lignes as $l) {
            $qte = (float) ($l['quantite'] ?? 0);
            $pu = (int) ($l['prix_unitaire'] ?? 0);
            $montant = (int) ($l['montant'] ?? ($qte * $pu));
            $html .= '<tr><td>' . self::h((string) ($l['designation'] ?? '')) . '</td><td style="text-align:right;">' . number_format($qte, 3, ',', ' ') . '</td><td style="text-align:right;">' . number_format($pu, 0, ',', ' ') . ' Ar</td><td style="text-align:right;">' . number_format($montant, 0, ',', ' ') . ' Ar</td></tr>';
        }
        $html .= '</tbody></table>';

        $ht = (int) ($devis['montant_ht'] ?? 0);
        $tva = (int) ($devis['montant_tva'] ?? 0);
        $ttc = (int) ($devis['montant_ttc'] ?? ($ht + $tva));
        $taux = (float) ($devis['tva_taux'] ?? 20);
        $html .= '<table class="totaux"><tr><td>Total HT</td><td style="text-align:right;">' . number_format($ht, 0, ',', ' ') . ' Ar</td></tr><tr><td>TVA (' . $taux . '%)</td><td style="text-align:right;">' . number_format($tva, 0, ',', ' ') . ' Ar</td></tr><tr class="ttc"><td>TOTAL TTC</td><td style="text-align:right;">' . number_format($ttc, 0, ',', ' ') . ' Ar</td></tr></table>';

        $html .= '<div class="footer"><strong>Conditions de paiement</strong><br>' . nl2br(self::h($conditions)) . '<br><br><em>Document approuvÃ© par validation. Ce devis fait foi.</em></div>';
        $html .= '</body></html>';

        $optionsPdf = new Options();
        $optionsPdf->set('isRemoteEnabled', true);
        $optionsPdf->set('defaultFont', 'DejaVu Sans');
        $dompdf = new Dompdf($optionsPdf);
        $dompdf->loadHtml($html, 'UTF-8');
        $dompdf->setPaper('A4', 'portrait');
        $dompdf->render();
        return $dompdf->output() ?: '';
    }

    public static function genererRapportFinancierPDF(array $donnees, array $colonnes, string $titre, array $options = []): string
    {
        return self::genererPDF($donnees, $colonnes, $titre, array_merge($options, ['entreprise' => $options['entreprise'] ?? [], 'utilisateur' => $options['utilisateur'] ?? '']));
    }

    private static function colonne(int $index): string
    {
        $resultat = '';
        while ($index > 0) {
            $index--;
            $resultat = chr(65 + ($index % 26)) . $resultat;
            $index = intdiv($index, 26);
        }
        return $resultat;
    }

    private static function h(string $valeur): string
    {
        return htmlspecialchars($valeur, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    }

    public static function telecharger(string $contenu, string $nomFichier, string $contentType): void
    {
        if (!headers_sent()) {
            header('Content-Type: ' . $contentType);
            header('Content-Disposition: attachment; filename="' . addslashes($nomFichier) . '"');
            header('Content-Length: ' . strlen($contenu));
            header('Cache-Control: no-cache, must-revalidate');
            header('Pragma: no-cache');
            header('X-Content-Type-Options: nosniff');
        }
        echo $contenu;
        exit;
    }

    public static function afficherPDF(string $contenu, string $titre): void
    {
        if (!headers_sent()) {
            header('Content-Type: application/pdf');
            $nomFichier = preg_replace('/[^A-Za-z0-9._-]+/', '_', $titre) ?: 'document';
            if (!str_ends_with(strtolower($nomFichier), '.pdf')) {
                $nomFichier .= '.pdf';
            }
            header('Content-Disposition: inline; filename="' . addslashes($nomFichier) . '"');
            header('Content-Length: ' . strlen($contenu));
            header('Cache-Control: private, no-store, max-age=0');
            header('X-Content-Type-Options: nosniff');
        }
        echo $contenu;
        exit;
    }

    public static function afficherHTML(string $contenu, string $titre): void
    {
        if (!headers_sent()) {
            header('Content-Type: text/html; charset=UTF-8');
        }
        echo $contenu;
        exit;
    }
}
