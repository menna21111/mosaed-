import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/functions.dart';
import '../../../core/constants/assets_manager.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../../core/network/failure.dart';
import '../data/custom_service_repository.dart';
import '../data/models/custom_service_models.dart';
import 'custom_request_success_screen.dart';

/// Standalone publishing progress screen shown after tapping «نشر».
class CustomRequestPublishingScreen extends StatefulWidget {
  const CustomRequestPublishingScreen({
    super.key,
    required this.payload,
  });

  final CustomRequestPayload payload;

  @override
  State<CustomRequestPublishingScreen> createState() =>
      _CustomRequestPublishingScreenState();
}

class _CustomRequestPublishingScreenState
    extends State<CustomRequestPublishingScreen>
    with TickerProviderStateMixin {
  /// 0 = first done, 1 = second done, 2 = third in progress / done
  int _activeStep = 0;
  double _progress = 0.12;
  bool _failed = false;

  late final AnimationController _pulseController;
  late final AnimationController _planeController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _run();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _planeController.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    CustomRequest? created;
    Object? error;

    final apiFuture = () async {
      try {
        created = await context
            .read<CustomServiceRepository>()
            .createCustomRequest(widget.payload);
      } catch (e) {
        error = e;
      }
    }();

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted || _failed) return;
    setState(() {
      _activeStep = 0;
      _progress = 0.35;
    });

    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted || _failed) return;
    setState(() {
      _activeStep = 1;
      _progress = 0.55;
    });

    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted || _failed) return;
    setState(() {
      _activeStep = 2;
      _progress = 0.7;
    });

    await apiFuture;
    if (!mounted) return;

    if (error != null || created == null) {
      setState(() => _failed = true);
      final message = error is ServerFailure
          ? (error as ServerFailure).errMessage
          : LocaleKeys.mosaedCustomServiceError.tr();
      AppFunctions.showsToast(message, MosaedColors.danger, context);
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _activeStep = 3;
      _progress = 1;
    });
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    AppFunctions.navigateToAndReplacement(
      context,
      CustomRequestSuccessScreen(requestId: created!.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_progress * 100).round().clamp(0, 100);

    return PopScope(
      canPop: _failed,
      child: Scaffold(
        backgroundColor: MosaedColors.surfaceWhite,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
            child: Column(
              children: [
                const Spacer(flex: 2),
                AnimatedBuilder(
                  animation: _planeController,
                  builder: (context, child) {
                    final t = _planeController.value;
                    return Transform.translate(
                      offset: Offset(0, -6.h * math.sin(t * math.pi)),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    ImageAssets.publishingIllustration,
                    width: 220.w,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 28.h),
                Text(
                  LocaleKeys.mosaedPublishingTitle.tr(),
                  textAlign: TextAlign.center,
                  style: getBoldStyle(
                    fontSize: 20.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  LocaleKeys.mosaedPublishingSubtitle.tr(),
                  textAlign: TextAlign.center,
                  style: getRegularStyle(
                    fontSize: 13.sp,
                    color: MosaedColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 36.h),
                _PublishingSteps(
                  activeStep: _activeStep,
                  pulse: _pulseController,
                ),
                const Spacer(flex: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8.h,
                    backgroundColor: MosaedColors.fieldBorder,
                    color: MosaedColors.brand,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  '$pct%',
                  textAlign: TextAlign.center,
                  style: getBoldStyle(
                    fontSize: 13.sp,
                    color: MosaedColors.brand,
                  ),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PublishingSteps extends StatelessWidget {
  const _PublishingSteps({
    required this.activeStep,
    required this.pulse,
  });

  final int activeStep;
  final AnimationController pulse;

  @override
  Widget build(BuildContext context) {
    final labels = [
      LocaleKeys.mosaedPublishingStepReceived.tr(),
      LocaleKeys.mosaedPublishingStepMatched.tr(),
      LocaleKeys.mosaedPublishingStepSending.tr(),
    ];

    return Column(
      children: List.generate(labels.length, (i) {
        final isDone = i < activeStep;
        final isCurrent = i == activeStep;
        final isLast = i == labels.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _StepDot(
                    isDone: isDone,
                    isCurrent: isCurrent,
                    pulse: pulse,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: EdgeInsets.symmetric(vertical: 4.h),
                        color: isDone || isCurrent
                            ? MosaedColors.brand
                            : MosaedColors.fieldBorder,
                      ),
                    ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 2.h,
                    bottom: isLast ? 0 : 22.h,
                  ),
                  child: Text(
                    labels[i],
                    style: getMediumStyle(
                      fontSize: 14.sp,
                      color: isCurrent
                          ? MosaedColors.brand
                          : isDone
                              ? MosaedColors.textPrimary
                              : MosaedColors.textHint,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.isDone,
    required this.isCurrent,
    required this.pulse,
  });

  final bool isDone;
  final bool isCurrent;
  final AnimationController pulse;

  @override
  Widget build(BuildContext context) {
    if (isDone) {
      return Container(
        width: 24.w,
        height: 24.w,
        decoration: const BoxDecoration(
          color: MosaedColors.brand,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_rounded, color: Colors.white, size: 14.sp),
      );
    }
    if (isCurrent) {
      return AnimatedBuilder(
        animation: pulse,
        builder: (context, _) {
          final scale = 0.9 + (pulse.value * 0.12);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: MosaedColors.brand, width: 2.5),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(
                  color: MosaedColors.brand,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      );
    }
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: MosaedColors.fieldBorder, width: 2),
      ),
    );
  }
}
