/* Liste des achats. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const STATUTS = { commande: 'Commande', recu: 'Recu', annule: 'Annule' };
    const corps = document.getElementById('corps-tableau');
    const compteur = document.getElementById('compteur');
    const recherche = document.getElementById('recherche');
    let minuteur = null;

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        charger('');
        recherche.addEventListener('input', function () {
            clearTimeout(minuteur);
            minuteur = setTimeout(function () { charger(recherche.value.trim()); }, 300);
        });
    });

    async function charger(terme) {
        const rep = await Auth.api('/api/v1/achats?recherche=' + encodeURIComponent(terme));
        if (!rep.ok) { corps.innerHTML = '<tr><td class="vide" colspan="7">Erreur.</td></tr>'; return; }
        const json = await rep.json();
        rendre(json.donnees.elements || [], json.donnees.total || 0);
    }

    function rendre(elements, total) {
        compteur.textContent = total + ' achat' + (total > 1 ? 's' : '');
        if (!elements.length) { corps.innerHTML = '<tr><td class="vide" colspan="7">Aucun achat.</td></tr>'; return; }
        corps.innerHTML = elements.map(function (a) {
            return '<tr>' +
                '<td><a class="lien" href="' + base + '/achats/' + a.id + '">' + (a.reference ? Format.echapper(a.reference) : '#' + a.id) + '</a></td>' +
                '<td>' + Format.echapper(a.fournisseur_nom || '—') + '</td>' +
                '<td>' + Format.echapper(a.chantier_nom || '—') + '</td>' +
                '<td>' + Format.date(a.date_achat) + '</td>' +
                '<td>' + Format.ariary(a.montant_total) + '</td>' +
                '<td><span class="badge-statut statut-' + a.statut + '">' + (STATUTS[a.statut] || a.statut) + '</span></td>' +
                '<td class="col-actions"><a class="lien-action" href="' + base + '/achats/' + a.id + '">Ouvrir</a></td>' +
                '</tr>';
        }).join('');
    }
})();
