/* Utilitaires de formatage partages (Ariary, dates, echappement HTML). */
window.Format = {
    ariary: function (v) {
        if (v === null || v === undefined || v === '') { return '—'; }
        return Number(v).toLocaleString('fr-FR').replace(/ /g, ' ') + ' Ar';
    },
    date: function (d) {
        if (!d) { return '—'; }
        const p = String(d).substring(0, 10).split('-');
        return p.length === 3 ? p[2] + '/' + p[1] + '/' + p[0] : d;
    },
    echapper: function (t) {
        const div = document.createElement('div');
        div.textContent = (t === null || t === undefined) ? '' : String(t);
        return div.innerHTML;
    }
};
