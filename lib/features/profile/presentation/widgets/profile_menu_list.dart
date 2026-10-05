import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/assets_manager.dart';
import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../auth/presentation/widgets/mosaed_buttons.dart';
import 'profile_header.dart';
import 'profile_menu_section.dart';
import 'profile_menu_tile.dart';

class ProfileMenuList extends StatelessWidget {
  const ProfileMenuList({
    super.key,
    required this.name,
    required this.languageLabel,
    required this.onEdit,
    required this.onAddresses,
    required this.onPoints,
    required this.onSettings,
    required this.onLanguage,
    required this.onSupport,
    required this.onAbout,
    required this.onLogout,
    this.avatarUrl,
  });

  final String name;
  final String? avatarUrl;
  final String languageLabel;
  final VoidCallback onEdit;
  final VoidCallback onAddresses;
  final VoidCallback onPoints;
  final VoidCallback onSettings;
  final VoidCallback onLanguage;
  final VoidCallback onSupport;
  final VoidCallback onAbout;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: [
        ProfileHeader(
          name: name,
          avatarUrl: avatarUrl,
          onEdit: onEdit,
        ),
        SizedBox(height: 22.h),
        ProfileMenuSection(
          title: 'account'.tr(),
          children: [
            ProfileMenuTile(
              asset: ImageAssets.userIconProfile,
              label: LocaleKeys.mosaedMyAccount.tr(),
              onTap: onEdit,
            ),
            ProfileMenuTile(
              asset: ImageAssets.locationProfile,
              label: LocaleKeys.mosaedMyAddresses.tr(),
              onTap: onAddresses,
            ),
            ProfileMenuTile(
              asset: ImageAssets.crownOutline,
              label: LocaleKeys.mosaedLoyaltyPoints.tr(),
              showDivider: false,
              onTap: onPoints,
            ),
          ],
        ),
        SizedBox(height: 18.h),
        ProfileMenuSection(
          title: LocaleKeys.mosaedHelpAndSettings.tr(),
          children: [
            ProfileMenuTile(
              asset: ImageAssets.settings01,
              label: LocaleKeys.mosaedSettings.tr(),
              onTap: onSettings,
            ),
            ProfileMenuTile(
              asset: ImageAssets.languageIcon,
              label: languageLabel,
              showDivider: false,
              onTap: onLanguage,
            ),
          ],
        ),
        SizedBox(height: 18.h),
        ProfileMenuSection(
          title: LocaleKeys.mosaedHelpAndAbout.tr(),
          children: [
            ProfileMenuTile(
              asset: ImageAssets.mail01,
              label: LocaleKeys.mosaedSupport.tr(),
              onTap: onSupport,
            ),
            ProfileMenuTile(
              asset: ImageAssets.aiMagic,
              label: LocaleKeys.mosaedAboutMosaed.tr(),
              showDivider: false,
              onTap: onAbout,
            ),
          ],
        ),
        SizedBox(height: 24.h),
        MosaedOutlineButton(
          text: 'logout'.tr(),
          iconAsset: ImageAssets.alertIcon,
          color: MosaedColors.danger,
          onPressed: onLogout,
        ),
      ],
    );
  }
}
