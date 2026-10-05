import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/caching/cach_helper.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../services/presentation/widgets/address_chrome.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late bool _messages;
  late bool _offers;
  late bool _orderStatus;
  late bool _technician;
  late bool _payment;

  @override
  void initState() {
    super.initState();
    _messages = _read(AppConstants.notifMessagesKey, true);
    _offers = _read(AppConstants.notifOffersKey, true);
    _orderStatus = _read(AppConstants.notifOrderStatusKey, true);
    _technician = _read(AppConstants.notifTechnicianKey, false);
    _payment = _read(AppConstants.notifPaymentKey, true);
  }

  bool _read(String key, bool fallback) {
    final value = CacheHelper().getData(key: key);
    return value is bool ? value : fallback;
  }

  Future<void> _set(String key, bool value, void Function(bool) assign) async {
    assign(value);
    setState(() {});
    await CacheHelper().saveData(key: key, value: value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MosaedColors.surfaceWhite,
      appBar: AddressAppBar(title: LocaleKeys.mosaedNotifications.tr()),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: MosaedColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: MosaedColors.fieldBorder),
                  ),
                  child: Column(
                    children: [
                      _row(
                        LocaleKeys.mosaedNotifMessagesTitle.tr(),
                        LocaleKeys.mosaedNotifMessagesBody.tr(),
                        _messages,
                        (v) => _set(
                          AppConstants.notifMessagesKey,
                          v,
                          (x) => _messages = x,
                        ),
                      ),
                      _divider(),
                      _row(
                        LocaleKeys.mosaedNotifOffersTitle.tr(),
                        LocaleKeys.mosaedNotifOffersBody.tr(),
                        _offers,
                        (v) => _set(
                          AppConstants.notifOffersKey,
                          v,
                          (x) => _offers = x,
                        ),
                      ),
                      _divider(),
                      _row(
                        LocaleKeys.mosaedNotifOrderStatusTitle.tr(),
                        LocaleKeys.mosaedNotifOrderStatusBody.tr(),
                        _orderStatus,
                        (v) => _set(
                          AppConstants.notifOrderStatusKey,
                          v,
                          (x) => _orderStatus = x,
                        ),
                      ),
                      _divider(),
                      _row(
                        LocaleKeys.mosaedNotifTechnicianTitle.tr(),
                        LocaleKeys.mosaedNotifTechnicianBody.tr(),
                        _technician,
                        (v) => _set(
                          AppConstants.notifTechnicianKey,
                          v,
                          (x) => _technician = x,
                        ),
                      ),
                      _divider(),
                      _row(
                        LocaleKeys.mosaedNotifPaymentTitle.tr(),
                        LocaleKeys.mosaedNotifPaymentBody.tr(),
                        _payment,
                        (v) => _set(
                          AppConstants.notifPaymentKey,
                          v,
                          (x) => _payment = x,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: MosaedColors.otpFill,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: MosaedColors.brand,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        LocaleKeys.mosaedNotifHint.tr(),
                        style: getMediumStyle(
                          fontSize: 12.sp,
                          color: MosaedColors.brand,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        indent: 16.w,
        endIndent: 16.w,
        color: MosaedColors.fieldBorder,
      );

  Widget _row(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: getMediumStyle(
                      fontSize: 14.sp,
                      color: MosaedColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: getRegularStyle(
                      fontSize: 12.sp,
                      color: MosaedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: MosaedColors.brand,
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
