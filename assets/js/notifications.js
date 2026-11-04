/* Notifications : liste et lecture */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    let notifications = [];
    let alertesSysteme = [];

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        await charger();
        document.getElementById('filtre-non-lues').addEventListener('change', afficher);
        document.getElementById('btn-tout-lire').addEventListener('click', toutLire);
    });

    function dateHeure(valeur) {
        if (!valeur) { return '';
        }
        const texte = String(valeur).replace('T', ' ');
        return texte.substring(0, 16);
    }

    async function charger() {
        const zone = document.getElementById('liste-notifications');
        
        // Charger les vraies notifications
        const repNotif = await Auth.api('/api/v1/notifications?limite=200');
        if (!repNotif.ok) { zone.innerHTML = '<div class="vide">Erreur de chargement</div>'; return; }
        const donneesNotif = (await repNotif.json()).donnees || {};
        notifications = donneesNotif.elements || [];

        // Charger les alertes système
        const repStats = await Auth.api('/api/v1/stats/tableau-de-bord');
        const stats = repStats.ok ? (await repStats.json()).donnees : {};
        alertesSysteme = [];
        
        if (stats.factures_impayees > 0) {
            alertesSysteme.push({
                id: null,
                titre: 'Factures impayées',
                message: stats.factures_impayees + ' à relancer',
                cree_le: new Date().toISOString().slice(0, 19).replace('T', ' '),
                lien: '/factures',
                lu: 0,
                est_alerte: true
            });
        }
        if (stats.devis_en_attente > 0) {
            alertesSysteme.push({
                id: null,
                titre: 'Devis en attente',
                message: stats.devis_en_attente + ' à traiter',
                cree_le: new Date().toISOString().slice(0, 19).replace('T', ' '),
                lien: '/devis',
                lu: 0,
                est_alerte: true
            });
        }
        if (stats.alertes_stock > 0) {
            alertesSysteme.push({
                id: null,
                titre: 'Alertes stock',
                message: stats.alertes_stock + ' matériau(x) sous le seuil',
                cree_le: new Date().toISOString().slice(0, 19).replace('T', ' '),
                lien: '/stock',
                lu: 0,
                est_alerte: true
            });
        }
        if (stats.reste_a_encaisser > 0) {
            alertesSysteme.push({
                id: null,
                titre: 'Reste à encaisser',
                message: 'Voir la trésorerie',
                cree_le: new Date().toISOString().slice(0, 19).replace('T', ' '),
                lien: '/finances',
                lu: 0,
                est_alerte: true
            });
        }

        afficher();
    }

    function afficher() {
        const zone = document.getElementById('liste-notifications');
        const nonLuesSeulement = document.getElementById('filtre-non-lues').checked;
        
        // Combiner notifications et alertes système
        const toutes = [...notifications, ...alertesSysteme];
        
        const lignes = toutes.filter(function (n) {
            return !nonLuesSeulement || Number(n.lu) === 0;
        });

        if (!lignes.length) {
            zone.innerHTML = '<div class="vide">Aucune notification</div>';
            return;
        }

        zone.innerHTML = lignes.map(function (n) {
            const nonLue = Number(n.lu) === 0;
            const cible = n.lien === '/validation' ? '/notifications' : n.lien;
            const lien = cible ? base + cible : '';
            const badgeAlerte = n.est_alerte ? '<span class="notif-badge">Alerte système</span>' : '';
            return '<a class="notif-item' + (nonLue ? ' non-lue' : '') + '" href="' + (lien || '#') + '"' +
                ' data-id="' + (n.id || '') + '"' + (lien ? '' : ' data-sans-lien="1"') + '>' +
                '<span class="notif-point"></span>' +
                '<span class="notif-contenu">' +
                '<span class="notif-titre">' + Format.echapper(n.titre) + '</span>' +
                badgeAlerte +
                '<span class="notif-message">' + Format.echapper(n.message) + '</span>' +
                '<span class="notif-date">' + Format.echapper(dateHeure(n.cree_le)) + '</span>' +
                '</span></a>';
        }).join('');

        zone.querySelectorAll('.notif-item').forEach(function (a) {
            a.addEventListener('click', async function (e) {
                e.preventDefault();
                const id = a.dataset.id;
                const lien = a.getAttribute('href');
                
                // Marquer comme lu si c'est une vraie notification non lue
                if (id && a.classList.contains('non-lue')) {
                    await Auth.api('/api/v1/notifications/' + id + '/lue', { method: 'POST' });
                }
                
                // Naviguer vers le lien ou recharger
                if (lien && lien !== '#') {
                    window.location.href = lien;
                } else {
                    await charger();
                }
            });
        });
    }

    async function toutLire() {
        const rep = await Auth.api('/api/v1/notifications/tout-lire', { method: 'POST' });
        if (!rep.ok) { alert('Erreur'); return; }
        await charger();
    }
})();
