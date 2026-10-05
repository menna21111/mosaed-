import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/functions.dart';
import '../../../core/constants/assets_manager.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../auth/presentation/widgets/mosaed_buttons.dart';
import '../../home/presentation/main_shell.dart';
import 'custom_request_detail_screen.dart';

/// Standalone success screen after a custom request is published.
class CustomRequestSuccessScreen extends StatefulWidget {
  const CustomRequestSuccessScreen({
    super.key,
    required this.requestId,
  });

  final String requestId;

  @override
  State<CustomRequestSuccessScreen> createState() =>
      _CustomRequestSuccessScreenState();
}

class _CustomRequestSuccessScreenState extends State<CustomRequestSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _goHome() {
    AppFunctions.navigateToAndFinish(context, const MainShell());
  }

  void _openDetail() {
    AppFunctions.navigateToAndFinish(
      context,
      CustomRequestDetailScreen(requestId: widget.requestId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.requestId.trim();
    final displayId = id.isEmpty
        ? '—'
        : id.startsWith('#')
            ? id
            : '#$id';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome();
      },
      child: Scaffold(
        backgroundColor: MosaedColors.surfaceWhite,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 24.h),
                        AnimatedBuilder(
                          animation: _confetti,
                          builder: (context, child) {
                            return Opacity(
                              opacity: Curves.easeOut.transform(
                                _confetti.value.clamp(0.0, 1.0),
                              ),
                              child: Transform.scale(
                                scale: 0.85 +
                                    (0.15 *
                                        Curves.elasticOut.transform(
                                          _confetti.value.clamp(0.0, 1.0),
                                        )),
                                child: child,
                              ),
                            );
                          },
                          child: Image.asset(
                            ImageAssets.publishSuccessIllustration,
                            width: 260.w,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          LocaleKeys.mosaedPublishSuccessTitle.tr(),
                          textAlign: TextAlign.center,
                          style: getBoldStyle(
                            fontSize: 22.sp,
                            color: MosaedColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          LocaleKeys.mosaedPublishSuccessSubtitle.tr(),
                          textAlign: TextAlign.center,
                          style: getRegularStyle(
                            fontSize: 13.sp,
                            color: MosaedColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 22.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: MosaedColors.brandTransparent,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                ImageAssets.checkmarkCircle03,
                                width: 20.w,
                                height: 20.w,
                                colorFilter: const ColorFilter.mode(
                                  MosaedColors.brand,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                LocaleKeys.mosaedOrderNumber.tr(),
                                style: getMediumStyle(
                                  fontSize: 13.sp,
                                  color: MosaedColors.textSecondary,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  displayId,
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: getBoldStyle(
                                    fontSize: 14.sp,
                                    color: MosaedColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: MosaedColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: MosaedColors.fieldBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocaleKeys.mosaedWhatHappensNow.tr(),
                                style: getBoldStyle(
                                  fontSize: 14.sp,
                                  color: MosaedColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                LocaleKeys.mosaedWhatHappensNowBody.tr(),
                                style: getRegularStyle(
                                  fontSize: 12.sp,
                                  color: MosaedColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48.h,
                        child: OutlinedButton(
                          onPressed: _goHome,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: MosaedColors.brand),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            foregroundColor: MosaedColors.brand,
                          ),
                          child: Text(
                            LocaleKeys.mosaedBackToHome.tr(),
                            style: getBoldStyle(
                              fontSize: 13.sp,
                              color: MosaedColors.brand,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: MosaedPrimaryButton(
                        text: LocaleKeys.mosaedViewMyRequest.tr(),
                        onPressed: _openDetail,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
