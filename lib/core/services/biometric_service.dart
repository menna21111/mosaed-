import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

enum BiometricAuthStatus { success, cancelled, failed, unavailable }

class BiometricCancelledException implements Exception {
  const BiometricCancelledException();
}

class BiometricService {
  BiometricService._();

  static final LocalAuthentication _localAuth = LocalAuthentication();

  static const _cancelCodes = {
    'UserCancel',
    'user_cancel',
    'UserFallback',
    'user_fallback',
    'SystemCancel',
    'system_cancel',
    'auth_in_progress',
  };

  static const _unavailableCodes = {
    'NotAvailable',
    'not_available',
    'NotEnrolled',
    'not_enrolled',
    'PasscodeNotSet',
    'passcode_not_set',
    'LockedOut',
    'locked_out',
    'PermanentlyLockedOut',
    'permanently_locked_out',
    'biometric_unavailable',
    'no_biometrics',
  };

  static bool _isChannelError(Object error) {
    return error is PlatformException && error.code == 'channel-error';
  }

  static bool _hasUsableBiometrics(List<BiometricType> types) {
    if (types.isEmpty) return false;
    return types.contains(BiometricType.fingerprint) ||
        types.contains(BiometricType.face) ||
        types.contains(BiometricType.iris) ||
        types.contains(BiometricType.strong) ||
        types.contains(BiometricType.weak);
  }

  static Future<bool> isFingerprintAvailable() async {
    try {
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) return false;

      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return _hasUsableBiometrics(availableBiometrics);
    } on PlatformException catch (e) {
      if (_isChannelError(e)) return false;
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<BiometricAuthStatus> authenticate({
    required String reason,
  }) async {
    try {
      if (!await isFingerprintAvailable()) {
        return BiometricAuthStatus.unavailable;
      }

      final ok = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      // local_auth returns false on cancel as well as a failed scan.
      return ok ? BiometricAuthStatus.success : BiometricAuthStatus.cancelled;
    } on PlatformException catch (e) {
      if (_isChannelError(e)) return BiometricAuthStatus.unavailable;
      if (_cancelCodes.contains(e.code)) return BiometricAuthStatus.cancelled;
      if (_unavailableCodes.contains(e.code)) {
        return BiometricAuthStatus.unavailable;
      }
      return BiometricAuthStatus.failed;
    } catch (_) {
      return BiometricAuthStatus.failed;
    }
  }
}
