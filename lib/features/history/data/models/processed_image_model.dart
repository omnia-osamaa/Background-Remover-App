import '../../domain/entities/processed_image.dart';

class ProcessedImageModel extends ProcessedImage {
  const ProcessedImageModel({
    required super.id,
    required super.originalPath,
    required super.resultPath,
    required super.createdAt,
  });

  factory ProcessedImageModel.fromJson(Map<String, dynamic> json) {
    return ProcessedImageModel(
      id: json['id'] as String,
      originalPath: json['originalPath'] as String,
      resultPath: json['resultPath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'originalPath': originalPath,
        'resultPath': resultPath,
        'createdAt': createdAt.toIso8601String(),
      };
}
