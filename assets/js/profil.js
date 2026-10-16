/* Profil personnel : informations et mot de passe. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const roles = { directeur: 'Directeur', chef_chantier: 'Chef de chantier', comptable: 'Comptable', magasinier: 'Magasinier' };

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        await chargerProfil();
        document.getElementById('form-profil').addEventListener('submit', enregistrerProfil);
        document.getElementById('form-mot-de-passe').addEventListener('submit', changerMotDePasse);
    });

    async function chargerProfil() {
        const rep = await Auth.api('/api/v1/auth/me');
        if (!rep.ok) { return; }
        const u = (await rep.json()).donnees;
        document.getElementById('profil_nom').value = u.nom || '';
        document.getElementById('profil_prenom').value = u.prenom || '';
        document.getElementById('profil_email').value = u.email || '';
        document.getElementById('profil_telephone').value = u.telephone || '';
        document.getElementById('profil_role').value = roles[u.role] || u.role || '';
    }

    async function enregistrerProfil(e) {
        e.preventDefault();
        const message = document.getElementById('message-profil');
        const statut = document.getElementById('statut-profil');
        const bouton = document.getElementById('btn-profil');
        message.hidden = true;
        bouton.disabled = true;
        const rep = await Auth.api('/api/v1/auth/me', {
            method: 'PUT',
            body: {
                nom: document.getElementById('profil_nom').value.trim(),
                prenom: document.getElementById('profil_prenom').value.trim(),
                email: document.getElementById('profil_email').value.trim(),
                telephone: document.getElementById('profil_telephone').value.trim()
            }
        });
        const json = await rep.json().catch(function () { return {}; });
        if (rep.ok && json.succes) {
            statut.textContent = 'Profil enregistre.';
            setTimeout(function () { statut.textContent = ''; }, 2500);
        } else {
            message.textContent = json.message || 'Modification impossible.';
            message.hidden = false;
        }
        bouton.disabled = false;
    }

    async function changerMotDePasse(e) {
        e.preventDefault();
        const message = document.getElementById('message-mot-de-passe');
        const bouton = document.getElementById('btn-mot-de-passe');
        const nouveau = document.getElementById('nouveau_mot_de_passe').value;
        const confirmation = document.getElementById('confirmation_mot_de_passe').value;
        message.hidden = true;
        if (nouveau !== confirmation) {
            message.textContent = 'Les deux nouveaux mots de passe sont differents.';
            message.hidden = false;
            return;
        }
        bouton.disabled = true;
        const rep = await Auth.api('/api/v1/auth/mot-de-passe', {
            method: 'POST',
            body: {
                mot_de_passe_actuel: document.getElementById('mot_de_passe_actuel').value,
                nouveau_mot_de_passe: nouveau,
                nouveau_mot_de_passe_confirmation: confirmation
            }
        });
        const json = await rep.json().catch(function () { return {}; });
        if (rep.ok && json.succes) {
            message.className = 'etat-api succes';
            message.textContent = 'Mot de passe modifie. Reconnexion...';
            message.hidden = false;
            setTimeout(function () { window.location.href = base + '/connexion'; }, 700);
        } else {
            message.textContent = json.message || 'Modification impossible.';
            message.hidden = false;
            bouton.disabled = false;
        }
    }
})();
