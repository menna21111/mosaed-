import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';

class ChatHeaderAvatar extends StatelessWidget {
  const ChatHeaderAvatar({super.key, required this.name, this.url});

  final String name;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final lower = trimmed.toLowerCase();
    final isGeneric = trimmed.isEmpty ||
        lower == 'provider' ||
        lower == 'worker' ||
        lower == 'technician' ||
        trimmed == 'فني' ||
        trimmed == 'عامل' ||
        trimmed == 'قيد التعيين';
    final letter = isGeneric ? 'ف' : trimmed[0].toUpperCase();

    return ClipOval(
      child: Container(
        width: 36.w,
        height: 36.w,
        color: MosaedColors.otpFill,
        child: url != null && url!.isNotEmpty
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Center(
                  child: Text(
                    letter,
                    style: getBoldStyle(
                      fontSize: 14.sp,
                      color: MosaedColors.brand,
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  letter,
                  style: getBoldStyle(
                    fontSize: 14.sp,
                    color: MosaedColors.brand,
                  ),
                ),
              ),
      ),
    );
  }
}
