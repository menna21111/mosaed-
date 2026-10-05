import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/locale_keys.dart';
import '../../../../../core/constants/mosaed_colors.dart';
import '../../../../../core/constants/styles_manager.dart';
import '../../../../auth/presentation/widgets/mosaed_buttons.dart';
import 'rating_success_sheet.dart';

class TechnicianRatingSheet extends StatefulWidget {
  const TechnicianRatingSheet({
    super.key,
    required this.technicianName,
    this.technicianImage,
    required this.onSubmit,
  });

  final String technicianName;
  final String? technicianImage;
  final Future<void> Function(int stars, String comment) onSubmit;

  static Future<bool?> show(
    BuildContext context, {
    required String technicianName,
    String? technicianImage,
    required Future<void> Function(int stars, String comment) onSubmit,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => TechnicianRatingSheet(
        technicianName: technicianName,
        technicianImage: technicianImage,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<TechnicianRatingSheet> createState() => _TechnicianRatingSheetState();
}

class _TechnicianRatingSheetState extends State<TechnicianRatingSheet> {
  static const _maxChars = 300;

  final _controller = TextEditingController();
  int _stars = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars <= 0 || _submitting) return;
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(_stars, _controller.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop(true);
      await RatingSuccessSheet.show(
        context,
        technicianName: widget.technicianName,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _stars > 0 && !_submitting;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: MosaedColors.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: MosaedColors.fieldBorder,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  LocaleKeys.mosaedRateTechnician.tr(),
                  style: getBoldStyle(
                    fontSize: 17.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  LocaleKeys.mosaedRateExperienceQuestion.tr(
                    args: [widget.technicianName],
                  ),
                  textAlign: TextAlign.center,
                  style: getRegularStyle(
                    fontSize: 13.sp,
                    color: MosaedColors.textSecondary,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final filled = index < _stars;
                    return IconButton(
                      onPressed: _submitting
                          ? null
                          : () => setState(() => _stars = index + 1),
                      icon: Icon(
                        filled ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: const Color(0xFFF59E0B),
                        size: 34.sp,
                      ),
                    );
                  }),
                ),
                SizedBox(height: 8.h),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    LocaleKeys.mosaedRateServiceExperience.tr(),
                    style: getBoldStyle(
                      fontSize: 13.sp,
                      color: MosaedColors.brand,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _controller,
                  maxLines: 4,
                  maxLength: _maxChars,
                  enabled: !_submitting,
                  onChanged: (_) => setState(() {}),
                  style: getRegularStyle(
                    fontSize: 13.sp,
                    color: MosaedColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: LocaleKeys.mosaedRateFeedbackHint.tr(),
                    hintStyle: getRegularStyle(
                      fontSize: 13.sp,
                      color: MosaedColors.textHint,
                    ),
                    filled: true,
                    fillColor: MosaedColors.surfaceContainerLow,
                    counterText: '${_controller.text.length}/$_maxChars',
                    contentPadding: EdgeInsets.all(12.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: MosaedColors.fieldBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: MosaedColors.fieldBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: MosaedColors.brand),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18.sp,
                      color: MosaedColors.brand,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        LocaleKeys.mosaedRateHelpsImprove.tr(),
                        style: getRegularStyle(
                          fontSize: 12.sp,
                          color: MosaedColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                MosaedPrimaryButton(
                  text: LocaleKeys.mosaedSubmitRating.tr(),
                  icon: Icons.send_rounded,
                  isLoading: _submitting,
                  onPressed: canSubmit ? _submit : null,
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed:
                      _submitting ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    LocaleKeys.mosaedLater.tr(),
                    style: getMediumStyle(
                      fontSize: 14.sp,
                      color: MosaedColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
