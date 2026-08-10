import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';

class MosaedPrimaryButton extends StatelessWidget {
  const MosaedPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: MosaedColors.primaryContainer,
          disabledBackgroundColor:
              MosaedColors.primaryContainer.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: getBoldStyle(fontSize: 16.sp, color: Colors.white),
                  ),
                  if (icon != null) ...[
                    SizedBox(width: 8.w),
                    Icon(icon, color: Colors.white, size: 20.sp),
                  ],
                ],
              ),
      ),
    );
  }
}

class MosaedOutlineButton extends StatelessWidget {
  const MosaedOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: MosaedColors.primaryContainer),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: MosaedColors.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: MosaedColors.textSecondary, size: 18.sp),
              SizedBox(width: 8.w),
            ],
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: getMediumStyle(
                  fontSize: 15.sp,
                  color: MosaedColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact container action (skip / chip) — same brand as login fields.
class MosaedChipButton extends StatelessWidget {
  const MosaedChipButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconAtEnd = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool iconAtEnd;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null && !iconAtEnd) ...[
          Icon(icon, size: 16.sp, color: MosaedColors.primaryContainer),
          SizedBox(width: 6.w),
        ],
        Text(
          text,
          style: getBoldStyle(
            fontSize: 13.sp,
            color: MosaedColors.primary,
          ),
        ),
        if (icon != null && iconAtEnd) ...[
          SizedBox(width: 6.w),
          Icon(icon, size: 16.sp, color: MosaedColors.primaryContainer),
        ],
      ],
    );

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: MosaedColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: MosaedColors.primaryContainer,
            width: 1.4,
          ),
        ),
        child: child,
      ),
    );
  }
}

class MosaedPhoneField extends StatelessWidget {
  const MosaedPhoneField({super.key, required this.controller, this.validator});

  final TextEditingController controller;
  final String? Function(String?)? validator;

  static const _fieldBorder = MosaedColors.primaryContainer;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
        textAlign: TextAlign.left,
        validator: validator,
        style: getRegularStyle(
          fontSize: 16.sp,
          color: MosaedColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: '5XXXXXXXX',
          hintStyle: getRegularStyle(
            fontSize: 15.sp,
            color: MosaedColors.textHint,
          ),
          prefixIcon: Padding(
            padding: EdgeInsetsDirectional.only(start: 12.w, end: 8.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+966',
                  style: getBoldStyle(
                    fontSize: 15.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: MosaedColors.textSecondary,
                  size: 20.sp,
                ),
                Container(
                  width: 1,
                  height: 24.h,
                  margin: EdgeInsetsDirectional.only(start: 10.w),
                  color: MosaedColors.primaryContainer.withValues(alpha: 0.45),
                ),
              ],
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 96.w, minHeight: 0),
          suffixIcon: Icon(
            Icons.smartphone_outlined,
            color: MosaedColors.primaryContainer,
            size: 22.sp,
          ),
          filled: true,
          fillColor: MosaedColors.surfaceWhite,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: _fieldBorder, width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: _fieldBorder, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: MosaedColors.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: MosaedColors.danger, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class MosaedInputField extends StatelessWidget {
  const MosaedInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  static const _fieldBorder = MosaedColors.primaryContainer;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label,
            style: getMediumStyle(
              fontSize: 14.sp,
              color: MosaedColors.textSecondary,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          validator: validator,
          textAlign: TextAlign.start,
          style: getRegularStyle(
            fontSize: 16.sp,
            color: MosaedColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: getRegularStyle(
              fontSize: 15.sp,
              color: MosaedColors.textHint,
            ),
            prefixIcon: icon != null
                ? Icon(icon, color: MosaedColors.primaryContainer, size: 22.sp)
                : null,
            filled: true,
            fillColor: MosaedColors.surfaceWhite,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(color: _fieldBorder, width: 1.4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(color: _fieldBorder, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(color: MosaedColors.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(
                color: MosaedColors.danger,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MosaedDividerText extends StatelessWidget {
  const MosaedDividerText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: MosaedColors.primaryContainer.withValues(alpha: 0.35),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            text,
            style: getRegularStyle(
              fontSize: 13.sp,
              color: MosaedColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: MosaedColors.primaryContainer.withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }
}
