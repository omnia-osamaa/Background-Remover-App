import 'package:flutter/material.dart';

import '../../../../core/widgets/checkerboard.dart';
import '../../../../core/widgets/local_image.dart';
import '../cubit/editor_cubit.dart';
import 'editor_palette.dart';

/// Builds a color filter that applies brightness, contrast and saturation.
ColorFilter buildAdjustFilter({
  required double brightness,
  required double contrast,
  required double saturation,
}) {
  const lr = 0.2126;
  const lg = 0.7152;
  const lb = 0.0722;
  final s = saturation;

  final sat = <double>[
    lr * (1 - s) + s, lg * (1 - s), lb * (1 - s), 0, 0,
    lr * (1 - s), lg * (1 - s) + s, lb * (1 - s), 0, 0,
    lr * (1 - s), lg * (1 - s), lb * (1 - s) + s, 0, 0,
    0, 0, 0, 1, 0,
  ];

  final t = 128 * (1 - contrast);
  final con = <double>[
    contrast, 0, 0, 0, t,
    0, contrast, 0, 0, t,
    0, 0, contrast, 0, t,
    0, 0, 0, 1, 0,
  ];

  final o = brightness * 255;
  final bri = <double>[
    1, 0, 0, 0, o,
    0, 1, 0, 0, o,
    0, 0, 1, 0, o,
    0, 0, 0, 1, 0,
  ];

  return ColorFilter.matrix(_multiply(bri, _multiply(con, sat)));
}

/// Returns the matrix that applies [b] first and then [a].
List<double> _multiply(List<double> a, List<double> b) {
  final result = List<double>.filled(20, 0);
  for (var i = 0; i < 4; i++) {
    for (var j = 0; j < 5; j++) {
      var v = 0.0;
      for (var k = 0; k < 4; k++) {
        v += a[i * 5 + k] * b[k * 5 + j];
      }
      if (j == 4) v += a[i * 5 + 4];
      result[i * 5 + j] = v;
    }
  }
  return result;
}

class EditorCanvas extends StatelessWidget {
  final EditorState state;
  final String imagePath;
  final GlobalKey boundaryKey;

  const EditorCanvas({
    super.key,
    required this.state,
    required this.imagePath,
    required this.boundaryKey,
  });

  Widget _background() {
    switch (state.backgroundType) {
      case BackgroundType.transparent:
        return state.exporting ? const SizedBox.expand() : const Checkerboard();
      case BackgroundType.color:
        return ColoredBox(color: kEditorColors[state.colorIndex]);
      case BackgroundType.gradient:
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: kEditorGradients[state.gradientIndex],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      case BackgroundType.photo:
        final path = state.photoPath;
        if (path == null) return const Checkerboard();
        return LocalImage(path: path, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(state.exporting ? 0 : 20),
      child: RepaintBoundary(
        key: boundaryKey,
        child: AspectRatio(
          aspectRatio: state.cropRatio.ratio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _background(),
              ColorFiltered(
                colorFilter: buildAdjustFilter(
                  brightness: state.brightness,
                  contrast: state.contrast,
                  saturation: state.saturation,
                ),
                child: LocalImage(path: imagePath, fit: BoxFit.cover),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
