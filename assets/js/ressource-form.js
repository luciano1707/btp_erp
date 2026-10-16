/* =========================================================
   Formulaire generique d'un referentiel (creation / edition).
   Configure par window.RESSOURCE (entite, endpoint, id, champs).
   ========================================================= */

(function () {
    'use strict';

    const base = window.APP_BASE || '';
    const R = window.RESSOURCE;
    if (!R) { return; }

    const form       = document.getElementById('form-ressource');
    const boiteErreur = document.getElementById('message-erreur');
    const bouton      = document.getElementById('btn-enregistrer');
    const retourListe = base + '/referentiels/' + R.entite;

    document.addEventListener('DOMContentLoaded', async function () {
        const ok = await Auth.rafraichir();
        if (!ok) { window.location.href = base + '/connexion'; return; }

        // Mode edition : charger l'enregistrement existant
        if (R.id) {
            const reponse = await Auth.api('/' + R.endpoint + '/' + R.id);
            if (!reponse.ok) { window.location.href = retourListe; return; }
            const json = await reponse.json();
            remplir(json.donnees);
        }

        form.addEventListener('submit', soumettre);
    });

    function remplir(donnees) {
        R.champs.forEach(function (c) {
            const element = document.getElementById(c.champ);
            if (!element) { return; }
            const valeur = donnees[c.champ];
            if (c.type === 'checkbox') {
                element.checked = Number(valeur) === 1;
            } else {
                element.value = (valeur === null || valeur === undefined) ? '' : valeur;
            }
        });
    }

    function collecter() {
        const charge = {};
        R.champs.forEach(function (c) {
            const element = document.getElementById(c.champ);
            if (!element) { return; }
            charge[c.champ] = (c.type === 'checkbox') ? (element.checked ? 1 : 0) : element.value;
        });
        return charge;
    }

    async function soumettre(evenement) {
        evenement.preventDefault();
        boiteErreur.hidden = true;
        bouton.disabled = true;
        bouton.textContent = 'Enregistrement…';

        const methode = R.id ? 'PUT' : 'POST';
        const url = '/' + R.endpoint + (R.id ? '/' + R.id : '');

        const reponse = await Auth.api(url, { method: methode, body: collecter() });
        const json = await reponse.json().catch(function () { return {}; });

        if (reponse.ok && json.succes) {
            window.location.href = retourListe;
            return;
        }

        afficherErreurs(json);
        bouton.disabled = false;
        bouton.textContent = 'Enregistrer';
    }

    function afficherErreurs(json) {
        let messages = [json.message || 'Enregistrement impossible.'];
        if (json.erreurs) {
            messages = [];
            Object.keys(json.erreurs).forEach(function (champ) {
                const liste = json.erreurs[champ];
                (Array.isArray(liste) ? liste : [liste]).forEach(function (m) { messages.push(m); });
            });
        }
        boiteErreur.innerHTML = messages.map(function (m) {
            const div = document.createElement('div');
            div.textContent = m;
            return div.innerHTML;
        }).join('<br>');
        boiteErreur.hidden = false;
    }
})();
