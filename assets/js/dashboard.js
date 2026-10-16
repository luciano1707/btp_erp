/* Tableau de bord : KPIs financiers, suivi budgetaire par chantier, alertes. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    let canViewFinances = false;

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }

        // Accueil personnalise + date du jour
        const repMe = await Auth.api('/api/v1/auth/me');
        if (repMe.ok) {
            const u = (await repMe.json()).donnees;
            canViewFinances = u.role === 'directeur' || u.role === 'comptable';
            document.querySelectorAll('[data-financial]').forEach(function (el) {
                el.hidden = !canViewFinances;
            });
            const h = new Date().getHours();
            const salut = h < 12 ? 'Bonjour' : (h < 18 ? 'Bon apres-midi' : 'Bonsoir');
            const prenom = u.prenom || u.nom || '';
            document.getElementById('tdb-greeting').textContent = salut + (prenom ? ', ' + prenom : '') + ' 👋';
            document.getElementById('tdb-date').textContent = new Date().toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });
            if (u.doit_changer_mdp) { document.getElementById('banniere-mdp').hidden = false; }
        }

        chargerKpis();
        if (canViewFinances) {
            chargerGraphique();
            chargerDonut();
        }
        chargerPlanning();
        chargerAlertes();
    });

    async function chargerGraphique() {
        const zone = document.getElementById('graphique-mensuel');
        const rep = await Auth.api('/api/v1/stats/mensuel');
        if (!rep.ok) { zone.innerHTML = '<p class="chargement">Erreur.</p>'; return; }
        const mois = (await rep.json()).donnees || [];
        Charts.aire(zone, {
            labels: mois.map(function (m) { return m.libelle; }),
            format: function (v) { return Format.ariary(v); },
            series: [
                { nom: 'Facture', couleur: '#2c6ea4', valeurs: mois.map(function (m) { return Number(m.facture); }) },
                { nom: 'Encaisse', couleur: '#2f9e6f', valeurs: mois.map(function (m) { return Number(m.encaisse); }) }
            ]
        });
    }

    async function chargerDonut() {
        const zone = document.getElementById('donut-ca');
        const rep = await Auth.api('/api/v1/stats/chantiers');
        if (!rep.ok) { zone.innerHTML = '<p class="chargement">Erreur.</p>'; return; }
        const lignes = (await rep.json()).donnees || [];
        const segments = lignes
            .filter(function (c) { return Number(c.facture) > 0; })
            .sort(function (a, b) { return Number(b.facture) - Number(a.facture); })
            .map(function (c, i) { return { nom: c.nom, valeur: Number(c.facture), couleur: Charts.couleur(i) }; });

        if (!segments.length) {
            zone.innerHTML = '<p class="sous-titre">Aucune facture pour le moment.</p>';
            return;
        }
        Charts.donut(zone, { segments: segments, format: function (v) { return Format.ariary(v); }, sousLibelle: 'CA total' });
    }

    async function chargerKpis() {
        const rep = await Auth.api('/api/v1/stats/tableau-de-bord');
        if (!rep.ok) { return; }
        const s = (await rep.json()).donnees;

        texte('kpi-chantiers', s.chantiers_actifs + ' / ' + s.chantiers_total);
        texte('kpi-chantiers-note', s.chantiers_total + ' chantier(s) au total');
        if (canViewFinances) {
            texte('kpi-ca', Format.ariary(s.ca_facture));
            texte('kpi-encaisse', Format.ariary(s.encaisse));
            const tauxEnc = s.ca_facture > 0 ? Math.round(s.encaisse / s.ca_facture * 100) : 0;
            texte('kpi-encaisse-note', tauxEnc + ' % du facture');
            texte('kpi-marge', Format.ariary(s.marge_brute));
            const noteMarge = document.getElementById('kpi-marge-note');
            noteMarge.textContent = s.marge_brute >= 0 ? 'CA facture - couts engages' : 'couts superieurs au facture';
            noteMarge.className = 'kpi-note ' + (s.marge_brute >= 0 ? 'positif' : 'negatif');

            texte('kpi-reste', Format.ariary(s.reste_a_encaisser));
            texte('kpi-cout', Format.ariary(s.cout_total));
            texte('kpi-impayees', s.factures_impayees);
        }
        texte('kpi-stock', s.alertes_stock);
    }

    async function chargerPlanning() {
        const rep = await Auth.api('/api/v1/stats/chantiers');
        const zone = document.getElementById('planning-chantiers');
        if (!rep.ok) { zone.innerHTML = '<p class="chargement">Erreur.</p>'; return; }
        const lignes = (await rep.json()).donnees || [];
        if (!lignes.length) { zone.innerHTML = '<p class="sous-titre">Aucun chantier.</p>'; return; }

        zone.innerHTML = lignes.slice(0, 8).map(function (c) {
            const pct = Math.max(0, Math.min(100, Number(c.avancement) || 0));
            let couleur = 'pr-bleu';
            if (pct >= 80) { couleur = 'pr-vert'; }
            else if (pct < 30) { couleur = 'pr-ambre'; }
            return '<div class="planning-ligne">' +
                '<a class="planning-nom lien" href="' + base + '/chantiers/' + c.id + '" title="' + Format.echapper(c.nom) + '">' + Format.echapper(c.nom) + '</a>' +
                '<div class="planning-barre"><div class="planning-remplie ' + couleur + '" style="width:' + Math.max(pct, 8) + '%">' + pct + '%</div></div>' +
                '</div>';
        }).join('');
    }

    async function chargerAlertes() {
        const zone = document.getElementById('liste-alertes');
        const alertes = [];

        const repStats = await Auth.api('/api/v1/stats/tableau-de-bord');
        if (repStats.ok) {
            const s = (await repStats.json()).donnees;
            if (s.factures_impayees > 0) {
                alertes.push(['ambre', s.factures_impayees + ' facture(s) impayee(s)', 'A relancer aupres des clients.']);
            }
            if (s.devis_en_attente > 0) {
                alertes.push(['ambre', s.devis_en_attente + ' devis en attente', 'Brouillons ou devis envoyes non traites.']);
            }
            if (s.marge_brute < 0) {
                alertes.push(['rouge', 'Marge brute negative', 'Les couts engages depassent le CA facture.']);
            }
        }

        const repStock = await Auth.api('/api/v1/stock');
        if (repStock.ok) {
            const stock = (await repStock.json()).donnees || [];
            stock.filter(function (m) { return m.sous_seuil; }).slice(0, 4).forEach(function (m) {
                alertes.push(['rouge', 'Stock bas - ' + m.designation, 'Reste ' + Number(m.stock) + ' ' + m.unite + ' (seuil : ' + m.seuil_alerte + ').']);
            });
        }

        if (!alertes.length) {
            zone.innerHTML = '<p class="sous-titre">Aucune alerte. Tout est en ordre.</p>';
            return;
        }
        zone.innerHTML = alertes.map(function (a) {
            return '<div class="alerte"><span class="alerte-point ' + a[0] + '"></span>' +
                '<div><div class="alerte-titre">' + Format.echapper(a[1]) + '</div>' +
                '<div class="alerte-detail">' + Format.echapper(a[2]) + '</div></div></div>';
        }).join('');
    }

    function texte(id, valeur) {
        const el = document.getElementById(id);
        if (el) { el.textContent = valeur; }
    }
})();
