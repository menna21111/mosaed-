import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/auth_navigation.dart';
import '../../../app/functions.dart';
import '../../../core/caching/cach_helper.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/assets_manager.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../../core/network/failure.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/widgets/mosaed_buttons.dart';
import '../data/models/onboard_slide.dart';
import '../data/onboarding_repository.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _repo = OnboardingRepository();

  List<OnboardSlide> _slides = const [];
  int _index = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final slides = await _repo.getOnboardSlides();
      if (!mounted) return;
      setState(() {
        _slides = slides.isNotEmpty ? slides : _fallbackSlides();
        _loading = false;
      });
    } on ServerFailure {
      if (!mounted) return;
      setState(() {
        _slides = _fallbackSlides();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _slides = _fallbackSlides();
        _loading = false;
      });
    }
  }

  List<OnboardSlide> _fallbackSlides() {
    return [
      OnboardSlide(
        id: '1',
        title: 'mosaedOnboardTitle1'.tr(),
        description: 'mosaedOnboardDesc1'.tr(),
        order: 1,
      ),
      OnboardSlide(
        id: '2',
        title: 'mosaedOnboardTitle2'.tr(),
        description: 'mosaedOnboardDesc2'.tr(),
        order: 2,
      ),
      OnboardSlide(
        id: '3',
        title: 'mosaedOnboardTitle3'.tr(),
        description: 'mosaedOnboardDesc3'.tr(),
        order: 3,
      ),
    ];
  }

  Future<void> _finish() async {
    await CacheHelper().saveData(
      key: AppConstants.onboardingSeenKey,
      value: true,
    );
    if (!mounted) return;
    AppFunctions.navigateToAndFinish(context, const LoginScrean());
  }

  void _next() {
    if (_index >= _slides.length - 1) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final isLast = _slides.isNotEmpty && _index >= _slides.length - 1;

    return Scaffold(
      backgroundColor: MosaedColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: MosaedColors.primaryContainer,
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: MosaedChipButton(
                        text: 'mosaedSkip'.tr(),
                        icon: Icons.arrow_back_ios_new_rounded,
                        onPressed: _finish,
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (context, index) {
                        final slide = _slides[index];
                        return _OnboardPage(
                          title: slide.localizedTitle(lang),
                          description: slide.localizedDescription(lang),
                          imageUrl: slide.imageUrl,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_slides.length, (i) {
                            final active = i == _index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              height: 8.h,
                              width: active ? 28.w : 8.w,
                              decoration: BoxDecoration(
                                color: active
                                    ? MosaedColors.primary
                                    : const Color(0xFFEAE7E7),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 20.h),
                        MosaedPrimaryButton(
                          text: isLast
                              ? 'mosaedGetStarted'.tr()
                              : 'next'.tr(),
                          icon: Icons.arrow_back_ios_new_rounded,
                          onPressed: _next,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({
    required this.title,
    required this.description,
    this.imageUrl,
  });

  final String title;
  final String description;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: 320.h),
                decoration: BoxDecoration(
                  color: MosaedColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x14BD5E19),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _placeholder(),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: MosaedColors.primaryContainer,
                            ),
                          );
                        },
                      )
                    : _placeholder(),
              ),
            ),
          ),
          SizedBox(height: 28.h),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: getBoldStyle(
                    fontSize: 24.sp,
                    color: MosaedColors.primary,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: getRegularStyle(
                    fontSize: 15.sp,
                    color: MosaedColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      color: MosaedColors.surfaceContainerLow,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            ImageAssets.logo,
            width: 160.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 12.h),
          Icon(
            Icons.home_repair_service_rounded,
            size: 48.sp,
            color: MosaedColors.primary.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}

/// Used by splash to decide whether to show onboarding first.
/// Temporarily unused — splash goes directly to [AuthNavigation.goFromSplash].
class OnboardingGate {
  OnboardingGate._();

  static bool get hasSeen =>
      CacheHelper().getData(key: AppConstants.onboardingSeenKey) == true;

  static Future<void> openIfNeeded(BuildContext context) async {
    // Onboarding temporarily disabled.
    // if (hasSeen) {
    //   await AuthNavigation.goFromSplash(context);
    //   return;
    // }
    // if (!context.mounted) return;
    // AppFunctions.navigateToAndFinish(context, const OnboardingScreen());
    await AuthNavigation.goFromSplash(context);
  }
}
