/* Formulaire d'achat avec lignes dynamiques et total en direct. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';
    let materiaux = [];

    const corpsLignes = document.getElementById('corps-lignes');
    const boiteErreur = document.getElementById('message-erreur');
    const bouton = document.getElementById('btn-enregistrer');

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        await Promise.all([peupler('/api/v1/fournisseurs?limite=200', 'fournisseur_id', 'nom'),
                           peupler('/api/v1/chantiers?limite=200', 'chantier_id', 'nom'),
                           chargerMateriaux()]);
        document.getElementById('date_achat').value = new Date().toISOString().substring(0, 10);
        ajouterLigne();
        document.getElementById('btn-ajouter-ligne').addEventListener('click', ajouterLigne);
        document.getElementById('form-achat').addEventListener('submit', soumettre);
    });

    async function peupler(url, selectId, champ) {
        const rep = await Auth.api(url);
        if (!rep.ok) { return; }
        const json = await rep.json();
        const liste = json.donnees.elements || json.donnees || [];
        const select = document.getElementById(selectId);
        liste.forEach(function (item) {
            const o = document.createElement('option');
            o.value = item.id; o.textContent = item[champ];
            select.appendChild(o);
        });
    }

    async function chargerMateriaux() {
        const rep = await Auth.api('/api/v1/materiaux?limite=500');
        if (rep.ok) { materiaux = (await rep.json()).donnees.elements || []; }
    }

    function ajouterLigne() {
        const tr = document.createElement('tr');
        const options = '<option value="">— Libre —</option>' + materiaux.map(function (m) {
            return '<option value="' + m.id + '" data-prix="' + (m.prix_unitaire || 0) + '" data-lib="' + Format.echapper(m.designation) + '">' + Format.echapper(m.designation) + '</option>';
        }).join('');
        tr.innerHTML =
            '<td><select class="l-materiau" data-recherche>' + options + '</select></td>' +
            '<td><input class="l-designation" type="text"></td>' +
            '<td><input class="l-quantite" type="number" min="0" step="0.001" value="1" style="width:90px"></td>' +
            '<td><input class="l-prix" type="number" min="0" value="0" style="width:110px"></td>' +
            '<td class="l-montant">0 Ar</td>' +
            '<td><button type="button" class="lien-action lien-danger l-suppr">×</button></td>';
        corpsLignes.appendChild(tr);

        const selMat = tr.querySelector('.l-materiau');
        selMat.addEventListener('change', function () {
            const opt = selMat.options[selMat.selectedIndex];
            if (opt.value) {
                tr.querySelector('.l-designation').value = opt.dataset.lib;
                tr.querySelector('.l-prix').value = opt.dataset.prix;
            }
            recalc();
        });
        tr.querySelector('.l-quantite').addEventListener('input', recalc);
        tr.querySelector('.l-prix').addEventListener('input', recalc);
        tr.querySelector('.l-suppr').addEventListener('click', function () { tr.remove(); recalc(); });
        recalc();
    }

    function recalc() {
        let total = 0;
        corpsLignes.querySelectorAll('tr').forEach(function (tr) {
            const q = Number(tr.querySelector('.l-quantite').value) || 0;
            const p = Number(tr.querySelector('.l-prix').value) || 0;
            const m = Math.round(q * p);
            tr.querySelector('.l-montant').textContent = Format.ariary(m);
            total += m;
        });
        document.getElementById('total-achat').textContent = Format.ariary(total);
    }

    function collecter() {
        const lignes = [];
        corpsLignes.querySelectorAll('tr').forEach(function (tr) {
            const designation = tr.querySelector('.l-designation').value.trim();
            if (!designation) { return; }
            lignes.push({
                materiau_id: tr.querySelector('.l-materiau').value || null,
                designation: designation,
                quantite: tr.querySelector('.l-quantite').value,
                prix_unitaire: tr.querySelector('.l-prix').value
            });
        });
        return {
            reference: document.getElementById('reference').value,
            date_achat: document.getElementById('date_achat').value,
            fournisseur_id: document.getElementById('fournisseur_id').value,
            chantier_id: document.getElementById('chantier_id').value,
            notes: document.getElementById('notes').value,
            lignes: lignes
        };
    }

    async function soumettre(e) {
        e.preventDefault();
        boiteErreur.hidden = true;
        const charge = collecter();
        if (charge.lignes.length === 0) {
            boiteErreur.textContent = 'Ajoutez au moins une ligne avec une designation.';
            boiteErreur.hidden = false;
            return;
        }
        bouton.disabled = true; bouton.textContent = 'Enregistrement…';
        const rep = await Auth.api('/api/v1/achats', { method: 'POST', body: charge });
        const json = await rep.json().catch(function () { return {}; });
        if (rep.ok && json.succes) { window.location.href = base + '/achats/' + json.donnees.id; return; }
        boiteErreur.textContent = json.message || 'Erreur.';
        boiteErreur.hidden = false;
        bouton.disabled = false; bouton.textContent = 'Enregistrer l\'achat';
    }
})();
