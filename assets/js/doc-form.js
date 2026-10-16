/* Formulaire generique devis/facture : lignes dynamiques + calcul HT/TVA/TTC. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    const R = window.RESSOURCE;
    if (!R) { return; }

    const corpsLignes = document.getElementById('corps-lignes');
    const boiteErreur = document.getElementById('message-erreur');
    const bouton = document.getElementById('btn-enregistrer');
    const champTva = document.getElementById('tva_taux');

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        await Promise.all([
            peupler('/api/v1/clients?limite=200', 'client_id'),
            peupler('/api/v1/chantiers?limite=200', 'chantier_id')
        ]);
        ajouterLigne();
        document.getElementById('btn-ajouter-ligne').addEventListener('click', ajouterLigne);
        champTva.addEventListener('input', recalc);
        document.getElementById('form-doc').addEventListener('submit', soumettre);
    });

    async function peupler(url, selectId) {
        const rep = await Auth.api(url);
        if (!rep.ok) { return; }
        const liste = (await rep.json()).donnees.elements || [];
        const select = document.getElementById(selectId);
        liste.forEach(function (item) {
            const o = document.createElement('option');
            o.value = item.id; o.textContent = item.nom;
            select.appendChild(o);
        });
    }

    function ajouterLigne() {
        const tr = document.createElement('tr');
        tr.innerHTML =
            '<td><input class="l-designation" type="text"></td>' +
            '<td><input class="l-quantite" type="number" min="0" step="0.001" value="1" style="width:90px"></td>' +
            '<td><input class="l-prix" type="number" min="0" value="0" style="width:120px"></td>' +
            '<td class="l-montant">0 Ar</td>' +
            '<td><button type="button" class="lien-action lien-danger l-suppr">×</button></td>';
        corpsLignes.appendChild(tr);
        tr.querySelector('.l-quantite').addEventListener('input', recalc);
        tr.querySelector('.l-prix').addEventListener('input', recalc);
        tr.querySelector('.l-suppr').addEventListener('click', function () { tr.remove(); recalc(); });
    }

    function recalc() {
        let ht = 0;
        corpsLignes.querySelectorAll('tr').forEach(function (tr) {
            const q = Number(tr.querySelector('.l-quantite').value) || 0;
            const p = Number(tr.querySelector('.l-prix').value) || 0;
            const m = Math.round(q * p);
            tr.querySelector('.l-montant').textContent = Format.ariary(m);
            ht += m;
        });
        const taux = Number(champTva.value) || 0;
        const tva = Math.round(ht * taux / 100);
        document.getElementById('total-ht').textContent = Format.ariary(ht);
        document.getElementById('total-tva').textContent = Format.ariary(tva);
        document.getElementById('total-ttc').innerHTML = '<strong>' + Format.ariary(ht + tva) + '</strong>';
    }

    function collecter() {
        const charge = { tva_taux: champTva.value, lignes: [] };
        document.querySelectorAll('[data-entete]').forEach(function (el) { charge[el.id] = el.value; });
        corpsLignes.querySelectorAll('tr').forEach(function (tr) {
            const d = tr.querySelector('.l-designation').value.trim();
            if (!d) { return; }
            charge.lignes.push({
                designation: d,
                quantite: tr.querySelector('.l-quantite').value,
                prix_unitaire: tr.querySelector('.l-prix').value
            });
        });
        return charge;
    }

    async function soumettre(e) {
        e.preventDefault();
        boiteErreur.hidden = true;
        const charge = collecter();
        if (charge.lignes.length === 0) {
            boiteErreur.textContent = 'Ajoutez au moins une ligne.';
            boiteErreur.hidden = false; return;
        }
        bouton.disabled = true; bouton.textContent = 'Enregistrement…';
        const rep = await Auth.api('/' + R.endpoint, { method: 'POST', body: charge });
        const json = await rep.json().catch(function () { return {}; });
        if (rep.ok && json.succes) { window.location.href = base + R.baseWeb + '/' + json.donnees.id; return; }
        boiteErreur.textContent = json.message || 'Erreur.';
        boiteErreur.hidden = false;
        bouton.disabled = false; bouton.textContent = 'Enregistrer';
    }
})();
