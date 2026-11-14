import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/state/auth_state.dart';
import 'core/state/business_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait (POS workflows benefit from phone orientation)
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Create the container and run bootstrap before showing the UI.
  final container = ProviderContainer();
  await container.read(authProvider.notifier).bootstrap();
  // After auth bootstrap, if the user is authenticated, load businesses.
  // We use read() on the state to check synchronously.
  if (container.read(authProvider).isAuthenticated) {
    await container.read(businessProvider.notifier).bootstrap();
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: const RetailOSApp(),
  ));
}
