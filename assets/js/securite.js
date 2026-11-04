/* Sécurité : liste, formulaire et détail */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const STATUTS = { ouvert: 'Ouvert', en_cours: 'En cours', clos: 'Clos' };
    const TYPES = { danger: 'Danger', risque: 'Risque', bonne_pratique: 'Bonne pratique', autre: 'Autre' };

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        if (document.getElementById('table-securite')) { await initialiserListe(); }
        if (document.getElementById('form-securite')) { initialiserFormulaire(); }
        if (document.getElementById('securite-detail')) { await initialiserDetail(); }
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
        const rep = await Auth.api('/api/v1/securite');
        const tbody = document.getElementById('table-securite');
        if (!rep.ok) { tbody.innerHTML = '<tr><td colspan="7" class="vide">Erreur de chargement</td></tr>'; return; }
        let donnees = (await rep.json()).donnees || [];
        if (!Array.isArray(donnees)) { donnees = donnees.elements || []; }

        function afficher(lignes) {
            if (!lignes.length) {
                tbody.innerHTML = '<tr><td colspan="7" class="vide">Aucune observation</td></tr>';
                return;
            }
            tbody.innerHTML = lignes.map(function (s) {
                return '<tr>' +
                    '<td>' + Format.echapper(s.numero) + '</td>' +
                    '<td>' + Format.echapper(s.chantier_nom || '-') + '</td>' +
                    '<td>' + Format.echapper(Format.date(s.date_observation)) + '</td>' +
                    '<td>' + Format.echapper(TYPES[s.type_observation] || s.type_observation) + '</td>' +
                    '<td>' + Format.echapper(s.lieu || '-') + '</td>' +
                    '<td>' + Format.echapper(STATUTS[s.statut] || s.statut) + '</td>' +
                    '<td><a class="lien" href="' + base + '/securite/' + s.id + '">Détail</a></td>' +
                    '</tr>';
            }).join('');
        }

        const filtreStatut = document.getElementById('filtre-statut');
        const filtreType = document.getElementById('filtre-type');
        function filtrer() {
            let lignes = donnees.slice();
            if (filtreStatut.value) { lignes = lignes.filter(function (s) { return s.statut === filtreStatut.value; }); }
            if (filtreType.value) { lignes = lignes.filter(function (s) { return s.type_observation === filtreType.value; }); }
            afficher(lignes);
        }
        filtreStatut.addEventListener('change', filtrer);
        filtreType.addEventListener('change', filtrer);
        afficher(donnees);
    }

    function initialiserFormulaire() {
        const form = document.getElementById('form-securite');
        form.date_observation.value = new Date().toISOString().slice(0, 10);
        chargerChantiers(document.getElementById('chantier_id'));
        form.addEventListener('submit', async function (e) {
            e.preventDefault();
            if (!form.checkValidity()) { form.reportValidity(); return; }
            const corps = {
                chantier_id: form.chantier_id.value,
                date_observation: form.date_observation.value,
                lieu: form.lieu.value || null,
                type_observation: form.type_observation.value,
                description: form.description.value,
                action_immediate: form.action_immediate.value || null,
                mesure_preventive: form.mesure_preventive.value || null
            };
            const rep = await Auth.api('/api/v1/securite', { method: 'POST', body: corps });
            if (!rep.ok) {
                const err = await rep.json().catch(function () { return {}; });
                alert(err.message || 'Erreur lors de l\'enregistrement');
                return;
            }
            const json = await rep.json();
            window.location.href = base + '/securite/' + json.donnees.id;
        });
    }

    async function initialiserDetail() {
        const zone = document.getElementById('securite-detail');
        const id = identifiant();
        const rep = await Auth.api('/api/v1/securite/' + id);
        if (!rep.ok) { zone.textContent = 'Observation introuvable.'; return; }
        const s = (await rep.json()).donnees;
        if (!s) { zone.textContent = 'Observation introuvable.'; return; }

        zone.innerHTML = '<div class="grille-info">' +
            '<div><span class="info-label">Numéro</span>' + Format.echapper(s.numero) + '</div>' +
            '<div><span class="info-label">Chantier</span>' + Format.echapper(s.chantier_nom || '-') + '</div>' +
            '<div><span class="info-label">Déclarant</span>' + Format.echapper(s.declarant_nom || '-') + '</div>' +
            '<div><span class="info-label">Date</span>' + Format.echapper(Format.date(s.date_observation)) + '</div>' +
            '<div><span class="info-label">Lieu</span>' + Format.echapper(s.lieu || '-') + '</div>' +
            '<div><span class="info-label">Type</span>' + Format.echapper(TYPES[s.type_observation] || s.type_observation) + '</div>' +
            '<div><span class="info-label">Statut</span>' + Format.echapper(STATUTS[s.statut] || s.statut) + '</div>' +
            '</div>' +
            '<h3>Description</h3><p>' + Format.echapper(s.description || '-') + '</p>' +
            (s.action_immediate ? '<h3>Action immédiate</h3><p>' + Format.echapper(s.action_immediate) + '</p>' : '') +
            (s.mesure_preventive ? '<h3>Mesure préventive</h3><p>' + Format.echapper(s.mesure_preventive) + '</p>' : '');

        const zoneActions = document.getElementById('actions-securite');
        if (!zoneActions || zoneActions.dataset.peutModifier !== '1') { return; }

        const btn = document.createElement('button');
        btn.className = 'btn btn-primaire';
        btn.textContent = 'Mettre à jour';
        btn.onclick = function () {
            const dialog = document.getElementById('dialog-securite');
            dialog.querySelector('[name="statut"]').value = s.statut;
            dialog.querySelector('[name="action_immediate"]').value = s.action_immediate || '';
            dialog.querySelector('[name="mesure_preventive"]').value = s.mesure_preventive || '';
            dialog.showModal();
        };
        zoneActions.appendChild(btn);

        document.getElementById('form-maj-securite').addEventListener('submit', async function (e) {
            e.preventDefault();
            const dialog = document.getElementById('dialog-securite');
            const corps = {
                statut: e.target.statut.value,
                action_immediate: e.target.action_immediate.value || null,
                mesure_preventive: e.target.mesure_preventive.value || null
            };
            const r = await Auth.api('/api/v1/securite/' + s.id, { method: 'PUT', body: corps });
            dialog.close();
            if (!r.ok) { alert('Erreur'); return; }
            location.reload();
        });
    }
})();
