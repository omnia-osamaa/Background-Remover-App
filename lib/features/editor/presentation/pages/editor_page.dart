import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../history/domain/entities/processed_image.dart';
import '../cubit/editor_cubit.dart';
import '../widgets/editor_canvas.dart';
import '../widgets/editor_palette.dart';

class EditorPage extends StatelessWidget {
  final ProcessedImage image;
  const EditorPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EditorCubit>(),
      child: _EditorView(image: image),
    );
  }
}

class _EditorView extends StatefulWidget {
  final ProcessedImage image;
  const _EditorView({required this.image});

  @override
  State<_EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<_EditorView> {
  final GlobalKey _boundaryKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();
  int _tab = 0;
  bool _busy = false;

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.error : null,
      ));
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2500,
      );
      if (file != null && mounted) {
        context.read<EditorCubit>().setPhoto(file.path);
      }
    } catch (_) {
      _toast('Could not open the photo', error: true);
    }
  }

  /// Renders the canvas to a PNG file and returns its path.
  Future<String?> _capture() async {
    final cubit = context.read<EditorCubit>();
    cubit.setExporting(true);
    await WidgetsBinding.instance.endOfFrame;
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return null;
      return await sl<ImageService>()
          .saveBytesToTemp(data.buffer.asUint8List());
    } finally {
      if (!cubit.isClosed) cubit.setExporting(false);
    }
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final path = await _capture();
      if (path == null) {
        _toast('Could not export the image', error: true);
        return;
      }
      await sl<ImageService>().saveToGallery(path);
      _toast('Saved to your gallery');
    } catch (_) {
      _toast('Could not save the image. Check storage permission.',
          error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final path = await _capture();
      if (path == null) {
        _toast('Could not export the image', error: true);
        return;
      }
      await sl<ImageService>().share(path);
    } catch (_) {
      _toast('Could not share the image', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: _busy ? null : _share,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _busy ? null : _save,
              child: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: BlocBuilder<EditorCubit, EditorState>(
                    builder: (context, state) => EditorCanvas(
                      state: state,
                      imagePath: widget.image.resultPath,
                      boundaryKey: _boundaryKey,
                    ),
                  ),
                ),
              ),
            ),
            _ToolTabs(
              selected: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 150, maxHeight: 210),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              color: Theme.of(context).colorScheme.surface,
              child: BlocBuilder<EditorCubit, EditorState>(
                builder: (context, state) {
                  switch (_tab) {
                    case 0:
                      return _BackgroundPanel(
                        state: state,
                        onPickPhoto: _pickPhoto,
                      );
                    case 1:
                      return _CropPanel(state: state);
                    default:
                      return _AdjustPanel(state: state);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolTabs extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _ToolTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.wallpaper_rounded, 'Background'),
      (Icons.crop_rounded, 'Crop'),
      (Icons.tune_rounded, 'Adjust'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i].$1,
                        color: i == selected ? AppColors.primary : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i].$2,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: i == selected ? AppColors.primary : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _typeLabel(BackgroundType type) {
  switch (type) {
    case BackgroundType.transparent:
      return 'Transparent';
    case BackgroundType.color:
      return 'Color';
    case BackgroundType.gradient:
      return 'Gradient';
    case BackgroundType.photo:
      return 'Photo';
  }
}

class _BackgroundPanel extends StatelessWidget {
  final EditorState state;
  final VoidCallback onPickPhoto;

  const _BackgroundPanel({required this.state, required this.onPickPhoto});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditorCubit>();

    Widget options;
    switch (state.backgroundType) {
      case BackgroundType.transparent:
        options = Text(
          'The background stays transparent. Save to keep it as a PNG.',
          style: Theme.of(context).textTheme.bodySmall,
        );
      case BackgroundType.color:
        options = ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: kEditorColors.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) => _Swatch(
            selected: state.colorIndex == i,
            color: kEditorColors[i],
            onTap: () => cubit.selectColor(i),
          ),
        );
      case BackgroundType.gradient:
        options = ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: kEditorGradients.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) => _Swatch(
            selected: state.gradientIndex == i,
            gradient: kEditorGradients[i],
            onTap: () => cubit.selectGradient(i),
          ),
        );
      case BackgroundType.photo:
        options = Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: onPickPhoto,
            icon: const Icon(Icons.add_photo_alternate_rounded),
            label: Text(state.photoPath == null ? 'Choose photo' : 'Change photo'),
          ),
        );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final type in BackgroundType.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_typeLabel(type)),
                    selected: state.backgroundType == type,
                    onSelected: (_) => cubit.setBackgroundType(type),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(height: 48, child: options),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  final bool selected;
  final Color? color;
  final List<Color>? gradient;
  final VoidCallback onTap;

  const _Swatch({
    required this.selected,
    required this.onTap,
    this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          gradient: gradient == null
              ? null
              : LinearGradient(
                  colors: gradient!,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
            width: selected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}

class _CropPanel extends StatelessWidget {
  final EditorState state;
  const _CropPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditorCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aspect ratio',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final ratio in CropRatio.values)
              ChoiceChip(
                label: Text(ratio.label),
                selected: state.cropRatio == ratio,
                onSelected: (_) => cubit.setCrop(ratio),
              ),
          ],
        ),
      ],
    );
  }
}

class _AdjustPanel extends StatelessWidget {
  final EditorState state;
  const _AdjustPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditorCubit>();
    return SingleChildScrollView(
      child: Column(
        children: [
          _SliderRow(
            label: 'Brightness',
            value: state.brightness,
            min: -0.5,
            max: 0.5,
            onChanged: cubit.setBrightness,
          ),
          _SliderRow(
            label: 'Contrast',
            value: state.contrast,
            min: 0.5,
            max: 1.5,
            onChanged: cubit.setContrast,
          ),
          _SliderRow(
            label: 'Saturation',
            value: state.saturation,
            min: 0,
            max: 2,
            onChanged: cubit.setSaturation,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: cubit.resetAdjustments,
              child: const Text('Reset'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max).toDouble(),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
