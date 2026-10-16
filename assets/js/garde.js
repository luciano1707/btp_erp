/* Garde d'authentification : redirige vers /connexion si aucune session valide. */
(function () {
    'use strict';
    document.addEventListener('DOMContentLoaded', async function () {
        const ok = await Auth.rafraichir();
        if (!ok) {
            window.location.href = (window.APP_BASE || '') + '/connexion';
        }
    });
})();
