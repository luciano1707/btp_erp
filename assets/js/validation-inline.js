/* File de validation intégrée aux pages métier. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const ROLES = { directeur: 'Directeur', comptable: 'Comptable' };
    const TYPES = {
        devis: 'Devis',
        depense: 'Dépense',
        paiement: 'Paiement',
        chantier_creation: 'Création de chantier',
        chantier_modification: 'Modification de chantier',
        sortie_stock: 'Sortie exceptionnelle de stock',
        demande_materiel: 'Demande de matériel'
    };

    document.addEventListener('DOMContentLoaded', async function () {
        const zone = document.getElementById('validations-integrees');
        if (!zone) { return; }
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }

        let reponseUtilisateur;
        try {
            reponseUtilisateur = await Auth.api('/api/v1/auth/me');
        } catch {
            afficherErreur(zone, 'Impossible de vérifier le rôle utilisateur. Actualisez la page pour réessayer.');
            return;
        }
        if (!reponseUtilisateur.ok) {
            afficherErreur(zone, 'Impossible de vérifier le rôle utilisateur.');
            return;
        }
        const utilisateur = (await reponseUtilisateur.json()).donnees || {};
        const types = (zone.dataset.types || '').split(',').filter(Boolean);
        let resultats;
        try {
            resultats = await Promise.all(types.map(chargerType));
        } catch (erreur) {
            afficherErreur(zone, erreur instanceof Error
                ? erreur.message
                : 'La requête de validation a échoué. Vérifiez la console du navigateur.');
            return;
        }
        const resultatEnErreur = resultats.find(function (resultat) { return resultat.erreur; });
        if (resultatEnErreur) {
            afficherErreur(zone, resultatEnErreur.message);
            return;
        }

        const validations = resultats.reduce(function (toutes, resultat) {
            return toutes.concat(resultat.validations);
        }, []).filter(function (validation) {
            return validation.statut === 'en_attente' && validation.role_attendu === utilisateur.role;
        });
        afficher(zone, validations, utilisateur.role);
    });

    async function chargerType(type) {
        const url = '/api/v1/validations?type_operation=' + encodeURIComponent(type) +
            '&statut=en_attente&limite=300';
        let reponse;
        try {
            reponse = await Auth.api(url);
        } catch (erreur) {
            const cause = erreur instanceof Error ? erreur.message : 'erreur réseau inconnue';
            throw new Error('Échec de la requête de validation (' + type + ') : ' + cause);
        }
        const contenuBrut = await reponse.text();
        let charge;
        try {
            charge = JSON.parse(contenuBrut);
        } catch {
            const extrait = contenuBrut.replace(/\s+/g, ' ').trim().slice(0, 120);
            throw new Error('Réponse non JSON pour les validations (' + type + ', HTTP ' +
                reponse.status + ', ' + contenuBrut.length + ' caractères)' +
                (extrait ? ' : ' + extrait : ' : réponse vide') +
                '. Vérifiez le corps de la réponse dans Réseau > Prévisualisation.');
        }
        if (!reponse.ok || !charge.succes) {
            return {
                erreur: true,
                validations: [],
                message: charge.message || 'Échec du chargement des validations (' +
                    type + ', HTTP ' + reponse.status + ').'
            };
        }
        const contenu = charge.donnees;
        const validations = Array.isArray(contenu) ? contenu
            : contenu && Array.isArray(contenu.elements) ? contenu.elements
                : null;
        if (!validations) {
            throw new Error('Format inattendu pour la liste de validations (' + type + ').');
        }
        return { erreur: false, validations: validations };
    }

    function afficher(zone, validations, role) {
        const tbody = zone.querySelector('tbody');
        if (!validations.length) {
            tbody.innerHTML = '<tr><td class="vide" colspan="6">Aucune opération en attente de votre validation.</td></tr>';
            zone.hidden = false;
            return;
        }

        tbody.innerHTML = validations.map(function (validation) {
            const etape = Number(validation.etapes_totales || 1) > 1
                ? validation.etape + '/' + validation.etapes_totales
                : 'Validation requise';
            const chantier = validation.chantier_nom || '—';
            const montant = validation.montant === null || validation.montant === undefined
                ? '—'
                : Format.ariary(validation.montant);
            const reference = validation.reference || ('#' + validation.operation_id);
            const changements = validation.meta && validation.meta.changements;
            const details = changements
                ? '<details><summary>Changements proposés</summary><pre>' +
                    Format.echapper(JSON.stringify(changements, null, 2)) + '</pre></details>'
                : '';

            return '<tr>' +
                '<td>' + Format.echapper(TYPES[validation.type_operation] || validation.libelle_type || validation.type_operation) + '</td>' +
                '<td><a class="lien" href="' + base + lienOperation(validation) + '">' + Format.echapper(reference) + '</a>' + details + '</td>' +
                '<td>' + Format.echapper(chantier) + '</td>' +
                '<td>' + Format.echapper(montant) + '</td>' +
                '<td>' + Format.echapper(etape) + '<br>' + Format.echapper(ROLES[role] || role) + '</td>' +
                '<td class="col-actions">' +
                    '<button type="button" class="btn btn-primaire" data-valider="' + Number(validation.id) + '">Valider</button> ' +
                    '<button type="button" class="btn btn-rouge" data-refuser="' + Number(validation.id) + '">Refuser</button>' +
                '</td>' +
                '</tr>';
        }).join('');

        tbody.querySelectorAll('[data-valider]').forEach(function (bouton) {
            bouton.addEventListener('click', function () {
                decider(Number(bouton.dataset.valider), true);
            });
        });
        tbody.querySelectorAll('[data-refuser]').forEach(function (bouton) {
            bouton.addEventListener('click', function () {
                decider(Number(bouton.dataset.refuser), false);
            });
        });
        zone.hidden = false;
    }

    function lienOperation(validation) {
        const id = Number(validation.operation_id);
        switch (validation.type_operation) {
            case 'devis': return '/devis/' + id;
            case 'depense': return '/depenses/' + id;
            case 'paiement': return validation.facture_id
                ? '/factures/' + Number(validation.facture_id)
                : '/factures';
            case 'chantier_creation':
            case 'chantier_modification': return '/chantiers/' + id;
            case 'demande_materiel': return '/demandes-materiel/' + id;
            case 'sortie_stock': return '/stock';
            default: return '/';
        }
    }

    async function decider(id, approuver) {
        if (approuver && !window.confirm('Confirmer la validation de cette opération ?')) { return; }
        let motif = null;
        if (!approuver) {
            motif = window.prompt('Motif du refus :');
            if (motif === null) { return; }
            motif = motif.trim();
            if (!motif) { window.alert('Le motif du refus est obligatoire.'); return; }
        }

        let reponse;
        try {
            reponse = await Auth.api('/api/v1/validations/' + id + (approuver ? '/valider' : '/refuser'), {
                method: 'POST',
                body: approuver ? {} : { motif: motif }
            });
        } catch {
            window.alert('Impossible de contacter le serveur. La décision n’a pas été enregistrée.');
            return;
        }
        if (!reponse.ok) {
            const erreur = await reponse.json().catch(function () { return {}; });
            window.alert(erreur.message || 'La décision n’a pas pu être enregistrée.');
            return;
        }
        window.location.reload();
    }

    function afficherErreur(zone, message) {
        zone.querySelector('tbody').innerHTML =
            '<tr><td class="vide" colspan="6">' + Format.echapper(message) + '</td></tr>';
        zone.hidden = false;
    }
})();
