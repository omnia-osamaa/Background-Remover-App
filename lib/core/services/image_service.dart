import 'dart:io';
import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Handles everything that touches image files: storing, saving to the
/// gallery and sharing.
class ImageService {
  Future<Directory> _imagesDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/images');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  String _newName(String ext) =>
      '${DateTime.now().microsecondsSinceEpoch}.$ext';

  String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot < path.lastIndexOf('/')) return 'jpg';
    return path.substring(dot + 1).toLowerCase();
  }

  /// Copies [sourcePath] into the app's permanent images folder.
  Future<String> persistFile(String sourcePath) async {
    final dir = await _imagesDir();
    final target = File('${dir.path}/${_newName(_extensionOf(sourcePath))}');
    await File(sourcePath).copy(target.path);
    return target.path;
  }

  /// Saves [bytes] into the app's permanent images folder.
  Future<String> saveBytes(Uint8List bytes, {String ext = 'png'}) async {
    final dir = await _imagesDir();
    final file = File('${dir.path}/${_newName(ext)}');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Saves [bytes] into the temp folder (used for exports / sharing).
  Future<String> saveBytesToTemp(Uint8List bytes, {String ext = 'png'}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${_newName(ext)}');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<void> saveToGallery(String path) async {
    if (!await Gal.hasAccess()) {
      await Gal.requestAccess();
    }
    await Gal.putImage(path);
  }

  Future<void> share(String path, {String? text}) async {
    await Share.shareXFiles([XFile(path)], text: text);
  }
}
