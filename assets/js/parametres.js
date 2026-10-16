/* Parametres entreprise : coordonnees + upload du logo. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const CHAMPS = ['entreprise_nom', 'entreprise_adresse', 'entreprise_telephone', 'entreprise_email', 'entreprise_nif', 'entreprise_stat'];

    let fichierChoisi = null;

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        await charger();

        document.getElementById('form-parametres').addEventListener('submit', enregistrer);
        document.getElementById('btn-choisir').addEventListener('click', function () { document.getElementById('fichier-logo').click(); });
        document.getElementById('fichier-logo').addEventListener('change', choisirFichier);
        document.getElementById('btn-envoyer-logo').addEventListener('click', envoyerLogo);
        document.getElementById('form-mot-de-passe').addEventListener('submit', changerMotDePasse);
    });

    async function charger() {
        const rep = await Auth.api('/api/v1/parametres');
        if (!rep.ok) { return; }
        const p = (await rep.json()).donnees;
        CHAMPS.forEach(function (c) {
            const el = document.getElementById(c);
            if (el && p[c] != null) { el.value = p[c]; }
        });
        afficherLogo(p.logo_url);
    }

    function afficherLogo(url) {
        const apercu = document.getElementById('apercu-logo');
        if (url) {
            apercu.innerHTML = '<img src="' + url + '?t=' + Date.now() + '" alt="Logo">';
        } else {
            apercu.innerHTML = '<span class="apercu-vide">Aucun logo</span>';
        }
    }

    function choisirFichier(e) {
        const f = e.target.files[0];
        const erreur = document.getElementById('erreur-logo');
        erreur.hidden = true;
        if (!f) { return; }
        if (f.size > 2 * 1024 * 1024) {
            erreur.textContent = 'Fichier trop volumineux (2 Mo max).';
            erreur.hidden = false;
            return;
        }
        fichierChoisi = f;
        document.getElementById('nom-fichier').textContent = f.name;
        document.getElementById('btn-envoyer-logo').disabled = false;
        // Apercu local immediat
        const lecteur = new FileReader();
        lecteur.onload = function () { document.getElementById('apercu-logo').innerHTML = '<img src="' + lecteur.result + '" alt="Apercu">'; };
        lecteur.readAsDataURL(f);
    }

    async function envoyerLogo() {
        if (!fichierChoisi) { return; }
        const bouton = document.getElementById('btn-envoyer-logo');
        const erreur = document.getElementById('erreur-logo');
        erreur.hidden = true;
        bouton.disabled = true;
        bouton.textContent = 'Envoi…';

        const forme = new FormData();
        forme.append('logo', fichierChoisi);

        // On n'ajoute pas de Content-Type : le navigateur gere le boundary multipart
        const rep = await Auth.api('/api/v1/parametres/logo', { method: 'POST', body: forme });
        const json = await rep.json().catch(function () { return {}; });

        if (rep.ok && json.succes) {
            afficherLogo(json.donnees.logo_url);
            document.getElementById('nom-fichier').textContent = 'Logo mis a jour.';
            fichierChoisi = null;
        } else {
            erreur.textContent = json.message || 'Televersement impossible.';
            erreur.hidden = false;
        }
        bouton.textContent = 'Televerser';
        bouton.disabled = true;
    }

    async function enregistrer(e) {
        e.preventDefault();
        const message = document.getElementById('message-parametres');
        const statut = document.getElementById('statut-enregistre');
        message.hidden = true;
        const charge = {};
        CHAMPS.forEach(function (c) { charge[c] = document.getElementById(c).value; });

        const rep = await Auth.api('/api/v1/parametres', { method: 'PUT', body: charge });
        const json = await rep.json().catch(function () { return {}; });
        if (rep.ok && json.succes) {
            statut.textContent = '✓ Enregistre';
            setTimeout(function () { statut.textContent = ''; }, 2500);
        } else {
            message.textContent = json.message || (rep.status === 403 ? 'Reserve au directeur.' : 'Erreur.');
            message.hidden = false;
        }
    }

    async function changerMotDePasse(e) {
        e.preventDefault();
        const message = document.getElementById('message-mot-de-passe');
        const statut = document.getElementById('statut-mot-de-passe');
        const bouton = document.getElementById('btn-mot-de-passe');
        const actuel = document.getElementById('mot_de_passe_actuel').value;
        const nouveau = document.getElementById('nouveau_mot_de_passe').value;
        const confirmation = document.getElementById('confirmation_mot_de_passe').value;

        message.hidden = true;
        statut.textContent = '';
        if (nouveau !== confirmation) {
            message.textContent = 'Les deux nouveaux mots de passe sont differents.';
            message.hidden = false;
            return;
        }

        bouton.disabled = true;
        const rep = await Auth.api('/api/v1/auth/mot-de-passe', {
            method: 'POST',
            body: {
                mot_de_passe_actuel: actuel,
                nouveau_mot_de_passe: nouveau,
                nouveau_mot_de_passe_confirmation: confirmation
            }
        });
        const json = await rep.json().catch(function () { return {}; });

        if (rep.ok && json.succes) {
            statut.textContent = 'Mot de passe modifie. Reconnexion...';
            setTimeout(function () { window.location.href = base + '/connexion'; }, 700);
        } else {
            message.textContent = json.message || 'Modification impossible.';
            message.hidden = false;
            bouton.disabled = false;
        }
    }
})();
