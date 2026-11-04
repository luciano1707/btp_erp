/* Demandes de matériel - formulaire */
(function(){
    'use strict';
    const base = window.APP_BASE || '';
    const id = window.RESSOURCE && window.RESSOURCE.id;
    const isEdit = id !== undefined && id !== null;

    document.addEventListener('DOMContentLoaded', async function(){
        if(!await Auth.rafraichir()){ window.location.href = base+'/connexion'; return; }
        const today = new Date().toISOString().slice(0,10);
        const dateInput = document.getElementById('date_demande');
        if(dateInput && !isEdit) dateInput.value = today;
        document.getElementById('ajouter-ligne').addEventListener('click', ajouterLigne);
        document.getElementById('form-demande').addEventListener('submit', enregistrer);
        await chargerChantiers();
        if(isEdit) await chargerDemande();
        else ajouterLigne();
    });
    async function chargerChantiers(){
        try {
            const rep = await Auth.api('/api/v1/chantiers?limite=200');
            if(!rep.ok) return;
            const data = await rep.json();
            const chantiers = Array.isArray(data.donnees) ? data.donnees : ((data.donnees && data.donnees.elements) || []);
            const select = document.getElementById('select-chantier');
            select.innerHTML = '<option value="">Aucun</option>' + chantiers.map(function(c){ return '<option value="'+c.id+'">'+Format.echapper(c.nom)+'</option>'; }).join('');
        } catch (e) { /* le formulaire reste utilisable sans la liste des chantiers */ }
    }
    async function chargerDemande(){
        const rep = await Auth.api('/api/v1/demandes-materiel/'+id);
        if(!rep.ok) return;
        const d = (await rep.json()).donnees;
        const form = document.getElementById('form-demande');
        if(form && d){
            form.objet.value = d.objet || '';
            form.chantier_id.value = d.chantier_id || '';
            form.date_demande.value = d.date_demande || '';
            form.urgence.value = d.urgence || 'normale';
            form.notes.value = d.notes || '';
            const tbody = document.getElementById('lignes-demande');
            tbody.innerHTML = '';
            (d.lignes || []).forEach(function(l){
                ajouterLigne(l.designation, l.unite, l.quantite_demandee);
            });
        }
    }
    function ajouterLigne(designation='', unite='U', quantite=''){
        const tbody = document.getElementById('lignes-demande');
        const tr = document.createElement('tr');
        tr.innerHTML = '<td><input type="text" class="champ-ligne designation" required value="'+Format.echapper(designation)+'"></td><td><input type="text" class="champ-ligne unite" value="'+Format.echapper(unite)+'"></td><td><input type="number" step="0.001" class="champ-ligne quantite" required value="'+Format.echapper(quantite)+'"></td><td><button type="button" class="btn-supprimer">Supprimer</button></td>';
        tr.querySelector('.btn-supprimer').addEventListener('click', function(){ tr.remove(); });
        tbody.appendChild(tr);
    }
    async function enregistrer(e){
        e.preventDefault();
        const form = e.target;
        const lignes = [];
        document.querySelectorAll('#lignes-demande tr').forEach(function(tr){
            const designation = tr.querySelector('.designation').value.trim();
            if(!designation) return;
            lignes.push({
                designation: designation,
                unite: tr.querySelector('.unite').value.trim() || 'U',
                quantite_demandee: tr.querySelector('.quantite').value
            });
        });
        if(lignes.length===0){ alert('Ajoutez au moins une ligne'); return; }
        const corps = {
            objet: form.objet.value,
            chantier_id: form.chantier_id.value || null,
            date_demande: form.date_demande.value,
            urgence: form.urgence.value,
            notes: form.notes.value,
            lignes: lignes
        };
        const url = isEdit ? '/api/v1/demandes-materiel/'+id : '/api/v1/demandes-materiel';
        const methode = isEdit ? 'PUT' : 'POST';
        const rep = await Auth.api(url, {method:methode, body: corps});
        if(!rep.ok){ const err = await rep.json().catch(function(){return{};}); alert(err.message || 'Erreur'); return; }
        const data = await rep.json();
        window.location.href = base + '/demandes-materiel/' + (data.donnees.id || id);
    }
})();
