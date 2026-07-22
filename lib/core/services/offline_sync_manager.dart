import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shreshtlibrary/core/network/api_client.dart';

final offlineSyncManagerProvider = Provider<OfflineSyncManager>((ref) {
  throw UnimplementedError('Initialize OfflineSyncManager.init() first');
});

class PendingRequest {
  PendingRequest({
    required this.id,
    required this.path,
    required this.method,
    this.body,
    required this.timestamp,
  });

  final String id;
  final String path;
  final String method;
  final dynamic body;
  final int timestamp;

  Map<String, dynamic> toJson() => {
        'id': id,
        'path': path,
        'method': method,
        'body': body,
        'timestamp': timestamp,
      };

  factory PendingRequest.fromJson(Map<String, dynamic> json) => PendingRequest(
        id: json['id'] as String,
        path: json['path'] as String,
        method: json['method'] as String,
        body: json['body'],
        timestamp: json['timestamp'] as int,
      );

  /// Deduplication key: same method + path = same logical request
  String get dedupKey => '${method.toUpperCase()}_$path';
}

class OfflineSyncManager {
  OfflineSyncManager(this._box, this._client);

  final Box _box;
  final ApiClient _client;

  static const _queueKey = 'pending_offline_requests';

  /// Maximum number of offline requests to queue (prevents unbounded growth on flaky networks)
  static const int maxQueueSize = 50;

  /// Maximum age of a queued request before it's considered expired and discarded
  static const Duration maxRequestAge = Duration(hours: 6);

  static Future<OfflineSyncManager> init(ApiClient client) async {
    final box = await Hive.openBox('offline_sync_queue');
    return OfflineSyncManager(box, client);
  }

  Future<void> enqueueRequest({
    required String path,
    required String method,
    dynamic body,
  }) async {
    final list = _getPendingRequests();

    final req = PendingRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      path: path,
      method: method,
      body: body,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    // Deduplication: remove any existing request with the same method + path
    list.removeWhere((existing) => existing.dedupKey == req.dedupKey);

    // Enforce max queue size (drop oldest if at capacity)
    if (list.length >= maxQueueSize) {
      list.removeAt(0); // Remove the oldest entry
      debugPrint('[OfflineSyncManager] Queue at capacity ($maxQueueSize), dropped oldest entry');
    }

    list.add(req);
    await _saveQueue(list);
    debugPrint('[OfflineSyncManager] Enqueued offline request: $method $path (queue size: ${list.length})');
  }

  List<PendingRequest> _getPendingRequests() {
    final raw = _box.get(_queueKey) as String?;
    if (raw == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(raw);
      return jsonList
          .map((e) => PendingRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveQueue(List<PendingRequest> queue) async {
    final jsonList = queue.map((e) => e.toJson()).toList();
    await _box.put(_queueKey, jsonEncode(jsonList));
  }

  Future<void> flushQueue() async {
    var queue = _getPendingRequests();
    if (queue.isEmpty) return;

    // Purge expired requests before processing
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiredCount = queue.where((r) =>
        Duration(milliseconds: now - r.timestamp) > maxRequestAge).length;
    queue.removeWhere((r) =>
        Duration(milliseconds: now - r.timestamp) > maxRequestAge);
    if (expiredCount > 0) {
      debugPrint('[OfflineSyncManager] Purged $expiredCount expired requests (older than ${maxRequestAge.inHours}h)');
    }

    if (queue.isEmpty) {
      await _saveQueue([]);
      return;
    }

    debugPrint('[OfflineSyncManager] Flushing ${queue.length} offline requests...');
    final remaining = <PendingRequest>[];

    for (final req in queue) {
      try {
        if (req.method.toUpperCase() == 'POST') {
          await _client.post<dynamic>(req.path, data: req.body);
        } else if (req.method.toUpperCase() == 'PUT') {
          await _client.put<dynamic>(req.path, data: req.body);
        } else if (req.method.toUpperCase() == 'DELETE') {
          await _client.delete<dynamic>(req.path, data: req.body);
        }
        debugPrint('[OfflineSyncManager] Successfully flushed request: ${req.path}');
      } catch (e) {
        debugPrint('[OfflineSyncManager] Request failed, keeping in queue: ${req.path} | $e');
        remaining.add(req);
      }
    }

    await _saveQueue(remaining);
  }
}
