import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class VersionedLocalCache {
  VersionedLocalCache(this._box);

  final Box _box;
  static const int schemaVersion = 3;

  /// Retrieves cached payload IF schemaVersion matches AND serverVersion matches.
  /// Returns null if version has bumped or schema is outdated.
  T? get<T>(String category, int serverVersion, T Function(Map<String, dynamic>) fromJson) {
    final raw = _box.get('v2_cache_$category') as String?;
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['schemaVersion'] != schemaVersion) return null;
      if (map['version'] != serverVersion) return null;
      return fromJson(map['data'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Saves payload with entity version and current schema version.
  Future<void> set(String category, Map<String, dynamic> data, int version) async {
    final entry = {
      'data': data,
      'version': version,
      'schemaVersion': schemaVersion,
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
    };
    await _box.put('v2_cache_$category', jsonEncode(entry));
  }

  /// Invalidates a specific category pattern
  Future<void> invalidatePattern(String category) async {
    final keysToDelete = _box.keys.where((key) {
      if (key is String) {
        return key.contains(category);
      }
      return false;
    }).toList();
    await _box.deleteAll(keysToDelete);
  }
}
