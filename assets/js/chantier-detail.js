/* Detail chantier : informations, avancement, gestion des lots (CRUD imbrique). */
(function () {
    'use strict';

    const base = window.APP_BASE || '';
    const id = window.RESSOURCE && window.RESSOURCE.id;
    const peutGererLots = Boolean(window.RESSOURCE && window.RESSOURCE.peutGererLots);
    const peutVoirFinances = Boolean(window.RESSOURCE && window.RESSOURCE.peutVoirFinances);

    const TYPES = { batiment: 'Batiment', route: 'Route / TP', autre: 'Autre' };
    const STATUTS = { planifie: 'Planifie', en_cours: 'En cours', suspendu: 'Suspendu', termine: 'Termine', annule: 'Annule' };
    const STATUTS_LOT = { a_faire: 'A faire', en_cours: 'En cours', termine: 'Termine' };

    const form = document.getElementById('form-lot');
    const boiteErreurLot = document.getElementById('lot-erreur');

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        const lienModifier = document.getElementById('lien-modifier');
        if (lienModifier) { lienModifier.href = base + '/chantiers/' + id + '/modifier'; }
        document.getElementById('lien-pointage').href = base + '/chantiers/' + id + '/pointage';
        await charger();

        if (peutGererLots) {
            document.getElementById('btn-ajouter-lot').addEventListener('click', ouvrirAjout);
            document.getElementById('btn-annuler-lot').addEventListener('click', fermerForm);
            form.addEventListener('submit', enregistrerLot);
        }
        const boutonSupprimer = document.getElementById('btn-supprimer-chantier');
        if (boutonSupprimer) {
            boutonSupprimer.addEventListener('click', supprimerChantier);
        }
    });

    async function charger() {
        const rep = await Auth.api('/api/v1/chantiers/' + id);
        if (!rep.ok) { document.getElementById('titre-chantier').textContent = 'Chantier introuvable'; return; }
        const c = (await rep.json()).donnees;
        rendre(c);
    }

    function rendre(c) {
        document.getElementById('zone-chantier').hidden = false;
        document.getElementById('titre-chantier').textContent = c.nom;
        document.getElementById('sous-titre-chantier').textContent =
            (c.code ? c.code + ' · ' : '') + (TYPES[c.type] || c.type) + ' · ' + (STATUTS[c.statut] || c.statut);

        const infos = [
            ['Client', c.client_nom || '—'],
            ['Responsable', c.responsable_nom || '—'],
            ['Localisation', c.localisation || '—'],
            ['Debut', Format.date(c.date_debut)],
            ['Fin prevue', Format.date(c.date_fin_prevue)],
            ['Description', c.description || '—']
        ];
        document.getElementById('infos-chantier').innerHTML = infos.map(function (i) {
            return '<dt>' + i[0] + '</dt><dd>' + Format.echapper(i[1]) + '</dd>';
        }).join('');

        const av = c.stats.avancement_global;
        document.getElementById('jauge-globale').style.width = av + '%';
        document.getElementById('avancement-valeur').textContent = av + ' %';
        document.getElementById('stat-nb-lots').textContent = c.stats.nb_lots;
        if (peutVoirFinances) {
            document.getElementById('stat-budget-prev').textContent = Format.ariary(c.budget_previsionnel);
            document.getElementById('stat-budget-lots').textContent = Format.ariary(c.stats.budget_lots);
        document.getElementById('stat-cout-mo').textContent = Format.ariary(c.stats.cout_main_oeuvre);
        document.getElementById('stat-cout-mat').textContent = Format.ariary(c.stats.cout_materiaux);
        document.getElementById('stat-cout-total').textContent = Format.ariary(c.stats.cout_total);
        document.getElementById('stat-reste').textContent = c.stats.reste_budget === null ? '—' : Format.ariary(c.stats.reste_budget);
        }

        // Donut repartition des couts
        if (peutVoirFinances) {
            const zoneDonut = document.getElementById('donut-couts');
            const segs = [
                { nom: "Main d'oeuvre", valeur: Number(c.stats.cout_main_oeuvre || 0), couleur: '#2c6ea4' },
                { nom: 'Materiaux', valeur: Number(c.stats.cout_materiaux || 0), couleur: '#d99a2b' }
            ];
            if (segs.some(function (s) { return s.valeur > 0; })) {
                Charts.donut(zoneDonut, { segments: segs, format: function (v) { return Format.ariary(v); }, sousLibelle: 'Total engage' });
            } else {
                zoneDonut.innerHTML = '<p class="sous-titre">Aucun cout engage pour le moment.</p>';
            }
        }

        rendreLots(c.lots || []);
    }

    function rendreLots(lots) {
        const corps = document.getElementById('corps-lots');
        if (lots.length === 0) {
            corps.innerHTML = '<tr><td class="vide" colspan="' + (3 + Number(peutGererLots) + Number(peutVoirFinances)) + '">' +
                (peutGererLots ? 'Aucun lot. Ajoutez le premier lot du chantier.' : 'Aucun lot.') + '</td></tr>';
            return;
        }
        corps.innerHTML = lots.map(function (l) {
            return '<tr>' +
                '<td>' + Format.echapper(l.nom) + '</td>' +
                (peutVoirFinances ? '<td>' + Format.ariary(l.budget_previsionnel) + '</td>' : '') +
                '<td><div class="jauge jauge-mini"><div class="jauge-remplie" style="width:' + Number(l.avancement) + '%"></div></div>' +
                    '<span class="jauge-mini-valeur">' + Number(l.avancement) + ' %</span></td>' +
                '<td><span class="badge-valeur">' + (STATUTS_LOT[l.statut] || l.statut) + '</span></td>' +
                (peutGererLots ? '<td class="col-actions">' +
                    '<button class="lien-action" data-edit=\'' + JSON.stringify(l) + '\'>Modifier</button>' +
                    '<button class="lien-action lien-danger" data-suppr="' + l.id + '">Supprimer</button>' +
                '</td>' : '') + '</tr>';
        }).join('');

        if (!peutGererLots) { return; }

        corps.querySelectorAll('button[data-edit]').forEach(function (b) {
            b.addEventListener('click', function () { ouvrirEdition(JSON.parse(b.dataset.edit)); });
        });
        corps.querySelectorAll('button[data-suppr]').forEach(function (b) {
            b.addEventListener('click', function () { supprimerLot(b.dataset.suppr); });
        });
    }

    function ouvrirAjout() {
        remplirForm({ id: '', nom: '', budget_previsionnel: '', avancement: 0, statut: 'a_faire' });
        form.hidden = false;
        document.getElementById('lot-nom').focus();
    }

    function ouvrirEdition(lot) {
        remplirForm(lot);
        form.hidden = false;
        document.getElementById('lot-nom').focus();
    }

    function remplirForm(lot) {
        boiteErreurLot.hidden = true;
        document.getElementById('lot-id').value = lot.id || '';
        document.getElementById('lot-nom').value = lot.nom || '';
        document.getElementById('lot-budget').value = (lot.budget_previsionnel === null || lot.budget_previsionnel === undefined) ? '' : lot.budget_previsionnel;
        document.getElementById('lot-avancement').value = lot.avancement || 0;
        document.getElementById('lot-statut').value = lot.statut || 'a_faire';
    }

    function fermerForm() { form.hidden = true; }

    async function enregistrerLot(evenement) {
        evenement.preventDefault();
        boiteErreurLot.hidden = true;

        const lotId = document.getElementById('lot-id').value;
        const charge = {
            nom: document.getElementById('lot-nom').value,
            budget_previsionnel: document.getElementById('lot-budget').value,
            avancement: document.getElementById('lot-avancement').value,
            statut: document.getElementById('lot-statut').value
        };

        const url = lotId ? '/api/v1/lots/' + lotId : '/api/v1/chantiers/' + id + '/lots';
        const methode = lotId ? 'PUT' : 'POST';
        const rep = await Auth.api(url, { method: methode, body: charge });
        const json = await rep.json().catch(function () { return {}; });

        if (rep.ok && json.succes) {
            fermerForm();
            await charger();
            return;
        }
        let messages = [json.message || 'Erreur.'];
        if (json.erreurs) {
            messages = [];
            Object.keys(json.erreurs).forEach(function (k) {
                (Array.isArray(json.erreurs[k]) ? json.erreurs[k] : [json.erreurs[k]]).forEach(function (m) { messages.push(m); });
            });
        }
        boiteErreurLot.innerHTML = messages.map(Format.echapper).join('<br>');
        boiteErreurLot.hidden = false;
    }

    async function supprimerLot(lotId) {
        if (!window.confirm('Supprimer ce lot ?')) { return; }
        const rep = await Auth.api('/api/v1/lots/' + lotId, { method: 'DELETE' });
        if (rep.ok) { await charger(); }
        else { alert('Suppression impossible.'); }
    }

    async function supprimerChantier() {
        if (!window.confirm('Supprimer définitivement ce chantier ?')) { return; }
        const rep = await Auth.api('/api/v1/chantiers/' + id, { method: 'DELETE' });
        if (rep.ok) {
            window.location.href = base + '/chantiers';
        } else {
            const json = await rep.json().catch(function () { return {}; });
            alert(json.message || 'Suppression impossible.');
        }
    }
})();
