import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

import '../../../app/functions.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../services/presentation/widgets/address_chrome.dart';
import 'info_screen.dart';
import 'widgets/more_card_tile.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

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
      appBar: AddressAppBar(title: LocaleKeys.mosaedSupport.tr()),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [
          MoreCardTile(
            title: LocaleKeys.mosaedSmartAssistant.tr(),
            onTap: () => _open(
              context,
              LocaleKeys.mosaedSmartAssistant,
              LocaleKeys.mosaedSmartAssistantBody,
            ),
          ),
          SizedBox(height: 10.h),
          MoreCardTile(
            title: LocaleKeys.mosaedSubmitComplaint.tr(),
            onTap: () => _open(
              context,
              LocaleKeys.mosaedSubmitComplaint,
              LocaleKeys.mosaedSubmitComplaintBody,
            ),
          ),
          SizedBox(height: 10.h),
          MoreCardTile(
            title: 'mosaedContactUs'.tr(),
            onTap: () => _open(
              context,
              'mosaedContactUs',
              'mosaedContactUsBody',
            ),
          ),
        ],
      ),
    );
  }
}
