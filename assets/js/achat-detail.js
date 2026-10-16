/* Detail d'un achat : informations, lignes, reception / annulation. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const R = window.RESSOURCE || {};
    const id = R.id;
    const STATUTS = { commande: 'Commande', recu: 'Recu', annule: 'Annule' };

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        await charger();
        document.getElementById('btn-reception').addEventListener('click', reception);
        document.getElementById('btn-annuler').addEventListener('click', annuler);
    });

    async function charger() {
        const rep = await Auth.api('/api/v1/achats/' + id);
        if (!rep.ok) { document.getElementById('titre-achat').textContent = 'Achat introuvable'; return; }
        rendre((await rep.json()).donnees);
    }

    function rendre(a) {
        document.getElementById('zone-achat').hidden = false;
        document.getElementById('titre-achat').textContent = a.reference || ('Achat #' + a.id);
        document.getElementById('sous-titre-achat').textContent = STATUTS[a.statut] || a.statut;

        document.getElementById('infos-achat').innerHTML = [
            ['Fournisseur', a.fournisseur_nom || '—'],
            ['Chantier', a.chantier_nom || '—'],
            ['Date', Format.date(a.date_achat)],
            ['Statut', STATUTS[a.statut] || a.statut],
            ['Notes', a.notes || '—']
        ].map(function (i) { return '<dt>' + i[0] + '</dt><dd>' + Format.echapper(i[1]) + '</dd>'; }).join('');

        document.getElementById('corps-lignes').innerHTML = (a.lignes || []).map(function (l) {
            return '<tr><td>' + Format.echapper(l.designation) + '</td><td>' + Number(l.quantite) + '</td><td>' +
                Format.ariary(l.prix_unitaire) + '</td><td>' + Format.ariary(l.montant) + '</td></tr>';
        }).join('');
        document.getElementById('total-achat').textContent = Format.ariary(a.montant_total);

        document.getElementById('btn-reception').hidden = !(R.peutReceptionner && a.statut === 'commande');
        document.getElementById('btn-annuler').hidden = !(R.peutAnnuler && a.statut === 'commande');
    }

    async function reception() {
        if (!window.confirm('Receptionner cet achat ? Les materiaux entreront en stock.')) { return; }
        const rep = await Auth.api('/api/v1/achats/' + id + '/reception', { method: 'POST' });
        const json = await rep.json().catch(function () { return {}; });
        if (rep.ok) { await charger(); } else { alert(json.message || 'Erreur.'); }
    }

    async function annuler() {
        if (!window.confirm('Annuler cet achat ?')) { return; }
        const rep = await Auth.api('/api/v1/achats/' + id + '/annuler', { method: 'POST' });
        const json = await rep.json().catch(function () { return {}; });
        if (rep.ok) { await charger(); } else { alert(json.message || 'Erreur.'); }
    }
})();
