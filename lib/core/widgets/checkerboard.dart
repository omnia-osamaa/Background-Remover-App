import 'package:flutter/material.dart';

/// Classic transparency grid. Must be placed in a bounded area.
class Checkerboard extends StatelessWidget {
  final Widget? child;
  final double cell;

  const Checkerboard({super.key, this.child, this.cell = 12});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _CheckerPainter(
              cell: cell,
              a: dark ? const Color(0xFF2A2940) : const Color(0xFFFFFFFF),
              b: dark ? const Color(0xFF1F1E33) : const Color(0xFFE6E4F2),
            ),
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}

class _CheckerPainter extends CustomPainter {
  final double cell;
  final Color a;
  final Color b;

  _CheckerPainter({required this.cell, required this.a, required this.b});

  @override
  void paint(Canvas canvas, Size size) {
    final paintA = Paint()..color = a;
    final paintB = Paint()..color = b;
    canvas.drawRect(Offset.zero & size, paintA);
    final cols = (size.width / cell).ceil();
    final rows = (size.height / cell).ceil();
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if ((r + c).isOdd) {
          canvas.drawRect(
            Rect.fromLTWH(c * cell, r * cell, cell, cell),
            paintB,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CheckerPainter old) =>
      old.cell != cell || old.a != a || old.b != b;
}
