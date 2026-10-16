/* Parcours public de recuperation par code OTP. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const demande = document.getElementById('form-demande-otp');
    const reinitialisation = document.getElementById('form-reinitialisation');
    const email = document.getElementById('otp-email');
    const messageOtp = document.getElementById('message-otp');
    const messageReset = document.getElementById('message-reinitialisation');

    demande.addEventListener('submit', async function (e) {
        e.preventDefault();
        messageOtp.hidden = true;
        const bouton = document.getElementById('btn-demande-otp');
        bouton.disabled = true;
        try {
            const rep = await fetch(base + '/api/v1/auth/mot-de-passe-oublie', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                credentials: 'same-origin',
                body: JSON.stringify({ email: email.value.trim() })
            });
            const json = await rep.json().catch(function () { return {}; });
            if (!rep.ok) {
                messageOtp.textContent = json.message || 'Adresse e-mail invalide.';
                messageOtp.hidden = false;
                return;
            }
            messageOtp.className = 'etat-api succes';
            messageOtp.textContent = 'Si cette adresse existe, un code vient d\'être envoyé. Vérifiez votre boîte e-mail.';
            messageOtp.hidden = false;
            reinitialisation.hidden = false;
            email.readOnly = true;
            document.getElementById('otp-code').focus();
        } catch (error) {
            messageOtp.textContent = 'Impossible de contacter le serveur. Veuillez réessayer.';
            messageOtp.hidden = false;
        } finally {
            bouton.disabled = false;
        }
    });

    reinitialisation.addEventListener('submit', async function (e) {
        e.preventDefault();
        messageReset.hidden = true;
        const nouveau = document.getElementById('otp-nouveau').value;
        const confirmation = document.getElementById('otp-confirmation').value;
        if (nouveau !== confirmation) {
            messageReset.textContent = 'Les deux mots de passe sont differents.';
            messageReset.hidden = false;
            return;
        }
        const bouton = document.getElementById('btn-reinitialisation');
        bouton.disabled = true;
        try {
            const rep = await fetch(base + '/api/v1/auth/reinitialiser-mot-de-passe', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                credentials: 'same-origin',
                body: JSON.stringify({
                    email: email.value.trim(),
                    code: document.getElementById('otp-code').value.trim(),
                    nouveau_mot_de_passe: nouveau,
                    nouveau_mot_de_passe_confirmation: confirmation
                })
            });
            const json = await rep.json().catch(function () { return {}; });
            if (rep.ok && json.succes) {
                messageReset.className = 'etat-api succes';
                messageReset.textContent = 'Mot de passe réinitialisé. Redirection vers la connexion...';
                messageReset.hidden = false;
                setTimeout(function () { window.location.href = base + '/connexion'; }, 900);
                return;
            }
            messageReset.textContent = json.message || 'Code invalide ou expiré.';
            messageReset.hidden = false;
        } catch (error) {
            messageReset.textContent = 'Impossible de contacter le serveur. Veuillez réessayer.';
            messageReset.hidden = false;
        } finally {
            bouton.disabled = false;
        }
    });
})();
