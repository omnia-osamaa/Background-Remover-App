import 'package:equatable/equatable.dart';

class ProcessedImage extends Equatable {
  final String id;
  final String originalPath;
  final String resultPath;
  final DateTime createdAt;

  const ProcessedImage({
    required this.id,
    required this.originalPath,
    required this.resultPath,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, originalPath, resultPath, createdAt];
}
