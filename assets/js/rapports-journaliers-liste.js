/* Rapports journaliers - liste */
(function(){
    'use strict';
    const base = window.APP_BASE || '';
    const peutModifier = Boolean(window.RESSOURCE && window.RESSOURCE.peutModifier);
    let donnees = [];
    document.addEventListener('DOMContentLoaded', async function(){
        if(!await Auth.rafraichir()){ window.location.href = base+'/connexion'; return; }
        charger();
        document.getElementById('filtre-statut').addEventListener('change', filtrer);

    });
    async function charger(){
        const rep = await Auth.api('/api/v1/rapports-journaliers');
        if(!rep.ok){ return; }
        donnees = (await rep.json()).donnees || [];
        afficher(donnees);
    }
    function filtrer(){
        const s = document.getElementById('filtre-statut').value;

        let l = donnees.slice();
        if(s) l = l.filter(x=>x.statut===s);

        afficher(l);
    }
    function afficher(lignes){
        const tbody = document.getElementById('table-rapports');
        const colSpan = peutModifier ? 8 : 7;
        if(!lignes.length){ tbody.innerHTML='<tr><td colspan="'+colSpan+'" class="vide">Aucun rapport</td></tr>'; return; }
        tbody.innerHTML = lignes.map(function(d){
            const statut = {'brouillon':'Brouillon','soumis':'Soumis','consulte':'Consulté','archive':'Archivé'}[d.statut]||d.statut||'';
            let actions = '<a class="lien" href="'+base+'/rapports-journaliers/'+d.id+'">Détail</a>';
            if(peutModifier){
                actions += ' <a class="lien-action" href="'+base+'/rapports-journaliers/'+d.id+'/modifier">Modifier</a>';
            }
            return '<tr><td>'+Format.echapper(d.id||'')+'</td><td>'+Format.echapper(d.chantier_nom||'-')+'</td><td>'+Format.echapper(d.date_rapport||'')+'</td><td>'+Format.echapper(d.chef_nom||'')+'</td><td>'+Format.echapper(d.avancement||'')+'</td><td>'+statut+'</td>'+(peutModifier?'<td class="col-actions">'+actions+'</td>':'<td>'+actions+'</td>')+'</tr>';
        }).join('');
    }
})();

