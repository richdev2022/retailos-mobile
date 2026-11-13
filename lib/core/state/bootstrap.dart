import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_state.dart';
import 'business_state.dart';
import 'providers.dart';


/// Singleton handle to the local notifications plugin.
final flutterLocalNotificationsProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});

/// Bootstrap the app's core infrastructure before the first frame:
///   - local SQLite (Drift) database (created lazily by LocalDatabase)
///   - secure storage (Keystore / Keychain)
///   - connectivity monitoring (SyncEngine subscribes on construction)
///   - local notifications (channel + initial settings)
///   - restore auth session + active business context
///
/// Resolves to `true` once ready. Screens that depend on a restored session
/// watch this provider so they only render after bootstrap completes.
@riverpod
Future<bool> bootstrap(Ref ref) async {
  // 1. Touch the database (opens the file lazily) so it's warm before use.
  ref.read(localDatabaseProvider);

  // 2. Initialize local notifications.
  await _initNotifications(ref);

  // 3. Prime the sync engine (this also starts connectivity listening).
  ref.read(syncEngineProvider);

  // 4. Restore the user's session (tokens + /me).
  await ref.read(authProvider.notifier).bootstrap();

  // 5. Restore active business / branch context (also primes the
  //    X-Business-Id header cache used by the ApiClient).
  if (ref.read(authProvider).isAuthenticated) {
    await ref.read(businessProvider.notifier).bootstrap();
    // Kick off a background sync once the user is known to be online.
    ref.read(syncEngineProvider).runFullSync().catchError((e) {
      if (kDebugMode) print('[bootstrap] initial sync failed: $e');
    });
  }

  return true;
}

Future<void> _initNotifications(Ref ref) async {
  final plugin = ref.read(flutterLocalNotificationsProvider);
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  await plugin.initialize(
    const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: _onNotificationTap,
  );

  // Create the default channel (Android).
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
        'retailos_default',
        'RetailOS notifications',
        description: 'Sales, stock and account alerts from RetailOS.',
        importance: Importance.defaultImportance,
      ));
}

void _onNotificationTap(NotificationResponse response) {
  // TODO(RetailOS): deep-link to the relevant screen based on response.payload.
  if (kDebugMode) {
    print('[notifications] tap payload: ${response.payload}');
  }
}
