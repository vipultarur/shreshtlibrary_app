import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoredTokens {
  const StoredTokens({required this.access, required this.refresh});

  final String access;
  final String refresh;

  bool get isComplete => access.isNotEmpty && refresh.isNotEmpty;
}

abstract class TokenStore {
  Future<StoredTokens?> read();

  Future<void> save(StoredTokens tokens);

  Future<void> saveAccess(String access);

  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  const SecureTokenStore([this._storage = const FlutterSecureStorage()]);

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<StoredTokens?> read() async {
    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);
    if (access == null || refresh == null) {
      return null;
    }
    return StoredTokens(access: access, refresh: refresh);
  }

  @override
  Future<void> save(StoredTokens tokens) async {
    await _storage.write(key: _accessKey, value: tokens.access);
    await _storage.write(key: _refreshKey, value: tokens.refresh);
  }

  @override
  Future<void> saveAccess(String access) async {
    await _storage.write(key: _accessKey, value: access);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

class MemoryTokenStore implements TokenStore {
  StoredTokens? tokens;

  @override
  Future<StoredTokens?> read() async => tokens;

  @override
  Future<void> save(StoredTokens tokens) async {
    this.tokens = tokens;
  }

  @override
  Future<void> saveAccess(String access) async {
    final current = tokens;
    if (current != null) {
      tokens = StoredTokens(access: access, refresh: current.refresh);
    }
  }

  @override
  Future<void> clear() async {
    tokens = null;
  }
}
