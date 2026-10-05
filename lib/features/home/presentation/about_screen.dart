import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

import '../../../app/functions.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../auth/presentation/widgets/mosaed_logo.dart';
import '../../services/presentation/widgets/address_chrome.dart';
import 'info_screen.dart';
import 'widgets/more_card_tile.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _open(BuildContext context, String title, String body) {
    AppFunctions.navigateTo(
      context,
      InfoScreen(titleKey: title, bodyKey: body),
      PageTransitionType.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MosaedColors.surfaceWhite,
      appBar: AddressAppBar(title: LocaleKeys.mosaedAboutMosaed.tr()),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              children: [
                const MosaedLogo(width: 96),
                SizedBox(height: 12.h),
                Text(
                  LocaleKeys.mosaedAboutTagline.tr(),
                  textAlign: TextAlign.center,
                  style: getRegularStyle(
                    fontSize: 13.sp,
                    color: MosaedColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 24.h),
                MoreCardTile(
                  title: LocaleKeys.mosaedAboutTheApp.tr(),
                  leadingIcon: Icons.info_outline_rounded,
                  onTap: () => _open(
                    context,
                    LocaleKeys.mosaedAboutTheApp,
                    'mosaedAboutUsBody',
                  ),
                ),
                SizedBox(height: 10.h),
                MoreCardTile(
                  title: LocaleKeys.mosaedOurServices.tr(),
                  leadingIcon: Icons.hub_outlined,
                  onTap: () => AppFunctions.navigateTo(
                    context,
                    InfoScreen(
                      titleKey: LocaleKeys.mosaedOurServices,
                      bodyKey: 'mosaedOurServicesBody',
                      bulletKeys: const [
                        'mosaedPlumbing',
                        'mosaedInsulation',
                        'mosaedElectric',
                        'mosaedAc',
                        'mosaedCleaning',
                        'mosaedPainting',
                      ],
                    ),
                    PageTransitionType.rightToLeft,
                  ),
                ),
                SizedBox(height: 10.h),
                MoreCardTile(
                  title: LocaleKeys.mosaedTermsAndConditions.tr(),
                  leadingIcon: Icons.description_outlined,
                  onTap: () => _open(
                    context,
                    LocaleKeys.mosaedTermsAndConditions,
                    LocaleKeys.mosaedTermsBody,
                  ),
                ),
                SizedBox(height: 10.h),
                MoreCardTile(
                  title: LocaleKeys.mosaedPrivacyPolicy.tr(),
                  leadingIcon: Icons.verified_user_outlined,
                  onTap: () => _open(
                    context,
                    LocaleKeys.mosaedPrivacyPolicy,
                    LocaleKeys.mosaedPrivacyBody,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Text(
              LocaleKeys.mosaedVersion.tr(args: [AppConstants.appVersion]),
              textAlign: TextAlign.center,
              style: getRegularStyle(
                fontSize: 12.sp,
                color: MosaedColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
