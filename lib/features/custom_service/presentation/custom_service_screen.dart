import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/functions.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../../core/network/failure.dart';
import '../../auth/presentation/widgets/mosaed_buttons.dart';
import '../../home/presentation/main_shell.dart';
import '../../services/data/models/address_models.dart';
import '../../services/data/services_repository.dart';
import '../../services/presentation/add_address_screen.dart';
import '../data/custom_service_repository.dart';
import '../data/models/custom_service_models.dart';

class CustomServiceScreen extends StatefulWidget {
  const CustomServiceScreen({super.key});

  @override
  State<CustomServiceScreen> createState() => _CustomServiceScreenState();
}

class _CustomServiceScreenState extends State<CustomServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  static const _brandShadow = Color(0x14BD5E19);
  static const _pageCount = 3;

  List<Specialization> _specializations = [];
  List<CustomerAddress> _addresses = [];
  String? _selectedSpecializationId;
  String? _selectedAddressId;
  DateTime? _scheduledDate;
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  File? _pickedImage;
  int _currentPage = 0;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final servicesRepo = context.read<ServicesRepository>();
      final customRepo = context.read<CustomServiceRepository>();

      final results = await Future.wait([
        customRepo.getSpecializations(),
        servicesRepo.getAddresses(),
      ]);

      final specializations = results[0] as List<Specialization>;
      final addresses = results[1] as List<CustomerAddress>;
      final defaultId = servicesRepo.cachedDefaultAddressId;

      String? selectedAddressId;
      if (addresses.isNotEmpty) {
        selectedAddressId = addresses
            .firstWhere(
              (a) => a.id == defaultId || a.isDefault,
              orElse: () => addresses.first,
            )
            .id;
      }

      if (!mounted) return;
      setState(() {
        _specializations = specializations;
        _addresses = addresses;
        _selectedAddressId = selectedAddressId;
        if (specializations.isNotEmpty) {
          _selectedSpecializationId ??= specializations.first.id;
        }
        _loading = false;
      });
    } on ServerFailure catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppFunctions.showsToast(e.errMessage, MosaedColors.danger, context);
      }
    }
  }

  Future<void> _addAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddAddressScreen(canSkip: true),
      ),
    );
    await _loadData();
  }

  Future<void> _showImageSourceSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: MosaedColors.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text('mosaedPickFromGallery'.tr()),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text('mosaedTakePhoto'.tr()),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() => _pickedImage = File(picked.path));
    } catch (_) {
      if (!mounted) return;
      AppFunctions.showsToast(
        'mosaedImagePickError'.tr(),
        MosaedColors.danger,
        context,
      );
    }
  }

  void _removeImage() => setState(() => _pickedImage = null);

  CustomerAddress? get _selectedAddress {
    if (_selectedAddressId == null) return null;
    for (final a in _addresses) {
      if (a.id == _selectedAddressId) return a;
    }
    return null;
  }

  String get _appBarTitle {
    switch (_currentPage) {
      case 1:
        return 'mosaedAddNewRequest'.tr();
      case 2:
        return 'mosaedLocationAndDate'.tr();
      default:
        return 'mosaedCustomServiceTitle'.tr();
    }
  }

  bool _validatePage(int page) {
    if (page == 0) {
      if (!_formKey.currentState!.validate()) return false;
      if (_selectedSpecializationId == null ||
          _selectedSpecializationId!.isEmpty) {
        AppFunctions.showsToast(
          'mosaedSelectSpecialization'.tr(),
          MosaedColors.danger,
          context,
        );
        return false;
      }
      return true;
    }
    if (page == 2) {
      if (_scheduledDate == null) {
        AppFunctions.showsToast(
          'mosaedSelectPreferredDay'.tr(),
          MosaedColors.danger,
          context,
        );
        return false;
      }
      if (_selectedAddressId == null) {
        AppFunctions.showsToast(
          'mosaedAddressRequired'.tr(),
          MosaedColors.danger,
          context,
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _goToPage(int page) async {
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _onBack() {
    if (_submitting) return;
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
      return;
    }
    Navigator.pop(context);
  }

  void _onNext() {
    if (_submitting) return;
    if (!_validatePage(_currentPage)) return;
    if (_currentPage < _pageCount - 1) {
      _goToPage(_currentPage + 1);
    }
  }

  Future<void> _submit() async {
    if (!_validatePage(0) || !_validatePage(2)) return;

    setState(() => _submitting = true);
    try {
      await context.read<CustomServiceRepository>().createCustomRequest(
            CustomRequestPayload(
              specializationId: _selectedSpecializationId!,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              scheduledDate: DateFormat('yyyy-MM-dd').format(_scheduledDate!),
              addressId: _selectedAddressId!,
              imageFile: _pickedImage,
            ),
          );
      if (!mounted) return;
      AppFunctions.showsToast(
        'mosaedCustomServiceSuccess'.tr(),
        MosaedColors.success,
        context,
      );
      AppFunctions.navigateToAndFinish(
        context,
        const MainShell(initialIndex: 1),
      );
    } on ServerFailure catch (e) {
      if (mounted) {
        AppFunctions.showsToast(e.errMessage, MosaedColors.danger, context);
      }
    } catch (_) {
      if (mounted) {
        AppFunctions.showsToast(
          'mosaedCustomServiceError'.tr(),
          MosaedColors.danger,
          context,
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _submitting;

    return Scaffold(
      backgroundColor: MosaedColors.background,
      appBar: AppBar(
        backgroundColor: MosaedColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: isBusy ? null : _onBack,
          icon: Icon(
            Icons.arrow_forward_rounded,
            color: MosaedColors.onSurfaceVariant,
            size: 22.sp,
          ),
        ),
        title: Text(
          _appBarTitle,
          style: getBoldStyle(fontSize: 18.sp, color: MosaedColors.textPrimary),
        ),
        centerTitle: _currentPage == 1,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: MosaedColors.primaryContainer,
              ),
            )
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_currentPage > 0) _progressBars(),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pageCount,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        return switch (index) {
                          0 => _buildDetailsPage(),
                          1 => _buildPhotosPage(),
                          _ => _buildLocationDatePage(),
                        };
                      },
                    ),
                  ),
                  _buildBottomBar(isBusy),
                ],
              ),
            ),
    );
  }

  Widget _progressBars() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pageCount, (i) {
          final active = i <= _currentPage;
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            height: 8.h,
            width: 56.w,
            decoration: BoxDecoration(
              color: active ? MosaedColors.primary : const Color(0xFFEAE7E7),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: _brandShadow,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _fieldDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: getRegularStyle(
        fontSize: 14.sp,
        color: MosaedColors.onSurfaceVariant.withValues(alpha: 0.7),
      ),
      filled: true,
      fillColor: MosaedColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: MosaedColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: MosaedColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: MosaedColors.danger, width: 1.5),
      ),
      contentPadding: EdgeInsets.all(12.w),
    );
  }

  Widget _buildDetailsPage() {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB85A15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(
                      Icons.manage_accounts_rounded,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'mosaedCustomServiceHomeDesc'.tr(),
                      style: getRegularStyle(
                        fontSize: 14.sp,
                        color: MosaedColors.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _titleController,
                textAlign: TextAlign.right,
                enabled: !_submitting,
                style: getRegularStyle(
                  fontSize: 16.sp,
                  color: MosaedColors.textPrimary,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'fieldRequired'.tr() : null,
                decoration: _fieldDecoration(
                  hint: 'mosaedCustomProblemHint'.tr(),
                ),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _descriptionController,
                textAlign: TextAlign.right,
                enabled: !_submitting,
                maxLines: 3,
                style: getRegularStyle(
                  fontSize: 14.sp,
                  color: MosaedColors.textPrimary,
                ),
                decoration: _fieldDecoration(
                  hint: 'mosaedCustomDescriptionOptionalHint'.tr(),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'mosaedSpecialization'.tr(),
                style: getBoldStyle(
                  fontSize: 12.sp,
                  color: MosaedColors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 8.h,
                children: _specializations.map((s) {
                  final selected = s.id == _selectedSpecializationId;
                  return GestureDetector(
                    onTap: _submitting
                        ? null
                        : () =>
                            setState(() => _selectedSpecializationId = s.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFB85A15)
                            : const Color(0xFFE7E1DE),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected
                              ? MosaedColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        s.name,
                        style: getMediumStyle(
                          fontSize: 12.sp,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF676462),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosPage() {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        Text(
          'mosaedAddPhotosTitle'.tr(),
          textAlign: TextAlign.right,
          style: getBoldStyle(fontSize: 20.sp, color: MosaedColors.textPrimary),
        ),
        SizedBox(height: 8.h),
        Text(
          'mosaedAddPhotosDesc'.tr(),
          textAlign: TextAlign.right,
          style: getRegularStyle(
            fontSize: 14.sp,
            color: MosaedColors.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        SizedBox(height: 24.h),
        GestureDetector(
          onTap: _submitting ? null : _showImageSourceSheet,
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: MosaedColors.outlineVariant,
              radius: 16.r,
            ),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 220.h),
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                color: MosaedColors.surfaceWhite,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: _pickedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB85A15),
                            shape: BoxShape.circle,
                            boxShadow: MosaedColors.softShadow,
                          ),
                          child: Icon(
                            Icons.add_a_photo_rounded,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'mosaedTapToCaptureOrPick'.tr(),
                          style: getBoldStyle(
                            fontSize: 14.sp,
                            color: MosaedColors.primary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'mosaedSupportedFormats'.tr(),
                          textAlign: TextAlign.center,
                          style: getRegularStyle(
                            fontSize: 12.sp,
                            color: MosaedColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.file(
                            _pickedImage!,
                            width: double.infinity,
                            height: 180.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8.h,
                          left: 8.w,
                          child: InkWell(
                            onTap: _submitting ? null : _removeImage,
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8.h,
                          right: 8.w,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                            ),
                            onPressed:
                                _submitting ? null : _showImageSourceSheet,
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label: Text('mosaedChangePhoto'.tr()),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'mosaedPhotosAddedCount'.tr(
            namedArgs: {'count': _pickedImage == null ? '0' : '1'},
          ),
          textAlign: TextAlign.right,
          style: getBoldStyle(fontSize: 14.sp, color: MosaedColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildLocationDatePage() {
    final address = _selectedAddress;
    final locale = context.locale.languageCode;
    final monthLabel = DateFormat('MMMM yyyy', locale).format(_visibleMonth);
    final weekdayLabels = locale == 'ar'
        ? const ['أحد', 'إثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت']
        : const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        Text(
          'mosaedSetLocation'.tr(),
          style: getBoldStyle(fontSize: 20.sp, color: MosaedColors.primary),
        ),
        SizedBox(height: 12.h),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 140.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE7E7),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.map_outlined,
                        size: 44.sp,
                        color: MosaedColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    Positioned(
                      bottom: 12.h,
                      right: 12.w,
                      child: Material(
                        color: MosaedColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(999),
                        elevation: 2,
                        child: InkWell(
                          onTap: _submitting ? null : _addAddress,
                          borderRadius: BorderRadius.circular(999),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_location_alt_outlined,
                                  size: 18.sp,
                                  color: MosaedColors.primary,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'mosaedAddAddress'.tr(),
                                  style: getBoldStyle(
                                    fontSize: 12.sp,
                                    color: MosaedColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'mosaedAddressDetail'.tr(),
                style: getBoldStyle(
                  fontSize: 12.sp,
                  color: MosaedColors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 8.h),
              if (_addresses.isEmpty)
                Text(
                  'mosaedAddressRequired'.tr(),
                  style: getRegularStyle(
                    fontSize: 13.sp,
                    color: MosaedColors.danger,
                  ),
                )
              else
                ..._addresses.map((a) {
                  final selected = a.id == _selectedAddressId;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: InkWell(
                      onTap: _submitting
                          ? null
                          : () => setState(() => _selectedAddressId = a.id),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: MosaedColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: selected
                                ? MosaedColors.primary
                                : MosaedColors.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: selected
                                  ? MosaedColors.primary
                                  : MosaedColors.onSurfaceVariant,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                a.fullAddress,
                                style: getRegularStyle(
                                  fontSize: 13.sp,
                                  color: MosaedColors.textPrimary,
                                ),
                              ),
                            ),
                            if (selected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: MosaedColors.primary,
                                size: 18.sp,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              if (address != null &&
                  ((address.buildingNo?.isNotEmpty ?? false) ||
                      (address.apartmentNo?.isNotEmpty ?? false))) ...[
                SizedBox(height: 4.h),
                Text(
                  'mosaedExtraAddressDetails'.tr(),
                  style: getBoldStyle(
                    fontSize: 12.sp,
                    color: MosaedColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: MosaedColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: MosaedColors.outlineVariant),
                  ),
                  child: Text(
                    [
                      if (address.buildingNo?.isNotEmpty ?? false)
                        '${'mosaedBuildingNo'.tr()}: ${address.buildingNo}',
                      if (address.floorNo?.isNotEmpty ?? false)
                        '${'mosaedFloorNo'.tr()}: ${address.floorNo}',
                      if (address.apartmentNo?.isNotEmpty ?? false)
                        '${'mosaedApartmentNo'.tr()}: ${address.apartmentNo}',
                    ].join(' • '),
                    style: getRegularStyle(
                      fontSize: 13.sp,
                      color: MosaedColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'mosaedSetAppointment'.tr(),
          style: getBoldStyle(fontSize: 20.sp, color: MosaedColors.primary),
        ),
        SizedBox(height: 12.h),
        _card(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthLabel,
                    style: getBoldStyle(
                      fontSize: 14.sp,
                      color: MosaedColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      _monthNavButton(
                        icon: Icons.chevron_right_rounded,
                        onTap: () {
                          setState(() {
                            _visibleMonth = DateTime(
                              _visibleMonth.year,
                              _visibleMonth.month - 1,
                            );
                          });
                        },
                      ),
                      SizedBox(width: 4.w),
                      _monthNavButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: () {
                          setState(() {
                            _visibleMonth = DateTime(
                              _visibleMonth.year,
                              _visibleMonth.month + 1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: weekdayLabels
                    .map(
                      (d) => Expanded(
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: getBoldStyle(
                            fontSize: 12.sp,
                            color: MosaedColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 8.h),
              _buildCalendarGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _monthNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _submitting ? null : onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: const BoxDecoration(
          color: Color(0xFFF0EDED),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18.sp, color: MosaedColors.textPrimary),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final first = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final leading = first.weekday % 7;
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final prevMonthDays =
        DateTime(_visibleMonth.year, _visibleMonth.month, 0).day;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final cells = <_CalCell>[];
    for (var i = leading; i > 0; i--) {
      cells.add(
        _CalCell(
          day: prevMonthDays - i + 1,
          date: DateTime(
            _visibleMonth.year,
            _visibleMonth.month - 1,
            prevMonthDays - i + 1,
          ),
          inMonth: false,
        ),
      );
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(
        _CalCell(
          day: d,
          date: DateTime(_visibleMonth.year, _visibleMonth.month, d),
          inMonth: true,
        ),
      );
    }
    var nextDay = 1;
    while (cells.length % 7 != 0) {
      cells.add(
        _CalCell(
          day: nextDay,
          date: DateTime(
            _visibleMonth.year,
            _visibleMonth.month + 1,
            nextDay,
          ),
          inMonth: false,
        ),
      );
      nextDay++;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cells.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final cell = cells[index];
        final isPast = cell.date.isBefore(todayDate);
        final selected = _scheduledDate != null &&
            _scheduledDate!.year == cell.date.year &&
            _scheduledDate!.month == cell.date.month &&
            _scheduledDate!.day == cell.date.day;
        final enabled = cell.inMonth && !isPast && !_submitting;

        return GestureDetector(
          onTap: !enabled
              ? null
              : () => setState(() => _scheduledDate = cell.date),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: selected ? MosaedColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: MosaedColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '${cell.day}',
              style: getRegularStyle(
                fontSize: 14.sp,
                color: selected
                    ? Colors.white
                    : !enabled
                        ? MosaedColors.onSurfaceVariant.withValues(alpha: 0.3)
                        : MosaedColors.textPrimary,
              ).copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(bool isBusy) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: _brandShadow,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: switch (_currentPage) {
          0 => MosaedPrimaryButton(
              text: 'next'.tr(),
              icon: Icons.arrow_back_ios_new_rounded,
              onPressed: isBusy ? null : _onNext,
            ),
          1 => Row(
              children: [
                Expanded(
                  child: MosaedOutlineButton(
                    text: 'mosaedSkip'.tr(),
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: isBusy ? null : _onNext,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: MosaedPrimaryButton(
                    text: 'next'.tr(),
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: isBusy ? null : _onNext,
                  ),
                ),
              ],
            ),
          _ => MosaedPrimaryButton(
              text: 'mosaedPublishRequestNow'.tr(),
              icon: Icons.publish_rounded,
              isLoading: isBusy,
              onPressed: isBusy ? null : _submit,
            ),
        },
      ),
    );
  }
}

class _CalCell {
  const _CalCell({
    required this.day,
    required this.date,
    required this.inMonth,
  });

  final int day;
  final DateTime date;
  final bool inMonth;
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dashWidth = 7.0;
    const dashSpace = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
