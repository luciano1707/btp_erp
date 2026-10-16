/* Feuille de pointage : presence journaliere par employe, cout calcule en direct. */
(function () {
    'use strict';

    const base = window.APP_BASE || '';
    const id = window.RESSOURCE && window.RESSOURCE.id;
    const peutModifier = Boolean(window.RESSOURCE && window.RESSOURCE.peutModifier);
    const peutVoirCout = Boolean(window.RESSOURCE && window.RESSOURCE.peutVoirCout);
    const COEF = { journee: 1, demi_journee: 0.5, absent: 0 };

    let employes = [];
    let lots = [];

    const corps = document.getElementById('corps-pointage');
    const champDate = document.getElementById('date-pointage');

    document.addEventListener('DOMContentLoaded', async function () {
        if (!await Auth.rafraichir()) { window.location.href = base + '/connexion'; return; }
        document.getElementById('lien-retour').href = base + '/chantiers/' + id;
        champDate.value = new Date().toISOString().substring(0, 10);

        await chargerContexte();
        await chargerFeuille();

        champDate.addEventListener('change', chargerFeuille);
        const boutonEnregistrer = document.getElementById('btn-enregistrer');
        if (boutonEnregistrer) { boutonEnregistrer.addEventListener('click', enregistrer); }
    });

    async function chargerContexte() {
        const repCh = await Auth.api('/api/v1/chantiers/' + id);
        if (repCh.ok) {
            const c = (await repCh.json()).donnees;
            document.getElementById('sous-titre-chantier').textContent = c.nom;
            lots = c.lots || [];
        }
        const repEmp = await Auth.api('/api/v1/employes?limite=200');
        if (repEmp.ok) {
            employes = ((await repEmp.json()).donnees.elements || []).filter(function (e) { return Number(e.actif) === 1; });
        }
    }

    async function chargerFeuille() {
        const rep = await Auth.api('/api/v1/chantiers/' + id + '/pointages?date=' + champDate.value);
        const existants = {};
        if (rep.ok) {
            ((await rep.json()).donnees || []).forEach(function (p) { existants[p.employe_id] = p; });
        }
        rendre(existants);
    }

    function rendre(existants) {
        if (employes.length === 0) {
            corps.innerHTML = '<tr><td class="vide" colspan="6">Aucun employe actif. Ajoutez des employes dans les referentiels.</td></tr>';
            return;
        }
        const optionsLots = '<option value="">—</option>' + lots.map(function (l) {
            return '<option value="' + l.id + '">' + Format.echapper(l.nom) + '</option>';
        }).join('');
        const disabled = peutModifier ? '' : ' disabled';

        corps.innerHTML = employes.map(function (e) {
            const p = existants[e.id];
            const presence = p ? p.type_presence : 'absent';
            const lotChoisi = p && p.lot_id ? p.lot_id : '';
            return '<tr data-employe="' + e.id + '" data-taux="' + (e.taux_journalier || 0) + '">' +
                '<td>' + Format.echapper((e.prenom ? e.prenom + ' ' : '') + e.nom) + '</td>' +
                '<td>' + Format.echapper(e.poste || '—') + '</td>' +
                (peutVoirCout ? '<td>' + Format.ariary(e.taux_journalier) + '</td>' : '') +
                '<td><select class="sel-presence"' + disabled + '>' +
                    opt('journee', 'Andro feno (journee)', presence) +
                    opt('demi_journee', "Antsasak'andro (1/2)", presence) +
                    opt('absent', 'Tsy tonga (absent)', presence) +
                '</select></td>' +
                '<td><select class="sel-lot"' + disabled + '>' + optionsLots + '</select></td>' +
                (peutVoirCout ? '<td class="cout-cellule">—</td>' : '') +
                '</tr>';
        }).join('');

        corps.querySelectorAll('tr[data-employe]').forEach(function (tr) {
            const selLot = tr.querySelector('.sel-lot');
            const val = existants[tr.dataset.employe] && existants[tr.dataset.employe].lot_id;
            if (val) { selLot.value = val; }
            if (peutVoirCout) {
                tr.querySelector('.sel-presence').addEventListener('change', function () { majCout(tr); });
                majCout(tr);
            }
        });
        if (peutVoirCout) { majTotal(); }
    }

    function opt(valeur, libelle, choisi) {
        return '<option value="' + valeur + '"' + (valeur === choisi ? ' selected' : '') + '>' + libelle + '</option>';
    }

    function majCout(tr) {
        const presence = tr.querySelector('.sel-presence').value;
        const cout = Math.round(Number(tr.dataset.taux) * COEF[presence]);
        tr.querySelector('.cout-cellule').textContent = Format.ariary(cout);
        majTotal();
    }

    function majTotal() {
        let total = 0;
        corps.querySelectorAll('tr[data-employe]').forEach(function (tr) {
            total += Math.round(Number(tr.dataset.taux) * COEF[tr.querySelector('.sel-presence').value]);
        });
        const totalElement = document.getElementById('total-jour');
        if (totalElement) {
            totalElement.textContent = "Total du jour (Totalin'ny andro) : " + Format.ariary(total);
        }
    }

    async function enregistrer() {
        const lignes = Array.prototype.map.call(corps.querySelectorAll('tr[data-employe]'), function (tr) {
            return {
                employe_id: Number(tr.dataset.employe),
                type_presence: tr.querySelector('.sel-presence').value,
                lot_id: tr.querySelector('.sel-lot').value || null
            };
        });

        const message = document.getElementById('message-pointage');
        message.textContent = 'Enregistrement…';
        const rep = await Auth.api('/api/v1/chantiers/' + id + '/pointages', {
            method: 'POST',
            body: { date: champDate.value, lignes: lignes }
        });
        const json = await rep.json().catch(function () { return {}; });
        message.textContent = (rep.ok && json.succes) ? ('✓ ' + json.donnees.enregistres + ' pointage(s) enregistre(s).') : ('Erreur : ' + (json.message || ''));
    }
})();
