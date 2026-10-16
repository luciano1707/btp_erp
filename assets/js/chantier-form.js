/* Formulaire chantier : peuple les selecteurs, charge (edition) et enregistre. */
(function () {
    'use strict';

    const base = window.APP_BASE || '';
    const id = window.RESSOURCE && window.RESSOURCE.id;
    const CHAMPS = (window.RESSOURCE && window.RESSOURCE.champs) || [];

    const form        = document.getElementById('form-chantier');
    const boiteErreur = document.getElementById('message-erreur');
    const bouton      = document.getElementById('btn-enregistrer');
    const retour      = base + '/chantiers';

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }

        await peuplerClients();
        await peuplerResponsables();

        if (id) { await chargerChantier(); }

        form.addEventListener('submit', soumettre);
    });

    async function peuplerClients() {
        const rep = await Auth.api('/api/v1/clients?limite=200');
        if (!rep.ok) { return; }
        const json = await rep.json();
        const select = document.getElementById('client_id');
        (json.donnees.elements || []).forEach(function (c) {
            const opt = document.createElement('option');
            opt.value = c.id; opt.textContent = c.nom;
            select.appendChild(opt);
        });
    }

    async function peuplerResponsables() {
        const rep = await Auth.api('/api/v1/utilisateurs');
        if (!rep.ok) { return; }
        const json = await rep.json();
        const select = document.getElementById('responsable_id');
        (json.donnees || []).forEach(function (u) {
            const opt = document.createElement('option');
            opt.value = u.id;
            opt.textContent = ((u.prenom ? u.prenom + ' ' : '') + u.nom) + ' (' + u.role + ')';
            select.appendChild(opt);
        });
    }

    async function chargerChantier() {
        const rep = await Auth.api('/api/v1/chantiers/' + id);
        if (!rep.ok) { window.location.href = retour; return; }
        const c = (await rep.json()).donnees;
        CHAMPS.forEach(function (champ) {
            const el = document.getElementById(champ);
            if (el && c[champ] !== null && c[champ] !== undefined) { el.value = c[champ]; }
        });
    }

    function collecter() {
        const charge = {};
        CHAMPS.forEach(function (champ) {
            const el = document.getElementById(champ);
            if (el) { charge[champ] = el.value; }
        });
        return charge;
    }

    async function soumettre(evenement) {
        evenement.preventDefault();
        boiteErreur.hidden = true;
        bouton.disabled = true;
        bouton.textContent = 'Enregistrement…';

        const methode = id ? 'PUT' : 'POST';
        const url = '/api/v1/chantiers' + (id ? '/' + id : '');
        const rep = await Auth.api(url, { method: methode, body: collecter() });
        const json = await rep.json().catch(function () { return {}; });

        if (rep.ok && json.succes) {
            window.location.href = base + '/chantiers/' + json.donnees.id;
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
        boiteErreur.innerHTML = messages.map(function (m) { return Format.echapper(m); }).join('<br>');
        boiteErreur.hidden = false;
    }
})();
