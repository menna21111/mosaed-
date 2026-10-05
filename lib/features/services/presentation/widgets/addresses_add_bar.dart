import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../auth/presentation/widgets/mosaed_buttons.dart';

class AddressesAddBar extends StatelessWidget {
  const AddressesAddBar({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      decoration: const BoxDecoration(
        color: MosaedColors.surfaceWhite,
        border: Border(
          top: BorderSide(color: MosaedColors.fieldBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: MosaedPrimaryButton(
          text: '+ ${LocaleKeys.mosaedAddNewAddress.tr()}',
          onPressed: onAdd,
        ),
      ),
    );
  }
}
