import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/functions.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../../core/network/failure.dart';
import '../../../core/widgets/mosaed_dropdown.dart';
import '../../auth/presentation/widgets/mosaed_buttons.dart';
import '../data/models/address_models.dart';
import '../data/models/existed_service.dart';
import '../data/services_repository.dart';
import 'add_address_screen.dart';
import 'order_success_screen.dart';

class ServiceBookingScreen extends StatefulWidget {
  const ServiceBookingScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  ExistedServiceDetail? _detail;
  List<CustomerAddress> _addresses = [];
  String? _selectedAddressId;
  String? _selectedAttributeId;
  DateTime? _scheduledDate;
  final _notesController = TextEditingController();
  final _couponController = TextEditingController();
  CouponValidationResult? _appliedCoupon;
  bool _loading = true;
  bool _submitting = false;
  bool _validatingCoupon = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  CustomerAddress? get _selectedAddress {
    if (_selectedAddressId == null) return null;
    for (final a in _addresses) {
      if (a.id == _selectedAddressId) return a;
    }
    return null;
  }

  ServiceAttribute? get _selectedAttribute {
    final attrs = _detail?.attributes ?? [];
    if (_selectedAttributeId == null) return null;
    for (final attr in attrs) {
      if (attr.id == _selectedAttributeId) return attr;
    }
    return null;
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = context.read<ServicesRepository>();
      final results = await Future.wait([
        repo.getServiceDetail(widget.serviceId),
        repo.getAddresses(),
      ]);
      final detail = results[0] as ExistedServiceDetail;
      final addresses = results[1] as List<CustomerAddress>;

      final defaultId = repo.cachedDefaultAddressId;
      String? selectedAddressId;
      if (addresses.isNotEmpty) {
        final match = addresses.firstWhere(
          (a) => a.id == defaultId || a.isDefault,
          orElse: () => addresses.first,
        );
        selectedAddressId = match.id;
      }

      if (!mounted) return;
      setState(() {
        _detail = detail;
        _addresses = addresses;
        _selectedAddressId = selectedAddressId;
        if (detail.attributes.isNotEmpty) {
          _selectedAttributeId = detail.attributes.first.id;
        }
        _appliedCoupon = null;
        _loading = false;
      });
    } on ServerFailure catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppFunctions.showsToast(e.errMessage, MosaedColors.danger, context);
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        Navigator.pop(context);
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  Future<void> _addAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddAddressScreen(canSkip: true),
      ),
    );
    await _load();
  }

  Future<void> _validateCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      AppFunctions.showsToast(
        'mosaedCouponRequired'.tr(),
        MosaedColors.danger,
        context,
      );
      return;
    }

    setState(() => _validatingCoupon = true);
    try {
      // Price is set later on dashboard — validate coupon without area/total calc.
      final result = await context.read<ServicesRepository>().validateCoupon(
            code: code,
            serviceId: widget.serviceId,
            totalCost: 0,
          );
      if (!mounted) return;
      setState(() {
        _appliedCoupon = result;
        _validatingCoupon = false;
      });
      AppFunctions.showsToast(
        result.message ?? 'mosaedCouponApplied'.tr(),
        MosaedColors.success,
        context,
      );
    } on ServerFailure catch (e) {
      if (mounted) {
        setState(() {
          _appliedCoupon = null;
          _validatingCoupon = false;
        });
        AppFunctions.showsToast(e.errMessage, MosaedColors.danger, context);
      }
    }
  }

  Future<void> _submit() async {
    if (_scheduledDate == null) {
      AppFunctions.showsToast(
        'mosaedSelectDate'.tr(),
        MosaedColors.danger,
        context,
      );
      return;
    }
    if (_selectedAddress == null) {
      AppFunctions.showsToast(
        'mosaedAddressRequired'.tr(),
        MosaedColors.danger,
        context,
      );
      return;
    }

    final items = <BookingItemPayload>[];
    final attrs = _detail?.attributes ?? [];
    if (attrs.isNotEmpty) {
      if (_selectedAttributeId == null) {
        AppFunctions.showsToast(
          'mosaedSelectAttribute'.tr(),
          MosaedColors.danger,
          context,
        );
        return;
      }
      // Area/quantity is no longer collected — dashboard sets pricing later.
      items.add(
        BookingItemPayload(attributeId: _selectedAttributeId!),
      );
    }

    setState(() => _submitting = true);
    try {
      final couponCode =
          _appliedCoupon != null ? _couponController.text.trim() : '';
      final result = await context.read<ServicesRepository>().createBooking(
            CreateBookingPayload(
              serviceId: widget.serviceId,
              scheduledDate: DateFormat('yyyy-MM-dd').format(_scheduledDate!),
              notes: _notesController.text.trim(),
              couponCode: couponCode,
              addressId: _selectedAddress!.id,
              items: items,
            ),
          );
      if (!mounted) return;
      final bookingId =
          result['id']?.toString() ?? result['booking_id']?.toString();
      AppFunctions.navigateToAndFinish(
        context,
        OrderSuccessScreen(bookingId: bookingId),
      );
    } on ServerFailure catch (e) {
      if (mounted) {
        AppFunctions.showsToast(e.errMessage, MosaedColors.danger, context);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: getBoldStyle(fontSize: 17.sp, color: MosaedColors.textPrimary),
    );
  }

  Widget _surfaceCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: MosaedColors.outlineVariant),
        boxShadow: MosaedColors.softShadow,
      ),
      child: child,
    );
  }

  Widget _pricePendingBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: MosaedColors.shieldBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: MosaedColors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: MosaedColors.primary,
            size: 22.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'mosaedPriceSetByDashboard'.tr(),
              style: getMediumStyle(
                fontSize: 13.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: MosaedColors.background,
        appBar: _bookingAppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: MosaedColors.primaryContainer),
        ),
      );
    }

    final detail = _detail!;
    final selectedAddress = _selectedAddress;

    return Scaffold(
      backgroundColor: MosaedColors.background,
      appBar: _bookingAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('mosaedSelectAppointment'.tr()),
                  SizedBox(height: 10.h),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12.r),
                    child: _surfaceCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _scheduledDate == null
                                ? 'mosaedSelectDate'.tr()
                                : DateFormat('dd-MM-yyyy')
                                    .format(_scheduledDate!),
                            style: getRegularStyle(
                              fontSize: 15.sp,
                              color: _scheduledDate == null
                                  ? MosaedColors.textSecondary
                                  : MosaedColors.textPrimary,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today_rounded,
                            color: MosaedColors.primary,
                            size: 22.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _sectionTitle('mosaedSelectAddress'.tr()),
                  SizedBox(height: 10.h),
                  _surfaceCard(
                    child: Column(
                      children: [
                        MosaedDropdown<String>(
                          title: '',
                          hint: 'mosaedSelectAddress'.tr(),
                          icon: Icons.location_on_outlined,
                          selectedValue: _selectedAddressId,
                          items: _addresses
                              .map(
                                (a) => MosaedDropdownItem(
                                  value: a.id,
                                  label: a.fullAddress,
                                ),
                              )
                              .toList(),
                          onSelected: (value) =>
                              setState(() => _selectedAddressId = value),
                        ),
                        if (selectedAddress != null) ...[
                          SizedBox(height: 8.h),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              selectedAddress.fullAddress,
                              style: getRegularStyle(
                                fontSize: 12.sp,
                                color: MosaedColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addAddress,
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: MosaedColors.primary,
                    ),
                    label: Text(
                      'mosaedAddAddress'.tr(),
                      style: getBoldStyle(
                        fontSize: 13.sp,
                        color: MosaedColors.primary,
                      ),
                    ),
                  ),
                  if (detail.attributes.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    _sectionTitle('mosaedServiceAttributes'.tr()),
                    SizedBox(height: 10.h),
                    _surfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MosaedDropdown<String>(
                            title: '',
                            hint: 'mosaedSelectAttribute'.tr(),
                            icon: Icons.tune_rounded,
                            selectedValue: _selectedAttributeId,
                            items: detail.attributes
                                .map(
                                  (attr) => MosaedDropdownItem(
                                    value: attr.id,
                                    label: attr.name,
                                  ),
                                )
                                .toList(),
                            onSelected: (value) => setState(() {
                              _selectedAttributeId = value;
                              _appliedCoupon = null;
                            }),
                          ),
                          if (_selectedAttribute?.details
                                  ?.trim()
                                  .isNotEmpty ==
                              true) ...[
                            SizedBox(height: 10.h),
                            Text(
                              _selectedAttribute!.details!,
                              style: getRegularStyle(
                                fontSize: 13.sp,
                                color: MosaedColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  _pricePendingBanner(),
                  SizedBox(height: 20.h),
                  _sectionTitle('mosaedCouponOptional'.tr()),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _couponController,
                          onChanged: (_) =>
                              setState(() => _appliedCoupon = null),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'mosaedCouponHint'.tr(),
                            filled: true,
                            fillColor: MosaedColors.surfaceWhite,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: MosaedColors.outlineVariant,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: MosaedColors.outlineVariant,
                              ),
                            ),
                            suffixIcon: _appliedCoupon != null
                                ? Icon(
                                    Icons.check_circle,
                                    color: MosaedColors.success,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      ElevatedButton(
                        onPressed: _validatingCoupon ? null : _validateCoupon,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MosaedColors.primaryContainer,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        child: _validatingCoupon
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'mosaedApplyCoupon'.tr(),
                                style: getBoldStyle(
                                  fontSize: 13.sp,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _sectionTitle('notesOptional'.tr()),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'notesHint'.tr(),
                      filled: true,
                      fillColor: MosaedColors.surfaceWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: MosaedColors.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
            decoration: BoxDecoration(
              color: MosaedColors.surfaceWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'mosaedTermsAgree'.tr(),
                    textAlign: TextAlign.center,
                    style: getRegularStyle(
                      fontSize: 11.sp,
                      color: MosaedColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: double.infinity,
                    child: MosaedPrimaryButton(
                      text: 'mosaedConfirmRequest'.tr(),
                      icon: Icons.check_rounded,
                      isLoading: _submitting,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _bookingAppBar() {
    return AppBar(
      backgroundColor: MosaedColors.surfaceWhite,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Text(
            'mosaedAppName'.tr(),
            style: getBoldStyle(
              fontSize: 18.sp,
              color: MosaedColors.primary,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: MosaedColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.home_repair_service_rounded,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
        ],
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.chevron_right_rounded,
          color: MosaedColors.textPrimary,
          size: 28.sp,
        ),
      ),
    );
  }
}
