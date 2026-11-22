import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum BackgroundType { transparent, color, gradient, photo }

enum CropRatio {
  portrait34('3:4', 3 / 4),
  square('1:1', 1),
  portrait45('4:5', 4 / 5),
  landscape169('16:9', 16 / 9);

  final String label;
  final double ratio;
  const CropRatio(this.label, this.ratio);
}

class EditorState extends Equatable {
  final BackgroundType backgroundType;
  final int colorIndex;
  final int gradientIndex;
  final String? photoPath;
  final CropRatio cropRatio;

  /// -1.0 .. 1.0 (0 = unchanged)
  final double brightness;

  /// 0.5 .. 1.5 (1 = unchanged)
  final double contrast;

  /// 0.0 .. 2.0 (1 = unchanged)
  final double saturation;

  /// True while capturing the canvas (hides the transparency grid).
  final bool exporting;

  const EditorState({
    this.backgroundType = BackgroundType.transparent,
    this.colorIndex = 0,
    this.gradientIndex = 0,
    this.photoPath,
    this.cropRatio = CropRatio.portrait34,
    this.brightness = 0,
    this.contrast = 1,
    this.saturation = 1,
    this.exporting = false,
  });

  EditorState copyWith({
    BackgroundType? backgroundType,
    int? colorIndex,
    int? gradientIndex,
    String? photoPath,
    CropRatio? cropRatio,
    double? brightness,
    double? contrast,
    double? saturation,
    bool? exporting,
  }) {
    return EditorState(
      backgroundType: backgroundType ?? this.backgroundType,
      colorIndex: colorIndex ?? this.colorIndex,
      gradientIndex: gradientIndex ?? this.gradientIndex,
      photoPath: photoPath ?? this.photoPath,
      cropRatio: cropRatio ?? this.cropRatio,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      exporting: exporting ?? this.exporting,
    );
  }

  @override
  List<Object?> get props => [
        backgroundType,
        colorIndex,
        gradientIndex,
        photoPath,
        cropRatio,
        brightness,
        contrast,
        saturation,
        exporting,
      ];
}

class EditorCubit extends Cubit<EditorState> {
  EditorCubit() : super(const EditorState());

  void setBackgroundType(BackgroundType type) =>
      emit(state.copyWith(backgroundType: type));

  void selectColor(int index) => emit(state.copyWith(
        backgroundType: BackgroundType.color,
        colorIndex: index,
      ));

  void selectGradient(int index) => emit(state.copyWith(
        backgroundType: BackgroundType.gradient,
        gradientIndex: index,
      ));

  void setPhoto(String path) => emit(state.copyWith(
        backgroundType: BackgroundType.photo,
        photoPath: path,
      ));

  void setCrop(CropRatio ratio) => emit(state.copyWith(cropRatio: ratio));

  void setBrightness(double v) => emit(state.copyWith(brightness: v));
  void setContrast(double v) => emit(state.copyWith(contrast: v));
  void setSaturation(double v) => emit(state.copyWith(saturation: v));

  void resetAdjustments() => emit(state.copyWith(
        brightness: 0,
        contrast: 1,
        saturation: 1,
      ));

  void setExporting(bool value) => emit(state.copyWith(exporting: value));
}
