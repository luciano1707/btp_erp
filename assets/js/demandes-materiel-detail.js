/* Demandes de matériel - détail */
(function(){
    'use strict';
    const base = window.APP_BASE || '';
    let demande = null;
    document.addEventListener('DOMContentLoaded', async function(){
        if(!await Auth.rafraichir()){ window.location.href = base+'/connexion'; return; }
        const id = window.location.pathname.split('/').filter(Boolean).pop();
        await charger(id);
    });
    async function charger(id){
        const rep = await Auth.api('/api/v1/demandes-materiel/'+id);
        if(!rep.ok){ return; }
        demande = (await rep.json()).donnees;
        remplir();
        afficherActions();
    }
    function remplir(){
        document.getElementById('dm-numero').textContent = demande.numero || '';
        document.getElementById('dm-objet').textContent = demande.objet || '';
        document.getElementById('dm-chantier').textContent = demande.chantier_nom || '-';
        document.getElementById('dm-demandeur').textContent = [demande.demandeur_prenom, demande.demandeur_nom].filter(Boolean).join(' ') || '';
        document.getElementById('dm-urgence').textContent = {'normale':'Normale','urgente':'Urgente','tres_urgente':'Très urgente'}[demande.urgence]||demande.urgence;
        document.getElementById('dm-statut').textContent = {'brouillon':'Brouillon','en_attente':'En attente','valide':'Validé','refuse':'Refusé','traite':'Traité','annule':'Annulé'}[demande.statut]||demande.statut;
        document.getElementById('dm-date').textContent = demande.date_demande || '';
        const tbody = document.getElementById('dm-lignes');
        const lignes = demande.lignes || [];
        if(!lignes.length){ tbody.innerHTML='<tr><td colspan="3" class="vide">Aucune ligne</td></tr>'; return; }
        tbody.innerHTML = lignes.map(function(l){ return '<tr><td>'+Format.echapper(l.designation)+'</td><td>'+Format.echapper(l.unite)+'</td><td>'+Format.echapper(l.quantite_demandee)+'</td></tr>'; }).join('');
        if(demande.statut==='refuse' && demande.motif_refus){
            document.getElementById('bloc-refus').hidden=false;
            document.getElementById('dm-motif-refus').textContent = demande.motif_refus;
        }
    }
    function afficherActions(){
        const zone = document.getElementById('actions-demande');
        zone.innerHTML = '';
        const peutValider = zone.dataset.peutValider === '1';
        const peutTraiter = zone.dataset.peutTraiter === '1';
        const peutModifier = zone.dataset.peutModifier === '1';
        const btnModifier = document.getElementById('btn-modifier');
        if(btnModifier){
            btnModifier.hidden = !(peutModifier && demande.statut === 'en_attente');
        }
        if(peutValider && demande.statut === 'en_attente'){
            const btnApprouver = document.createElement('button'); btnApprouver.className='btn btn-primaire'; btnApprouver.textContent='Approuver'; btnApprouver.onclick = approuver; zone.appendChild(btnApprouver);
            const btnRefuser = document.createElement('button'); btnRefuser.className='btn btn-rouge'; btnRefuser.textContent='Refuser'; btnRefuser.onclick = ouvrirRefus; zone.appendChild(btnRefuser);
        }
        if(peutTraiter && demande.statut === 'valide'){
            const btnTraiter = document.createElement('button'); btnTraiter.className='btn btn-primaire'; btnTraiter.textContent='Traiter (sortie stock)'; btnTraiter.onclick = traiter; zone.appendChild(btnTraiter);
        }
    }
    async function approuver(){
        if(!confirm('Approuver cette demande ?')) return;
        const rep = await Auth.api('/api/v1/demandes-materiel/'+demande.id+'/approuver', {method:'POST'});
        if(!rep.ok){ alert('Erreur'); return; }
        location.reload();
    }
    function ouvrirRefus(){
        const dlg = document.getElementById('dialog-refus');
        dlg.showModal();
        document.getElementById('form-refus').onsubmit = function(e){
            e.preventDefault();
            const motif = e.target.motif_refus.value;
            refuser(motif);
            dlg.close();
        };
    }
    async function refuser(motif){
        const rep = await Auth.api('/api/v1/demandes-materiel/'+demande.id+'/refuser', {method:'POST', body:{motif_refus: motif}});
        if(!rep.ok){ alert('Erreur'); return; }
        location.reload();
    }
    async function traiter(){
        if(!confirm('Enregistrer les sorties de stock pour cette demande ?')) return;
        const rep = await Auth.api('/api/v1/demandes-materiel/'+demande.id+'/traiter', {method:'POST'});
        if(!rep.ok){ alert('Erreur'); return; }
        location.reload();
    }
})();
