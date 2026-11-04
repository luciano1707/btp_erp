/* Demandes de matériel - liste */
(function(){
    'use strict';
    const base = window.APP_BASE || '';
    const peutModifier = Boolean(window.RESSOURCE && window.RESSOURCE.peutModifier);
    let donnees = [];
    document.addEventListener('DOMContentLoaded', async function(){
        if(!await Auth.rafraichir()){ window.location.href = base+'/connexion'; return; }
        charger();
        document.getElementById('filtre-statut').addEventListener('change', filtrer);
        document.getElementById('filtre-urgence').addEventListener('change', filtrer);
    });
    async function charger(){
        const rep = await Auth.api('/api/v1/demandes-materiel');
        if(!rep.ok){ return; }
        donnees = (await rep.json()).donnees || [];
        afficher(donnees);
    }
    function filtrer(){
        const s = document.getElementById('filtre-statut').value;
        const u = document.getElementById('filtre-urgence').value;
        let l = donnees.slice();
        if(s) l = l.filter(x=>x.statut===s);
        if(u) l = l.filter(x=>x.urgence===u);
        afficher(l);
    }
    function afficher(lignes){
        const tbody = document.getElementById('table-demandes');
        const colSpan = peutModifier ? 9 : 8;
        if(!lignes.length){ tbody.innerHTML='<tr><td colspan="'+colSpan+'" class="vide">Aucune demande</td></tr>'; return; }
        tbody.innerHTML = lignes.map(function(d){
            const urgence = {'normale':'Normale','urgente':'Urgente','tres_urgente':'Très urgente'}[d.urgence]||d.urgence;
            const statut = {'brouillon':'Brouillon','en_attente':'En attente','valide':'Validé','refuse':'Refusé','traite':'Traité','annule':'Annulé'}[d.statut]||d.statut;
            let actions = '<a class="lien" href="'+base+'/demandes-materiel/'+d.id+'">Détail</a>';
            if(peutModifier && d.statut === 'en_attente'){
                actions += ' <a class="lien-action" href="'+base+'/demandes-materiel/'+d.id+'/modifier">Modifier</a>';
            }
            return '<tr><td>'+Format.echapper(d.numero)+'</td><td>'+Format.echapper(d.objet)+'</td><td>'+(d.chantier_nom?Format.echapper(d.chantier_nom):'-')+'</td><td>'+Format.echapper([d.demandeur_prenom,d.demandeur_nom].filter(Boolean).join(' '))+'</td><td>'+urgence+'</td><td>'+statut+'</td><td>'+Format.echapper(d.date_demande)+'</td>'+(peutModifier?'<td class="col-actions">'+actions+'</td>':'<td>'+actions+'</td>')+'</tr>';
        }).join('');
    }
})();
