import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/functions.dart';
import '../../../app/theme_cubit.dart/theme_cubit.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/services/biometric_service.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/widgets/fingerprint_success_sheet.dart';
import '../../services/presentation/widgets/address_chrome.dart';
import 'notification_settings_screen.dart';
import 'widgets/language_sheet.dart';
import 'widgets/more_card_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = context.read<AuthRepository>();
    if (mounted) {
      setState(() => _biometricEnabled = repo.isBiometricEnabled);
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final repo = context.read<AuthRepository>();
    final available = await BiometricService.isFingerprintAvailable();
    if (!available) {
      if (!mounted) return;
      AppFunctions.showsToast(
        LocaleKeys.mosaedBiometricDeviceUnavailable.tr(),
        MosaedColors.danger,
        context,
      );
      return;
    }
    if (value) {
      final result = await repo.setupBiometricLogin(
        promptMessage: LocaleKeys.mosaedBiometricReason.tr(),
      );
      if (!result.success) {
        if (!mounted) return;
        AppFunctions.showsToast(
          result.error ??
              (repo.hasBiometricToken
                  ? LocaleKeys.mosaedBiometricSetupFailed.tr()
                  : LocaleKeys.mosaedBiometricNeedLogin.tr()),
          MosaedColors.danger,
          context,
        );
        return;
      }
      if (!mounted) return;
      await showFingerprintSuccessSheet(context);
    } else {
      await repo.disableBiometric();
    }
    if (mounted) setState(() => _biometricEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MosaedColors.surfaceWhite,
      appBar: AddressAppBar(title: LocaleKeys.mosaedSettings.tr()),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return MoreSettingsSwitchTile(
                title: 'mosaedDarkMode'.tr(),
                value: themeState.isDark,
                onChanged: (value) {
                  if (value) {
                    context.read<ThemeCubit>().setDarkTheme();
                  } else {
                    context.read<ThemeCubit>().setLightTheme();
                  }
                },
              );
            },
          ),
          SizedBox(height: 10.h),
          MoreSettingsSwitchTile(
            title: LocaleKeys.mosaedBiometricFaceTitle.tr(),
            subtitle: LocaleKeys.mosaedBiometricFaceSubtitle.tr(),
            value: _biometricEnabled,
            onChanged: _toggleBiometric,
          ),
          SizedBox(height: 10.h),
          MoreCardTile(
            title: 'language'.tr(),
            onTap: () => LanguageSheet.show(context),
          ),
          SizedBox(height: 10.h),
          MoreCardTile(
            title: LocaleKeys.mosaedNotifications.tr(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
