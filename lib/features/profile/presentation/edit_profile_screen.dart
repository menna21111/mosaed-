import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/functions.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../../core/network/failure.dart';
import '../../../core/widgets/mosaed_confirm_dialog.dart';
import '../../auth/data/models/customer_profile.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/widgets/mosaed_buttons.dart';
import '../../services/presentation/widgets/address_chrome.dart';
import '../../services/presentation/widgets/address_form_fields.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final CustomerProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _picker = ImagePicker();

  File? _photo;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController.text = p.name;
    _phoneController.text = _localPhone(p.phoneNumber);
    _emailController.text = p.email ?? '';
    _nameController.addListener(_onChanged);
    _phoneController.addListener(_onChanged);
    _emailController.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.removeListener(_onChanged);
    _phoneController.removeListener(_onChanged);
    _emailController.removeListener(_onChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _localPhone(String phone) {
    var digits = mosaedToAsciiDigits(phone).replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('966')) digits = digits.substring(3);
    if (digits.startsWith('0')) digits = digits.substring(1);
    return digits;
  }

  String _normalizePhone(String value) {
    var phone = mosaedToAsciiDigits(value).trim().replaceAll(' ', '');
    if (phone.startsWith('+966')) phone = phone.substring(4);
    if (phone.startsWith('966')) phone = phone.substring(3);
    if (phone.startsWith('0')) phone = phone.substring(1);
    return '0$phone';
  }

  bool get _canSubmit {
    final nameOk = _nameController.text.trim().isNotEmpty;
    final phoneOk = mosaedPhoneDigitCount(_phoneController.text) >= 9;
    return !_saving && nameOk && phoneOk;
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() => _photo = File(picked.path));
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_canSubmit) return;
    setState(() => _saving = true);
    try {
      await context.read<AuthCubit>().updateProfile(
            name: _nameController.text.trim(),
            phoneNumber: _normalizePhone(_phoneController.text),
            email: _emailController.text.trim(),
            photo: _photo,
          );
      if (!mounted) return;
      AppFunctions.showsToast(
        LocaleKeys.mosaedProfileUpdated.tr(),
        MosaedColors.success,
        context,
      );
      Navigator.pop(context, true);
    } on ServerFailure catch (e) {
      if (mounted) {
        AppFunctions.showsToast(e.errMessage, MosaedColors.danger, context);
      }
    } catch (_) {
      if (mounted) {
        AppFunctions.showsToast(
          LocaleKeys.mosaedCustomServiceError.tr(),
          MosaedColors.danger,
          context,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showMosaedConfirmDialog(
      context,
      title: LocaleKeys.mosaedDeleteAccountTitle.tr(),
      message: LocaleKeys.mosaedDeleteAccountBody.tr(),
      confirmText: LocaleKeys.mosaedDelete.tr(),
    );
    if (!confirmed || !mounted) return;
    await context.read<AuthCubit>().deleteAccount();
  }

  ImageProvider? get _avatar {
    if (_photo != null) return FileImage(_photo!);
    final url = widget.profile.avatar;
    if (url != null && url.trim().isNotEmpty) return NetworkImage(url);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MosaedColors.surfaceWhite,
      appBar: AddressAppBar(title: LocaleKeys.mosaedEditProfile.tr()),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickPhoto,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 44.r,
                              backgroundColor: MosaedColors.otpFill,
                              backgroundImage: _avatar,
                              child: _avatar == null
                                  ? Icon(
                                      Icons.person_rounded,
                                      color: MosaedColors.brand,
                                      size: 40.sp,
                                    )
                                  : null,
                            ),
                            PositionedDirectional(
                              start: 0,
                              bottom: 0,
                              child: Container(
                                width: 26.w,
                                height: 26.w,
                                decoration: BoxDecoration(
                                  color: MosaedColors.brand,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      LocaleKeys.mosaedChooseClearPhoto.tr(),
                      textAlign: TextAlign.center,
                      style: getRegularStyle(
                        fontSize: 12.sp,
                        color: MosaedColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    AddressFieldLabel(LocaleKeys.mosaedYourName.tr()),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _nameController,
                      style: getRegularStyle(
                        fontSize: 13.sp,
                        color: MosaedColors.textPrimary,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? LocaleKeys.nameRequired.tr()
                          : null,
                      decoration: addressFieldDecoration(
                        hint: LocaleKeys.mosaedFullNameHint.tr(),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    AddressFieldLabel(LocaleKeys.mosaedPhoneLabel.tr()),
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
                    SizedBox(height: 16.h),
                    AddressFieldLabel(LocaleKeys.mosaedEmailOptional.tr()),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: getRegularStyle(
                        fontSize: 13.sp,
                        color: MosaedColors.textPrimary,
                      ),
                      decoration: addressFieldDecoration(
                        hint: 'email'.tr(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
              decoration: const BoxDecoration(
                color: MosaedColors.surfaceWhite,
                border: Border(
                  top: BorderSide(color: MosaedColors.fieldBorder),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    MosaedPrimaryButton(
                      text: LocaleKeys.mosaedSaveEdits.tr(),
                      isLoading: _saving,
                      enabled: _canSubmit,
                      onPressed: _canSubmit ? _save : null,
                    ),
                    SizedBox(height: 10.h),
                    MosaedOutlineButton(
                      text: LocaleKeys.mosaedDeleteAccount.tr(),
                      color: MosaedColors.danger,
                      onPressed: _deleteAccount,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
