/* Dépenses : liste, formulaire et détail */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const STATUTS = {
        brouillon: 'Brouillon', en_attente: 'En attente', valide: 'Validée',
        rejete: 'Rejetée', comptabilise: 'Comptabilisée'
    };
    const CATEGORIES = {
        materiaux: 'Matériaux', main_oeuvre: "Main d'œuvre", transport: 'Transport',
        carburant: 'Carburant', location: 'Location', administratif: 'Administratif', autre: 'Autre'
    };
    const PAIEMENTS = {
        especes: 'Espèces', virement: 'Virement', mobile_money: 'Mobile money', cheque: 'Chèque'
    };

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        if (document.getElementById('table-depenses')) { await initialiserListe(); }
        if (document.getElementById('form-depense')) { initialiserFormulaire(); }
        if (document.getElementById('depense-detail')) { await initialiserDetail(); }
    });

    function identifiant() {
        return window.location.pathname.split('/').filter(Boolean).pop();
    }

    function montant(valeur, devise) {
        return Number(valeur || 0).toLocaleString('fr-FR') + ' ' + (devise || 'MGA');
    }

    async function chargerChantiers(select) {
        try {
            const rep = await Auth.api('/api/v1/chantiers?limite=200');
            if (!rep.ok) { return; }
            const json = await rep.json();
            const data = json.donnees;
            const chantiers = Array.isArray(data) ? data : ((data && data.elements) || []);
            select.innerHTML = '<option value="">Aucun</option>' + chantiers.map(function (c) {
                return '<option value="' + c.id + '">' + Format.echapper(c.nom) + '</option>';
            }).join('');
        } catch (e) { /* liste facultative */ }
    }

    async function initialiserListe() {
        const rep = await Auth.api('/api/v1/depenses');
        const tbody = document.getElementById('table-depenses');
        if (!rep.ok) { tbody.innerHTML = '<tr><td colspan="8" class="vide">Erreur de chargement</td></tr>'; return; }
        let donnees = (await rep.json()).donnees || [];
        if (!Array.isArray(donnees)) { donnees = donnees.elements || []; }

        function afficher(lignes) {
            if (!lignes.length) {
                tbody.innerHTML = '<tr><td colspan="8" class="vide">Aucune dépense</td></tr>';
                return;
            }
            tbody.innerHTML = lignes.map(function (d) {
                return '<tr>' +
                    '<td>' + Format.echapper(d.numero) + '</td>' +
                    '<td>' + Format.echapper(d.libelle) + '</td>' +
                    '<td>' + Format.echapper(CATEGORIES[d.categorie] || d.categorie) + '</td>' +
                    '<td>' + Format.echapper(d.chantier_nom || '-') + '</td>' +
                    '<td>' + Format.echapper(Format.date(d.date_depense)) + '</td>' +
                    '<td>' + Format.echapper(montant(d.montant, d.devise)) + '</td>' +
                    '<td>' + Format.echapper(STATUTS[d.statut] || d.statut) + '</td>' +
                    '<td><a class="lien" href="' + base + '/depenses/' + d.id + '">Détail</a></td>' +
                    '</tr>';
            }).join('');
        }

        const filtre = document.getElementById('filtre-statut');
        if (filtre) {
            filtre.addEventListener('change', function () {
                const statut = filtre.value;
                afficher(statut ? donnees.filter(function (d) { return d.statut === statut; }) : donnees);
            });
        }
        afficher(donnees);
    }

    function initialiserFormulaire() {
        const form = document.getElementById('form-depense');
        const date = form.querySelector('[name="date_depense"]');
        if (date) { date.value = new Date().toISOString().slice(0, 10); }
        chargerChantiers(document.getElementById('chantier_id'));

        form.addEventListener('submit', async function (e) {
            e.preventDefault();
            if (!form.checkValidity()) { form.reportValidity(); return; }
            const corps = {
                libelle: form.libelle.value,
                categorie: form.categorie.value,
                chantier_id: form.chantier_id.value || null,
                date_depense: form.date_depense.value,
                montant: form.montant.value,
                devise: form.devise.value,
                mode_paiement: form.mode_paiement.value || null,
                beneficiaire: form.beneficiaire.value || null,
                justificatif: form.justificatif.value || null,
                notes: form.notes.value || null
            };
            const rep = await Auth.api('/api/v1/depenses', { method: 'POST', body: corps });
            if (!rep.ok) {
                const err = await rep.json().catch(function () { return {}; });
                alert(err.message || 'Erreur lors de l\'enregistrement');
                return;
            }
            const json = await rep.json();
            window.location.href = base + '/depenses/' + json.donnees.id;
        });
    }

    async function initialiserDetail() {
        const zone = document.getElementById('depense-detail');
        const id = identifiant();
        const rep = await Auth.api('/api/v1/depenses/' + id);
        if (!rep.ok) { zone.textContent = 'Dépense introuvable.'; return; }
        const d = (await rep.json()).donnees;
        if (!d) { zone.textContent = 'Dépense introuvable.'; return; }

        zone.innerHTML = '<div class="grille-info">' +
            '<div><span class="info-label">Numéro</span>' + Format.echapper(d.numero) + '</div>' +
            '<div><span class="info-label">Libellé</span>' + Format.echapper(d.libelle) + '</div>' +
            '<div><span class="info-label">Catégorie</span>' + Format.echapper(CATEGORIES[d.categorie] || d.categorie) + '</div>' +
            '<div><span class="info-label">Chantier</span>' + Format.echapper(d.chantier_nom || '-') + '</div>' +
            '<div><span class="info-label">Déclarant</span>' + Format.echapper(d.declarant_nom || '-') + '</div>' +
            '<div><span class="info-label">Date</span>' + Format.echapper(Format.date(d.date_depense)) + '</div>' +
            '<div><span class="info-label">Montant</span>' + Format.echapper(montant(d.montant, d.devise)) + '</div>' +
            '<div><span class="info-label">Paiement</span>' + Format.echapper(PAIEMENTS[d.mode_paiement] || d.mode_paiement || '-') + '</div>' +
            '<div><span class="info-label">Bénéficiaire</span>' + Format.echapper(d.beneficiaire || '-') + '</div>' +
            '<div><span class="info-label">Statut</span>' + Format.echapper(STATUTS[d.statut] || d.statut) + '</div>' +
            '<div><span class="info-label">Validée par</span>' + Format.echapper(d.valideur_nom || '-') + '</div>' +
            '<div><span class="info-label">Justificatif</span>' + Format.echapper(d.justificatif || '-') + '</div>' +
            '</div>' +
            (d.notes ? '<h3>Notes</h3><p>' + Format.echapper(d.notes) + '</p>' : '') +
            (d.motif_rejet ? '<div class="bloc-note"><h4>Motif du rejet</h4><p>' + Format.echapper(d.motif_rejet) + '</p></div>' : '');

        const zoneActions = document.getElementById('actions-depense');
        if (!zoneActions || zoneActions.dataset.peutValider !== '1') { return; }
        if (['brouillon', 'en_attente'].indexOf(d.statut) === -1) { return; }
        const validationRep = await Auth.api(
            '/api/v1/validations?type_operation=depense&operation_id=' + encodeURIComponent(d.id) + '&limite=1'
        );
        if (!validationRep.ok) {
            zoneActions.textContent = 'Impossible de vérifier l’étape de validation.';
            return;
        }
        const validationData = (await validationRep.json()).donnees || [];
        const validation = Array.isArray(validationData) ? validationData[0] : (validationData.elements || [])[0];
        if (!validation || validation.statut !== 'en_attente' ||
            validation.role_attendu !== zoneActions.dataset.role) { return; }

        const btnValider = document.createElement('button');
        btnValider.className = 'btn btn-primaire';
        btnValider.textContent = 'Approuver';
        btnValider.onclick = async function () {
            if (!confirm('Approuver cette dépense ?')) { return; }
            const r = await Auth.api('/api/v1/depenses/' + d.id + '/valider', { method: 'POST' });
            if (!r.ok) { alert('Erreur'); return; }
            location.reload();
        };
        zoneActions.appendChild(btnValider);

        const btnRejeter = document.createElement('button');
        btnRejeter.className = 'btn btn-rouge';
        btnRejeter.textContent = 'Refuser';
        btnRejeter.onclick = function () { document.getElementById('dialog-rejet').showModal(); };
        zoneActions.appendChild(btnRejeter);

        const dialog = document.getElementById('dialog-rejet');
        document.getElementById('form-rejet').addEventListener('submit', async function (e) {
            e.preventDefault();
            const motif = e.target.motif_rejet.value;
            if (!motif) { return; }
            const r = await Auth.api('/api/v1/depenses/' + d.id + '/rejeter', {
                method: 'POST', body: { motif_rejet: motif }
            });
            dialog.close();
            if (!r.ok) { alert('Erreur'); return; }
            location.reload();
        });
    }
})();
