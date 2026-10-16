/* Rendu imprimable d'un devis (avec logo + coordonnees de l'entreprise). */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const id = window.RESSOURCE && window.RESSOURCE.id;
    const conteneur = document.getElementById('devis-impression');
    let entreprise = {};

    document.addEventListener('DOMContentLoaded', async function () {
        document.getElementById('lien-retour').href = base + '/devis/' + id;
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }

        const repParam = await Auth.api('/api/v1/parametres');
        if (repParam.ok) { entreprise = (await repParam.json()).donnees || {}; }

        const rep = await Auth.api('/api/v1/devis/' + id);
        if (!rep.ok) { conteneur.textContent = 'Devis introuvable.'; return; }
        rendre((await rep.json()).donnees);
    });

    function blocEmetteur() {
        const nom = entreprise.entreprise_nom || 'Digital Chantier';
        const logo = entreprise.logo_url ? '<img class="logo-doc" src="' + entreprise.logo_url + '" alt="Logo">' : '';
        const lignes = [entreprise.entreprise_adresse, entreprise.entreprise_telephone, entreprise.entreprise_email]
            .filter(Boolean).map(Format.echapper).join('<br>');
        const fiscal = [entreprise.entreprise_nif ? 'NIF : ' + entreprise.entreprise_nif : '',
                        entreprise.entreprise_stat ? 'STAT : ' + entreprise.entreprise_stat : '']
            .filter(Boolean).map(Format.echapper).join(' &middot; ');
        return '<div class="bloc-emetteur">' + logo +
            '<strong>' + Format.echapper(nom) + '</strong>' +
            (lignes ? '<br>' + lignes : '') + (fiscal ? '<br>' + fiscal : '') + '</div>';
    }

    function rendre(d) {
        const lignes = (d.lignes || []).map(function (l) {
            return '<tr><td>' + Format.echapper(l.designation) + '</td><td class="d">' + Number(l.quantite) +
                '</td><td class="d">' + Format.ariary(l.prix_unitaire) + '</td><td class="d">' + Format.ariary(l.montant) + '</td></tr>';
        }).join('');

        conteneur.innerHTML =
            '<div class="entete-facture">' +
                '<div><h1>DEVIS</h1><p>' + Format.echapper(d.reference || ('#' + d.id)) + '</p></div>' +
                blocEmetteur() +
            '</div>' +
            '<div class="bloc-client"><strong>Client :</strong> ' + Format.echapper(d.client_nom || '—') +
                '<br><strong>Date :</strong> ' + Format.date(d.date_devis) +
                '<br><strong>Validite :</strong> ' + Format.date(d.validite) + '</div>' +
            '<table class="table-facture"><thead><tr><th>Designation</th><th class="d">Qte</th><th class="d">P.U.</th><th class="d">Montant</th></tr></thead>' +
                '<tbody>' + lignes + '</tbody></table>' +
            '<div class="totaux-facture">' +
                '<div>Total HT : <strong>' + Format.ariary(d.montant_ht) + '</strong></div>' +
                '<div>TVA (' + Number(d.tva_taux) + '%) : <strong>' + Format.ariary(d.montant_tva) + '</strong></div>' +
                '<div class="ttc">Total TTC : <strong>' + Format.ariary(d.montant_ttc) + '</strong></div>' +
            '</div>';
    }
})();
