/* =========================================================
   Digital Chantier - Module d'authentification cote client (Phase 1)

   Strategie :
   - L'access token est garde UNIQUEMENT en memoire JavaScript (jamais localStorage).
   - Le refresh token vit dans un cookie httpOnly (envoye automatiquement au serveur).
   - A chaque chargement de page, on tente un /refresh pour recuperer un access token.
   ========================================================= */

window.Auth = (function () {
    'use strict';

    const base = window.APP_BASE || '';
    let accessToken = null;
    let refreshEnCours = null; // promesse partagee pour eviter les rafraichissements concurrents

    /** Effectue un appel a l'API en injectant l'access token, avec refresh automatique si 401. */
    async function api(chemin, options) {
        options = options || {};
        options.headers = Object.assign({ 'Accept': 'application/json' }, options.headers || {});
        options.credentials = 'same-origin';

        const methode = (options.method || 'GET').toUpperCase();
        if (window.APP_DESKTOP && ['PUT', 'PATCH', 'DELETE'].includes(methode)) {
            options.method = 'POST';
            options.headers['X-HTTP-Method-Override'] = methode;
        }

        // Corps JSON, sauf pour les envois de fichiers (FormData : le navigateur gere l'en-tete)
        if (options.body && typeof options.body === 'object' && !(options.body instanceof FormData)) {
            options.headers['Content-Type'] = 'application/json';
            options.body = JSON.stringify(options.body);
        }
        if (accessToken) {
            options.headers['Authorization'] = 'Bearer ' + accessToken;
        }

        let reponse = await fetch(base + chemin, options);

        // 401 : token absent ou expire. On force un vrai rafraichissement (via le cookie)
        // puis on rejoue la requete une seule fois.
        if (reponse.status === 401) {
            accessToken = null;
            if (await rafraichir()) {
                options.headers['Authorization'] = 'Bearer ' + accessToken;
                reponse = await fetch(base + chemin, options);
            }
            if (reponse.status === 401 && !window.location.pathname.endsWith('/connexion')) {
                window.location.href = base + '/connexion';
            }
        }
        return reponse;
    }

    /** Connexion : renvoie { ok, utilisateur } ou { ok:false, message }. */
    async function login(email, motDePasse) {
        const reponse = await fetch(base + '/api/v1/auth/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
            credentials: 'same-origin',
            body: JSON.stringify({ email: email, mot_de_passe: motDePasse, client: 'web' })
        });
        const json = await reponse.json().catch(function () { return {}; });

        if (reponse.ok && json.succes) {
            accessToken = json.donnees.access_token;
            return { ok: true, utilisateur: json.donnees.utilisateur };
        }
        return { ok: false, message: json.message || 'Connexion impossible.' };
    }

    /**
     * Rafraichit l'access token depuis le cookie refresh. Renvoie true si succes.
     * Memoise : si un token est deja en memoire, on le reutilise ; si un rafraichissement
     * est deja en cours, on attend la meme promesse (evite la double rotation du refresh token).
     */
    function rafraichir() {
        if (accessToken) {
            return Promise.resolve(true);
        }
        if (refreshEnCours) {
            return refreshEnCours;
        }
        refreshEnCours = (async function () {
            try {
                const reponse = await fetch(base + '/api/v1/auth/refresh', {
                    method: 'POST',
                    headers: { 'Accept': 'application/json' },
                    credentials: 'same-origin'
                });
                if (!reponse.ok) { accessToken = null; return false; }
                const json = await reponse.json().catch(function () { return {}; });
                if (json.succes) { accessToken = json.donnees.access_token; return true; }
                accessToken = null;
                return false;
            } finally {
                refreshEnCours = null;
            }
        })();
        return refreshEnCours;
    }

    /** Deconnexion : revoque le refresh token cote serveur et oublie l'access token. */
    async function logout() {
        await fetch(base + '/api/v1/auth/logout', {
            method: 'POST',
            headers: { 'Accept': 'application/json' },
            credentials: 'same-origin'
        }).catch(function () {});
        accessToken = null;
    }

    return {
        api: api,
        login: login,
        logout: logout,
        rafraichir: rafraichir,
        getToken: function () { return accessToken; }
    };
})();
