// @ts-nocheck

/* Rapports journaliers - formulaire */
(function(){
    'use strict';
    const base = window.APP_BASE || '';
    const id = window.RESSOURCE && window.RESSOURCE.id;
    const isEdit = id !== undefined && id !== null;

    document.addEventListener('DOMContentLoaded', async function(){
        if(!await Auth.rafraichir()){ window.location.href = base+'/connexion'; return; }
        const today = new Date().toISOString().slice(0,10);
        const dateInput = document.getElementById('date_rapport');
        if(dateInput && !isEdit) dateInput.value = today;
        const form = document.getElementById('form-rapport');
        if(form) form.addEventListener('submit', enregistrer);
        await chargerChantiers();
        if(isEdit) await chargerRapport();
    });
    async function chargerChantiers(){
        try {
            const rep = await Auth.api('/api/v1/chantiers?limite=200');
            if(!rep.ok) return;
            const data = await rep.json();
            const chantiers = Array.isArray(data.donnees) ? data.donnees : ((data.donnees && data.donnees.elements) || []);
            const select = document.getElementById('chantier_id');
            if(!select) return;
            select.innerHTML = '<option value="">Aucun</option>' + chantiers.map(function(c){ return '<option value="'+c.id+'">'+Format.echapper(c.nom)+'</option>'; }).join('');
        } catch (e) { /* le formulaire reste utilisable sans la liste des chantiers */ }
    }
    async function chargerRapport(){
        const rep = await Auth.api('/api/v1/rapports-journaliers/'+id);
        if(!rep.ok) return;
        const d = (await rep.json()).donnees;
        const form = document.getElementById('form-rapport');
        if(form && d){
            form.chantier_id.value = d.chantier_id || '';
            form.date_rapport.value = d.date_rapport || '';
            form.meteo.value = d.meteo || '';
            form.avancement_pct.value = d.avancement_pct || '';
            form.travaux_effectues.value = d.travaux_realises || '';
            form.problemes.value = d.problemes || '';
            form.observations.value = d.observations || '';
        }
    }
    async function enregistrer(e){
        e.preventDefault();
        const form = e.target;
        const corps = {
            chantier_id: form.chantier_id.value || null,
            date_rapport: form.date_rapport.value,
            meteo: form.meteo.value,
            avancement_pct: form.avancement_pct.value,
            travaux_realises: form.travaux_effectues.value,
            problemes: form.problemes.value,
            observations: form.observations.value
        };
        const url = isEdit ? '/api/v1/rapports-journaliers/'+id : '/api/v1/rapports-journaliers';
        const methode = isEdit ? 'PUT' : 'POST';
        const rep = await Auth.api(url, {method:methode, body: corps});
        if(!rep.ok){ const err = await rep.json().catch(function(){return{};}); alert(err.message || 'Erreur'); return; }
        window.location.href = base + '/rapports-journaliers';
    }
})();
