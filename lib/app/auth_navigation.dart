import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/services/biometric_service.dart';
import '../core/services/location_service.dart';
import '../core/services/notification/notification_service.dart';
import '../features/auth/data/auth_repository.dart';

import '../features/onboarding/presentation/onboarding_screen.dart';

import 'functions.dart';

class AuthNavigation {
  AuthNavigation._();

  static void goAfterLogin(BuildContext context) {
    unawaited(NotificationService.syncTokenWithBackend());
    if (!LocationService.isSetupDone) {
      AppFunctions.navigateToAndFinish(context, const OnboardingScreen());
      return;
    }
    AppFunctions.navigateToAndFinish(context, const OnboardingScreen());
  }

  static Future<void> goFromSplash(BuildContext context) async {
    final repo = context.read<AuthRepository>();

    if (!repo.isLoggedIn) {
      AppFunctions.navigateToAndFinish(context, const OnboardingScreen());
      return;
    }

    final fingerprintAvailable =
        await BiometricService.isFingerprintAvailable();
    if (!context.mounted) return;

    if (fingerprintAvailable) {
      AppFunctions.navigateToAndFinish(context, const OnboardingScreen());
      return;
    }

    goAfterLogin(context);
  }

  static void goAfterBiometricUnlock(BuildContext context) {
    goAfterLogin(context);
  }
}
