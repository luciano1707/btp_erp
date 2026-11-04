/* RFI : liste, formulaire et détail */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const STATUTS = {
        ouvert: 'Ouvert', en_cours: 'En cours', repondu: 'Répondu',
        cloture: 'Clôturé', annule: 'Annulé'
    };
    const PRIORITES = { basse: 'Basse', normale: 'Normale', haute: 'Haute', critique: 'Critique' };

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        if (document.getElementById('table-rfi')) { await initialiserListe(); }
        if (document.getElementById('form-rfi')) { initialiserFormulaire(); }
        if (document.getElementById('rfi-detail')) { await initialiserDetail(); }
    });

    function identifiant() {
        return window.location.pathname.split('/').filter(Boolean).pop();
    }

    async function chargerChantiers(select) {
        try {
            const rep = await Auth.api('/api/v1/chantiers?limite=200');
            if (!rep.ok) { return; }
            const data = (await rep.json()).donnees;
            const chantiers = Array.isArray(data) ? data : ((data && data.elements) || []);
            select.innerHTML = '<option value="">Choisir un chantier…</option>' + chantiers.map(function (c) {
                return '<option value="' + c.id + '">' + Format.echapper(c.nom) + '</option>';
            }).join('');
        } catch (e) { /* liste facultative */ }
    }

    async function initialiserListe() {
        const rep = await Auth.api('/api/v1/rfi');
        const tbody = document.getElementById('table-rfi');
        if (!rep.ok) { tbody.innerHTML = '<tr><td colspan="8" class="vide">Erreur de chargement</td></tr>'; return; }
        let donnees = (await rep.json()).donnees || [];
        if (!Array.isArray(donnees)) { donnees = donnees.elements || []; }

        function afficher(lignes) {
            if (!lignes.length) {
                tbody.innerHTML = '<tr><td colspan="8" class="vide">Aucune RFI</td></tr>';
                return;
            }
            tbody.innerHTML = lignes.map(function (r) {
                return '<tr>' +
                    '<td>' + Format.echapper(r.numero) + '</td>' +
                    '<td>' + Format.echapper(r.objet) + '</td>' +
                    '<td>' + Format.echapper(r.chantier_nom || '-') + '</td>' +
                    '<td>' + Format.echapper(r.emetteur_nom || '-') + '</td>' +
                    '<td>' + Format.echapper(PRIORITES[r.priorite] || r.priorite) + '</td>' +
                    '<td>' + Format.echapper(STATUTS[r.statut] || r.statut) + '</td>' +
                    '<td>' + Format.echapper(r.date_limite ? Format.date(r.date_limite) : '-') + '</td>' +
                    '<td><a class="lien" href="' + base + '/rfi/' + r.id + '">Détail</a></td>' +
                    '</tr>';
            }).join('');
        }

        const filtreStatut = document.getElementById('filtre-statut');
        const filtrePriorite = document.getElementById('filtre-priorite');
        function filtrer() {
            let lignes = donnees.slice();
            if (filtreStatut.value) { lignes = lignes.filter(function (r) { return r.statut === filtreStatut.value; }); }
            if (filtrePriorite.value) { lignes = lignes.filter(function (r) { return r.priorite === filtrePriorite.value; }); }
            afficher(lignes);
        }
        filtreStatut.addEventListener('change', filtrer);
        filtrePriorite.addEventListener('change', filtrer);
        afficher(donnees);
    }

    function initialiserFormulaire() {
        const form = document.getElementById('form-rfi');
        chargerChantiers(document.getElementById('chantier_id'));
        form.addEventListener('submit', async function (e) {
            e.preventDefault();
            if (!form.checkValidity()) { form.reportValidity(); return; }
            const corps = {
                chantier_id: form.chantier_id.value,
                objet: form.objet.value,
                priorite: form.priorite.value,
                date_limite: form.date_limite.value || null,
                question: form.question.value
            };
            const rep = await Auth.api('/api/v1/rfi', { method: 'POST', body: corps });
            if (!rep.ok) {
                const err = await rep.json().catch(function () { return {}; });
                alert(err.message || 'Erreur lors de l\'enregistrement');
                return;
            }
            const json = await rep.json();
            window.location.href = base + '/rfi/' + json.donnees.id;
        });
    }

    async function initialiserDetail() {
        const zone = document.getElementById('rfi-detail');
        const id = identifiant();
        const rep = await Auth.api('/api/v1/rfi/' + id);
        if (!rep.ok) { zone.textContent = 'RFI introuvable.'; return; }
        const r = (await rep.json()).donnees;
        if (!r) { zone.textContent = 'RFI introuvable.'; return; }

        zone.innerHTML = '<div class="grille-info">' +
            '<div><span class="info-label">Numéro</span>' + Format.echapper(r.numero) + '</div>' +
            '<div><span class="info-label">Objet</span>' + Format.echapper(r.objet) + '</div>' +
            '<div><span class="info-label">Chantier</span>' + Format.echapper(r.chantier_nom || '-') + '</div>' +
            '<div><span class="info-label">Émetteur</span>' + Format.echapper(r.emetteur_nom || '-') + '</div>' +
            '<div><span class="info-label">Priorité</span>' + Format.echapper(PRIORITES[r.priorite] || r.priorite) + '</div>' +
            '<div><span class="info-label">Statut</span>' + Format.echapper(STATUTS[r.statut] || r.statut) + '</div>' +
            '<div><span class="info-label">Date limite</span>' + Format.echapper(r.date_limite ? Format.date(r.date_limite) : '-') + '</div>' +
            '<div><span class="info-label">Répondu par</span>' + Format.echapper(r.repondeur_nom || '-') + '</div>' +
            '</div>' +
            '<h3>Question</h3><p>' + Format.echapper(r.question || '-') + '</p>' +
            (r.reponse ? '<h3>Réponse</h3><p>' + Format.echapper(r.reponse) + '</p>' : '');

        const zoneActions = document.getElementById('actions-rfi');
        const bloc = document.getElementById('bloc-reponse');
        if (!zoneActions || zoneActions.dataset.peutRepondre !== '1') { return; }
        if (['repondu', 'cloture', 'annule'].indexOf(r.statut) !== -1) { return; }

        const btn = document.createElement('button');
        btn.className = 'btn btn-primaire';
        btn.textContent = 'Répondre';
        btn.onclick = function () { bloc.hidden = false; document.getElementById('reponse-rfi').focus(); };
        zoneActions.appendChild(btn);

        document.getElementById('btn-repondre-rfi').addEventListener('click', async function () {
            const reponse = document.getElementById('reponse-rfi').value.trim();
            if (!reponse) { alert('Saisissez une réponse.'); return; }
            const res = await Auth.api('/api/v1/rfi/' + r.id + '/repondre', {
                method: 'POST', body: { reponse: reponse }
            });
            if (!res.ok) { alert('Erreur'); return; }
            location.reload();
        });
    }
})();
