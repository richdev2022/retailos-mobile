import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../network/api_client.dart';
import '../storage/local_database.dart';
import '../storage/secure_storage.dart';
import '../sync/sync_engine.dart';

part 'providers.g.dart';

// ---------------------------------------------------------------------------
// Infrastructure singletons
// ---------------------------------------------------------------------------

/// Whether the app is built in production mode (governs the default API URL
/// and a couple of behaviors). Reads the `--dart-define=APP_ENV=prod` flag.
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

/// A simple global event bus the [ApiClient] uses to signal that the current
/// session is no longer valid (refresh failed / 401 after retry). The
/// [AuthNotifier] subscribes so it can clear state and trigger a redirect,
/// without creating a circular dependency with [apiClientProvider].
final _authInvalidationController =
    StreamController<void>.broadcast(sync: false);

Stream<void> get authInvalidationStream => _authInvalidationController.stream;

void signalAuthInvalidation() {
  if (!_authInvalidationController.isClosed) {
    _authInvalidationController.add(null);
  }
}

/// Configured [ApiClient]. Its token / business-id accessors and refresh
/// handler read directly from [SecureStorage] (which both [AuthNotifier] and
/// the client share), keeping the dependency graph acyclic.
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final isProd = ref.watch(isProdProvider);
  return ApiClient(
    isProd: isProd,
    accessTokenProvider: storage.getAccessToken,
    businessIdProvider: () {
      // Synchronous best-effort: cache the last seen value. For a true sync
      // accessor we expose the cached value, refreshed asynchronously below.
      return _cachedBusinessId;
    },
    refreshTokenHandler: () async {
      final refresh = await storage.getRefreshToken();
      if (refresh == null || refresh.isEmpty) return null;
      try {
        final client = ApiClient(
          isProd: isProd,
          baseUrl: resolveBaseUrl(isProd: isProd),
        );
        final response = await client.post(
          'auth/refresh',
          data: {'refresh_token': refresh},
        );
        final data = response.data;
        if (data is Map) {
          final access = data['access_token']?.toString();
          final newRefresh = data['refresh_token']?.toString();
          if (access != null && access.isNotEmpty) {
            await storage.setTokens(
              accessToken: access,
              refreshToken: newRefresh ?? refresh,
            );
            return access;
          }
        }
        return null;
      } catch (e) {
        return null;
      }
    },
    onAuthInvalid: signalAuthInvalidation,
  );
});

// A tiny cache so the synchronous [BusinessIdProvider] accessor can return a
// value without awaiting storage. Updated by [BusinessNotifier] on changes.
String? _cachedBusinessId;

// ignore: unused_element
void setCachedBusinessId(String? id) => _cachedBusinessId = id;

/// The sync engine. Listens to connectivity and exposes a status stream.
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = SyncEngine(
    apiClient: ref.watch(apiClientProvider),
    database: ref.watch(localDatabaseProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
  ref.onDispose(engine.dispose);
  return engine;
});

/// A watchable stream of sync status for the UI (sync indicator, banners).
@riverpod
Stream<SyncStatusState> syncStatus(SyncStatusRef ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.statusStream;
}
