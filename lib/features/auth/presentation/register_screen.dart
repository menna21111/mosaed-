import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/functions.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import 'cubit/auth_cubit.dart';
import 'otp_bottom_sheet.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_rich_link.dart';
import 'widgets/mosaed_buttons.dart';
import 'widgets/terms_agree_tile.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _agreedToTerms = false;
  bool _otpSheetOpen = false;

  bool get _canSubmit =>
      _agreedToTerms &&
      _nameController.text.trim().isNotEmpty &&
      mosaedPhoneDigitCount(_phoneController.text) >= 9;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _normalizePhone(String value) {
    var phone = mosaedToAsciiDigits(value).trim().replaceAll(' ', '');
    if (phone.startsWith('+966')) phone = phone.substring(4);
    if (phone.startsWith('966')) phone = phone.substring(3);
    if (phone.startsWith('0')) phone = phone.substring(1);
    return '0$phone';
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      AppFunctions.showsToast(
        LocaleKeys.mosaedAcceptTermsRequired.tr(),
        MosaedColors.danger,
        context,
      );
      return;
    }
    context.read<AuthCubit>().register(
          name: _nameController.text.trim(),
          phoneNumber: _normalizePhone(_phoneController.text),
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
              LocaleKeys.mosaedOtpCodeToast.tr(args: [otpCode]),
              MosaedColors.success,
              context,
            );
          } else {
            AppFunctions.showsToast(
              LocaleKeys.mosaedRegisterVerifyPhone.tr(),
              MosaedColors.success,
              context,
            );
          }
          if (!_otpSheetOpen) {
            _otpSheetOpen = true;
            OtpBottomSheet.show(
              context,
              phoneNumber: state.phoneNumber,
            ).whenComplete(() {
              if (mounted) _otpSheetOpen = false;
            });
          }
          context.read<AuthCubit>().reset();
        } else if (state is AuthFailure) {
          AppFunctions.showsToast(state.message, MosaedColors.danger, context);
          context.read<AuthCubit>().reset();
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: MosaedColors.surfaceWhite,
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 20.h),
                          AuthHeader(
                            title: LocaleKeys.mosaedRegisterTitle.tr(),
                            subtitle: LocaleKeys.mosaedRegisterSubtitle.tr(),
                            logoWidth: 110,
                          ),
                          SizedBox(height: 28.h),
                          MosaedInputField(
                            label: LocaleKeys.mosaedYourName.tr(),
                            controller: _nameController,
                            hint: LocaleKeys.mosaedFullNameHint.tr(),
                            onChanged: (_) => setState(() {}),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? LocaleKeys.nameRequired.tr()
                                : null,
                          ),
                          SizedBox(height: 16.h),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              LocaleKeys.mosaedPhoneLabel.tr(),
                              style: getMediumStyle(
                                fontSize: 12.sp,
                                color: MosaedColors.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          MosaedPhoneField(
                            controller: _phoneController,
                            onChanged: (_) => setState(() {}),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return LocaleKeys.mosaedPhoneRequired.tr();
                              }
                              if (mosaedPhoneDigitCount(value) < 9) {
                                return LocaleKeys.mosaedPhoneInvalid.tr();
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),
                          TermsAgreeTile(
                            agreed: _agreedToTerms,
                            onChanged: (v) =>
                                setState(() => _agreedToTerms = v),
                          ),
                          SizedBox(height: 20.h),
                          AuthRichLink(
                            prefix: LocaleKeys.alreadyHaveAccount.tr(),
                            action: LocaleKeys.login.tr(),
                            onTap: () => Navigator.pop(context),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: MosaedColors.surfaceWhite,
                      border: Border(
                        top: BorderSide(
                          color: MosaedColors.fieldBorder,
                          width: 1,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 24.w, 16.h),
                    child: MosaedPrimaryButton(
                      text: LocaleKeys.mosaedContinue.tr(),
                      isLoading: isLoading,
                      enabled: _canSubmit,
                      fontSize: 13,
                      onPressed: _canSubmit ? _register : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
