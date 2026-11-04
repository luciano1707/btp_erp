/* Shell applicatif : lien de nav actif, identite dans la topbar, deconnexion. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const ROLES = { directeur: 'Directeur', chef_chantier: 'Chef de chantier', comptable: 'Comptable', magasinier: 'Magasinier' };
    const MODULES = {
        tableau_de_bord: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        chantiers: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        finances: ['directeur', 'chef_chantier', 'comptable'],
        achats: ['directeur', 'chef_chantier', 'magasinier'],
        stock: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        devis: ['directeur', 'chef_chantier', 'comptable'],
        factures: ['directeur', 'chef_chantier', 'comptable'],
        referentiels: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        demandes_materiel: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        rapports_journaliers: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        pointages: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        fournisseurs: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        depenses: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        budgets: ['directeur', 'chef_chantier', 'comptable'],
        rfi: ['directeur', 'chef_chantier', 'comptable'],
        qualite: ['directeur', 'chef_chantier', 'comptable'],
        securite: ['directeur', 'chef_chantier', 'comptable'],
        incidents: ['directeur', 'chef_chantier', 'comptable'],
        documents: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        photos: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        notifications: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        journal: ['directeur'],
        profil: ['directeur', 'chef_chantier', 'comptable', 'magasinier'],
        parametres: ['directeur']
    };

    document.addEventListener('DOMContentLoaded', function () {
        marquerActif();
        remplirUtilisateur();
        chargerCloche();
        initialiserMenu();
        const btn = document.getElementById('btn-deconnexion-shell');
        if (btn) {
            btn.addEventListener('click', async function () {
                if (window.Auth) { await Auth.logout(); }
                window.location.href = base + '/connexion';
            });
        }
    });

    function initialiserMenu() {
        const corps = document.body;
        const bouton = document.getElementById('btn-menu');
        const fermerBouton = document.getElementById('btn-menu-fermer');
        const sidebar = document.getElementById('sidebar');
        if (!bouton || !sidebar) { return; }

        function estOuvert() {
            return corps.classList.contains('nav-ouverte');
        }

        function appliquer(ouvert) {
            corps.classList.toggle('nav-ouverte', ouvert);
            bouton.setAttribute('aria-expanded', ouvert ? 'true' : 'false');
            bouton.setAttribute('aria-label', ouvert ? 'Fermer le menu' : 'Ouvrir le menu');
        }

        function fermer() {
            if (estOuvert()) { appliquer(false); }
        }

        bouton.addEventListener('click', function (evenement) {
            evenement.stopPropagation();
            appliquer(!estOuvert());
        });

        if (fermerBouton) {
            fermerBouton.addEventListener('click', fermer);
        }

        document.addEventListener('click', function (evenement) {
            if (!estOuvert()) { return; }
            if (sidebar.contains(evenement.target) || bouton.contains(evenement.target)) { return; }
            fermer();
        });

        document.addEventListener('keydown', function (evenement) {
            if (evenement.key === 'Escape') { fermer(); }
        });

        sidebar.querySelectorAll('a').forEach(function (lien) {
            lien.addEventListener('click', fermer);
        });

        window.addEventListener('resize', function () {
            if (window.innerWidth > 900) { fermer(); }
        });
    }

    async function chargerCloche() {
        if (!window.Auth) { return; }
        if (!await Auth.rafraichir()) { return; }
        const cloche = document.getElementById('cloche');
        const panneau = document.getElementById('cloche-panneau');
        if (!cloche || !panneau) { return; }

        // Charger les vraies notifications
        const repNotif = await Auth.api('/api/v1/notifications');
        const dataNotif = repNotif.ok ? (await repNotif.json()).donnees : { elements: [], non_lues: 0 };
        const notifications = dataNotif.elements || [];
        const nonLues = dataNotif.non_lues || 0;

        // Charger les alertes du tableau de bord pour les utilisateurs qui n'ont pas de notifications système
        const repStats = await Auth.api('/api/v1/stats/tableau-de-bord');
        const stats = repStats.ok ? (await repStats.json()).donnees : {};

        const items = [];
        notifications.forEach(function (n) {
            items.push({
                titre: n.titre || 'Notification',
                message: n.message || '',
                date: n.cree_le || '',
                lien: n.lien || null,
                id: n.id
            });
        });

        // Ajouter les alertes système si pas de notifications dédiées
        if (stats.factures_impayees > 0) {
            items.push({
                titre: 'Factures impayées',
                message: stats.factures_impayees + ' à relancer',
                date: new Date().toISOString().slice(0, 10),
                lien: '/factures',
                id: null
            });
        }
        if (stats.devis_en_attente > 0) {
            items.push({
                titre: 'Devis en attente',
                message: stats.devis_en_attente + ' à traiter',
                date: new Date().toISOString().slice(0, 10),
                lien: '/devis',
                id: null
            });
        }
        if (stats.alertes_stock > 0) {
            items.push({
                titre: 'Alertes stock',
                message: stats.alertes_stock + ' matériau(x) sous le seuil',
                date: new Date().toISOString().slice(0, 10),
                lien: '/stock',
                id: null
            });
        }
        if (stats.reste_a_encaisser > 0) {
            items.push({
                titre: 'Reste à encaisser',
                message: 'Voir la trésorerie',
                date: new Date().toISOString().slice(0, 10),
                lien: '/finances',
                id: null
            });
        }

        const total = nonLues + items.length - notifications.length;
        const badge = document.getElementById('badge-cloche');
        if (total > 0) { badge.textContent = total; badge.hidden = false; }
        else { badge.hidden = true; }

        panneau.innerHTML = '<div class="cloche-tete">Notifications</div>' + (items.length > 0
            ? items.map(function (i) {
                const onClick = i.id ? 'data-notif-id="' + i.id + '"' : 'data-lien="' + i.lien + '"';
                return '<a class="cloche-item" href="#" ' + onClick + '>' +
                    '<span class="cloche-item-titre">' + Format.echapper(i.titre) + '</span>' +
                    '<span class="cloche-item-detail">' + Format.echapper(i.message) + '</span>' +
                    '<span class="cloche-item-date">' + Format.echapper(i.date) + '</span></a>';
            }).join('') + '<div class="cloche-pied"><button class="btn btn-link" id="btn-tout-lire">Tout marquer comme lu</button></div>'
            : '<div class="cloche-vide">Aucune notification.</div>');

        cloche.addEventListener('click', function (e) {
            e.stopPropagation();
            panneau.hidden = !panneau.hidden;
        });
        document.addEventListener('click', function () { panneau.hidden = true; });
        panneau.addEventListener('click', function (e) { e.stopPropagation(); });

        const btnToutLire = document.getElementById('btn-tout-lire');
        if (btnToutLire) {
            btnToutLire.addEventListener('click', async function (e) {
                e.preventDefault();
                const rep = await Auth.api('/api/v1/notifications/tout-lire', { method: 'POST' });
                if (rep.ok) {
                    chargerCloche();
                }
            });
        }

        panneau.querySelectorAll('.cloche-item').forEach(function (item) {
            item.addEventListener('click', async function (e) {
                e.preventDefault();
                const notifId = item.dataset.notifId;
                const lien = item.dataset.lien;
                if (notifId) {
                    await Auth.api('/api/v1/notifications/' + notifId + '/lue', { method: 'POST' });
                    chargerCloche();
                } else if (lien) {
                    window.location.href = base + (lien === '/validation' ? '/notifications' : lien);
                }
            });
        });
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
