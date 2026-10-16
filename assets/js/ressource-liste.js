/* =========================================================
   Liste generique d'un referentiel (Phase 2).
   Configure par window.RESSOURCE (entite, endpoint, colonnes).
   ========================================================= */

(function () {
    'use strict';

    const base = window.APP_BASE || '';
    const R = window.RESSOURCE;
    if (!R) { return; }

    const corps     = document.getElementById('corps-tableau');
    const compteur  = document.getElementById('compteur');
    const recherche = document.getElementById('recherche');
    const peutAfficherActions = R.peutModifier || R.peutSupprimer;
    const nbColonnes = R.colonnes.length + Number(peutAfficherActions);

    let minuteur = null;

    document.addEventListener('DOMContentLoaded', async function () {
        const ok = await Auth.rafraichir();
        if (!ok) { window.location.href = base + '/connexion'; return; }

        charger('');

        recherche.addEventListener('input', function () {
            clearTimeout(minuteur);
            minuteur = setTimeout(function () { charger(recherche.value.trim()); }, 300);
        });
    });

    async function charger(terme) {
        const url = '/' + R.endpoint + '?recherche=' + encodeURIComponent(terme);
        const reponse = await Auth.api(url);
        if (!reponse.ok) {
            afficherMessage('Erreur de chargement.');
            return;
        }
        const json = await reponse.json();
        rendre(json.donnees.elements || [], json.donnees.total || 0);
    }

    function rendre(elements, total) {
        compteur.textContent = total + ' ' + (total > 1 ? 'enregistrements' : 'enregistrement');

        if (elements.length === 0) {
            corps.innerHTML = '<tr><td class="vide" colspan="' + nbColonnes + '">Aucun enregistrement.</td></tr>';
            return;
        }

        corps.innerHTML = elements.map(function (element) {
            let cellules = R.colonnes.map(function (col) {
                return '<td>' + formater(col.type, element[col.champ]) + '</td>';
            }).join('');

            if (peutAfficherActions) {
                cellules += '<td class="col-actions">';
                if (R.peutModifier) {
                    const lienEdition = base + '/referentiels/' + R.entite + '/' + element.id + '/modifier';
                    cellules += '<a class="lien-action" href="' + lienEdition + '">Modifier</a>';
                }
                if (R.peutSupprimer) {
                    cellules += '<button class="lien-action lien-danger" data-id="' + element.id + '">Supprimer</button>';
                }
                cellules += '</td>';
            }

            return '<tr>' + cellules + '</tr>';
        }).join('');

        corps.querySelectorAll('button[data-id]').forEach(function (bouton) {
            bouton.addEventListener('click', function () { supprimer(bouton.dataset.id); });
        });
    }

    async function supprimer(id) {
        if (!R.peutSupprimer || !window.confirm('Confirmer la suppression de cet enregistrement ?')) { return; }
        const reponse = await Auth.api('/' + R.endpoint + '/' + id, { method: 'DELETE' });
        if (reponse.ok) {
            charger(recherche.value.trim());
        } else {
            const json = await reponse.json().catch(function () { return {}; });
            alert(json.message || 'Suppression impossible.');
        }
    }

    function formater(type, valeur) {
        if (valeur === null || valeur === undefined || valeur === '') { return '<span class="cle">&mdash;</span>'; }
        switch (type) {
            case 'ariary':
                return echapper(Number(valeur).toLocaleString('fr-FR').replace(/ /g, ' ')) + ' Ar';
            case 'booleen':
                return Number(valeur) ? '<span class="badge-oui">Oui</span>' : '<span class="badge-non">Non</span>';
            case 'badge':
                return '<span class="badge-valeur">' + echapper(String(valeur)) + '</span>';
            default:
                return echapper(String(valeur));
        }
    }

    function afficherMessage(msg) {
        corps.innerHTML = '<tr><td class="vide" colspan="' + nbColonnes + '">' + echapper(msg) + '</td></tr>';
    }

    function echapper(texte) {
        const div = document.createElement('div');
        div.textContent = texte;
        return div.innerHTML;
    }
})();
