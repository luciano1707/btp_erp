/* Page de connexion :
   - soumet le formulaire via l'API et redirige vers le tableau de bord,
   - affiche les etats du bouton (normal, chargement, succes, erreur),
   - parallaxe legere sur la scene 3D (desktop unique, amplitude faible). */

(function () {
    'use strict';

    const base = window.APP_BASE || '';
    const form = document.getElementById('form-connexion');
    const boiteErreur = document.getElementById('message-erreur');
    const bouton = document.getElementById('btn-connexion');
    const texteBouton = document.getElementById('btn-texte');
    const iconeBouton = document.getElementById('btn-icone');
    const spinnerBouton = document.getElementById('btn-spinner');
    const reductionMouvement = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    const pointeurPrecis = window.matchMedia('(pointer: fine)').matches;

    if (!form) {
        return;
    }

    // Si l'utilisateur possede deja une session valide (cookie refresh), on l'envoie au tableau de bord.
    Auth.rafraichir().then(function (ok) {
        if (ok) {
            window.location.href = base + '/tableau-de-bord';
        }
    });

    function etatBouton(type) {
        bouton.classList.remove('en-cours', 'succes', 'erreur');
        if (type) { bouton.classList.add(type); }
        if (type === 'en-cours') {
            spinnerBouton.hidden = false;
            iconeBouton.hidden = true;
            bouton.disabled = true;
            if (texteBouton) { texteBouton.textContent = 'Connexion en cours…'; }
        } else {
            spinnerBouton.hidden = true;
            iconeBouton.hidden = false;
            bouton.disabled = false;
            if (texteBouton) { texteBouton.textContent = 'Se connecter'; }
        }
    }

    form.addEventListener('submit', async function (evenement) {
        evenement.preventDefault();
        boiteErreur.hidden = true;
        boiteErreur.textContent = '';
        bouton.classList.remove('erreur');
        etatBouton('en-cours');

        const email = document.getElementById('email').value.trim();
        const motDePasse = document.getElementById('mot_de_passe').value;

        const resultat = await Auth.login(email, motDePasse);

        if (resultat.ok) {
            etatBouton('succes');
            document.getElementById('btn-texte').textContent = 'Connexion reussie';
            setTimeout(function () {
                window.location.href = base + '/tableau-de-bord';
            }, 350);
        } else {
            etatBouton('');
            bouton.classList.add('erreur');
            boiteErreur.textContent = resultat.message;
            boiteErreur.hidden = false;
            form.classList.add('retour-brutal');
            setTimeout(function () { form.classList.remove('retour-brutal'); }, 500);
        }
    });

    /* --- Parallaxe de la scene 3D : uniquement sur grand ecran, pointeur fin,
           amplitude limitee a quelques pixels, desactivee si prefers-reduced-motion. --- */
    const scene = document.getElementById('scene3d');
    if (scene && pointeurPrecis && !reductionMouvement && window.matchMedia('(min-width: 1024px)').matches) {
        const zone = document.getElementById('ecran-connexion');
        let attitude = false;
        let cx = 0.5, cy = 0.4;

        zone.addEventListener('mousemove', function (e) {
            const rect = zone.getBoundingClientRect();
            cx = (e.clientX - rect.left) / rect.width;
            cy = (e.clientY - rect.top) / rect.height;
        });
        zone.addEventListener('mouseenter', function () { attitude = true; });
        zone.addEventListener('mouseleave', function () { attitude = false; });

        (function boucle() {
            if (attitude) {
                const dx = (cx - 0.5) * -10;
                const dy = (cy - 0.5) * -8;
                scene.style.transform = 'translate3d(' + dx.toFixed(1) + 'px,' + dy.toFixed(1) + 'px,0)';
            }
            requestAnimationFrame(boucle);
        })();
    }
})();