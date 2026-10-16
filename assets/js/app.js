/* =========================================================
   Digital Chantier - JavaScript front (Phase 0)
   Verifie la disponibilite de l'API interne.
   ========================================================= */

(function () {
    'use strict';

    const conteneur = document.getElementById('etat-api');
    if (!conteneur) {
        return;
    }

    const base = window.APP_BASE || '';
    const endpoint = base + '/' + (conteneur.dataset.endpoint || 'api/v1/health');

    fetch(endpoint, { headers: { 'Accept': 'application/json' } })
        .then(function (reponse) {
            if (!reponse.ok) {
                throw new Error('HTTP ' + reponse.status);
            }
            return reponse.json();
        })
        .then(function (json) {
            const d = json.donnees || {};
            conteneur.classList.remove('echec');
            conteneur.classList.add('succes');
            conteneur.innerHTML =
                ligne('Statut', json.message || 'OK') +
                ligne('Version API', d.version_api) +
                ligne('PHP', d.php) +
                ligne('Base de donnees', d.base_donnees) +
                ligne('Environnement', d.environnement);
        })
        .catch(function (err) {
            conteneur.classList.remove('succes');
            conteneur.classList.add('echec');
            conteneur.textContent = 'API injoignable : ' + err.message;
        });

    function ligne(cle, valeur) {
        return '<div><span class="cle">' + cle + ' :</span> <strong>' +
            (valeur == null ? '-' : String(valeur)) + '</strong></div>';
    }
})();
