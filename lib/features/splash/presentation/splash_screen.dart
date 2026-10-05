import 'package:flutter/material.dart';

import '../../../app/auth_navigation.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../auth/presentation/widgets/mosaed_logo.dart';

/// App entry splash. Onboarding is temporarily disabled.
class SplashScrean extends StatefulWidget {
  const SplashScrean({super.key});

  @override
  State<SplashScrean> createState() => _SplashScreanState();
}

class _SplashScreanState extends State<SplashScrean> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    // Onboarding temporarily commented out — go straight to auth flow.
    // await OnboardingGate.openIfNeeded(context);
    await AuthNavigation.goFromSplash(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MosaedColors.background,
      body: Center(
        child: const MosaedLogo(width: 200),
      ),
    );
  }
}
