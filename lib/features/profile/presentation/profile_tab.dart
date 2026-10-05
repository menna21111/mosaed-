import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

import '../../../app/functions.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/widgets/mosaed_confirm_dialog.dart';
import '../../../core/widgets/profile_shimmer.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/models/customer_profile.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../home/presentation/about_screen.dart';
import '../../home/presentation/settings_screen.dart';
import '../../home/presentation/support_screen.dart';
import '../../home/presentation/widgets/language_sheet.dart';
import '../../payments/presentation/points_wallet_screen.dart';
import '../../services/presentation/addresses_list_screen.dart';
import '../../services/presentation/widgets/address_chrome.dart';
import '../../splash/presentation/splash_screen.dart';
import 'edit_profile_screen.dart';
import 'widgets/profile_menu_list.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().fetchProfile();
  }

  Future<void> _logout() async {
    final confirmed = await showMosaedConfirmDialog(
      context,
      title: 'logout'.tr(),
      message: LocaleKeys.mosaedLogoutQuestion.tr(),
      confirmText: 'logout'.tr(),
    );
    if (!confirmed || !mounted) return;
    context.read<AuthCubit>().logout();
  }

  Future<void> _openEdit(CustomerProfile? profile) async {
    final fallback = CustomerProfile(
      id: '',
      name: context.read<AuthRepository>().userName,
      phoneNumber: context.read<AuthRepository>().storedPhone ?? '',
      addresses: const [],
      isPhoneVerified: false,
    );
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profile: profile ?? fallback),
      ),
    );
    if (mounted) context.read<AuthCubit>().fetchProfile();
  }

  Future<void> _openAddresses() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressesListScreen()),
    );
    if (!mounted) return;
    context.read<AuthCubit>().fetchProfile();
  }

  CustomerProfile? _profileFromState(AuthState state) {
    if (state is ProfileLoaded) return state.profile;
    return null;
  }

  String _languageLabel(BuildContext context) {
    switch (context.locale.languageCode) {
      case 'en':
        return 'english'.tr();
      default:
        return 'arabic'.tr();
    }
  }

  void _open(Widget screen) {
    AppFunctions.navigateTo(context, screen, PageTransitionType.rightToLeft);
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<AuthRepository>();

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          AppFunctions.navigateToAndFinish(context, const SplashScrean());
        } else if (state is AuthFailure) {
          AppFunctions.showsToast(state.message, MosaedColors.danger, context);
        } else if (state is ProfileFailure) {
          AppFunctions.showsToast(state.message, MosaedColors.danger, context);
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final profile = _profileFromState(state);
          final isLoading = state is ProfileLoading && profile == null;
          final name = profile?.name.isNotEmpty == true
              ? profile!.name
              : repo.userName;

          return Scaffold(
            backgroundColor: MosaedColors.surfaceWhite,
            appBar: AddressAppBar(
              title: LocaleKeys.mosaedMore.tr(),
              showBack: false,
              showDivider: true,
            ),
            body: isLoading
                ? Padding(
                    padding: EdgeInsets.all(20.w),
                    child: const ProfileShimmer(),
                  )
                : ProfileMenuList(
                    name: name,
                    avatarUrl: profile?.avatar,
                    languageLabel: _languageLabel(context),
                    onEdit: () => _openEdit(profile),
                    onAddresses: _openAddresses,
                    onPoints: () => _open(const PointsWalletScreen()),
                    onSettings: () => _open(const SettingsScreen()),
                    onLanguage: () => LanguageSheet.show(context),
                    onSupport: () => _open(const SupportScreen()),
                    onAbout: () => _open(const AboutScreen()),
                    onLogout: _logout,
                  ),
          );
        },
      ),
    );
  }
}
