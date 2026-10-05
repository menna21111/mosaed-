import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/assets_manager.dart';
import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../data/models/app_notification.dart';

enum NotificationVisualType { success, payment, general }

extension AppNotificationVisualX on AppNotification {
  NotificationVisualType get visualType {
    final e = event.toLowerCase();
    final text = '$title $body'.toLowerCase();

    final isPaymentAlert = e.contains('payment_required') ||
        e.contains('dues') ||
        e.contains('wallet') ||
        e.contains('warning') ||
        text.contains('مستحق') ||
        text.contains('تحذير') ||
        text.contains('ايقاف') ||
        text.contains('إيقاف') ||
        text.contains('ادفع') ||
        text.contains('دفع مستحق');

    if (isPaymentAlert) return NotificationVisualType.payment;

    final isSuccess = e.contains('payment_confirm') ||
        e.contains('completed') ||
        e.contains('accepted') ||
        e.contains('profit') ||
        e.contains('received') ||
        e.contains('success') ||
        text.contains('تم ') ||
        text.contains('أرباح') ||
        text.contains('ارباح');

    if (isSuccess) return NotificationVisualType.success;
    return NotificationVisualType.general;
  }
}

class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    super.key,
    required this.notification,
    required this.onTap,
    this.showDivider = true,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final bool showDivider;

  static const _teal = Color(0xFF2A9D8F);
  static const _purple = Color(0xFF7C5CBF);

  @override
  Widget build(BuildContext context) {
    final type = notification.visualType;
    final Color bg;
    final String asset;
    final bool isSvg;
    switch (type) {
      case NotificationVisualType.payment:
        bg = _purple;
        asset = ImageAssets.notificationCard;
        isSvg = false;
      case NotificationVisualType.success:
        bg = _teal;
        asset = ImageAssets.verifyWhite;
        isSvg = true;
      case NotificationVisualType.general:
        bg = MosaedColors.brand;
        asset = ImageAssets.messages;
        isSvg = true;
    }

    final message = notification.body.trim().isNotEmpty
        ? notification.body
        : notification.title;
    final time = _relativeTime(notification.createdAt);

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: isSvg
                      ? SvgPicture.asset(
                          asset,
                          width: 18.w,
                          height: 18.w,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        )
                      : Image.asset(
                          asset,
                          width: 18.w,
                          height: 18.w,
                          fit: BoxFit.contain,
                          color: Colors.white,
                          colorBlendMode: BlendMode.srcIn,
                        ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        textAlign: TextAlign.start,
                        style: getMediumStyle(
                          fontSize: 13.sp,
                          color: notification.isRead
                              ? MosaedColors.textSecondary
                              : MosaedColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      if (time.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Text(
                          time,
                          textAlign: TextAlign.start,
                          style: getRegularStyle(
                            fontSize: 11.sp,
                            color: MosaedColors.textHint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 0.5,
              color: MosaedColors.border,
            ),
        ],
      ),
    );
  }

  static String _relativeTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return LocaleKeys.mosaedJustNow.tr();
    if (diff.inMinutes < 60) {
      return LocaleKeys.mosaedMinutesAgo.tr(args: ['${diff.inMinutes}']);
    }
    if (diff.inHours < 24) {
      return LocaleKeys.mosaedHoursAgo.tr(args: ['${diff.inHours}']);
    }
    return LocaleKeys.mosaedDaysAgo.tr(args: ['${diff.inDays}']);
  }
}

class NotificationGroupCard extends StatelessWidget {
  const NotificationGroupCard({
    super.key,
    required this.title,
    required this.items,
    required this.onTapItem,
  });

  final String title;
  final List<AppNotification> items;
  final ValueChanged<AppNotification> onTapItem;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 4.w, bottom: 10.h),
          child: Text(
            title,
            style: getMediumStyle(
              fontSize: 13.sp,
              color: MosaedColors.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: MosaedColors.surfaceWhite,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: MosaedColors.fieldBorder),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++)
                NotificationListItem(
                  notification: items[i],
                  showDivider: i != items.length - 1,
                  onTap: () => onTapItem(items[i]),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
