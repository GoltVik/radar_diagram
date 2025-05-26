part of 'radar_diagram_widget.dart';

class _RadarPainter extends CustomPainter {
  final List<double> values;
  final List<double> previousValues;
  final int axes;
  final int levels;
  final Color dataFillColor;
  final Color dataBorderColor;
  final double dataBorderWidth;
  final Color gridBorderColor;
  final double gridBorderWidth;
  final double outerGridBorderWidth;
  final Color axisLineColor;
  final double axisLineWidth;
  final double curveRadiusFraction;
  final Color backgroundColor;
  final Animation<double> animation;

  _RadarPainter({
    required this.values,
    required this.previousValues,
    required this.axes,
    required this.levels,
    required this.dataFillColor,
    required this.dataBorderColor,
    required this.dataBorderWidth,
    required this.gridBorderColor,
    required this.gridBorderWidth,
    required this.outerGridBorderWidth,
    required this.axisLineColor,
    required this.axisLineWidth,
    required this.curveRadiusFraction,
    required this.backgroundColor,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Variables to store the outermost polygon points and corner radius
    List<Offset> outermostPolygonPoints;
    double outermostCornerRadius;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.9;
    final angle = (2 * math.pi) / axes;

    // Calculate points for the outermost polygon to determine min side length
    final outerPoints = List.generate(axes, (i) {
      final x = center.dx + radius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + radius * math.sin(angle * i - math.pi / 2);
      return Offset(x, y);
    });
    double minSideLength = double.infinity;
    for (int i = 0; i < axes; i++) {
      final a = outerPoints[i];
      final b = outerPoints[(i + 1) % axes];
      final d = (a - b).distance;
      if (d < minSideLength) minSideLength = d;
    }
    final double cornerRadius = minSideLength * curveRadiusFraction;

    // Calculate outermost polygon points and corner radius first
    final r = radius * levels / levels; // r == radius
    outermostPolygonPoints = List.generate(axes, (i) {
      final x = center.dx + r * math.cos(angle * i - math.pi / 2);
      final y = center.dy + r * math.sin(angle * i - math.pi / 2);
      return Offset(x, y);
    });
    outermostCornerRadius = cornerRadius;

    // Fill background using the outermost polygon
    {
      final outerPolygonPath = _roundedPolygonPath(
        outermostPolygonPoints,
        outermostCornerRadius,
      );
      canvas.drawPath(
        outerPolygonPath,
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill,
      );
    }

    // Draw grid (background) polygons
    for (int l = 1; l <= levels; l++) {
      final r = radius * l / levels;
      final gridPoints = List.generate(axes, (i) {
        final x = center.dx + r * math.cos(angle * i - math.pi / 2);
        final y = center.dy + r * math.sin(angle * i - math.pi / 2);
        return Offset(x, y);
      });
      final gridPath = _roundedPolygonPath(gridPoints, cornerRadius);
      canvas.drawPath(
        gridPath,
        Paint()
          ..color = gridBorderColor.withAlpha(0.5.alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (l == levels)
              ? outerGridBorderWidth
              : gridBorderWidth,
      );
    }

    // Draw axes (lines from center to vertices)
    for (int i = 0; i < axes; i++) {
      final x = center.dx + radius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + radius * math.sin(angle * i - math.pi / 2);
      canvas.drawLine(
        center,
        Offset(x, y),
        Paint()
          ..color = axisLineColor
          ..strokeWidth = axisLineWidth,
      );
    }

    // Draw data polygon
    final dataPoints = List.generate(axes, (i) {
      final interpolatedValue = Tween<double>(
        begin: previousValues.isNotEmpty ? previousValues[i] : values[i],
        end: values[i],
      ).evaluate(animation);
      final value = interpolatedValue * radius;
      final x = center.dx + value * math.cos(angle * i - math.pi / 2);
      final y = center.dy + value * math.sin(angle * i - math.pi / 2);
      return Offset(x, y);
    });
    final dataPath = _roundedPolygonPath(dataPoints, cornerRadius);
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = dataFillColor.withAlpha(0.5.alpha)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = dataBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = dataBorderWidth,
    );
  }

  /// Returns a path for a polygon with rounded corners.
  Path _roundedPolygonPath(List<Offset> points, double cornerRadius) {
    final path = Path();
    if (points.isEmpty) return path;
    for (int i = 0; i < points.length; i++) {
      final prev = points[(i - 1 + points.length) % points.length];
      final curr = points[i];
      final next = points[(i + 1) % points.length];
      final v1 = (curr - prev);
      final v2 = (next - curr);
      final v1n = v1 / v1.distance;
      final v2n = v2 / v2.distance;
      final start = curr - v1n * cornerRadius;
      final end = curr + v2n * cornerRadius;
      if (i == 0) {
        path.moveTo(start.dx, start.dy);
      } else {
        path.lineTo(start.dx, start.dy);
      }
      path.quadraticBezierTo(curr.dx, curr.dy, end.dx, end.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
