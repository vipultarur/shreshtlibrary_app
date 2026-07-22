import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shreshtlibrary/core/models/models.dart';

final localCacheServiceProvider = Provider<LocalCacheService>((ref) {
  throw UnimplementedError('Initialize with LocalCacheService.init() first');
});

class LocalCacheService {
  LocalCacheService(this._box);

  final Box _box;

  static const _idCardKey = 'cached_id_card';
  static const _notificationsKey = 'cached_notifications';
  static const _processedNotifsKey = 'processed_notifs_ids';
  static const _languageCodeKey = 'selected_language_code';
  static const _hasSelectedLanguageKey = 'has_selected_language';

  bool hasSelectedLanguage() {
    return _box.get(_hasSelectedLanguageKey, defaultValue: false) as bool;
  }

  String? getLanguageCode() {
    return _box.get(_languageCodeKey) as String?;
  }

  Future<void> setLanguageCode(String code) async {
    await _box.put(_languageCodeKey, code);
    await _box.put(_hasSelectedLanguageKey, true);
  }

  static Future<LocalCacheService> init() async {
    await Hive.initFlutter();
    final box = await Hive.openBox('app_cache');
    return LocalCacheService(box);
  }

  Future<void> saveIdCard(StudentIdCard idCard) async {
    final map = {
      'student_id': idCard.studentId,
      'full_name': idCard.fullName,
      'mobile': idCard.mobile,
      'email': idCard.email,
      'goal': idCard.goal,
      'qr_data': idCard.qrData,
      'dob': idCard.dob,
      'photo_url': idCard.photoUrl,
    };
    await _box.put(_idCardKey, jsonEncode(map));
  }

  StudentIdCard? getIdCard() {
    final jsonStr = _box.get(_idCardKey) as String?;
    if (jsonStr == null) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return StudentIdCard.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCache(String key, dynamic data) async {
    final wrapper = {
      '_timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': data,
    };
    await _box.put('cache_$key', jsonEncode(wrapper));
  }

  dynamic getCache(String key, {Duration? maxAge}) {
    final jsonStr = _box.get('cache_$key') as String?;
    if (jsonStr == null) return null;
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic> &&
          decoded.containsKey('_timestamp')) {
        final timestamp = decoded['_timestamp'] as int;
        final age = DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(timestamp),
        );
        if (maxAge != null && age > maxAge) {
          return null; // Expired
        }
        return decoded['data'];
      }
      return decoded; // Fallback for old cache format
    } catch (_) {
      return null;
    }
  }

  Future<void> saveNotifications(List<dynamic> data) async {
    await _box.put(_notificationsKey, jsonEncode(data));
  }

  List<dynamic> getNotifications() {
    final jsonStr = _box.get(_notificationsKey) as String?;
    if (jsonStr == null) return [];
    try {
      return jsonDecode(jsonStr) as List<dynamic>;
    } catch (_) {
      return [];
    }
  }

  Future<void> markNotificationProcessed(String id) async {
    final ids = getProcessedNotifications();
    if (!ids.contains(id)) {
      ids.add(id);
      await _box.put(_processedNotifsKey, ids.toList());
    }
  }

  Set<String> getProcessedNotifications() {
    final list = _box.get(_processedNotifsKey) as List<dynamic>?;
    return (list?.map((e) => e.toString()).toList() ?? []).toSet();
  }

  Future<void> clearAll() async {
    await _box.delete(_idCardKey);
  }

  Future<void> clearCache(String key) async {
    await _box.delete('cache_$key');
  }

  Future<void> invalidatePattern(String pattern) async {
    final keysToDelete = _box.keys.where((key) {
      if (key is String) {
        // Cache keys are stored as 'cache_$key', so we check if the original key starts with pattern
        return key.startsWith('cache_$pattern');
      }
      return false;
    }).toList();
    
    await _box.deleteAll(keysToDelete);
  }

  // Adding specific methods for the explicit data models requested by user

  Future<void> saveLibraryInfo(LibraryInfo info) async {
    // Requires encoding logic in caller, so saveCache handles it
  }

  Future<void> clearCacheVersion() async {
    await _box.delete('cache_versions');
  }

  Future<void> saveCacheVersions(Map<String, dynamic> versions) async {
    await _box.put('cache_versions', jsonEncode(versions));
  }

  Map<String, dynamic> getCacheVersions() {
    final jsonStr = _box.get('cache_versions') as String?;
    if (jsonStr == null) return {};
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}

