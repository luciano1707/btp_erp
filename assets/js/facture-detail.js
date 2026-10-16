/* Detail d'une facture : infos, lignes, paiements, emission / annulation. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const R = window.RESSOURCE || {};
    const id = R.id;
    const STATUTS = { brouillon: 'Brouillon', emise: 'Emise', payee_partiel: 'Paye partiel', payee: 'Payee', annulee: 'Annulee' };
    const MODES = { especes: 'Especes', cheque: 'Cheque', virement: 'Virement', mobile_money: 'Mobile Money', autre: 'Autre' };

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        document.getElementById('lien-imprimer').href = base + '/factures/' + id + '/imprimer';
        document.getElementById('lien-recu').href = base + '/factures/' + id + '/recu';
        await charger();
        document.getElementById('btn-emettre').addEventListener('click', emettre);
        document.getElementById('btn-annuler').addEventListener('click', annuler);
        document.getElementById('form-paiement').addEventListener('submit', payer);
    });

    async function charger() {
        const rep = await Auth.api('/api/v1/factures/' + id);
        if (!rep.ok) { document.getElementById('titre-doc').textContent = 'Facture introuvable'; return; }
        rendre((await rep.json()).donnees);
    }

    function rendre(f) {
        document.getElementById('zone-doc').hidden = false;
        document.getElementById('titre-doc').textContent = f.reference || ('Facture #' + f.id);
        document.getElementById('statut-doc').textContent = STATUTS[f.statut] || f.statut;
        document.getElementById('infos-doc').innerHTML = [
            ['Client', f.client_nom || '—'], ['Chantier', f.chantier_nom || '—'],
            ['Date', Format.date(f.date_facture)], ['Echeance', Format.date(f.echeance)],
            ['Statut', STATUTS[f.statut] || f.statut]
        ].map(function (i) { return '<dt>' + i[0] + '</dt><dd>' + Format.echapper(i[1]) + '</dd>'; }).join('');

        const reste = Number(f.montant_ttc) - Number(f.montant_paye);
        document.getElementById('r-ttc').textContent = Format.ariary(f.montant_ttc);
        document.getElementById('r-paye').textContent = Format.ariary(f.montant_paye);
        document.getElementById('r-reste').innerHTML = '<strong>' + Format.ariary(reste) + '</strong>';

        document.getElementById('corps-lignes').innerHTML = (f.lignes || []).map(function (l) {
            return '<tr><td>' + Format.echapper(l.designation) + '</td><td>' + Number(l.quantite) + '</td><td>' +
                Format.ariary(l.prix_unitaire) + '</td><td>' + Format.ariary(l.montant) + '</td></tr>';
        }).join('');
        document.getElementById('t-ht').textContent = Format.ariary(f.montant_ht);
        document.getElementById('t-tva').textContent = Format.ariary(f.montant_tva) + ' (' + Number(f.tva_taux) + '%)';
        document.getElementById('t-ttc').innerHTML = '<strong>' + Format.ariary(f.montant_ttc) + '</strong>';

        document.getElementById('corps-paiements').innerHTML = (f.paiements || []).length
            ? f.paiements.map(function (p) {
                return '<tr><td>' + Format.date(p.date_paiement) + '</td><td>' + Format.ariary(p.montant) + '</td><td>' +
                    (MODES[p.mode] || p.mode) + '</td><td>' + Format.echapper(p.reference_paiement || '—') + '</td></tr>';
            }).join('')
            : '<tr><td class="vide" colspan="4">Aucun paiement.</td></tr>';

        document.getElementById('lien-recu').hidden = !(f.paiements && f.paiements.length);
        document.getElementById('btn-emettre').hidden = !(R.peutValider && f.statut === 'brouillon');
        document.getElementById('btn-annuler').hidden = !(R.peutAnnuler && f.statut !== 'annulee' && Number(f.montant_paye) === 0);
        document.getElementById('form-paiement').hidden = !(R.peutPayer && (f.statut === 'emise' || f.statut === 'payee_partiel'));
    }

    async function emettre() {
        const rep = await Auth.api('/api/v1/factures/' + id + '/emettre', { method: 'POST' });
        if (rep.ok) { await charger(); } else { alert('Erreur.'); }
    }

    async function annuler() {
        if (!window.confirm('Annuler cette facture ?')) { return; }
        const rep = await Auth.api('/api/v1/factures/' + id + '/annuler', { method: 'POST' });
        const json = await rep.json().catch(function () { return {}; });
        if (rep.ok) { await charger(); } else { alert(json.message || 'Erreur.'); }
    }

    async function payer(e) {
        e.preventDefault();
        const montant = Number(document.getElementById('p-montant').value);
        if (!montant || montant < 1) { return; }
        const rep = await Auth.api('/api/v1/factures/' + id + '/paiements', {
            method: 'POST',
            body: { montant: montant, mode: document.getElementById('p-mode').value }
        });
        const json = await rep.json().catch(function () { return {}; });
        if (rep.ok) { document.getElementById('p-montant').value = ''; await charger(); }
        else { alert(json.message || 'Erreur.'); }
    }
})();
