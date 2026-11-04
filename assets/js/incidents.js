/* Incidents : liste, formulaire et détail */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const STATUTS = { ouvert: 'Ouvert', enquete: 'Enquête', clos: 'Clos' };
    const GRAVITES = { faible: 'Faible', moyenne: 'Moyenne', grave: 'Grave', critique: 'Critique' };
    const TYPES = { incident: 'Incident', accident: 'Accident', presque_accident: 'Presque accident' };

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        if (document.getElementById('table-incidents')) { await initialiserListe(); }
        if (document.getElementById('form-incident')) { initialiserFormulaire(); }
        if (document.getElementById('incident-detail')) { await initialiserDetail(); }
    });

    function identifiant() {
        return window.location.pathname.split('/').filter(Boolean).pop();
    }

    function dateHeure(valeur) {
        if (!valeur) { return '-'; }
        const texte = String(valeur).replace('T', ' ').substring(0, 16);
        const parties = texte.split(' ');
        if (parties.length !== 2) { return texte; }
        return Format.date(parties[0]) + ' à ' + parties[1];
    }

    function maintenantLocal() {
        const d = new Date();
        const pad = function (n) { return String(n).padStart(2, '0'); };
        return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate()) +
            'T' + pad(d.getHours()) + ':' + pad(d.getMinutes());
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
        const rep = await Auth.api('/api/v1/incidents');
        const tbody = document.getElementById('table-incidents');
        if (!rep.ok) { tbody.innerHTML = '<tr><td colspan="7" class="vide">Erreur de chargement</td></tr>'; return; }
        let donnees = (await rep.json()).donnees || [];
        if (!Array.isArray(donnees)) { donnees = donnees.elements || []; }

        function afficher(lignes) {
            if (!lignes.length) {
                tbody.innerHTML = '<tr><td colspan="7" class="vide">Aucun incident</td></tr>';
                return;
            }
            tbody.innerHTML = lignes.map(function (i) {
                return '<tr>' +
                    '<td>' + Format.echapper(i.numero) + '</td>' +
                    '<td>' + Format.echapper(i.chantier_nom || '-') + '</td>' +
                    '<td>' + Format.echapper(dateHeure(i.date_incident)) + '</td>' +
                    '<td>' + Format.echapper(TYPES[i.type_incident] || i.type_incident) + '</td>' +
                    '<td>' + Format.echapper(GRAVITES[i.gravite] || i.gravite) + '</td>' +
                    '<td>' + Format.echapper(STATUTS[i.statut] || i.statut) + '</td>' +
                    '<td><a class="lien" href="' + base + '/incidents/' + i.id + '">Détail</a></td>' +
                    '</tr>';
            }).join('');
        }

        const filtreStatut = document.getElementById('filtre-statut');
        const filtreGravite = document.getElementById('filtre-gravite');
        function filtrer() {
            let lignes = donnees.slice();
            if (filtreStatut.value) { lignes = lignes.filter(function (i) { return i.statut === filtreStatut.value; }); }
            if (filtreGravite.value) { lignes = lignes.filter(function (i) { return i.gravite === filtreGravite.value; }); }
            afficher(lignes);
        }
        filtreStatut.addEventListener('change', filtrer);
        filtreGravite.addEventListener('change', filtrer);
        afficher(donnees);
    }

    function initialiserFormulaire() {
        const form = document.getElementById('form-incident');
        form.date_incident.value = maintenantLocal();
        chargerChantiers(document.getElementById('chantier_id'));
        form.addEventListener('submit', async function (e) {
            e.preventDefault();
            if (!form.checkValidity()) { form.reportValidity(); return; }
            const corps = {
                chantier_id: form.chantier_id.value,
                date_incident: form.date_incident.value,
                lieu: form.lieu.value || null,
                type_incident: form.type_incident.value,
                gravite: form.gravite.value,
                victimes: form.victimes.value || null,
                description: form.description.value,
                premiers_secours: form.premiers_secours.value || null,
                action_corrective: form.action_corrective.value || null
            };
            const rep = await Auth.api('/api/v1/incidents', { method: 'POST', body: corps });
            if (!rep.ok) {
                const err = await rep.json().catch(function () { return {}; });
                alert(err.message || 'Erreur lors de l\'enregistrement');
                return;
            }
            const json = await rep.json();
            window.location.href = base + '/incidents/' + json.donnees.id;
        });
    }

    async function initialiserDetail() {
        const zone = document.getElementById('incident-detail');
        const id = identifiant();
        const rep = await Auth.api('/api/v1/incidents/' + id);
        if (!rep.ok) { zone.textContent = 'Incident introuvable.'; return; }
        const i = (await rep.json()).donnees;
        if (!i) { zone.textContent = 'Incident introuvable.'; return; }

        zone.innerHTML = '<div class="grille-info">' +
            '<div><span class="info-label">Numéro</span>' + Format.echapper(i.numero) + '</div>' +
            '<div><span class="info-label">Chantier</span>' + Format.echapper(i.chantier_nom || '-') + '</div>' +
            '<div><span class="info-label">Déclarant</span>' + Format.echapper(i.declarant_nom || '-') + '</div>' +
            '<div><span class="info-label">Date</span>' + Format.echapper(dateHeure(i.date_incident)) + '</div>' +
            '<div><span class="info-label">Lieu</span>' + Format.echapper(i.lieu || '-') + '</div>' +
            '<div><span class="info-label">Type</span>' + Format.echapper(TYPES[i.type_incident] || i.type_incident) + '</div>' +
            '<div><span class="info-label">Gravité</span>' + Format.echapper(GRAVITES[i.gravite] || i.gravite) + '</div>' +
            '<div><span class="info-label">Statut</span>' + Format.echapper(STATUTS[i.statut] || i.statut) + '</div>' +
            '<div><span class="info-label">Victimes</span>' + Format.echapper(i.victimes || '-') + '</div>' +
            '<div><span class="info-label">Suivi par</span>' + Format.echapper(i.suiveur_nom || '-') + '</div>' +
            '</div>' +
            '<h3>Description</h3><p>' + Format.echapper(i.description || '-') + '</p>' +
            (i.premiers_secours ? '<h3>Premiers secours</h3><p>' + Format.echapper(i.premiers_secours) + '</p>' : '') +
            (i.action_corrective ? '<h3>Action corrective</h3><p>' + Format.echapper(i.action_corrective) + '</p>' : '');

        const zoneActions = document.getElementById('actions-incident');
        if (!zoneActions || zoneActions.dataset.peutModifier !== '1') { return; }

        const btn = document.createElement('button');
        btn.className = 'btn btn-primaire';
        btn.textContent = 'Mettre à jour';
        btn.onclick = function () {
            const dialog = document.getElementById('dialog-incident');
            dialog.querySelector('[name="statut"]').value = i.statut;
            dialog.querySelector('[name="premiers_secours"]').value = i.premiers_secours || '';
            dialog.querySelector('[name="action_corrective"]').value = i.action_corrective || '';
            dialog.showModal();
        };
        zoneActions.appendChild(btn);

        document.getElementById('form-maj-incident').addEventListener('submit', async function (e) {
            e.preventDefault();
            const dialog = document.getElementById('dialog-incident');
            const corps = {
                statut: e.target.statut.value,
                premiers_secours: e.target.premiers_secours.value || null,
                action_corrective: e.target.action_corrective.value || null
            };
            const r = await Auth.api('/api/v1/incidents/' + i.id, { method: 'PUT', body: corps });
            dialog.close();
            if (!r.ok) { alert('Erreur'); return; }
            location.reload();
        });
    }
})();
