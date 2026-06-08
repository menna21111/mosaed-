import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/services/location_service.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/biometric_lock_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/location_setup_screen.dart';
import '../features/home/presentation/main_shell.dart';
import 'functions.dart';

class AuthNavigation {
  AuthNavigation._();

  static void goAfterLogin(BuildContext context) {
    if (!LocationService.isSetupDone) {
      AppFunctions.navigateToAndFinish(context, const LocationSetupScreen());
      return;
    }
    AppFunctions.navigateToAndFinish(context, const MainShell());
  }

  static void goFromSplash(BuildContext context) {
    final repo = context.read<AuthRepository>();

    if (!repo.isLoggedIn) {
      AppFunctions.navigateToAndFinish(context, const LoginScrean());
      return;
    }

    if (repo.canUseBiometricLogin) {
      AppFunctions.navigateToAndFinish(context, const BiometricLockScreen());
      return;
    }

    goAfterLogin(context);
  }

  static void goAfterBiometricUnlock(BuildContext context) {
    goAfterLogin(context);
  }
}
