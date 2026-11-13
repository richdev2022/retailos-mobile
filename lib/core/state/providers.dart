import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/env.dart';
import '../network/api_client.dart';
import '../storage/local_database.dart';
import '../storage/secure_storage.dart';
import '../sync/sync_engine.dart';

/// Resolve the backend base URL. Reads from `Env.apiBaseUrl` (which honors
/// --dart-define=API_BASE_URL=... at build time). Falls back to the production
/// Render deployment URL.
String resolveBaseUrl({required bool isProd}) {
  return Env.apiBaseUrl;
}

// ---------------------------------------------------------------------------
// Infrastructure singletons
// ---------------------------------------------------------------------------

/// Whether the app is built in production mode.
final isProdProvider = Provider<bool>((ref) {
  const env = String.fromEnvironment('APP_ENV', defaultValue: '');
  return env == 'prod' || kReleaseMode;
});

/// Secure storage (Keystore / Keychain backed).
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

/// Local SQLite (Drift) database.
final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  final db = LocalDatabase();
  ref.onDispose(db.close);
  return db;
});

/// A simple global event bus for signaling auth invalidation.
final _authInvalidationController = StreamController<void>.broadcast(sync: false);
Stream<void> get authInvalidationStream => _authInvalidationController.stream;
void signalAuthInvalidation() {
  if (!_authInvalidationController.isClosed) {
    _authInvalidationController.add(null);
  }
}

/// Configured [ApiClient]. Token and business-id accessors are wired through
/// the [_AuthInterceptor] inside ApiClient.
final apiClientProvider = Provider<ApiClient>((ref) {
  final isProd = ref.watch(isProdProvider);
  return ApiClient(
    baseUrl: resolveBaseUrl(isProd: isProd),
    ref: ref,
  );
});

/// Cached business id for synchronous accessors.
String? _cachedBusinessId;
// ignore: unused_element
void setCachedBusinessId(String? id) => _cachedBusinessId = id;

/// The sync engine.
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = SyncEngine(
    apiClient: ref.watch(apiClientProvider),
    database: ref.watch(localDatabaseProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
  ref.onDispose(engine.dispose);
  return engine;
});


/// Watchable sync status stream.
final syncStatusProvider = StreamProvider<SyncStatusState>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.statusStream;
});
