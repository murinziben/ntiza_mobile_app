import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// NTIZA mark + wordmark. [light] is the white variant used on photos/dark heroes.
class NtizaLogo extends StatelessWidget {
  const NtizaLogo({super.key, this.light = false});

  final bool light;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: light ? const Color(0x26FFFFFF) : AppColors.green,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const CustomPaint(size: Size(28, 28), painter: _LeafPainter()),
        ),
        const SizedBox(width: 9),
        Text(
          'NTIZA',
          style: TextStyle(
            color: light ? AppColors.white : AppColors.greenDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Leaf glyph, ported from the prototype's 40x40 SVG paths.
class _LeafPainter extends CustomPainter {
  const _LeafPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 40, size.height / 40);
    final paint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final leaf = Path()
      ..moveTo(7, 28)
      ..relativeCubicTo(7, -1, 11, -5, 13, -14)
      ..relativeCubicTo(7, 3, 11, 9, 10, 18)
      ..relativeCubicTo(-8, 2, -17, 0, -23, -4)
      ..close();
    final stem = Path()
      ..moveTo(20, 14)
      ..relativeCubicTo(-1, 9, 1, 15, 6, 20);

    canvas.drawPath(leaf, paint);
    canvas.drawPath(stem, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
