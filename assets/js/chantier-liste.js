/* Liste des chantiers (chargement AJAX). */
(function () {
    'use strict';

    const base = window.APP_BASE || '';
    const statuts = (window.RESSOURCE && window.RESSOURCE.statuts) || {};
    const peutModifier = Boolean(window.RESSOURCE && window.RESSOURCE.peutModifier);
    const peutVoirFinances = Boolean(window.RESSOURCE && window.RESSOURCE.peutVoirFinances);
    const nbColonnes = 5 + Number(peutVoirFinances) + Number(peutModifier);
    const typesLibelles = { batiment: 'Batiment', route: 'Route', autre: 'Autre' };

    const corps     = document.getElementById('corps-tableau');
    const compteur  = document.getElementById('compteur');
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
        const reponse = await Auth.api('/api/v1/chantiers?recherche=' + encodeURIComponent(terme));
        if (!reponse.ok) { corps.innerHTML = '<tr><td class="vide" colspan="' + nbColonnes + '">Erreur de chargement.</td></tr>'; return; }
        const json = await reponse.json();
        rendre(json.donnees.elements || [], json.donnees.total || 0);
    }

    function rendre(elements, total) {
        compteur.textContent = total + ' chantier' + (total > 1 ? 's' : '');
        if (elements.length === 0) {
            corps.innerHTML = '<tr><td class="vide" colspan="' + nbColonnes + '">Aucun chantier.</td></tr>';
            return;
        }
        corps.innerHTML = elements.map(function (c) {
            const lienDetail = base + '/chantiers/' + c.id;
            const lienEdit = base + '/chantiers/' + c.id + '/modifier';
            return '<tr>' +
                '<td>' + (c.code ? Format.echapper(c.code) : '<span class="cle">—</span>') + '</td>' +
                '<td><a class="lien" href="' + lienDetail + '">' + Format.echapper(c.nom) + '</a></td>' +
                '<td><span class="badge-valeur">' + (typesLibelles[c.type] || c.type) + '</span></td>' +
                '<td>' + (c.client_nom ? Format.echapper(c.client_nom) : '<span class="cle">—</span>') + '</td>' +
                (peutVoirFinances ? '<td>' + Format.ariary(c.budget_previsionnel) + '</td>' : '') +
                '<td>' + badgeStatut(c.statut) + '</td>' +
                (peutModifier ? '<td class="col-actions">' +
                    '<a class="lien-action" href="' + lienDetail + '">Ouvrir</a>' +
                    '<a class="lien-action" href="' + lienEdit + '">Modifier</a>' +
                '</td>' : '') +
                '</tr>';
        }).join('');
    }

    function badgeStatut(statut) {
        const libelle = statuts[statut] || statut;
        return '<span class="badge-statut statut-' + Format.echapper(statut) + '">' + Format.echapper(libelle) + '</span>';
    }
})();
