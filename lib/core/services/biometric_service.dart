import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Biometric authentication service.
///
/// Uses the `local_auth` Flutter plugin to access:
/// - Fingerprint (Android + iOS)
/// - Face ID (iOS)
/// - Iris (Samsung devices)
/// - Device PIN/Pattern/Password (fallback when biometrics unavailable)
///
/// Usage flow:
///   1. Call `isAvailable()` on app startup to check if biometrics are supported.
///   2. If available + user has opted in (stored in SecureStorage), call
///      `authenticate()` during the splash/welcome screen to auto-login.
///   3. If authentication succeeds, load tokens from SecureStorage and proceed
///      to the app without requiring a password re-entry.
class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if the device supports biometric authentication.
  Future<bool> get isAvailable async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  /// Get the list of enrolled biometric types.
  Future<List<BiometricType>> get availableBiometrics async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }

  /// Authenticate the user with biometrics.
  ///
  /// Returns `true` if authentication succeeded, `false` otherwise.
  /// Shows a system biometric prompt with [reason] as the message.
  /// Falls back to device PIN/pattern if biometrics fail.
  Future<bool> authenticate({
    String reason = 'Please authenticate to access RetailOS',
    bool biometricOnly = false,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Stop the authentication flow (if in progress).
  Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } on PlatformException {
      // ignore
    }
  }
}
