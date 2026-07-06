import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shreshtlibrary/core/models/models.dart';

final localCacheServiceProvider = Provider<LocalCacheService>((ref) {
  throw UnimplementedError('Initialize with LocalCacheService.init() first');
});

class LocalCacheService {
  LocalCacheService(this._prefs);

  final SharedPreferences _prefs;

  static const _idCardKey = 'cached_id_card';
  static const _notificationsKey = 'cached_notifications';

  static Future<LocalCacheService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalCacheService(prefs);
  }

  Future<void> saveIdCard(StudentIdCard idCard) async {
    // We don't have a built-in toJson() in models.dart for StudentIdCard, so we manually encode it
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
    await _prefs.setString(_idCardKey, jsonEncode(map));
  }

  StudentIdCard? getIdCard() {
    final jsonStr = _prefs.getString(_idCardKey);
    if (jsonStr == null) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return StudentIdCard.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveNotifications(List<dynamic> data) async {
    await _prefs.setString(_notificationsKey, jsonEncode(data));
  }

  List<dynamic> getNotifications() {
    final jsonStr = _prefs.getString(_notificationsKey);
    if (jsonStr == null) return [];
    try {
      return jsonDecode(jsonStr) as List<dynamic>;
    } catch (_) {
      return [];
    }
  }

  Future<void> clearAll() async {
    await _prefs.remove(_idCardKey);
  }
}
