import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../app/functions.dart';
import '../../../../core/constants/assets_manager.dart';
import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../notifications/presentation/cubit/notification_cubit.dart';
import '../../../notifications/presentation/notifications_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.userName,
    required this.locationText,
    required this.onLocationTap,
    this.avatarUrl,
  });

  final String userName;
  final String? avatarUrl;
  final String locationText;
  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context) {
    final name = userName.trim().isEmpty
        ? LocaleKeys.mosaedGuest.tr()
        : userName.trim();

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: Column(
        children: [
          Row(
            children: [
              _HomeAvatar(avatarUrl: avatarUrl),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.mosaedHelloUser.tr(args: [name]),
                      style: getSemiBoldStyle(
                        fontSize: 14.sp,
                        color: MosaedColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      LocaleKeys.mosaedReadyToHelp.tr(),
                      style: getRegularStyle(
                        fontSize: 11.sp,
                        color: MosaedColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const _HomeNotificationBell(),
            ],
          ),
          SizedBox(height: 14.h),
          GestureDetector(
            onTap: onLocationTap,
            child: Container(
              width: MediaQuery.of(context).size.width*.5,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: MosaedColors.surfaceWhite,
                borderRadius: BorderRadius.circular(40.r),
                border: Border.all(color: MosaedColors.fieldBorder),
              ),
              child: Row(
                children: [
                 SvgPicture.asset('assets/images/location_fill.svg',width: 16.w,height: 16.h,),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      locationText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getMediumStyle(
                        fontSize: 11.sp,
                        color: MosaedColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: MosaedColors.textSecondary,
                    size: 22.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAvatar extends StatelessWidget {
  const _HomeAvatar({this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    final hasPhoto = url != null && url.isNotEmpty;

    return CircleAvatar(
      radius: 24.r,
      backgroundColor: MosaedColors.surfaceContainerLow,
      child: hasPhoto
          ? ClipOval(
              child: Image.network(
                url,
                width: 48.r,
                height: 48.r,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person_rounded,
                  color: MosaedColors.brand,
                  size: 28.sp,
                ),
              ),
            )
          : Icon(
              Icons.person_rounded,
              color: MosaedColors.brand,
              size: 28.sp,
            ),
    );
  }
}

class _HomeNotificationBell extends StatelessWidget {
  const _HomeNotificationBell();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => AppFunctions.navigateTo(
                  context,
                  const NotificationsScreen(),
                  PageTransitionType.rightToLeft,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                  height: 40.w,
                  width: 40.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: MosaedColors.border),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    ImageAssets.notification,
                    height: 24.h,
                    width: 24.w,
                  ),
                ),
              ),
            ),
            if (state.unreadCount > 0)
              PositionedDirectional(
                start: 2.w,
                top: 2.h,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: const BoxDecoration(
                    color: MosaedColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
