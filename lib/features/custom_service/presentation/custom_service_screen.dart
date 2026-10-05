import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

import '../../../app/functions.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../../core/network/failure.dart';
import '../../services/data/models/address_models.dart';
import '../../services/data/services_repository.dart';
import '../../services/presentation/add_address_screen.dart';
import '../data/custom_service_repository.dart';
import '../data/models/custom_service_models.dart';
import 'custom_request_publishing_screen.dart';
import 'widgets/custom_request_chrome.dart';
import 'widgets/step_location.dart';
import 'widgets/step_photos.dart';
import 'widgets/step_problem_details.dart';
import 'widgets/step_review.dart';
import 'widgets/step_schedule.dart';

class CustomServiceScreen extends StatefulWidget {
  const CustomServiceScreen({super.key, this.initialDescription});

  final String? initialDescription;

  @override
  State<CustomServiceScreen> createState() => _CustomServiceScreenState();
}

class _CustomServiceScreenState extends State<CustomServiceScreen> {
  final _pageController = PageController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  static const _pageCount = 4;
  static const _maxPhotos = 5;

  List<Specialization> _specializations = [];
  List<CustomerAddress> _addresses = [];
  String? _selectedSpecializationId;
  String? _selectedAddressId;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  final List<File> _pickedImages = [];
  int _currentPage = 0;
  bool _loading = true;
  bool _showingReview = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDescription?.trim();
    if (initial != null && initial.isNotEmpty) {
      _descriptionController.text = initial;
      _titleController.text =
          initial.length > 40 ? '${initial.substring(0, 40)}…' : initial;
    }
    _titleController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
    _loadData();
  }

  void _onFormChanged() => setState(() {});

  @override
  void dispose() {
    _titleController.removeListener(_onFormChanged);
    _descriptionController.removeListener(_onFormChanged);
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
        _selectedAddressId = selectedAddressId ?? _selectedAddressId;
        _loading = false;
      });
    } on ServerFailure catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppFunctions.showsToast(e.errMessage, MosaedColors.danger, context);
      }
    }
  }

  CustomerAddress? get _selectedAddress {
    if (_selectedAddressId == null) return null;
    for (final a in _addresses) {
      if (a.id == _selectedAddressId) return a;
    }
    return null;
  }

  Specialization? get _selectedSpecialization {
    if (_selectedSpecializationId == null) return null;
    for (final s in _specializations) {
      if (s.id == _selectedSpecializationId) return s;
    }
    return null;
  }

  bool get _canContinueStep0 =>
      _titleController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty &&
      _selectedSpecializationId != null;

  bool get _canContinueStep1 => _pickedImages.isNotEmpty;

  bool get _canContinueStep2 => _selectedAddressId != null;

  bool get _canContinueStep3 =>
      _scheduledDate != null && _scheduledTime != null;

  bool get _canPrimary {
    if (_showingReview) {
      return _canContinueStep0 &&
          _canContinueStep1 &&
          _canContinueStep2 &&
          _canContinueStep3;
    }
    switch (_currentPage) {
      case 0:
        return _canContinueStep0;
      case 1:
        return _canContinueStep1;
      case 2:
        return _canContinueStep2;
      case 3:
        return _canContinueStep3;
      default:
        return false;
    }
  }

  String get _primaryText {
    if (_showingReview) return LocaleKeys.mosaedPublish.tr();
    if (_currentPage == 1 && !_canContinueStep1) {
      return LocaleKeys.mosaedAddAtLeastOnePhoto.tr();
    }
    return LocaleKeys.mosaedContinue.tr();
  }

  Future<void> _goToPage(int page) async {
    void jump() {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.jumpToPage(page);
    }

    if (_pageController.hasClients) {
      await _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => jump());
  }

  void _onBack() {
    if (_showingReview) {
      setState(() => _showingReview = false);
      return;
    }
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
      return;
    }
    Navigator.pop(context);
  }

  void _onPrimary() {
    if (!_canPrimary) return;
    if (_showingReview) {
      _submit();
      return;
    }
    if (_currentPage < _pageCount - 1) {
      _goToPage(_currentPage + 1);
      return;
    }
    setState(() => _showingReview = true);
  }

  void _editFromReview(int page) {
    if (_pageController.hasClients) {
      _pageController.jumpToPage(page);
    }
    setState(() => _showingReview = false);
  }

  Future<void> _pickImages() async {
    final source = await showPhotoSourceSheet(context);
    if (source == null || !mounted) return;
    if (_pickedImages.length >= _maxPhotos) {
      AppFunctions.showsToast(
        LocaleKeys.mosaedMaxPhotosReached.tr(),
        MosaedColors.danger,
        context,
      );
      return;
    }
    try {
      if (source == ImageSource.gallery) {
        final remaining = _maxPhotos - _pickedImages.length;
        final picked = await _imagePicker.pickMultiImage(
          maxWidth: 1600,
          imageQuality: 85,
        );
        if (picked.isEmpty) return;
        setState(() {
          _pickedImages.addAll(
            picked.take(remaining).map((x) => File(x.path)),
          );
        });
        return;
      }
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() => _pickedImages.add(File(picked.path)));
    } catch (_) {
      if (!mounted) return;
      AppFunctions.showsToast(
        LocaleKeys.mosaedImagePickError.tr(),
        MosaedColors.danger,
        context,
      );
    }
  }

  Future<void> _changeLocation() async {
    final picked = await showAddressPickerSheet(
      context: context,
      addresses: _addresses,
      selectedId: _selectedAddressId,
      onAddAddress: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddAddressScreen(canSkip: true),
          ),
        );
        await _loadData();
      },
    );
    if (picked != null && mounted) {
      setState(() => _selectedAddressId = picked.id);
    }
  }

  Future<void> _submit() async {
    if (!_canPrimary) return;

    final payload = CustomRequestPayload(
      specializationId: _selectedSpecializationId!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      scheduledDate: DateFormat('yyyy-MM-dd').format(_scheduledDate!),
      addressId: _selectedAddressId!,
      imageFiles: List<File>.from(_pickedImages),
    );

    AppFunctions.navigateTo(
      context,
      CustomRequestPublishingScreen(payload: payload),
      PageTransitionType.fade,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MosaedColors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: MosaedColors.surfaceWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: _onBack,
          icon: Icon(
            Icons.arrow_forward_ios_rounded,
            color: MosaedColors.textPrimary,
            size: 18.sp,
          ),
        ),
        title: Text(
          LocaleKeys.mosaedCustomServiceTitle.tr(),
          style: getBoldStyle(
            fontSize: 16.sp,
            color: MosaedColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Divider(height: 1, color: MosaedColors.fieldBorder),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: MosaedColors.brand),
            )
          : Column(
              children: [
                if (!_showingReview) ...[
                  SizedBox(height: 10.h),
                  CustomRequestProgressBar(
                    currentStep: _currentPage,
                    totalSteps: _pageCount,
                  ),
                  SizedBox(height: 10.h),
                ],
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Offstage(
                        offstage: _showingReview,
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (i) =>
                              setState(() => _currentPage = i),
                          children: [
                            StepProblemDetails(
                              titleController: _titleController,
                              descriptionController: _descriptionController,
                              specializations: _specializations,
                              selectedSpecializationId:
                                  _selectedSpecializationId,
                              onSpecializationChanged: (id) => setState(
                                () => _selectedSpecializationId = id,
                              ),
                              onChanged: () => setState(() {}),
                            ),
                            StepPhotos(
                              images: _pickedImages,
                              maxPhotos: _maxPhotos,
                              onAdd: _pickImages,
                              onRemove: (i) =>
                                  setState(() => _pickedImages.removeAt(i)),
                            ),
                            StepLocation(
                              address: _selectedAddress,
                              onChangeLocation: _changeLocation,
                            ),
                            StepSchedule(
                              selectedDate: _scheduledDate,
                              selectedTime: _scheduledTime,
                              onDateSelected: (d) =>
                                  setState(() => _scheduledDate = d),
                              onTimeSelected: (t) =>
                                  setState(() => _scheduledTime = t),
                            ),
                          ],
                        ),
                      ),
                      if (_showingReview)
                        StepReview(
                          title: _titleController.text.trim(),
                          description: _descriptionController.text.trim(),
                          specialization: _selectedSpecialization,
                          images: _pickedImages,
                          address: _selectedAddress,
                          scheduledDate: _scheduledDate,
                          scheduledTime: _scheduledTime,
                          onEditStep: _editFromReview,
                        ),
                    ],
                  ),
                ),
                CustomRequestBottomBar(
                  primaryText: _primaryText,
                  showPrevious: _showingReview || _currentPage > 0,
                  onPrevious: _onBack,
                  onPrimary: _canPrimary ? _onPrimary : null,
                ),
              ],
            ),
    );
  }
}
