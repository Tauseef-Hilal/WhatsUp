import 'dart:math';

import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatefulWidget {
  final double value;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  const CustomProgressIndicator({
    super.key,
    this.strokeWidth = 3,
    required this.value,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  State<CustomProgressIndicator> createState() =>
      _CustomProgressIndicatorState();
}

class _CustomProgressIndicatorState extends State<CustomProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..forward();
    _animation = Tween(begin: 0.0, end: 0.0).animate(_animationController);
  }

  @override
  void didUpdateWidget(covariant CustomProgressIndicator old) {
    super.didUpdateWidget(old);
    _animationController.stop();
    _animation = Tween(begin: old.value, end: widget.value)
        .animate(_animationController);
    _animationController
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          return ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 36.0,
              minHeight: 36.0,
            ),
            child: CustomPaint(
              painter: CircularProgressBarPainter(
                value: _animation.value,
                progressColor: widget.progressColor,
                trackColor: widget.trackColor,
                strokeWidth: widget.strokeWidth,
              ),
            ),
          );
        });
  }
}

class CircularProgressBarPainter extends CustomPainter {
  final double value;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  CircularProgressBarPainter({
    required this.value,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw the track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // Draw the progress
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start angle at the top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
