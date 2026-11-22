import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Drag the handle to compare [before] (left) and [after] (right).
class BeforeAfterSlider extends StatefulWidget {
  final Widget before;
  final Widget after;

  const BeforeAfterSlider({
    super.key,
    required this.before,
    required this.after,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _position = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final x = width * _position;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) {
            setState(() {
              _position =
                  (_position + details.delta.dx / width).clamp(0.0, 1.0).toDouble();
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.after,
              ClipRect(
                clipper: _LeftClipper(x),
                child: widget.before,
              ),
              Positioned(
                left: x - 1.5,
                top: 0,
                bottom: 0,
                child: Container(width: 3, color: Colors.white),
              ),
              Positioned(
                left: x - 20,
                top: height / 2 - 20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.swap_horiz_rounded,
                      color: AppColors.primary),
                ),
              ),
              const Positioned(
                left: 12,
                top: 12,
                child: _Tag('Before'),
              ),
              const Positioned(
                right: 12,
                top: 12,
                child: _Tag('After'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LeftClipper extends CustomClipper<Rect> {
  final double width;
  _LeftClipper(this.width);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, width, size.height);

  @override
  bool shouldReclip(covariant _LeftClipper oldClipper) =>
      oldClipper.width != width;
}
