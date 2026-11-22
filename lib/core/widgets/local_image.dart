import 'dart:io';

import 'package:flutter/material.dart';

/// Image.file with a graceful fallback when the file is missing.
class LocalImage extends StatelessWidget {
  final String path;
  final BoxFit fit;

  const LocalImage({super.key, required this.path, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 36,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
      ),
    );
  }
}
