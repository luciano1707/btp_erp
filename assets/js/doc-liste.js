/* Liste generique devis/factures. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const R = window.RESSOURCE;
    if (!R) { return; }
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
        const rep = await Auth.api('/' + R.endpoint + '?recherche=' + encodeURIComponent(terme));
        if (!rep.ok) { corps.innerHTML = '<tr><td class="vide" colspan="6">Erreur.</td></tr>'; return; }
        const json = await rep.json();
        rendre(json.donnees.elements || [], json.donnees.total || 0);
    }

    function rendre(elements, total) {
        compteur.textContent = total + ' document' + (total > 1 ? 's' : '');
        if (!elements.length) { corps.innerHTML = '<tr><td class="vide" colspan="6">Aucun document.</td></tr>'; return; }
        corps.innerHTML = elements.map(function (d) {
            const lien = base + R.baseWeb + '/' + d.id;
            return '<tr>' +
                '<td><a class="lien" href="' + lien + '">' + (d.reference ? Format.echapper(d.reference) : '#' + d.id) + '</a></td>' +
                '<td>' + Format.echapper(d.client_nom || '—') + '</td>' +
                '<td>' + Format.date(d[R.champDate]) + '</td>' +
                '<td>' + Format.ariary(d.montant_ttc) + '</td>' +
                '<td><span class="badge-statut statut-' + d.statut + '">' + (R.statuts[d.statut] || d.statut) + '</span></td>' +
                '<td class="col-actions"><a class="lien-action" href="' + lien + '">Ouvrir</a></td>' +
                '</tr>';
        }).join('');
    }
})();
