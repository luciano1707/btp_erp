/* Journal d'audit (directeur) : liste paginee + filtre par action. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const corps = document.getElementById('corps-tableau');
    const filtre = document.getElementById('filtre-action');
    let page = 1;
    let minuteur = null;

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        charger();
        filtre.addEventListener('input', function () {
            clearTimeout(minuteur);
            minuteur = setTimeout(function () { page = 1; charger(); }, 300);
        });
        document.getElementById('btn-precedent').addEventListener('click', function () { if (page > 1) { page--; charger(); } });
        document.getElementById('btn-suivant').addEventListener('click', function () { page++; charger(); });
    });

    async function charger() {
        const rep = await Auth.api('/api/v1/journal?page=' + page + '&action=' + encodeURIComponent(filtre.value.trim()));
        if (rep.status === 403) { corps.innerHTML = '<tr><td class="vide" colspan="6">Acces reserve au directeur.</td></tr>'; return; }
        if (!rep.ok) { corps.innerHTML = '<tr><td class="vide" colspan="6">Erreur.</td></tr>'; return; }
        const d = (await rep.json()).donnees;
        rendre(d);
    }

    function rendre(d) {
        document.getElementById('compteur').textContent = d.total + ' evenement(s)';
        const pages = Math.max(1, Math.ceil(d.total / d.limite));
        document.getElementById('info-page').textContent = 'Page ' + d.page + ' / ' + pages;
        if (!d.elements.length) { corps.innerHTML = '<tr><td class="vide" colspan="6">Aucun evenement.</td></tr>'; return; }
        corps.innerHTML = d.elements.map(function (e) {
            return '<tr>' +
                '<td>' + Format.echapper(e.cree_le) + '</td>' +
                '<td>' + Format.echapper(e.utilisateur_nom || '—') + '</td>' +
                '<td><span class="badge-valeur">' + Format.echapper(e.action) + '</span></td>' +
                '<td>' + Format.echapper(e.entite || '—') + (e.entite_id ? ' #' + Format.echapper(e.entite_id) : '') + '</td>' +
                '<td class="details-audit">' + Format.echapper(e.details || '—') + '</td>' +
                '<td>' + Format.echapper(e.adresse_ip || '—') + '</td>' +
                '</tr>';
        }).join('');
    }
})();
