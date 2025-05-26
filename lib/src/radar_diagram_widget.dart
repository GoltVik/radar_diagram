import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

part 'radar_diagram_painter.dart';

/// A customizable radar (spider) diagram widget.
class RadarDiagram extends StatefulWidget {
  /// The values for each axis, in the range 0..levels (inclusive).
  /// For example, if levels=5, values can be [2, 1, 4, 5, 3].
  final List<double> values;

  /// The number of axes (sides) of the radar diagram.
  final int axes;

  /// The number of concentric grid levels.
  final int levels;

  /// The color of the data polygon fill.
  final Color dataFillColor;

  /// The color of the data polygon border.
  final Color dataBorderColor;

  /// The width of the data polygon border.
  final double dataBorderWidth;

  /// The color of the grid (background) borders.
  final Color gridBorderColor;

  /// The width of the grid (background) borders.
  final double gridBorderWidth;

  /// The width of the outermost grid border.
  final double outerGridBorderWidth;

  /// The color of the axes (lines from center to vertices).
  final Color axisLineColor;

  /// The width of the axes lines.
  final double axisLineWidth;

  /// The fraction of the minimum side length used for corner rounding.
  final double curveRadiusFraction;

  /// The background color of the radar diagram.
  final Color backgroundColor;

  /// The duration of the animation when values change.
  final Duration animationDuration;

  RadarDiagram({
    super.key,
    required this.values,
    this.axes = 5,
    this.levels = 4,
    this.dataFillColor = const Color(0xFF2196F3),
    this.dataBorderWidth = 2.0,
    this.gridBorderWidth = .7,
    this.outerGridBorderWidth = 2.2,
    this.axisLineColor = Colors.transparent,
    this.axisLineWidth = 1.0,
    this.curveRadiusFraction = 0.05,
    this.animationDuration = const Duration(milliseconds: 400),
    Color? dataBorderColor,
    Color? gridBorderColor,
    Color? backgroundColor,
  }) : backgroundColor = backgroundColor ?? dataFillColor.withAlpha(0.1.alpha),
       dataBorderColor = dataBorderColor ?? dataFillColor.withAlpha(0.9.alpha),
       gridBorderColor = gridBorderColor ?? dataFillColor;

  @override
  State<RadarDiagram> createState() => _RadarDiagramState();
}

class _RadarDiagramState extends State<RadarDiagram>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<double> _values;

  // Helper method to normalize values
  List<double> _normalizeValues(List<double> values, int levels) {
    return values.map((v) => (v.clamp(0, levels)) / levels).toList();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _values = _normalizeValues(widget.values, widget.levels);

    _controller.addListener(
      () => setState(() {}), // Trigger rebuild on animation progress
    );
  }

  @override
  void didUpdateWidget(covariant RadarDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.values, widget.values)) {
      _values = _normalizeValues(oldWidget.values, oldWidget.levels);
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedValues = _normalizeValues(widget.values, widget.levels);
    return CustomPaint(
      painter: _RadarPainter(
        values: normalizedValues,
        previousValues: _values,
        axes: widget.axes,
        levels: widget.levels,
        dataFillColor: widget.dataFillColor,
        dataBorderColor: widget.dataBorderColor,
        dataBorderWidth: widget.dataBorderWidth,
        gridBorderColor: widget.gridBorderColor,
        gridBorderWidth: widget.gridBorderWidth,
        outerGridBorderWidth: widget.outerGridBorderWidth,
        axisLineColor: widget.axisLineColor,
        axisLineWidth: widget.axisLineWidth,
        curveRadiusFraction: widget.curveRadiusFraction,
        backgroundColor: widget.backgroundColor,
        animation: _animation,
      ),
    );
  }
}

/// Extension on double to easily set opacity using a fraction (0.0 to 1.0).
extension on double {
  /// Returns a new alpha int with the given opacity fraction.
  int get alpha => (clamp(0.0, 1.0) * 255).toInt();
}
