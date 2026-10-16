/* Shell applicatif : lien de nav actif, identite dans la topbar, deconnexion. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const ROLES = { directeur: 'Directeur', chef_chantier: 'Chef de chantier', comptable: 'Comptable', magasinier: 'Magasinier' };
    const MODULES = {
        tableau_de_bord: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        chantiers: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        finances: ['directeur', 'comptable'],
        achats: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        stock: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        devis: ['directeur', 'chef_chantier', 'comptable'],
        factures: ['directeur', 'comptable'],
        referentiels: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        journal: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        profil: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        parametres: ['directeur']
    };

    document.addEventListener('DOMContentLoaded', function () {
        marquerActif();
        remplirUtilisateur();
        chargerCloche();
        const btn = document.getElementById('btn-deconnexion-shell');
        if (btn) {
            btn.addEventListener('click', async function () {
                if (window.Auth) { await Auth.logout(); }
                window.location.href = base + '/connexion';
            });
        }
    });

    async function chargerCloche() {
        if (!window.Auth) { return; }
        if (!await Auth.rafraichir()) { return; }
        const cloche = document.getElementById('cloche');
        const panneau = document.getElementById('cloche-panneau');
        if (!cloche || !panneau) { return; }

        const rep = await Auth.api('/api/v1/stats/tableau-de-bord');
        if (!rep.ok) { return; }
        const s = (await rep.json()).donnees;

        const items = [];
        if (s.factures_impayees > 0) { items.push(['Factures impayees', s.factures_impayees + ' a relancer', '/factures']); }
        if (s.devis_en_attente > 0) { items.push(['Devis en attente', s.devis_en_attente + ' a traiter', '/devis']); }
        if (s.alertes_stock > 0) { items.push(['Alertes stock', s.alertes_stock + ' materiau(x) sous le seuil', '/stock']); }
        if (s.reste_a_encaisser > 0) { items.push(['Reste a encaisser', 'Voir la tresorerie', '/finances']); }

        const total = items.length;
        const badge = document.getElementById('badge-cloche');
        if (total > 0) { badge.textContent = total; badge.hidden = false; }

        panneau.innerHTML = '<div class="cloche-tete">Notifications</div>' + (total
            ? items.map(function (i) {
                return '<a class="cloche-item" href="' + base + i[2] + '">' +
                    '<span class="cloche-item-titre">' + i[0] + '</span>' +
                    '<span class="cloche-item-detail">' + i[1] + '</span></a>';
            }).join('')
            : '<div class="cloche-vide">Aucune notification.</div>');

        cloche.addEventListener('click', function (e) {
            e.stopPropagation();
            panneau.hidden = !panneau.hidden;
        });
        document.addEventListener('click', function () { panneau.hidden = true; });
        panneau.addEventListener('click', function (e) { e.stopPropagation(); });
    }

    function marquerActif() {
        const chemin = window.location.pathname;
        let meilleur = null;
        let longueur = -1;
        document.querySelectorAll('.nav-item').forEach(function (a) {
            const cible = base + a.dataset.chemin;
            if ((chemin === cible || chemin.indexOf(cible + '/') === 0) && a.dataset.chemin.length > longueur) {
                meilleur = a;
                longueur = a.dataset.chemin.length;
            }
        });
        if (meilleur) { meilleur.classList.add('actif'); }
    }

    async function remplirUtilisateur() {
        if (!window.Auth) { return; }
        const ok = await Auth.rafraichir();
        if (!ok) { return; }
        const rep = await Auth.api('/api/v1/auth/me');
        if (!rep.ok) { return; }
        const u = (await rep.json()).donnees;
        filtrerNavigation(u.role);
        const nom = document.getElementById('topbar-user-nom');
        const role = document.getElementById('topbar-user-role');
        if (nom) { nom.textContent = (u.prenom ? u.prenom + ' ' : '') + u.nom; }
        if (role) { role.textContent = ROLES[u.role] || u.role; }
    }

    function filtrerNavigation(role) {
        document.querySelectorAll('.nav-item').forEach(function (item) {
            const roles = MODULES[item.dataset.module] || [];
            item.hidden = role !== 'directeur' && roles.indexOf(role) === -1;
        });
    }
})();
