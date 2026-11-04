/* Budgets : liste, formulaire et détail */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const STATUTS = { ouvert: 'Ouvert', cloture: 'Clôturé' };
    let donnees = [];

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        if (document.getElementById('table-budgets')) { await initialiserListe(); }
        if (document.getElementById('form-budget')) { initialiserFormulaire(); }
        if (document.getElementById('budget-detail')) { await initialiserDetail(); }
    });

    function identifiant() {
        return window.location.pathname.split('/').filter(Boolean).pop();
    }

    function montant(valeur, devise) {
        return Number(valeur || 0).toLocaleString('fr-FR') + ' ' + (devise || 'MGA');
    }

    function pourcentage(valeur) {
        return Number(valeur || 0).toFixed(1) + '%';
    }

    function couleurPourcentage(pct) {
        if (pct >= 90) return '#ef4444'; // rouge
        if (pct >= 70) return '#f97316'; // orange
        return '#22c55e'; // vert
    }

    async function chargerChantiers(select) {
        try {
            const rep = await Auth.api('/api/v1/chantiers?limite=200');
            if (!rep.ok) { return; }
            const data = (await rep.json()).donnees;
            const chantiers = Array.isArray(data) ? data : ((data && data.elements) || []);
            select.innerHTML = '<option value="">Tous les chantiers</option>' + chantiers.map(function (c) {
                return '<option value="' + c.id + '">' + Format.echapper((c.code ? c.code + ' - ' : '') + c.nom) + '</option>';
            }).join('');
        } catch (e) { /* liste facultative */ }
    }

    async function initialiserListe() {
        const rep = await Auth.api('/api/v1/budgets');
        const tbody = document.getElementById('table-budgets');
        if (!rep.ok) { tbody.innerHTML = '<tr><td colspan="11" class="vide">Erreur de chargement</td></tr>'; return; }
        const json = await rep.json();
        donnees = json.donnees || [];
        if (!Array.isArray(donnees)) { donnees = donnees.elements || []; }

        // Charger les filtres
        await chargerChantiers(document.getElementById('filtre-chantier'));
        
        // Remplir le filtre année
        const filtreAnnee = document.getElementById('filtre-annee');
        if (filtreAnnee) {
            const annees = [...new Set(donnees.map(function (b) { return b.annee; }))];
            filtreAnnee.innerHTML = '<option value="">Toutes les années</option>' + 
                annees.map(function (a) { return '<option value="' + a + '">' + a + '</option>'; }).join('');
        }

        function afficher(lignes) {
            // Calculer les KPI
            let totalPrevu = 0, totalDepense = 0, totalRestant = 0;
            lignes.forEach(function (b) {
                totalPrevu += Number(b.budget_previsionnel || 0);
                totalDepense += Number(b.total_reel || 0);
                totalRestant += Number(b.budget_previsionnel || 0) - Number(b.total_reel || 0);
            });
            const pctConso = totalPrevu > 0 ? (totalDepense / totalPrevu * 100) : 0;

            document.getElementById('kpi-total').textContent = montant(totalPrevu, 'MGA');
            document.getElementById('kpi-depense').textContent = montant(totalDepense, 'MGA');
            document.getElementById('kpi-restant').textContent = montant(totalRestant, 'MGA');
            document.getElementById('kpi-pourcentage').textContent = pourcentage(pctConso);
            document.getElementById('kpi-pourcentage').style.color = couleurPourcentage(pctConso);

            if (!lignes.length) {
                tbody.innerHTML = '<tr><td colspan="11" class="vide">Aucun budget</td></tr>';
                return;
            }
            tbody.innerHTML = lignes.map(function (b) {
                const prevu = Number(b.budget_previsionnel || 0);
                const reel = Number(b.total_reel || 0);
                const restant = prevu - reel;
                const pct = prevu > 0 ? (reel / prevu * 100) : 0;
                const couleur = couleurPourcentage(pct);
                
                return '<tr>' +
                    '<td>' + Format.echapper(b.chantier_nom || '-') + '</td>' +
                    '<td>' + Format.echapper(b.annee) + '</td>' +
                    '<td>' + Format.echapper(montant(prevu, b.devise)) + '</td>' +
                    '<td>' + Format.echapper(montant(b.total_engage, b.devise)) + '</td>' +
                    '<td>' + Format.echapper(montant(reel, b.devise)) + '</td>' +
                    '<td>' + Format.echapper(montant(b.depenses_validees, b.devise)) + '</td>' +
                    '<td>' + Format.echapper(montant(restant, b.devise)) + '</td>' +
                    '<td><span style="color:' + couleur + ';font-weight:600;">' + pourcentage(pct) + '</span></td>' +
                    '<td><div class="jauge jauge-mini"><div class="jauge-remplie" style="width:' + Math.min(pct, 100) + '%;background:' + couleur + ';"></div></div></td>' +
                    '<td>' + Format.echapper(STATUTS[b.statut] || b.statut) + '</td>' +
                    '<td><a class="lien" href="' + base + '/budgets/' + b.id + '">Détail</a></td>' +
                    '</tr>';
            }).join('');
        }

        const filtreStatut = document.getElementById('filtre-statut');
        const filtreChantier = document.getElementById('filtre-chantier');

        function appliquerFiltres() {
            let filtrees = donnees;
            if (filtreStatut && filtreStatut.value) {
                filtrees = filtrees.filter(function (b) { return b.statut === filtreStatut.value; });
            }
            if (filtreChantier && filtreChantier.value) {
                filtrees = filtrees.filter(function (b) { return b.chantier_id == filtreChantier.value; });
            }
            if (filtreAnnee && filtreAnnee.value) {
                filtrees = filtrees.filter(function (b) { return b.annee == filtreAnnee.value; });
            }
            afficher(filtrees);
        }

        if (filtreStatut) filtreStatut.addEventListener('change', appliquerFiltres);
        if (filtreChantier) filtreChantier.addEventListener('change', appliquerFiltres);
        if (filtreAnnee) filtreAnnee.addEventListener('change', appliquerFiltres);
        
        afficher(donnees);
    }

    function initialiserFormulaire() {
        const form = document.getElementById('form-budget');
        const tbody = document.getElementById('lignes-budget');
        const total = document.getElementById('total-budget');
        const id = window.RESSOURCE && window.RESSOURCE.id;
        const isEdit = id !== undefined && id !== null;
        
        const annee = document.getElementById('annee');
        annee.value = new Date().getFullYear();
        chargerChantiers(document.getElementById('chantier_id'));

        function recalculer() {
            let somme = 0;
            tbody.querySelectorAll('input[name="montant_prevu"]').forEach(function (input) {
                somme += Number(input.value || 0);
            });
            const devise = document.getElementById('devise').value;
            total.textContent = 'Total prévu : ' + montant(somme, devise);
        }

        function ajouterLigne(rubrique='', prevu=0, engage=0, reel=0) {
            const tr = document.createElement('tr');
            tr.innerHTML =
                '<td><input type="text" class="champ-select" name="rubrique" maxlength="80" placeholder="Ex: Gros œuvre" value="' + Format.echapper(rubrique) + '"></td>' +
                '<td><input type="number" class="champ-select" name="montant_prevu" min="0" step="0.01" value="' + prevu + '"></td>' +
                '<td><input type="number" class="champ-select" name="montant_engage" min="0" step="0.01" value="' + engage + '"></td>' +
                '<td><input type="number" class="champ-select" name="montant_reel" min="0" step="0.01" value="' + reel + '"></td>' +
                '<td><button class="btn btn-rouge" type="button" title="Supprimer">×</button></td>';
            tr.querySelector('button').addEventListener('click', function () { tr.remove(); recalculer(); });
            tr.querySelectorAll('input').forEach(function (input) { input.addEventListener('input', recalculer); });
            tbody.appendChild(tr);
            recalculer();
        }

        document.getElementById('ajouter-ligne').addEventListener('click', function () { ajouterLigne(); });
        document.getElementById('devise').addEventListener('change', recalculer);
        
        // Charger les données existantes si modification
        if (isEdit) {
            chargerBudget(id);
        } else {
            ajouterLigne();
        }

        form.addEventListener('submit', async function (e) {
            e.preventDefault();
            if (!form.checkValidity()) { form.reportValidity(); return; }
            const lignes = [];
            tbody.querySelectorAll('tr').forEach(function (tr) {
                const rubrique = tr.querySelector('[name="rubrique"]').value.trim();
                if (!rubrique) { return; }
                lignes.push({
                    rubrique: rubrique,
                    montant_prevu: tr.querySelector('[name="montant_prevu"]').value || 0,
                    montant_engage: tr.querySelector('[name="montant_engage"]').value || 0,
                    montant_reel: tr.querySelector('[name="montant_reel"]').value || 0
                });
            });
            const corps = {
                chantier_id: form.chantier_id.value,
                annee: form.annee.value,
                budget_revision: form.budget_revision.value || 0,
                devise: form.devise.value,
                statut: form.statut.value,
                notes: form.notes.value || null,
                lignes: lignes
            };
            const url = isEdit ? '/api/v1/budgets/' + id : '/api/v1/budgets';
            const methode = isEdit ? 'PUT' : 'POST';
            const rep = await Auth.api(url, { method: methode, body: corps });
            if (!rep.ok) {
                const err = await rep.json().catch(function () { return {}; });
                alert(err.message || 'Erreur lors de l\'enregistrement');
                return;
            }
            const json = await rep.json();
            window.location.href = base + '/budgets/' + (json.donnees.id || id);
        });
    }

    async function chargerBudget(id) {
        const rep = await Auth.api('/api/v1/budgets/' + id);
        if (!rep.ok) return;
        const b = (await rep.json()).donnees;
        const form = document.getElementById('form-budget');
        const tbody = document.getElementById('lignes-budget');
        
        if (form && b) {
            form.chantier_id.value = b.chantier_id || '';
            form.annee.value = b.annee || '';
            form.budget_revision.value = b.budget_revision || 0;
            form.devise.value = b.devise || 'MGA';
            form.statut.value = b.statut || 'ouvert';
            form.notes.value = b.notes || '';
            
            tbody.innerHTML = '';
            (b.lignes || []).forEach(function (l) {
                ajouterLigne(l.rubrique, l.montant_prevu, l.montant_engage, l.montant_reel);
            });
        }
    }

    async function initialiserDetail() {
        const zone = document.getElementById('budget-detail');
        const id = window.RESSOURCE && window.RESSOURCE.id;
        const peutModifier = window.RESSOURCE && window.RESSOURCE.peutModifier;
        
        if (!id) { zone.textContent = 'Budget introuvable.'; return; }
        
        const rep = await Auth.api('/api/v1/budgets/' + id);
        if (!rep.ok) { zone.textContent = 'Budget introuvable.'; return; }
        const b = (await rep.json()).donnees;
        if (!b) { zone.textContent = 'Budget introuvable.'; return; }

        // Initialiser les onglets
        const onglets = document.querySelectorAll('.onglet');
        onglets.forEach(function (onglet) {
            onglet.addEventListener('click', function () {
                onglets.forEach(function (o) { o.classList.remove('actif'); });
                onglet.classList.add('actif');
                afficherOnglet(onglet.dataset.onglet, b);
            });
        });

        // Afficher le premier onglet
        afficherOnglet('general', b);

        // Bouton d'action
        const zoneActions = document.getElementById('actions-budget');
        if (!zoneActions || !peutModifier) { return; }
        
        const btnCloturer = document.createElement('button');
        btnCloturer.className = 'btn btn-primaire';
        btnCloturer.textContent = b.statut === 'ouvert' ? 'Clôturer le budget' : 'Réouvrir le budget';
        btnCloturer.onclick = async function () {
            if (!confirm(btnCloturer.textContent + ' ?')) { return; }
            const nouveau = b.statut === 'ouvert' ? 'cloture' : 'ouvert';
            const r = await Auth.api('/api/v1/budgets/' + b.id, { method: 'PUT', body: { statut: nouveau } });
            if (!r.ok) { alert('Erreur'); return; }
            location.reload();
        };
        zoneActions.appendChild(btnCloturer);
    }

    function afficherOnglet(onglet, budget) {
        const zone = document.getElementById('budget-detail');
        const lignes = budget.lignes || [];
        
        // Calculer les totaux
        let totalPrevu = 0, totalEngage = 0, totalReel = 0;
        lignes.forEach(function (l) {
            totalPrevu += Number(l.montant_prevu || 0);
            totalEngage += Number(l.montant_engage || 0);
            totalReel += Number(l.montant_reel || 0);
        });

        const prevu = Number(budget.budget_previsionnel || 0);
        const reel = Number(budget.total_reel || 0);
        const restant = prevu - reel;
        const pct = prevu > 0 ? (reel / prevu * 100) : 0;
        const couleur = pct >= 90 ? '#ef4444' : (pct >= 70 ? '#f97316' : '#22c55e');

        // Mettre à jour les KPI
        document.getElementById('kpi-prevu').textContent = montant(prevu, budget.devise);
        document.getElementById('kpi-engage').textContent = montant(totalEngage, budget.devise);
        document.getElementById('kpi-reel').textContent = montant(reel, budget.devise);
        document.getElementById('kpi-restant').textContent = montant(restant, budget.devise);

        if (onglet === 'general') {
            zone.innerHTML = '<div class="grille-info">' +
                '<div><span class="info-label">Chantier</span>' + Format.echapper(budget.chantier_nom || '-') + '</div>' +
                '<div><span class="info-label">Année</span>' + Format.echapper(budget.annee) + '</div>' +
                '<div><span class="info-label">Budget prévisionnel</span>' + Format.echapper(montant(prevu, budget.devise)) + '</div>' +
                '<div><span class="info-label">Budget révisé</span>' + Format.echapper(montant(budget.budget_revision, budget.devise)) + '</div>' +
                '<div><span class="info-label">Dépenses validées</span>' + Format.echapper(montant(budget.depenses_validees, budget.devise)) + '</div>' +
                '<div><span class="info-label">Statut</span>' + Format.echapper(STATUTS[budget.statut] || budget.statut) + '</div>' +
                '</div>' +
                '<div class="jauge-grande" style="margin-top:20px;">' +
                '<div class="jauge"><div class="jauge-remplie" style="width:' + Math.min(pct, 100) + '%;background:' + couleur + ';"></div></div>' +
                '<span class="jauge-valeur">' + pourcentage(pct) + ' consommé</span>' +
                '</div>' +
                (budget.notes ? '<h3 style="margin-top:20px;">Notes</h3><p>' + Format.echapper(budget.notes) + '</p>' : '');
        } else if (onglet === 'lignes') {
            zone.innerHTML = '<div class="table-wrapper"><table class="table"><thead><tr>' +
                '<th>Rubrique</th><th>Prévu</th><th>Engagé</th><th>Réel</th><th>Restant</th><th>% Utilisé</th></tr></thead><tbody>' +
                (lignes.length ? lignes.map(function (l) {
                    const lPrevu = Number(l.montant_prevu || 0);
                    const lReel = Number(l.montant_reel || 0);
                    const lRestant = lPrevu - lReel;
                    const lPct = lPrevu > 0 ? (lReel / lPrevu * 100) : 0;
                    const lCouleur = lPct >= 90 ? '#ef4444' : (lPct >= 70 ? '#f97316' : '#22c55e');
                    return '<tr><td>' + Format.echapper(l.rubrique) + '</td>' +
                        '<td>' + Format.echapper(montant(lPrevu, budget.devise)) + '</td>' +
                        '<td>' + Format.echapper(montant(l.montant_engage, budget.devise)) + '</td>' +
                        '<td>' + Format.echapper(montant(lReel, budget.devise)) + '</td>' +
                        '<td>' + Format.echapper(montant(lRestant, budget.devise)) + '</td>' +
                        '<td><span style="color:' + lCouleur + ';font-weight:600;">' + pourcentage(lPct) + '</span></td></tr>';
                }).join('') : '<tr><td colspan="6" class="vide">Aucune ligne</td></tr>') +
                '</tbody><tfoot><tr><th>Total</th><th>' + Format.echapper(montant(totalPrevu, budget.devise)) + '</th>' +
                '<th>' + Format.echapper(montant(totalEngage, budget.devise)) + '</th>' +
                '<th>' + Format.echapper(montant(totalReel, budget.devise)) + '</th>' +
                '<th>' + Format.echapper(montant(totalPrevu - totalReel, budget.devise)) + '</th>' +
                '<th>' + pourcentage(totalPrevu > 0 ? (totalReel / totalPrevu * 100) : 0) + '</th></tr></tfoot></table></div>';
        } else if (onglet === 'depenses') {
            zone.innerHTML = '<div class="table-wrapper"><table class="table"><thead><tr>' +
                '<th>Date</th><th>Description</th><th>Montant</th><th>Statut</th></tr></thead><tbody>' +
                '<tr><td colspan="4" class="vide">Aucune dépense rattachée pour le moment</td></tr>' +
                '</tbody></table></div>' +
                '<p class="sous-titre" style="margin-top:16px;">Les dépenses sont gérées depuis le module Dépenses.</p>';
        } else if (onglet === 'devis') {
            zone.innerHTML = '<div class="table-wrapper"><table class="table"><thead><tr>' +
                '<th>N° Devis</th><th>Client</th><th>Montant TTC</th><th>Statut</th></tr></thead><tbody>' +
                '<tr><td colspan="4" class="vide">Aucun devis rattaché pour le moment</td></tr>' +
                '</tbody></table></div>' +
                '<p class="sous-titre" style="margin-top:16px;">Les devis sont gérés depuis le module Facturation.</p>';
        }
    }
})();
