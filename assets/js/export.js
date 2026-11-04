/* Exports centralises : PDF dans un nouvel onglet, Excel .xlsx en telechargement direct. */
(function () {
    'use strict';
    const base = window.APP_BASE || '';

    function moduleCourant() {
        const basePath = base ? new URL(base, window.location.origin).pathname.replace(/\/+$/, '') : '';
        let chemin = window.location.pathname;
        if (basePath && (chemin === basePath || chemin.indexOf(basePath + '/') === 0)) {
            chemin = chemin.slice(basePath.length);
        }
        const segments = chemin.split('/').filter(Boolean);
        const premier = segments[0] || '';
        if (premier === 'referentiels') { return segments[1] || 'clients'; }
        if (premier === 'demandes-materiel') { return 'demandes_materiel'; }
        if (premier === 'rapports-journaliers') { return 'rapports_journaliers'; }
        if (premier === 'devis') { return 'devis'; }
        if (premier === 'factures') { return 'factures'; }
        return premier.replace(/-/g, '_');
    }

    function filtresCourants() {
        const filtres = {};
        const recherche = document.getElementById('recherche') || document.getElementById('recherche-stock');
        if (recherche && recherche.value.trim() !== '') {
            filtres.recherche = recherche.value.trim();
        }
        document.querySelectorAll('[id^="filtre-"]').forEach(function (champ) {
            if (champ.value !== '') {
                const cle = champ.id.replace('filtre-', '').replace(/-/g, '_');
                filtres[cle === 'chantier' ? 'chantier_id' : cle] = champ.value;
            }
        });
        ['chantier_id', 'date_debut', 'date_fin', 'categorie', 'annee'].forEach(function (cle) {
            const champ = document.querySelector('[name="' + cle + '"]');
            if (champ && champ.value) { filtres[cle] = champ.value; }
        });
        return filtres;
    }

    function nomDepuisEntete(reponse, defaut) {
        const disposition = reponse.headers.get('Content-Disposition') || '';
        const match = /filename="?([^";]+)"?/i.exec(disposition);
        return match ? match[1] : defaut;
    }

    function telechargerBlob(blob, nomFichier) {
        const url = URL.createObjectURL(blob);
        const lien = document.createElement('a');
        lien.href = url;
        lien.download = nomFichier;
        document.body.appendChild(lien);
        lien.click();
        document.body.removeChild(lien);
        setTimeout(function () { URL.revokeObjectURL(url); }, 60000);
    }

    function ouvrirPDFDansNouvelOnglet(url, donnees) {
        const formulaire = document.createElement('form');
        formulaire.method = 'POST';
        formulaire.action = url;
        formulaire.target = '_blank';
        formulaire.hidden = true;
        Object.keys(donnees).forEach(function (cle) {
            const champ = document.createElement('input');
            champ.type = 'hidden';
            champ.name = cle;
            champ.value = typeof donnees[cle] === 'string' ? donnees[cle] : JSON.stringify(donnees[cle]);
            formulaire.appendChild(champ);
        });
        document.body.appendChild(formulaire);
        formulaire.submit();
        formulaire.remove();
    }

    async function erreurLisible(reponse) {
        try {
            const json = await reponse.clone().json();
            return json.message || 'Erreur lors de l\'export.';
        } catch (e) {
            return 'Erreur lors de l\'export.';
        }
    }

    /**
     * @param {'pdf'|'excel'|'xlsx'|'csv'} format
     * @param {string} [module]
     * @param {object} [filtres]
     */
    async function exporter(format, module, filtres) {
        module = module || moduleCourant();
        filtres = filtres || filtresCourants();
        if (!module) { alert('Module d\'export introuvable.'); return; }

        const type = String(format || 'pdf').toLowerCase();
        const formats = {
            pdf: { endpoint: '/api/v1/export/pdf', extension: 'pdf' },
            excel: { endpoint: '/api/v1/export/xlsx', extension: 'xlsx' },
            xlsx: { endpoint: '/api/v1/export/xlsx', extension: 'xlsx' },
            csv: { endpoint: '/api/v1/export/csv', extension: 'csv' }
        };
        const exportFormat = formats[type];
        if (!exportFormat) {
            alert('Format d\'export non pris en charge.');
            return;
        }
        const nomDefaut = 'export_' + module + '.' + exportFormat.extension;

        if (type === 'pdf') {
            ouvrirPDFDansNouvelOnglet(
                base + '/export/pdf/' + encodeURIComponent(module),
                { filtres: filtres }
            );
            return;
        }

        try {
            const reponse = await Auth.api(exportFormat.endpoint, {
                method: 'POST',
                body: { module: module, filtres: filtres }
            });
            if (!reponse.ok) {
                alert(await erreurLisible(reponse));
                return;
            }

            const blob = await reponse.blob();
            telechargerBlob(blob, nomDepuisEntete(reponse, nomDefaut));
        } catch (e) {
            alert('Erreur reseau lors de l\'export.');
        }
    }

    async function exporterRapportFinancier(format, filtres) {
        filtres = filtres || filtresCourants();
        const type = String(format || 'pdf').toLowerCase();
        if (type === 'pdf') {
            ouvrirPDFDansNouvelOnglet(base + '/export/rapport-financier/pdf', { filtres: filtres });
            return;
        }
        const endpoint = type === 'pdf'
            ? '/api/v1/export/rapport-financier-pdf'
            : '/api/v1/export/rapport-financier-xlsx';
        const nomDefaut = 'rapport_financier.' + (type === 'pdf' ? 'pdf' : 'xlsx');

        try {
            const reponse = await Auth.api(endpoint, { method: 'POST', body: { filtres: filtres } });
            if (!reponse.ok) {
                alert(await erreurLisible(reponse));
                return;
            }
            const blob = await reponse.blob();
            telechargerBlob(blob, nomDepuisEntete(reponse, nomDefaut));
        } catch (e) {
            alert('Erreur reseau lors de l\'export.');
        }
    }

    async function exporterDevisPDF(id) {
        ouvrirPDFDansNouvelOnglet(base + '/export/devis/' + encodeURIComponent(id) + '/pdf', {});
    }

    window.exporter = exporter;
    window.exporterRapportFinancier = exporterRapportFinancier;
    window.exporterDevisPDF = exporterDevisPDF;
})();
