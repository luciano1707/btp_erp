/* Detail d'un devis : infos, lignes, envoi et facturation. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const R = window.RESSOURCE || {};
    const id = R.id;
    const STATUTS = { brouillon: 'Brouillon', envoye: 'Envoye', accepte: 'Accepte', refuse: 'Refuse' };

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        document.getElementById('lien-imprimer').href = base + '/devis/' + id + '/imprimer';
        await charger();
        document.getElementById('btn-envoyer').addEventListener('click', function () { changerStatut('envoye'); });
        document.getElementById('btn-facturer').addEventListener('click', facturer);
    });

    async function charger() {
        const rep = await Auth.api('/api/v1/devis/' + id);
        if (!rep.ok) { document.getElementById('titre-doc').textContent = 'Devis introuvable'; return; }
        rendre((await rep.json()).donnees);
    }

    function rendre(d) {
        document.getElementById('zone-doc').hidden = false;
        document.getElementById('titre-doc').textContent = d.reference || ('Devis #' + d.id);
        document.getElementById('statut-doc').textContent = STATUTS[d.statut] || d.statut;
        document.getElementById('infos-doc').innerHTML = [
            ['Client', d.client_nom || '—'], ['Chantier', d.chantier_nom || '—'],
            ['Date', Format.date(d.date_devis)], ['Validite', Format.date(d.validite)],
            ['Statut', STATUTS[d.statut] || d.statut], ['Notes', d.notes || '—']
        ].map(function (i) { return '<dt>' + i[0] + '</dt><dd>' + Format.echapper(i[1]) + '</dd>'; }).join('');
        document.getElementById('corps-lignes').innerHTML = (d.lignes || []).map(function (l) {
            return '<tr><td>' + Format.echapper(l.designation) + '</td><td>' + Number(l.quantite) + '</td><td>' +
                Format.ariary(l.prix_unitaire) + '</td><td>' + Format.ariary(l.montant) + '</td></tr>';
        }).join('');
        document.getElementById('t-ht').textContent = Format.ariary(d.montant_ht);
        document.getElementById('t-tva').textContent = Format.ariary(d.montant_tva) + ' (' + Number(d.tva_taux) + '%)';
        document.getElementById('t-ttc').innerHTML = '<strong>' + Format.ariary(d.montant_ttc) + '</strong>';

        document.getElementById('btn-envoyer').hidden = !(R.peutValider && d.statut === 'brouillon');
        document.getElementById('btn-facturer').hidden = !(R.peutValider && d.statut !== 'refuse');
    }

    async function changerStatut(statut) {
        const rep = await Auth.api('/api/v1/devis/' + id + '/statut', { method: 'PUT', body: { statut: statut } });
        if (rep.ok) { await charger(); } else { alert('Erreur.'); }
    }

    async function facturer() {
        if (!window.confirm('Creer une facture a partir de ce devis ?')) { return; }
        const rep = await Auth.api('/api/v1/devis/' + id + '/facturer', { method: 'POST' });
        const json = await rep.json().catch(function () { return {}; });
        if (rep.ok && json.succes) { window.location.href = base + '/factures/' + json.donnees.id; }
        else { alert(json.message || 'Erreur.'); }
    }
})();
