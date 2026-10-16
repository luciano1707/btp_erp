/* =========================================================
   Digital Chantier - Mini-bibliotheque de graphiques SVG
   Sans dependance. Courbes en aires + donuts.
   Usage : Charts.aire(el, {labels, series, format})
           Charts.donut(el, {segments, format, sousLibelle})
   ========================================================= */
window.Charts = (function () {
    'use strict';

    const PALETTE = ['#2c6ea4', '#2f9e6f', '#d99a2b', '#cf5454', '#7c5cbf', '#2f8f9e', '#c2528b', '#5a8f3a'];
    let compteur = 0;

    function echap(t) {
        return String(t == null ? '' : t).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    // Format compact pour les axes (60 M, 1,8 Md...)
    function compact(v) {
        v = Number(v);
        if (v >= 1e9) { return (v / 1e9).toFixed(v % 1e9 ? 1 : 0).replace('.', ',') + ' Md'; }
        if (v >= 1e6) { return Math.round(v / 1e6) + ' M'; }
        if (v >= 1e3) { return Math.round(v / 1e3) + ' k'; }
        return String(Math.round(v));
    }

    function maxJoli(v) {
        if (v <= 0) { return 1; }
        const exp = Math.pow(10, Math.floor(Math.log10(v)));
        const f = v / exp;
        let nf;
        if (f <= 1) { nf = 1; } else if (f <= 2) { nf = 2; } else if (f <= 2.5) { nf = 2.5; }
        else if (f <= 5) { nf = 5; } else { nf = 10; }
        return nf * exp;
    }

    // Courbe lisse (Catmull-Rom -> Bezier)
    function lisse(P) {
        if (P.length === 0) { return ''; }
        if (P.length === 1) { return 'M ' + P[0].x + ' ' + P[0].y; }
        let d = 'M ' + P[0].x + ' ' + P[0].y;
        for (let i = 0; i < P.length - 1; i++) {
            const p0 = P[i - 1] || P[i], p1 = P[i], p2 = P[i + 1], p3 = P[i + 2] || p2;
            const c1x = p1.x + (p2.x - p0.x) / 6, c1y = p1.y + (p2.y - p0.y) / 6;
            const c2x = p2.x - (p3.x - p1.x) / 6, c2y = p2.y - (p3.y - p1.y) / 6;
            d += ' C ' + c1x + ' ' + c1y + ' ' + c2x + ' ' + c2y + ' ' + p2.x + ' ' + p2.y;
        }
        return d;
    }

    /** Graphique en aires (une ou plusieurs series). */
    function aire(conteneur, opts) {
        if (!conteneur) { return; }
        const labels = opts.labels || [];
        const series = opts.series || [];
        const format = opts.format || function (v) { return v; };
        const formatAxe = opts.formatAxe || compact;
        const W = 660, H = 280, m = { t: 16, r: 18, b: 34, l: 52 };
        const iw = W - m.l - m.r, ih = H - m.t - m.b;

        let max = 0;
        series.forEach(function (s) { s.valeurs.forEach(function (v) { if (v > max) { max = v; } }); });
        max = maxJoli(max);
        const n = labels.length;
        const X = function (i) { return m.l + (n <= 1 ? iw / 2 : iw * i / (n - 1)); };
        const Y = function (v) { return m.t + ih - (max ? (v / max) * ih : 0); };

        let grid = '';
        const pas = 4;
        for (let g = 0; g <= pas; g++) {
            const val = max * g / pas, gy = Y(val);
            grid += '<line x1="' + m.l + '" y1="' + gy + '" x2="' + (m.l + iw) + '" y2="' + gy + '" class="c-grid"/>';
            grid += '<text x="' + (m.l - 8) + '" y="' + (gy + 4) + '" class="c-ylabel">' + echap(formatAxe(val)) + '</text>';
        }
        let xlab = '';
        labels.forEach(function (l, i) { xlab += '<text x="' + X(i) + '" y="' + (H - 12) + '" class="c-xlabel">' + echap(l) + '</text>'; });

        let defs = '', paths = '', pts = '';
        const base = ++compteur;
        series.forEach(function (s, si) {
            const P = s.valeurs.map(function (v, i) { return { x: X(i), y: Y(v) }; });
            const d = lisse(P);
            const aireP = d + ' L ' + X(n - 1) + ' ' + Y(0) + ' L ' + X(0) + ' ' + Y(0) + ' Z';
            const gid = 'grad' + base + '_' + si;
            defs += '<linearGradient id="' + gid + '" x1="0" y1="0" x2="0" y2="1">' +
                '<stop offset="0%" stop-color="' + s.couleur + '" stop-opacity="0.30"/>' +
                '<stop offset="100%" stop-color="' + s.couleur + '" stop-opacity="0"/></linearGradient>';
            paths += '<path d="' + aireP + '" fill="url(#' + gid + ')"/>';
            paths += '<path d="' + d + '" fill="none" stroke="' + s.couleur + '" stroke-width="2.5" stroke-linejoin="round" stroke-linecap="round" class="c-ligne"/>';
            P.forEach(function (p, i) {
                pts += '<circle cx="' + p.x + '" cy="' + p.y + '" r="3.5" fill="#fff" stroke="' + s.couleur + '" stroke-width="2">' +
                    '<title>' + echap(s.nom) + ' · ' + echap(labels[i]) + ' : ' + echap(format(s.valeurs[i])) + '</title></circle>';
            });
        });

        conteneur.innerHTML = '<svg viewBox="0 0 ' + W + ' ' + H + '" class="c-svg" preserveAspectRatio="xMidYMid meet">' +
            '<defs>' + defs + '</defs>' + grid + paths + pts + xlab + '</svg>';
    }

    /** Donut (camembert evide) avec legende. */
    function donut(conteneur, opts) {
        if (!conteneur) { return; }
        const segments = (opts.segments || []).filter(function (s) { return Number(s.valeur) > 0; });
        const format = opts.format || function (v) { return v; };
        const total = segments.reduce(function (a, s) { return a + Number(s.valeur); }, 0);
        const size = 220, r = 82, sw = 26, C = 2 * Math.PI * r, cx = size / 2, cy = size / 2;

        let off = 0, arcs = '';
        segments.forEach(function (s) {
            const frac = total ? Number(s.valeur) / total : 0, len = frac * C;
            arcs += '<circle cx="' + cx + '" cy="' + cy + '" r="' + r + '" fill="none" stroke="' + s.couleur + '" stroke-width="' + sw +
                '" stroke-dasharray="' + len + ' ' + (C - len) + '" stroke-dashoffset="' + (-off) + '" transform="rotate(-90 ' + cx + ' ' + cy + ')" class="c-arc">' +
                '<title>' + echap(s.nom) + ' : ' + echap(format(Number(s.valeur))) + ' (' + Math.round(frac * 100) + '%)</title></circle>';
            off += len;
        });
        if (!arcs) {
            arcs = '<circle cx="' + cx + '" cy="' + cy + '" r="' + r + '" fill="none" stroke="#e5eaf1" stroke-width="' + sw + '"/>';
        }
        const centre = opts.libelleCentre != null ? opts.libelleCentre : format(total);
        const svg = '<svg viewBox="0 0 ' + size + ' ' + size + '" class="c-donut">' + arcs +
            '<text x="' + cx + '" y="' + (cy - 2) + '" class="c-donut-total">' + echap(centre) + '</text>' +
            '<text x="' + cx + '" y="' + (cy + 16) + '" class="c-donut-sub">' + echap(opts.sousLibelle || '') + '</text></svg>';

        const legende = '<ul class="c-legende">' + segments.map(function (s) {
            return '<li><span class="c-pastille" style="background:' + s.couleur + '"></span>' +
                '<span class="c-leg-nom">' + echap(s.nom) + '</span><strong>' + echap(format(Number(s.valeur))) + '</strong></li>';
        }).join('') + '</ul>';

        conteneur.innerHTML = '<div class="c-donut-wrap">' + svg + legende + '</div>';
    }

    return { aire: aire, donut: donut, PALETTE: PALETTE, couleur: function (i) { return PALETTE[i % PALETTE.length]; } };
})();
