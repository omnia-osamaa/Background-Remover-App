import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/processed_image_model.dart';

abstract class HistoryLocalDataSource {
  /// Newest first.
  List<ProcessedImageModel> getAll();
  Future<void> add(ProcessedImageModel item);
  Future<void> remove(String id);
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  final SharedPreferences prefs;
  HistoryLocalDataSourceImpl(this.prefs);

  @override
  List<ProcessedImageModel> getAll() {
    final raw = prefs.getString(AppConstants.historyKey!);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ProcessedImageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save(List<ProcessedImageModel> items) {
    return prefs.setString(
      AppConstants.historyKey!,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> add(ProcessedImageModel item) async {
    final items = getAll()..insert(0, item);
    await _save(items);
  }

  @override
  Future<void> remove(String id) async {
    final items = getAll();
    final index = items.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final removed = items.removeAt(index);
    await _save(items);

    // Best effort: free the storage used by this item.
    for (final path in [removed.originalPath, removed.resultPath]) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }
}
