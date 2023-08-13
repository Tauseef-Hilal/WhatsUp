import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> samples;
  final double maxHeight;
  final Color Function(int) colorGetter;

  WaveformPainter({
    required this.samples,
    required this.maxHeight,
    required this.colorGetter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const lineWidth = 3.0;
    const lineSpacing = 2.0;
    const cornerRadius = 1.0;
    final verticalCenter = size.height / 2;

    final paint = Paint()..strokeWidth = lineWidth;
    double xPos = size.width - lineWidth - 6;

    for (int index = samples.length - 1; index > 0; index--) {
      double height = samples[index] * 2 / 120 * maxHeight;

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
        const Radius.circular(cornerRadius),
      );

      canvas.drawRRect(rect, paint..color = colorGetter(index));
      xPos -= lineSpacing + lineWidth;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
