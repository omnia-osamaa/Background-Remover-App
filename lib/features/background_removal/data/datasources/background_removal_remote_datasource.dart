import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/image_service.dart';

abstract class BackgroundRemovalRemoteDataSource {
  /// Returns the local path of the processed (transparent PNG) image.
  Future<String> removeBackground(String imagePath);
}

/// Fake implementation used when no API key is provided.
/// It only simulates the waiting time and returns a COPY OF THE ORIGINAL
/// image, so the background is NOT actually removed.
class BackgroundRemovalFakeDataSource
    implements BackgroundRemovalRemoteDataSource {
  final ImageService imageService;
  BackgroundRemovalFakeDataSource(this.imageService);

  @override
  Future<String> removeBackground(String imagePath) async {
    await Future.delayed(const Duration(seconds: 3));
    if (!await File(imagePath).exists()) {
      throw const ServerException(message: 'We could not read this image');
    }
    return imageService.persistFile(imagePath);
  }
}

/// Real implementation using the remove.bg API.
/// Enable with: flutter run --dart-define=REMOVE_BG_API_KEY=your_key
class BackgroundRemovalRemoveBgDataSource
    implements BackgroundRemovalRemoteDataSource {
  final ImageService imageService;
  final String apiKey;

  BackgroundRemovalRemoveBgDataSource({
    required this.imageService,
    required this.apiKey,
  });

  @override
  Future<String> removeBackground(String imagePath) async {
    // A separate Dio on purpose: the app's main Dio adds the user's auth token
    // to every request and it must never be sent to a third party.
    final dio = Dio(
      BaseOptions(
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
      ),
    );

    try {
      final form = FormData.fromMap({
        'image_file': await MultipartFile.fromFile(imagePath),
        'size': 'auto',
        'format': 'png',
      });

      final response = await dio.post<List<int>>(
        AppConstants.removeBgUrl!,
        data: form,
        options: Options(
          headers: {'X-Api-Key': apiKey},
          responseType: ResponseType.bytes,
        ),
      );

      final data = response.data;
      if (data == null || data.isEmpty) {
        throw const ServerException(message: 'Empty response from the server');
      }
      return imageService.saveBytes(Uint8List.fromList(data));
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw const NetworkException();
        default:
          throw ServerException(
            message: 'Processing failed. Please try another image.',
            statusCode: e.response?.statusCode,
          );
      }
    }
  }
}
