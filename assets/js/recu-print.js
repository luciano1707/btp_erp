/* Recu de paiement imprimable (en-tete logo + liste des encaissements). */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const id = window.RESSOURCE && window.RESSOURCE.id;
    const conteneur = document.getElementById('recu-impression');
    const MODES = { especes: 'Especes', cheque: 'Cheque', virement: 'Virement', mobile_money: 'Mobile Money', autre: 'Autre' };
    let entreprise = {};

    document.addEventListener('DOMContentLoaded', async function () {
        document.getElementById('lien-retour').href = base + '/factures/' + id;
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }

        const repParam = await Auth.api('/api/v1/parametres');
        if (repParam.ok) { entreprise = (await repParam.json()).donnees || {}; }

        const rep = await Auth.api('/api/v1/factures/' + id);
        if (!rep.ok) { conteneur.textContent = 'Facture introuvable.'; return; }
        rendre((await rep.json()).donnees);
    });

    function blocEmetteur() {
        const nom = entreprise.entreprise_nom || 'Digital Chantier';
        const logo = entreprise.logo_url ? '<img class="logo-doc" src="' + entreprise.logo_url + '" alt="Logo">' : '';
        const lignes = [entreprise.entreprise_adresse, entreprise.entreprise_telephone, entreprise.entreprise_email]
            .filter(Boolean).map(Format.echapper).join('<br>');
        return '<div class="bloc-emetteur">' + logo + '<strong>' + Format.echapper(nom) + '</strong>' + (lignes ? '<br>' + lignes : '') + '</div>';
    }

    function rendre(f) {
        const paiements = f.paiements || [];
        const lignes = paiements.map(function (p) {
            return '<tr><td>' + Format.date(p.date_paiement) + '</td><td>' + (MODES[p.mode] || p.mode) +
                '</td><td>' + Format.echapper(p.reference_paiement || '—') + '</td><td class="d">' + Format.ariary(p.montant) + '</td></tr>';
        }).join('');
        const reste = Number(f.montant_ttc) - Number(f.montant_paye);

        conteneur.innerHTML =
            '<div class="entete-facture">' +
                '<div><h1>RE&Ccedil;U</h1><p>Facture ' + Format.echapper(f.reference || ('#' + f.id)) + '</p></div>' +
                blocEmetteur() +
            '</div>' +
            '<div class="bloc-client"><strong>Re&ccedil;u de :</strong> ' + Format.echapper(f.client_nom || '—') +
                '<br><strong>Au titre de la facture :</strong> ' + Format.echapper(f.reference || ('#' + f.id)) + '</div>' +
            (paiements.length
                ? '<table class="table-facture"><thead><tr><th>Date</th><th>Mode</th><th>Reference</th><th class="d">Montant</th></tr></thead><tbody>' + lignes + '</tbody></table>'
                : '<p>Aucun paiement enregistre pour cette facture.</p>') +
            '<div class="totaux-facture">' +
                '<div>Total facture (TTC) : <strong>' + Format.ariary(f.montant_ttc) + '</strong></div>' +
                '<div class="ttc">Total encaisse : <strong>' + Format.ariary(f.montant_paye) + '</strong></div>' +
                '<div>Reste du : <strong>' + Format.ariary(reste) + '</strong></div>' +
            '</div>' +
            '<p style="margin-top:30px;font-size:.85rem;color:#64748b">Fait a Mahajanga, le ' + Format.date(new Date().toISOString()) + '.</p>';
    }
})();
