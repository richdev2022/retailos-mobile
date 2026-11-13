import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted persistent storage for tokens + IDs that must survive app restarts.
///
/// On Android, uses EncryptedSharedPreferences (Jetpack Security).
/// On iOS, uses Keychain.
class SecureStorage {
  SecureStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Keys
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUserId = 'user_id';
  static const _kActiveBusinessId = 'active_business_id';
  static const _kActiveBranchId = 'active_branch_id';
  static const _kThemeMode = 'theme_mode';
  static const _kLocale = 'locale';
  static const _kLastSyncCursor = 'last_sync_cursor';

  static Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);
  static Future<void> setAccessToken(String? token) async {
    if (token == null) {
      await _storage.delete(key: _kAccessToken);
    } else {
      await _storage.write(key: _kAccessToken, value: token);
    }
  }

  static Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);
  static Future<void> setRefreshToken(String? token) async {
    if (token == null) {
      await _storage.delete(key: _kRefreshToken);
    } else {
      await _storage.write(key: _kRefreshToken, value: token);
    }
  }

  static Future<String?> getUserId() => _storage.read(key: _kUserId);
  static Future<void> setUserId(String? id) async {
    if (id == null) {
      await _storage.delete(key: _kUserId);
    } else {
      await _storage.write(key: _kUserId, value: id);
    }
  }

  static Future<String?> getActiveBusinessId() => _storage.read(key: _kActiveBusinessId);
  static Future<void> setActiveBusinessId(String? id) async {
    if (id == null) {
      await _storage.delete(key: _kActiveBusinessId);
    } else {
      await _storage.write(key: _kActiveBusinessId, value: id);
    }
  }

  static Future<String?> getActiveBranchId() => _storage.read(key: _kActiveBranchId);
  static Future<void> setActiveBranchId(String? id) async {
    if (id == null) {
      await _storage.delete(key: _kActiveBranchId);
    } else {
      await _storage.write(key: _kActiveBranchId, value: id);
    }
  }

  static Future<String?> getThemeMode() => _storage.read(key: _kThemeMode);
  static Future<void> setThemeMode(String mode) => _storage.write(key: _kThemeMode, value: mode);

  static Future<String?> getLocale() => _storage.read(key: _kLocale);
  static Future<void> setLocale(String locale) => _storage.write(key: _kLocale, value: locale);

  static Future<String?> getLastSyncCursor() => _storage.read(key: _kLastSyncCursor);
  static Future<void> setLastSyncCursor(String cursor) => _storage.write(key: _kLastSyncCursor, value: cursor);

  /// Clear all auth-related keys (on logout).
  static Future<void> clearAuth() async {
    await Future.wait(<Future<void>>[
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
      _storage.delete(key: _kUserId),
      _storage.delete(key: _kActiveBusinessId),
      _storage.delete(key: _kActiveBranchId),
      _storage.delete(key: _kLastSyncCursor),
    ]);
  }

  /// Clear everything (reset).
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e, st) {
      debugPrint('SecureStorage.clearAll error: $e\n$st');
    }
  }
}
