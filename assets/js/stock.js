/* Etat du stock + sortie rapide de matiere. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const peutEcrire = Boolean(window.RESSOURCE && window.RESSOURCE.peutEcrire);
    const nbColonnes = peutEcrire ? 6 : 5;
    const corps = document.getElementById('corps-tableau');
    const compteur = document.getElementById('compteur');
    const recherche = document.getElementById('recherche-stock');
    let elementsStock = [];

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        recherche.addEventListener('input', afficherRecherche);
        await charger();
    });

    async function charger() {
        const rep = await Auth.api('/api/v1/stock');
        if (!rep.ok) { corps.innerHTML = '<tr><td class="vide" colspan="' + nbColonnes + '">Erreur.</td></tr>'; return; }
        elementsStock = (await rep.json()).donnees || [];
        afficher(elementsStock);
    }

    function afficherRecherche() {
        const terme = recherche.value.trim().toLocaleLowerCase();
        const filtres = elementsStock.filter(function (m) {
            return [m.code, m.designation, m.unite].some(function (valeur) {
                return String(valeur || '').toLocaleLowerCase().indexOf(terme) !== -1;
            });
        });
        afficher(filtres, terme !== '');
    }

    function afficher(elements, rechercheActive) {
        compteur.textContent = elements.length + ' materiau' + (elements.length > 1 ? 'x' : '');
        if (!elements.length) {
            corps.innerHTML = '<tr><td class="vide" colspan="' + nbColonnes + '">' + (rechercheActive ? 'Aucun resultat.' : 'Aucun materiau.') + '</td></tr>';
            return;
        }
        corps.innerHTML = elements.map(function (m) {
            const alerte = m.sous_seuil ? ' class="ligne-alerte"' : '';
            return '<tr' + alerte + '>' +
                '<td>' + (m.code ? Format.echapper(m.code) : '—') + '</td>' +
                '<td>' + Format.echapper(m.designation) + (m.sous_seuil ? ' <span class="badge-non">seuil</span>' : '') + '</td>' +
                '<td>' + Format.echapper(m.unite) + '</td>' +
                '<td><strong>' + Number(m.stock) + '</strong></td>' +
                '<td>' + (m.seuil_alerte !== null ? Number(m.seuil_alerte) : '—') + '</td>' +
                (peutEcrire ? '<td class="col-actions">' +
                    '<button class="lien-action" data-id="' + m.id + '" data-nom="' + Format.echapper(m.designation) + '" data-type="entree">Entrer</button> ' +
                    '<button class="lien-action" data-id="' + m.id + '" data-nom="' + Format.echapper(m.designation) + '" data-type="sortie">Sortie</button>' +
                    '</td>' : '') +
                '</tr>';
        }).join('');

        if (!peutEcrire) { return; }
        corps.querySelectorAll('button[data-id]').forEach(function (b) {
            b.addEventListener('click', function () { mouvement(b.dataset.id, b.dataset.nom, b.dataset.type); });
        });
    }

    async function mouvement(materiauId, nom, type) {
        const entree = type === 'entree';
        const libelle = entree ? 'a entrer dans' : 'a sortir de';
        const q = window.prompt('Quantite ' + libelle + ' « ' + nom + ' » :', '');
        if (q === null || q.trim() === '' || isNaN(Number(q)) || Number(q) <= 0) { return; }
        const rep = await Auth.api('/api/v1/mouvements', {
            method: 'POST',
            body: {
                materiau_id: Number(materiauId),
                type: type,
                quantite: Number(q),
                motif: entree ? 'Entree manuelle' : 'Sortie manuelle'
            }
        });
        if (rep.ok) { await charger(); } else {
            const json = await rep.json().catch(function () { return {}; });
            alert(json.message || 'Erreur.');
        }
    }
})();
