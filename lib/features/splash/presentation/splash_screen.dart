import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/assets_manager.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/services/notification/push_notification_service.dart';
import '../../onboarding/presentation/onboarding_screen.dart';

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
    final token = await PushNotificationService.getToken();
    log('Splash FCM token: ${token ?? 'null'}');

    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    await OnboardingGate.openIfNeeded(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MosaedColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(ImageAssets.logo, width: 260.w, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }
}
