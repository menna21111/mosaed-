import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../app/functions.dart';
import '../../../core/caching/cach_helper.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../../core/network/failure.dart';
import '../../../core/widgets/mosaed_confirm_dialog.dart';
import '../../home/presentation/main_shell.dart';
import '../data/models/address_models.dart';
import '../data/services_repository.dart';
import 'add_address_screen.dart';
import 'edit_address_screen.dart';
import 'pick_location_map_screen.dart';
import 'widgets/address_chrome.dart';
import 'widgets/address_list_card.dart';
import 'widgets/addresses_add_bar.dart';
import 'widgets/addresses_empty_state.dart';
import 'widgets/location_prompt_sheet.dart';

class AddressesListScreen extends StatefulWidget {
  const AddressesListScreen({
    super.key,
    this.showLocationPromptOnOpen = false,
    this.onboarding = false,
  });

  /// Opens the "حدد موقعك" sheet after the first frame.
  final bool showLocationPromptOnOpen;

  /// After save / later → mark setup done and go home.
  final bool onboarding;

  @override
  State<AddressesListScreen> createState() => _AddressesListScreenState();
}

class _AddressesListScreenState extends State<AddressesListScreen> {
  List<CustomerAddress> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    if (widget.showLocationPromptOnOpen || widget.onboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openAddFlow();
      });
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await context.read<ServicesRepository>().getAddresses();
      if (mounted) {
        setState(() {
          _addresses = [...list]..sort((a, b) {
              if (a.isDefault == b.isDefault) return 0;
              return a.isDefault ? -1 : 1;
            });
          _loading = false;
        });
      }
    } on ServerFailure catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppFunctions.showsToast(e.errMessage, MosaedColors.danger, context);
      }
    }
  }

  Future<void> _finishOnboarding() async {
    await CacheHelper().saveData(
      key: AppConstants.locationSetupDoneKey,
      value: true,
    );
    if (!mounted) return;
    AppFunctions.navigateToAndFinish(context, const MainShell());
  }

  Future<void> _openAddFlow() async {
    final action = await LocationPromptSheet.show(context);
    if (!mounted || action == null) return;

    switch (action) {
      case LocationPromptAction.later:
        if (widget.onboarding) await _finishOnboarding();
        return;
      case LocationPromptAction.currentLocation:
        await _addViaCurrentLocation();
      case LocationPromptAction.manual:
        await _addManually();
    }
  }

  Future<void> _addViaCurrentLocation() async {
    final picked = await PickLocationMapScreen.open(
      context,
      goToCurrentOnStart: true,
    );
    if (!mounted || picked == null) return;
    await _openAddAddressForm(initialPosition: picked);
  }

  Future<void> _addManually() async {
    await _openAddAddressForm();
  }

  Future<void> _openAddAddressForm({LatLng? initialPosition}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddAddressScreen(
          canSkip: true,
          initialPosition: initialPosition,
        ),
      ),
    );
    if (!mounted) return;
    if (saved == true) {
      if (widget.onboarding) {
        await _finishOnboarding();
      } else {
        await _load();
      }
    }
  }

  Future<void> _edit(CustomerAddress address) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditAddressScreen(address: address),
      ),
    );
    if (updated == true && mounted) await _load();
  }

  Future<void> _confirmDelete(CustomerAddress address) async {
    final confirmed = await showMosaedConfirmDialog(
      context,
      title: LocaleKeys.mosaedDeleteAddressTitle.tr(),
      message: LocaleKeys.mosaedDeleteAddressBody.tr(),
      confirmText: LocaleKeys.mosaedDelete.tr(),
    );
    if (!confirmed || !mounted) return;
    await _delete(address.id);
  }

  Future<void> _delete(String id) async {
    try {
      await context.read<ServicesRepository>().deleteAddress(id);
      await _load();
      if (mounted) {
        AppFunctions.showsToast(
          LocaleKeys.mosaedAddressDeleted.tr(),
          MosaedColors.success,
          context,
        );
      }
    } on ServerFailure catch (e) {
      if (mounted) {
        AppFunctions.showsToast(e.errMessage, MosaedColors.danger, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MosaedColors.surfaceWhite,
      appBar: AddressAppBar(
        title: LocaleKeys.mosaedMyAddresses.tr(),
        showBack: !widget.onboarding,
        showDivider: true,
        actions: [
          if (widget.onboarding)
            TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                LocaleKeys.mosaedLater.tr(),
                style: getBoldStyle(
                  fontSize: 13.sp,
                  color: MosaedColors.brand,
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: MosaedColors.brand),
            )
          : RefreshIndicator(
              color: MosaedColors.brand,
              onRefresh: _load,
              child: _addresses.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 80.h),
                        const AddressesEmptyState(),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                      itemCount: _addresses.length,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final a = _addresses[index];
                        return AddressListCard(
                          address: a,
                          onEdit: () => _edit(a),
                          onDelete:
                              a.isDefault ? null : () => _confirmDelete(a),
                        );
                      },
                    ),
            ),
      bottomNavigationBar:
          _loading ? null : AddressesAddBar(onAdd: _openAddFlow),
    );
  }
}
