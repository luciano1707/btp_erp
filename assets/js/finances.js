/* Page finances : rentabilite par chantier + tresorerie. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        await Promise.all([chargerChantiers(), chargerTresorerie(), chargerGraphiques()]);
        document.getElementById('btn-treso').addEventListener('click', chargerTresorerie);
    });

    async function chargerGraphiques() {
        // Courbe mensuelle
        const repM = await Auth.api('/api/v1/stats/mensuel');
        if (repM.ok) {
            const mois = (await repM.json()).donnees || [];
            Charts.aire(document.getElementById('graphique-mensuel'), {
                labels: mois.map(function (m) { return m.libelle; }),
                format: function (v) { return Format.ariary(v); },
                series: [
                    { nom: 'Facture', couleur: '#2c6ea4', valeurs: mois.map(function (m) { return Number(m.facture); }) },
                    { nom: 'Encaisse', couleur: '#2f9e6f', valeurs: mois.map(function (m) { return Number(m.encaisse); }) }
                ]
            });
        }
        // Donut couts par chantier
        const repC = await Auth.api('/api/v1/stats/chantiers');
        if (repC.ok) {
            const lignes = (await repC.json()).donnees || [];
            const segs = lignes
                .filter(function (c) { return Number(c.cout_total) > 0; })
                .sort(function (a, b) { return Number(b.cout_total) - Number(a.cout_total); })
                .map(function (c, i) { return { nom: c.nom, valeur: Number(c.cout_total), couleur: Charts.couleur(i) }; });
            const zone = document.getElementById('donut-couts');
            if (segs.length) {
                Charts.donut(zone, { segments: segs, format: function (v) { return Format.ariary(v); }, sousLibelle: 'Cout total' });
            } else {
                zone.innerHTML = '<p class="sous-titre">Aucun cout engage.</p>';
            }
        }
    }

    async function chargerChantiers() {
        const rep = await Auth.api('/api/v1/stats/chantiers');
        const corps = document.getElementById('corps-chantiers');
        if (!rep.ok) { corps.innerHTML = '<tr><td class="vide" colspan="8">Erreur.</td></tr>'; return; }
        const lignes = (await rep.json()).donnees || [];
        if (!lignes.length) { corps.innerHTML = '<tr><td class="vide" colspan="8">Aucun chantier.</td></tr>'; return; }
        corps.innerHTML = lignes.map(function (c) {
            const marge = Number(c.marge);
            return '<tr>' +
                '<td><a class="lien" href="' + base + '/chantiers/' + c.id + '">' + Format.echapper(c.nom) + '</a></td>' +
                '<td>' + Format.ariary(c.budget_previsionnel) + '</td>' +
                '<td>' + Format.ariary(c.cout_mo) + '</td>' +
                '<td>' + Format.ariary(c.cout_mat) + '</td>' +
                '<td>' + Format.ariary(c.cout_total) + '</td>' +
                '<td>' + Format.ariary(c.facture) + '</td>' +
                '<td>' + Format.ariary(c.encaisse) + '</td>' +
                '<td class="' + (marge < 0 ? 'montant-negatif' : 'montant-positif') + '">' + Format.ariary(marge) + '</td>' +
                '</tr>';
        }).join('');
    }

    async function chargerTresorerie() {
        const debut = document.getElementById('treso-debut').value;
        const fin = document.getElementById('treso-fin').value;
        let url = '/api/v1/stats/tresorerie';
        const q = [];
        if (debut) { q.push('debut=' + debut); }
        if (fin) { q.push('fin=' + fin); }
        if (q.length) { url += '?' + q.join('&'); }

        const rep = await Auth.api(url);
        if (!rep.ok) { return; }
        const t = (await rep.json()).donnees;
        document.getElementById('tr-enc').textContent = Format.ariary(t.encaissements);
        document.getElementById('tr-dec').textContent = Format.ariary(t.decaissements);
        const solde = document.getElementById('tr-solde');
        solde.innerHTML = '<strong class="' + (t.solde < 0 ? 'montant-negatif' : 'montant-positif') + '">' + Format.ariary(t.solde) + '</strong>';
    }
})();
