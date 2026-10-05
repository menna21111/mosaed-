import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/functions.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../../core/network/failure.dart';
import '../../custom_service/presentation/widgets/custom_request_chrome.dart';
import '../../custom_service/presentation/widgets/step_location.dart';
import '../../custom_service/presentation/widgets/step_schedule.dart';
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
  static const _stepCount = 2;

  final _pageController = PageController();

  ExistedServiceDetail? _detail;
  List<CustomerAddress> _addresses = [];
  String? _selectedAddressId;
  String? _selectedAttributeId;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  int _currentStep = 0;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  CustomerAddress? get _selectedAddress {
    if (_selectedAddressId == null) return null;
    for (final a in _addresses) {
      if (a.id == _selectedAddressId) return a;
    }
    return null;
  }

  bool get _canContinueSchedule =>
      _scheduledDate != null && _scheduledTime != null;

  bool get _canConfirm => _selectedAddress != null;

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

  Future<void> _changeLocation() async {
    if (_addresses.isEmpty) {
      await _addAddress();
      return;
    }
    final picked = await showAddressPickerSheet(
      context: context,
      addresses: _addresses,
      selectedId: _selectedAddressId,
      onAddAddress: _addAddress,
    );
    if (picked != null && mounted) {
      setState(() => _selectedAddressId = picked.id);
    }
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

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void _onPrimary() {
    if (_currentStep == 0) {
      if (!_canContinueSchedule) {
        AppFunctions.showsToast(
          LocaleKeys.mosaedSelectPreferredDay.tr(),
          MosaedColors.danger,
          context,
        );
        return;
      }
      _goToStep(1);
      return;
    }
    _submit();
  }

  void _onPrevious() {
    if (_currentStep > 0) _goToStep(_currentStep - 1);
  }

  String _scheduleNotes() {
    if (_scheduledDate == null || _scheduledTime == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = _scheduledDate!.difference(today).inDays;
    String dayLabel;
    if (diff == 0) {
      dayLabel = LocaleKeys.mosaedToday.tr();
    } else if (diff == 1) {
      dayLabel = LocaleKeys.mosaedTomorrow.tr();
    } else {
      dayLabel = DateFormat('EEEE').format(_scheduledDate!);
    }
    final hour = _scheduledTime!.hourOfPeriod == 0
        ? 12
        : _scheduledTime!.hourOfPeriod;
    final period = _scheduledTime!.period == DayPeriod.am ? 'ص' : 'م';
    final mm = _scheduledTime!.minute.toString().padLeft(2, '0');
    return '${LocaleKeys.mosaedAppointment.tr()}: $dayLabel • ${DateFormat('d MMMM').format(_scheduledDate!)} • ${hour.toString().padLeft(2, '0')}:$mm $period';
  }

  Future<void> _submit() async {
    if (_scheduledDate == null || _selectedAddress == null) {
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
      items.add(BookingItemPayload(attributeId: _selectedAttributeId!));
    }

    setState(() => _submitting = true);
    try {
      final result = await context.read<ServicesRepository>().createBooking(
            CreateBookingPayload(
              serviceId: widget.serviceId,
              scheduledDate: DateFormat('yyyy-MM-dd').format(_scheduledDate!),
              notes: _scheduleNotes(),
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

  String get _primaryButtonText => _currentStep == 0
      ? LocaleKeys.mosaedContinue.tr()
      : 'mosaedConfirmRequest'.tr();

  bool get _primaryEnabled {
    if (_currentStep == 0) return _canContinueSchedule;
    return _canConfirm;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: MosaedColors.surfaceWhite,
        appBar: _bookingAppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: MosaedColors.brand),
        ),
      );
    }

    return Scaffold(
      backgroundColor: MosaedColors.surfaceWhite,
      appBar: _bookingAppBar(),
      body: Column(
        children: [
          CustomRequestProgressBar(
            currentStep: _currentStep,
            totalSteps: _stepCount,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StepSchedule(
                  selectedDate: _scheduledDate,
                  selectedTime: _scheduledTime,
                  onDateSelected: (d) => setState(() => _scheduledDate = d),
                  onTimeSelected: (t) => setState(() => _scheduledTime = t),
                ),
                StepLocation(
                  address: _selectedAddress,
                  onChangeLocation: _changeLocation,
                ),
              ],
            ),
          ),
          CustomRequestBottomBar(
            primaryText: _primaryButtonText,
            onPrimary: _primaryEnabled && !_submitting ? _onPrimary : null,
            showPrevious: _currentStep > 0,
            onPrevious: _onPrevious,
            isLoading: _submitting,
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
      centerTitle: true,
      title: Text(
        'mosaedRequestService'.tr(),
        style: getBoldStyle(
          fontSize: 16.sp,
          color: MosaedColors.textPrimary,
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: MosaedColors.textPrimary,
          size: 18.sp,
        ),
      ),
    );
  }
}
