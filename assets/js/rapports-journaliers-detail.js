/* Rapports journaliers - detail */
(function(){
    'use strict';
    const base = window.APP_BASE || '';
    document.addEventListener('DOMContentLoaded', async function(){
        if(!await Auth.rafraichir()){ window.location.href = base+'/connexion'; return; }
        const id = window.location.pathname.split('/').filter(Boolean).pop();
        const zone = document.getElementById('rapport-detail');
        const rep = await Auth.api('/api/v1/rapports-journaliers/'+id);
        if(!rep.ok || !zone){ if(zone) zone.textContent = 'Rapport introuvable.'; return; }
        const json = await rep.json().catch(function(){return{};});
        const d = json.donnees;
        if(!d){ zone.textContent = 'Rapport introuvable.'; return; }
        const statut = {'brouillon':'Brouillon','soumis':'Soumis','consulte':'Consulté','archive':'Archivé'}[d.statut]||d.statut||'';
        zone.innerHTML = '<div class="grille-info">' +
            '<div><span class="info-label">Numéro</span>'+Format.echapper(d.numero||d.id||'')+'</div>' +
            '<div><span class="info-label">Chantier</span>'+Format.echapper(d.chantier_nom||'-')+'</div>' +
            '<div><span class="info-label">Date</span>'+Format.echapper(d.date_rapport||'')+'</div>' +
            '<div><span class="info-label">Chef de chantier</span>'+Format.echapper(d.chef_nom||'-')+'</div>' +
            '<div><span class="info-label">Météo</span>'+Format.echapper(d.meteo||'-')+'</div>' +
            '<div><span class="info-label">Avancement</span>'+Format.echapper(d.avancement_pct!=null?d.avancement_pct+' %':'-')+'</div>' +
            '<div><span class="info-label">Statut</span>'+Format.echapper(statut)+'</div>' +
            '</div>' +
            '<h3>Travaux réalisés</h3><p>'+(Format.echapper(d.travaux_realises||'-'))+'</p>' +
            (d.problemes?'<h3>Problèmes</h3><p>'+Format.echapper(d.problemes)+'</p>':'') +
            (d.observations?'<h3>Observations</h3><p>'+Format.echapper(d.observations)+'</p>':'');
    });
})();
