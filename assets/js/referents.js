/* =========================================================
   Sommaire des referentiels : compteurs en direct via l'API.
   Chaque carte porte data-endpoint (ex: api/v1/employes).
   Un appel ?limite=1 retourne {donnees:{total,n}} -> on affiche total.
   ========================================================= */

(function () {
    'use strict';

    const base = window.APP_BASE || '';

    document.addEventListener('DOMContentLoaded', async function () {
        const ok = await Auth.rafraichir();
        if (!ok) { window.location.href = base + '/connexion'; return; }

        const cartes = document.querySelectorAll('.carte-referentiel');
        if (!cartes.length) {
            basculerVide(true);
            return;
        }

        const resultats = await Promise.all(
            Array.from(cartes).map(function (carte) {
                return compter(carte.dataset.endpoint);
            })
        );

        // Recherche par endpoint pour retrouver le panneau (liste/vue) associe.
        const panneaux = document.querySelector('[data-compteur]');
        let total = 0;
        resultats.forEach(function (n) { total += n; });

        // Aucune donnee du tout -> etat vide global.
        basculerVide(total === 0);
    });

    async function compter(endpoint) {
        const element = document.querySelector('[data-compteur]');
        if (!endpoint) { return 0; }

        try {
            const reponse = await Auth.api('/' + endpoint + '?limite=1');
            if (!reponse.ok) { return 0; }
            const json = await reponse.json();
            const n = Number(json.donnees ? json.donnees.total : 0);

            // Renseigne TOUS les compteurs de la grille (chacun son endpoint).
            document.querySelectorAll('.carte-referentiel').forEach(function (carte) {
                if (carte.dataset.endpoint === endpoint) {
                    const cible = carte.querySelector('.cr-total');
                    if (cible) {
                        cible.textContent = n;
                        cible.classList.remove('squelette');
                    }
                }
            });

            return n;
        } catch (erreur) {
            return 0;
        }
    }

    function basculerVide(vide) {
        const zone = document.getElementById('referentiels-vide');
        const grille = document.getElementById('grille-referentiels');
        if (zone) { zone.hidden = !vide; }
        if (grille) { grille.hidden = vide; }
    }
})();
