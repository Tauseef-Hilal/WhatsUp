import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> samples;
  final double maxHeight;
  final Color waveColor;
  final bool reverse;

  final lineWidth = 3.0;
  final lineSpacing = 2.0;
  final cornerRadius = 1.0;

  WaveformPainter({
    required this.samples,
    required this.maxHeight,
    required this.waveColor,
    this.reverse = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = lineWidth
      ..color = waveColor;

    if (reverse) {
      _paintInReverse(canvas, paint, size.width);
    } else {
      _paint(canvas, paint);
    }
  }

  void _paint(Canvas canvas, Paint paint) {
    double xPos = 0;
    for (final sample in samples) {
      _drawRectForSample(sample, xPos, canvas, paint);
      xPos += lineWidth + lineSpacing;
    }
  }

  void _paintInReverse(Canvas canvas, Paint paint, double width) {
    double xPos = width - lineWidth;
    for (final sample in samples.reversed) {
      _drawRectForSample(sample, xPos, canvas, paint);
      xPos -= lineWidth + lineSpacing;
    }
  }

  void _drawRectForSample(
    double sample,
    double xPos,
    Canvas canvas,
    Paint paint,
  ) {
    final verticalCenter = maxHeight / 2;
    double height = sample * 2 / 120 * maxHeight;

    if (height < 2) {
      height = 2;
    } else if (height > maxHeight) {
      height = maxHeight;
    }

    final double x1 = xPos;
    final double y1 = verticalCenter - height / 2;

    final double x2 = x1 + lineWidth;
    final double y2 = verticalCenter + height / 2;

    final RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTRB(x1, y1, x2, y2),
      Radius.circular(cornerRadius),
    );

    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
