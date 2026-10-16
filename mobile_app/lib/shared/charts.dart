import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Palette des graphiques, alignee sur celle du back-office web (assets/js/charts.js).
const chartPalette = <Color>[
  Color(0xFF2C6EA4),
  Color(0xFF2F9E6F),
  Color(0xFFD99A2B),
  Color(0xFFCF5454),
  Color(0xFF7C5CBC),
  Color(0xFF2F8F9E),
  Color(0xFFC2528B),
  Color(0xFF5A8F3A),
];

Color chartColor(int index) => chartPalette[index % chartPalette.length];

/// Serie d'un graphique en aires : facturé, encaissé, etc.
class ChartSeries {
  const ChartSeries({required this.name, required this.color, required this.values});

  final String name;
  final Color color;
  final List<double> values;
}

/// Segment de graphique en anneau.
class DonutSegment {
  const DonutSegment({required this.name, required this.value});

  final String name;
  final double value;
}

/// Abrège un montant pour les axes : 1,2 M / 340 k / 900.
String compactNumber(num value) {
  final nombre = value.toDouble();
  if (nombre.abs() >= 1e9) {
    return '${(nombre / 1e9).toStringAsFixed(1).replaceAll('.', ',')} Md';
  }
  if (nombre.abs() >= 1e6) {
    return '${(nombre / 1e6).round()} M';
  }
  if (nombre.abs() >= 1e3) {
    return '${(nombre / 1e3).round()} k';
  }
  return nombre.round().toString();
}

/// Courbe en aires (une ou plusieurs series), equivalent mobile de `Charts.aire`.
class AreaChart extends StatefulWidget {
  const AreaChart({
    required this.labels,
    required this.series,
    this.height = 190,
    this.valueFormatter,
    super.key,
  });

  final List<String> labels;
  final List<ChartSeries> series;
  final double height;
  final String Function(double value)? valueFormatter;

  @override
  State<AreaChart> createState() => _AreaChartState();
}

class _AreaChartState extends State<AreaChart> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    if (widget.series.isEmpty || widget.labels.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text('Aucune donnée.', style: TextStyle(color: AppColors.muted)),
        ),
      );
    }
    final format = widget.valueFormatter ?? compactNumber;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selected != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.series
                  .map(
                    (serie) =>
                        '${serie.name} : ${format(serie.values[_selected!])}',
                  )
                  .join('   ·   '),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => _select(
                  details.localPosition.dx,
                  constraints.maxWidth,
                ),
                onHorizontalDragUpdate: (details) => _select(
                  details.localPosition.dx,
                  constraints.maxWidth,
                ),
                onHorizontalDragEnd: (_) => setState(() => _selected = null),
                onTapCancel: () => setState(() => _selected = null),
                child: CustomPaint(
                  size: Size(constraints.maxWidth, widget.height),
                  painter: _AreaPainter(
                    labels: widget.labels,
                    series: widget.series,
                    selected: _selected,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _select(double dx, double width) {
    const marge = 46.0;
    final utile = math.max(1.0, width - marge - 14);
    final ratio = ((dx - marge) / utile).clamp(0.0, 1.0);
    final index = widget.labels.length == 1
        ? 0
        : (ratio * (widget.labels.length - 1)).round();
    setState(() => _selected = index.clamp(0, widget.labels.length - 1));
  }
}

class _AreaPainter extends CustomPainter {
  _AreaPainter({required this.labels, required this.series, this.selected});

  final List<String> labels;
  final List<ChartSeries> series;
  final int? selected;

  static const _gauche = 46.0;
  static const _droite = 14.0;
  static const _haut = 12.0;
  static const _bas = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    final largeur = size.width - _gauche - _droite;
    final hauteur = size.height - _haut - _bas;
    if (largeur <= 0 || hauteur <= 0) return;

    var maximum = 0.0;
    for (final serie in series) {
      for (final valeur in serie.values) {
        if (valeur > maximum) maximum = valeur;
      }
    }
    maximum = _joli(maximum);

    double x(int index) => labels.length <= 1
        ? _gauche + largeur / 2
        : _gauche + largeur * index / (labels.length - 1);
    double y(double valeur) =>
        _haut + hauteur - (maximum == 0 ? 0 : valeur / maximum * hauteur);

    final grille = Paint()
      ..color = const Color(0xFFE5E9E2)
      ..strokeWidth = 1;
    for (var pas = 0; pas <= 4; pas++) {
      final valeur = maximum * pas / 4;
      final position = y(valeur);
      canvas.drawLine(Offset(_gauche, position), Offset(_gauche + largeur, position), grille);
      _texte(
        canvas,
        compactNumber(valeur),
        Offset(_gauche - 6, position),
        const TextStyle(fontSize: 9, color: AppColors.muted),
        align: TextAlign.right,
        anchor: _Anchor.milieuDroite,
      );
    }

    labels.asMap().forEach((index, libelle) {
      _texte(
        canvas,
        libelle,
        Offset(x(index), size.height - _bas + 6),
        TextStyle(
          fontSize: 9,
          color: selected == index ? AppColors.ink : AppColors.muted,
          fontWeight: selected == index ? FontWeight.w800 : FontWeight.w500,
        ),
        anchor: _Anchor.hautCentre,
      );
    });

    for (final serie in series) {
      final points = <Offset>[
        for (var index = 0; index < labels.length; index++)
          Offset(x(index), y(index < serie.values.length ? serie.values[index] : 0)),
      ];
      final courbe = _lisse(points);
      final aire = Path.from(courbe)
        ..lineTo(points.last.dx, y(0))
        ..lineTo(points.first.dx, y(0))
        ..close();
      canvas.drawPath(
        aire,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [serie.color.withValues(alpha: .30), serie.color.withValues(alpha: 0)],
          ).createShader(Rect.fromLTWH(0, _haut, size.width, hauteur)),
      );
      canvas.drawPath(
        courbe,
        Paint()
          ..color = serie.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
      points.asMap().forEach((index, point) {
        final actif = selected == index;
        canvas.drawCircle(
          point,
          actif ? 5 : 3.2,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          point,
          actif ? 5 : 3.2,
          Paint()
            ..color = serie.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      });
    }
  }

  static double _joli(double valeur) {
    if (valeur <= 0) return 1;
    final exposant = math.pow(10, (math.log(valeur) / math.ln10).floor()).toDouble();
    final fraction = valeur / exposant;
    final arrondi = fraction <= 1
        ? 1.0
        : fraction <= 2
        ? 2.0
        : fraction <= 2.5
        ? 2.5
        : fraction <= 5
        ? 5.0
        : 10.0;
    return arrondi * exposant;
  }

  /// Courbe lisse (Catmull-Rom converti en segments de Bezier cubiques).
  static Path _lisse(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points.first.dx, points.first.dy);
    if (points.length == 1) return path;
    for (var index = 0; index < points.length - 1; index++) {
      final p0 = index == 0 ? points[index] : points[index - 1];
      final p1 = points[index];
      final p2 = points[index + 1];
      final p3 = index + 2 < points.length ? points[index + 2] : p2;
      path.cubicTo(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
        p2.dx,
        p2.dy,
      );
    }
    return path;
  }

  void _texte(
    Canvas canvas,
    String valeur,
    Offset position,
    TextStyle style, {
    TextAlign align = TextAlign.left,
    _Anchor anchor = _Anchor.gauche,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: valeur, style: style),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (anchor) {
      _Anchor.gauche => position.dx,
      _Anchor.hautCentre => position.dx - painter.width / 2,
      _Anchor.milieuDroite => position.dx - painter.width,
    };
    final dy = switch (anchor) {
      _Anchor.gauche => position.dy,
      _Anchor.hautCentre => position.dy,
      _Anchor.milieuDroite => position.dy - painter.height / 2,
    };
    painter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(_AreaPainter oldDelegate) =>
      oldDelegate.selected != selected ||
      oldDelegate.labels != labels ||
      oldDelegate.series != series;
}

enum _Anchor { gauche, hautCentre, milieuDroite }

/// Anneau de repartition avec legende, equivalent mobile de `Charts.donut`.
class DonutChart extends StatelessWidget {
  const DonutChart({
    required this.segments,
    this.centerLabel,
    this.centerSubLabel,
    this.valueFormatter,
    super.key,
  });

  final List<DonutSegment> segments;
  final String? centerLabel;
  final String? centerSubLabel;
  final String Function(double value)? valueFormatter;

  @override
  Widget build(BuildContext context) {
    final visibles = segments
        .where((segment) => segment.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final format = valueFormatter ?? compactNumber;
    if (visibles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Text(
            'Aucune donnée à représenter.',
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      );
    }
    final total = visibles
        .map((segment) => segment.value)
        .reduce((a, b) => a + b);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 132,
          height: 132,
          child: CustomPaint(
            painter: _DonutPainter(segments: visibles, total: total),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerLabel ?? format(total),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  if (centerSubLabel != null)
                    Text(
                      centerSubLabel!,
                      style: const TextStyle(fontSize: 10, color: AppColors.muted),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < visibles.length && index < 6; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: chartColor(index),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          visibles[index].name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        format(visibles[index].value),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments, required this.total});

  final List<DonutSegment> segments;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final rayon = math.min(size.width, size.height) / 2 - 14;
    final circonference = 2 * math.pi * rayon;
    var offset = 0.0;
    for (var index = 0; index < segments.length; index++) {
      final fraction = total == 0 ? 0.0 : segments[index].value / total;
      final longueur = fraction * circonference;
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: rayon),
        -math.pi / 2 + offset / rayon,
        longueur / rayon,
        false,
        Paint()
          ..color = chartColor(index)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20
          ..strokeCap = StrokeCap.butt,
      );
      offset += longueur;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) => oldDelegate.segments != segments;
}

/// Legende d'une serie de graphique.
class ChartLegend extends StatelessWidget {
  const ChartLegend({required this.series, super.key});

  final List<ChartSeries> series;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 14,
    runSpacing: 6,
    children: [
      for (final serie in series)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: serie.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 5),
            Text(serie.name, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ),
    ],
  );
}

