import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/auth_navigation.dart';
import '../../../app/functions.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../../core/services/location_service.dart';
import '../../auth/presentation/widgets/mosaed_buttons.dart';
import '../../auth/presentation/widgets/mosaed_logo.dart';

class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key, this.canSkip = false});

  final bool canSkip;

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _streetController = TextEditingController();
  final _detailsController = TextEditingController();

  static const _cities = ['الرياض', 'جدة', 'الدمام', 'مكة', 'المدينة'];
  static const _districts = {
    'الرياض': ['النرجس', 'الياسمين', 'الملقا', 'العارض'],
    'جدة': ['الروضة', 'السلامة', 'الشاطئ'],
    'الدمام': ['الفيصلية', 'الشاطئ'],
    'مكة': ['العزيزية', 'النسيم'],
    'المدينة': ['العوالي', 'قباء'],
  };

  String? _selectedCity;
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    final saved = LocationService.savedLocation;
    if (saved.city.isNotEmpty) {
      _selectedCity = saved.city;
      _cityController.text = saved.city;
    }
    if (saved.district.isNotEmpty) {
      _selectedDistrict = saved.district;
      _districtController.text = saved.district;
    }
    _streetController.text = saved.street;
    _detailsController.text = saved.details ?? '';
  }

  @override
  void dispose() {
    _cityController.dispose();
    _districtController.dispose();
    _streetController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await LocationService.saveLocation(
      UserLocation(
        city: _selectedCity ?? _cityController.text.trim(),
        district: _selectedDistrict ?? _districtController.text.trim(),
        street: _streetController.text.trim(),
        details: _detailsController.text.trim(),
      ),
    );

    if (!mounted) return;
    AppFunctions.showsToast(
      'mosaedLocationSaved'.tr(),
      MosaedColors.success,
      context,
    );
    AuthNavigation.goAfterLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    final districts = _districts[_selectedCity] ?? [];

    return Scaffold(
      backgroundColor: MosaedColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'mosaedLocationTitle'.tr(),
          style: getBoldStyle(fontSize: 18.sp, color: MosaedColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: MosaedLogo(width: 180, showTagline: false)),
                SizedBox(height: 16.h),
                Text(
                  'mosaedLocationSubtitle'.tr(),
                  style: getRegularStyle(
                    fontSize: 14.sp,
                    color: MosaedColors.textSecondary,
                  ),
                ),
                SizedBox(height: 20.h),
                _label('mosaedCity'.tr()),
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: _inputDecoration('mosaedSelectCity'.tr()),
                  items: _cities
                      .map(
                        (city) => DropdownMenuItem(value: city, child: Text(city)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                      _selectedDistrict = null;
                      _cityController.text = value ?? '';
                      _districtController.clear();
                    });
                  },
                  validator: (v) =>
                      v == null || v.isEmpty ? 'mosaedCityRequired'.tr() : null,
                ),
                SizedBox(height: 14.h),
                _label('mosaedDistrict'.tr()),
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: _inputDecoration('mosaedSelectDistrict'.tr()),
                  items: districts
                      .map(
                        (d) => DropdownMenuItem(value: d, child: Text(d)),
                      )
                      .toList(),
                  onChanged: districts.isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            _selectedDistrict = value;
                            _districtController.text = value ?? '';
                          });
                        },
                  validator: (v) =>
                      v == null || v.isEmpty ? 'mosaedDistrictRequired'.tr() : null,
                ),
                SizedBox(height: 14.h),
                _label('mosaedStreet'.tr()),
                TextFormField(
                  controller: _streetController,
                  decoration: _inputDecoration('mosaedStreetHint'.tr()),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'mosaedStreetRequired'.tr() : null,
                ),
                SizedBox(height: 14.h),
                _label('mosaedLocationDetails'.tr()),
                TextFormField(
                  controller: _detailsController,
                  maxLines: 2,
                  decoration: _inputDecoration('mosaedLocationDetailsHint'.tr()),
                ),
                SizedBox(height: 24.h),
                MosaedPrimaryButton(
                  text: 'mosaedSaveLocation'.tr(),
                  icon: Icons.location_on_rounded,
                  onPressed: _save,
                ),
                if (widget.canSkip) ...[
                  SizedBox(height: 12.h),
                  MosaedOutlineButton(
                    text: 'skip'.tr(),
                    onPressed: () => AuthNavigation.goAfterLogin(context),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: getMediumStyle(fontSize: 13.sp, color: MosaedColors.textSecondary),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: MosaedColors.inputFill,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: MosaedColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: MosaedColors.primary, width: 1.5),
      ),
    );
  }
}
