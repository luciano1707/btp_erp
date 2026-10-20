/* Etat du stock + sortie rapide de matiere. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const peutEcrire = Boolean(window.RESSOURCE && window.RESSOURCE.peutEcrire);
    const nbColonnes = peutEcrire ? 6 : 5;
    const corps = document.getElementById('corps-tableau');
    const compteur = document.getElementById('compteur');
    const recherche = document.getElementById('recherche-stock');
    const modal = peutEcrire ? document.getElementById('modal-mouvement') : null;
    const formulaire = peutEcrire ? document.getElementById('form-mouvement') : null;
    const champQuantite = peutEcrire ? document.getElementById('mouvement-quantite') : null;
    const champMotif = peutEcrire ? document.getElementById('mouvement-motif') : null;
    const erreurMouvement = peutEcrire ? document.getElementById('mouvement-erreur') : null;
    const boutonEnregistrer = peutEcrire ? document.getElementById('btn-enregistrer-mouvement') : null;
    const boutonAnnuler = peutEcrire ? document.getElementById('btn-annuler-mouvement') : null;
    const noticeStock = peutEcrire ? document.getElementById('stock-notice') : null;
    let elementsStock = [];
    let mouvementActif = null;
    let declencheurModal = null;

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        recherche.addEventListener('input', afficherRecherche);
        if (peutEcrire) {
            formulaire.addEventListener('submit', enregistrerMouvement);
            boutonAnnuler.addEventListener('click', fermerModal);
            modal.addEventListener('click', function (evenement) {
                if (evenement.target === modal && !boutonEnregistrer.disabled) { fermerModal(); }
            });
            document.addEventListener('keydown', function (evenement) {
                if (evenement.key === 'Escape' && !modal.hidden && !boutonEnregistrer.disabled) { fermerModal(); }
            });
        }
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
            b.addEventListener('click', function () { ouvrirModal(b.dataset.id, b.dataset.type); });
        });
    }

    function ouvrirModal(materiauId, type) {
        const materiau = elementsStock.find(function (element) { return String(element.id) === String(materiauId); });
        if (!materiau) { return; }
        mouvementActif = { materiauId: Number(materiau.id), type: type, designation: materiau.designation };
        declencheurModal = document.activeElement;
        const entree = type === 'entree';
        document.getElementById('titre-mouvement').textContent = entree ? 'Enregistrer une entree' : 'Enregistrer une sortie';
        document.getElementById('description-mouvement').textContent =
            materiau.designation + ' — stock actuel : ' + Number(materiau.stock) + ' ' + materiau.unite;
        document.getElementById('label-quantite').textContent = 'Quantite (' + materiau.unite + ') *';
        champQuantite.value = '';
        champMotif.value = '';
        champMotif.placeholder = entree ? 'Ex. : livraison fournisseur' : 'Ex. : utilisation sur chantier';
        erreurMouvement.hidden = true;
        erreurMouvement.textContent = '';
        boutonEnregistrer.disabled = false;
        boutonAnnuler.disabled = false;
        modal.hidden = false;
        champQuantite.focus();
    }

    function fermerModal() {
        if (boutonEnregistrer.disabled) { return; }
        modal.hidden = true;
        mouvementActif = null;
        if (declencheurModal && declencheurModal.isConnected) { declencheurModal.focus(); }
    }

    async function enregistrerMouvement(evenement) {
        evenement.preventDefault();
        if (!mouvementActif || !formulaire.reportValidity()) { return; }
        const quantite = Number(champQuantite.value);
        if (!Number.isFinite(quantite) || quantite <= 0) {
            afficherErreur('La quantite doit etre superieure a zero.');
            return;
        }

        boutonEnregistrer.disabled = true;
        boutonAnnuler.disabled = true;
        let rep;
        try {
            rep = await Auth.api('/api/v1/mouvements', {
                method: 'POST',
                body: {
                    materiau_id: mouvementActif.materiauId,
                    type: mouvementActif.type,
                    quantite: quantite,
                    motif: champMotif.value.trim() || (mouvementActif.type === 'entree' ? 'Entree manuelle' : 'Sortie manuelle')
                }
            });
        } catch {
            afficherErreur('Impossible de contacter le serveur. Verifiez votre connexion puis reessayez.');
            boutonEnregistrer.disabled = false;
            boutonAnnuler.disabled = false;
            return;
        }

        const json = await rep.json().catch(function () { return {}; });
        if (!rep.ok) {
            afficherErreur(json.message || "Le mouvement n'a pas pu etre enregistre.");
            boutonEnregistrer.disabled = false;
            boutonAnnuler.disabled = false;
            return;
        }

        const nom = mouvementActif.designation;
        const libelle = mouvementActif.type === 'entree' ? 'Entree' : 'Sortie';
        modal.hidden = true;
        mouvementActif = null;
        noticeStock.textContent = libelle + ' enregistree pour ' + nom + '.';
        noticeStock.hidden = false;
        await charger();
        if (declencheurModal && declencheurModal.isConnected) { declencheurModal.focus(); }
    }

    function afficherErreur(message) {
        erreurMouvement.textContent = message;
        erreurMouvement.hidden = false;
    }
})();
