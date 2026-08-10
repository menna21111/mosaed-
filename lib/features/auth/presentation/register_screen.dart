import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/functions.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';

import 'cubit/auth_cubit.dart';
import 'otp_screen.dart';
import 'widgets/mosaed_buttons.dart';
import 'widgets/mosaed_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _marketingCodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _marketingCodeController.dispose();
    super.dispose();
  }

  String _normalizePhone(String value) {
    var phone = value.trim().replaceAll(' ', '');
    if (phone.startsWith('+966')) phone = phone.substring(4);
    if (phone.startsWith('966')) phone = phone.substring(3);
    if (phone.startsWith('0')) phone = phone.substring(1);
    return '0$phone';
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    final code = _marketingCodeController.text.trim();
    context.read<AuthCubit>().register(
          name: _nameController.text.trim(),
          phoneNumber: _normalizePhone(_phoneController.text),
          marketingCode: code.isEmpty ? null : code,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is OtpSent) {
          final otpCode = state.otpCode?.trim();
          if (otpCode != null && otpCode.isNotEmpty) {
            AppFunctions.showsToast(
              'mosaedOtpCodeToast'.tr(args: [otpCode]),
              MosaedColors.success,
              context,
            );
          } else {
            AppFunctions.showsToast(
              'mosaedRegisterVerifyPhone'.tr(),
              MosaedColors.success,
              context,
            );
          }
          AppFunctions.navigateToAndFinish(
            context,
            OtpScreen(phoneNumber: state.phoneNumber),
          );
          context.read<AuthCubit>().reset();
        } else if (state is AuthFailure) {
          AppFunctions.showsToast(state.message, MosaedColors.danger, context);
          context.read<AuthCubit>().reset();
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: MosaedColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: MosaedColors.textPrimary,
                size: 20.sp,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const MosaedLogo(width: 200),
                    SizedBox(height: 16.h),
                    Text(
                      'mosaedRegisterTitle'.tr(),
                      style: getBoldStyle(
                        fontSize: 22.sp,
                        color: MosaedColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'mosaedRegisterSubtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: getRegularStyle(
                        fontSize: 13.sp,
                        color: MosaedColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: MosaedColors.surface,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: MosaedColors.border),
                      ),
                      child: Column(
                        children: [
                          MosaedInputField(
                            label: 'fullName'.tr(),
                            controller: _nameController,
                            hint: 'mosaedFullNameHint'.tr(),
                            icon: Icons.person_outline_rounded,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'nameRequired'.tr() : null,
                          ),
                          SizedBox(height: 14.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'phoneNumber'.tr(),
                                style: getMediumStyle(
                                  fontSize: 13.sp,
                                  color: MosaedColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              MosaedPhoneField(
                                controller: _phoneController,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'phoneRequired'.tr()
                                    : null,
                              ),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          MosaedInputField(
                            label: 'mosaedMarketingCodeOptional'.tr(),
                            controller: _marketingCodeController,
                            hint: 'mosaedMarketingCodeHint'.tr(),
                            icon: Icons.local_offer_outlined,
                          ),
                          SizedBox(height: 20.h),
                          MosaedPrimaryButton(
                            text: 'mosaedCreateAccount'.tr(),
                            isLoading: isLoading,
                            icon: Icons.person_add_alt_1_rounded,
                            onPressed: _register,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(
                          style: getRegularStyle(
                            fontSize: 14.sp,
                            color: MosaedColors.textSecondary,
                          ),
                          children: [
                            TextSpan(text: '${'alreadyHaveAccount'.tr()} '),
                            TextSpan(
                              text: 'login'.tr(),
                              style: getBoldStyle(
                                fontSize: 14.sp,
                                color: MosaedColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'mosaedRegisterTerms'.tr(),
                      textAlign: TextAlign.center,
                      style: getRegularStyle(
                        fontSize: 11.sp,
                        color: MosaedColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
