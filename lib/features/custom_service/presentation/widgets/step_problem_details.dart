import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../data/models/custom_service_models.dart';
import 'custom_request_chrome.dart';

class StepProblemDetails extends StatelessWidget {
  const StepProblemDetails({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.specializations,
    required this.selectedSpecializationId,
    required this.onSpecializationChanged,
    required this.onChanged,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final List<Specialization> specializations;
  final String? selectedSpecializationId;
  final ValueChanged<String> onSpecializationChanged;
  final VoidCallback onChanged;

  static const _maxDesc = 300;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      children: [
        CustomRequestStepHeader(
          title: LocaleKeys.mosaedWhatsYourProblem.tr(),
          subtitle: LocaleKeys.mosaedCustomProblemStepSubtitle.tr(),
        ),
        SizedBox(height: 22.h),
        _label(LocaleKeys.mosaedWhatIsTheProblem.tr()),
        SizedBox(height: 8.h),
        TextField(
          controller: titleController,
          onChanged: (_) => onChanged(),
          style: getRegularStyle(
            fontSize: 13.sp,
            color: MosaedColors.textPrimary,
          ),
          decoration: _decoration(
            hint: LocaleKeys.mosaedWhatIsTheProblemHint.tr(),
          ),
        ),
        SizedBox(height: 16.h),
        _label(LocaleKeys.mosaedProblemDescription.tr()),
        SizedBox(height: 8.h),
        TextField(
          controller: descriptionController,
          onChanged: (_) => onChanged(),
          maxLines: 3,
          maxLength: _maxDesc,
          buildCounter: (
            context, {
            required currentLength,
            required isFocused,
            maxLength,
          }) {
            return Text(
              '$currentLength/${maxLength ?? _maxDesc}',
              style: getRegularStyle(
                fontSize: 11.sp,
                color: MosaedColors.textHint,
              ),
            );
          },
          style: getRegularStyle(
            fontSize: 13.sp,
            color: MosaedColors.textPrimary,
          ),
          decoration: _decoration(
            hint: LocaleKeys.mosaedProblemDescriptionHint.tr(),
          ),
        ),
        SizedBox(height: 8.h),
        _label(LocaleKeys.mosaedServiceType.tr()),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: specializations.map((s) {
            final selected = s.id == selectedSpecializationId;
            return GestureDetector(
              onTap: () => onSpecializationChanged(s.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: selected
                      ? MosaedColors.brand
                      : MosaedColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(100.r),
                  border: Border.all(
                    color: selected
                        ? MosaedColors.brand
                        : MosaedColors.fieldBorder,
                  ),
                ),
                child: Text(
                  s.name,
                  style: getMediumStyle(
                    fontSize: 12.sp,
                    color: selected ? Colors.white : MosaedColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: getMediumStyle(
          fontSize: 16.sp,
          color: MosaedColors.textPrimary,
        ),
      ),
    );
  }

  InputDecoration _decoration({required String hint}) {
    final radius = BorderRadius.circular(8.r);
    return InputDecoration(
      hintText: hint,
      hintStyle: getRegularStyle(
        fontSize: 13.sp,
        color: MosaedColors.textHint,
      ),
      filled: true,
      fillColor: MosaedColors.surfaceWhite,
      contentPadding: EdgeInsets.all(14.w),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: MosaedColors.fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: MosaedColors.brand, width: 1.4),
      ),
    );
  }
}
