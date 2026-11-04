/* Qualité : liste, formulaire et détail */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const STATUTS = { ouvert: 'Ouvert', en_cours: 'En cours', clos: 'Clos' };
    const RESULTATS = { conforme: 'Conforme', non_conforme: 'Non conforme', reserve: 'Réserve' };
    const TYPES = { reception: 'Réception', controle: 'Contrôle', essai: 'Essai', audit: 'Audit', autre: 'Autre' };

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        if (document.getElementById('table-qualite')) { await initialiserListe(); }
        if (document.getElementById('form-qualite')) { initialiserFormulaire(); }
        if (document.getElementById('qualite-detail')) { await initialiserDetail(); }
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

    async function chargerLots(chantierId, select) {
        select.innerHTML = '<option value="">Aucun lot</option>';
        if (!chantierId) { return; }
        try {
            const rep = await Auth.api('/api/v1/chantiers/' + chantierId + '/lots');
            if (!rep.ok) { return; }
            const data = (await rep.json()).donnees;
            const lots = Array.isArray(data) ? data : ((data && data.elements) || []);
            select.innerHTML = '<option value="">Aucun lot</option>' + lots.map(function (l) {
                return '<option value="' + l.id + '">' + Format.echapper(l.nom) + '</option>';
            }).join('');
        } catch (e) { /* facultatif */ }
    }

    async function initialiserListe() {
        const rep = await Auth.api('/api/v1/qualite');
        const tbody = document.getElementById('table-qualite');
        if (!rep.ok) { tbody.innerHTML = '<tr><td colspan="8" class="vide">Erreur de chargement</td></tr>'; return; }
        let donnees = (await rep.json()).donnees || [];
        if (!Array.isArray(donnees)) { donnees = donnees.elements || []; }

        function afficher(lignes) {
            if (!lignes.length) {
                tbody.innerHTML = '<tr><td colspan="8" class="vide">Aucune inspection</td></tr>';
                return;
            }
            tbody.innerHTML = lignes.map(function (q) {
                return '<tr>' +
                    '<td>' + Format.echapper(q.numero) + '</td>' +
                    '<td>' + Format.echapper(q.chantier_nom || '-') + '</td>' +
                    '<td>' + Format.echapper(q.lot_nom || '-') + '</td>' +
                    '<td>' + Format.echapper(Format.date(q.date_inspection)) + '</td>' +
                    '<td>' + Format.echapper(TYPES[q.type_inspection] || q.type_inspection || '-') + '</td>' +
                    '<td>' + Format.echapper(RESULTATS[q.resultat] || q.resultat) + '</td>' +
                    '<td>' + Format.echapper(STATUTS[q.statut] || q.statut) + '</td>' +
                    '<td><a class="lien" href="' + base + '/qualite/' + q.id + '">Détail</a></td>' +
                    '</tr>';
            }).join('');
        }

        const filtreStatut = document.getElementById('filtre-statut');
        const filtreResultat = document.getElementById('filtre-resultat');
        function filtrer() {
            let lignes = donnees.slice();
            if (filtreStatut.value) { lignes = lignes.filter(function (q) { return q.statut === filtreStatut.value; }); }
            if (filtreResultat.value) { lignes = lignes.filter(function (q) { return q.resultat === filtreResultat.value; }); }
            afficher(lignes);
        }
        filtreStatut.addEventListener('change', filtrer);
        filtreResultat.addEventListener('change', filtrer);
        afficher(donnees);
    }

    function initialiserFormulaire() {
        const form = document.getElementById('form-qualite');
        const chantier = document.getElementById('chantier_id');
        const lot = document.getElementById('lot_id');
        form.date_inspection.value = new Date().toISOString().slice(0, 10);
        chargerChantiers(chantier);
        chantier.addEventListener('change', function () { chargerLots(chantier.value, lot); });

        form.addEventListener('submit', async function (e) {
            e.preventDefault();
            if (!form.checkValidity()) { form.reportValidity(); return; }
            const corps = {
                chantier_id: chantier.value,
                lot_id: lot.value || null,
                date_inspection: form.date_inspection.value,
                type_inspection: form.type_inspection.value || null,
                resultat: form.resultat.value,
                constat: form.constat.value || null,
                action_corrective: form.action_corrective.value || null
            };
            const rep = await Auth.api('/api/v1/qualite', { method: 'POST', body: corps });
            if (!rep.ok) {
                const err = await rep.json().catch(function () { return {}; });
                alert(err.message || 'Erreur lors de l\'enregistrement');
                return;
            }
            const json = await rep.json();
            window.location.href = base + '/qualite/' + json.donnees.id;
        });
    }

    async function initialiserDetail() {
        const zone = document.getElementById('qualite-detail');
        const id = identifiant();
        const rep = await Auth.api('/api/v1/qualite/' + id);
        if (!rep.ok) { zone.textContent = 'Inspection introuvable.'; return; }
        const q = (await rep.json()).donnees;
        if (!q) { zone.textContent = 'Inspection introuvable.'; return; }

        zone.innerHTML = '<div class="grille-info">' +
            '<div><span class="info-label">Numéro</span>' + Format.echapper(q.numero) + '</div>' +
            '<div><span class="info-label">Chantier</span>' + Format.echapper(q.chantier_nom || '-') + '</div>' +
            '<div><span class="info-label">Lot</span>' + Format.echapper(q.lot_nom || '-') + '</div>' +
            '<div><span class="info-label">Inspecteur</span>' + Format.echapper(q.inspecteur_nom || '-') + '</div>' +
            '<div><span class="info-label">Date</span>' + Format.echapper(Format.date(q.date_inspection)) + '</div>' +
            '<div><span class="info-label">Type</span>' + Format.echapper(TYPES[q.type_inspection] || q.type_inspection || '-') + '</div>' +
            '<div><span class="info-label">Résultat</span>' + Format.echapper(RESULTATS[q.resultat] || q.resultat) + '</div>' +
            '<div><span class="info-label">Statut</span>' + Format.echapper(STATUTS[q.statut] || q.statut) + '</div>' +
            '</div>' +
            '<h3>Constat</h3><p>' + Format.echapper(q.constat || '-') + '</p>' +
            (q.action_corrective ? '<h3>Action corrective</h3><p>' + Format.echapper(q.action_corrective) + '</p>' : '');

        const zoneActions = document.getElementById('actions-qualite');
        if (!zoneActions || zoneActions.dataset.peutModifier !== '1') { return; }

        const btn = document.createElement('button');
        btn.className = 'btn btn-primaire';
        btn.textContent = 'Mettre à jour';
        btn.onclick = function () {
            const dialog = document.getElementById('dialog-qualite');
            dialog.querySelector('[name="statut"]').value = q.statut;
            dialog.querySelector('[name="action_corrective"]').value = q.action_corrective || '';
            dialog.showModal();
        };
        zoneActions.appendChild(btn);

        document.getElementById('form-maj-qualite').addEventListener('submit', async function (e) {
            e.preventDefault();
            const dialog = document.getElementById('dialog-qualite');
            const corps = {
                statut: e.target.statut.value,
                action_corrective: e.target.action_corrective.value || null
            };
            const r = await Auth.api('/api/v1/qualite/' + q.id, { method: 'PUT', body: corps });
            dialog.close();
            if (!r.ok) { alert('Erreur'); return; }
            location.reload();
        });
    }
})();
