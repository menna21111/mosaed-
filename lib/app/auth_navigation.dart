import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/services/biometric_service.dart';
import '../core/services/notification/notification_service.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/biometric_lock_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/main_shell.dart';
import '../features/services/data/services_repository.dart';
import '../features/services/presentation/address_onboarding_screen.dart';
// import '../features/onboarding/presentation/onboarding_screen.dart';

import 'functions.dart';

class AuthNavigation {
  AuthNavigation._();

  static Future<void> goAfterLogin(BuildContext context) async {
    unawaited(NotificationService.syncTokenWithBackend());
    try {
      final hasAddress =
          await context.read<ServicesRepository>().hasSavedAddress();
      if (!context.mounted) return;
      if (!hasAddress) {
        AppFunctions.navigateToAndFinish(
          context,
          const AddressOnboardingScreen(),
        );
        return;
      }
    } catch (_) {
      if (!context.mounted) return;
      AppFunctions.navigateToAndFinish(
        context,
        const AddressOnboardingScreen(),
      );
      return;
    }

    if (!context.mounted) return;
    AppFunctions.navigateToAndFinish(context, const MainShell());
  }

  static Future<void> goFromSplash(BuildContext context) async {
    final repo = context.read<AuthRepository>();

    if (!repo.isLoggedIn) {
      AppFunctions.navigateToAndFinish(context, const LoginScrean());
      return;
    }

    final fingerprintAvailable =
        await BiometricService.isFingerprintAvailable();
    if (!context.mounted) return;

    if (fingerprintAvailable) {
      AppFunctions.navigateToAndFinish(context, const BiometricLockScreen());
      return;
    }

    await goAfterLogin(context);
  }

  static Future<void> goAfterBiometricUnlock(BuildContext context) async {
    await goAfterLogin(context);
  }
}
