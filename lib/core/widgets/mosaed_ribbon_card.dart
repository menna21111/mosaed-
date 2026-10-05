import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/mosaed_colors.dart';
import 'mosaed_status_ribbon.dart';

class MosaedRibbonCard extends StatelessWidget {
  const MosaedRibbonCard({
    super.key,
    required this.statusLabel,
    required this.child,
    this.onTap,
    this.width,
    this.height,
    this.padding,
  });

  final String statusLabel;
  final Widget child;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);
    final body = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: radius,
        border: Border.all(color: MosaedColors.fieldBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: padding ?? EdgeInsets.fromLTRB(14.w, 32.h, 14.w, 14.h),
            child: child,
          ),
          MosaedStatusRibbon(label: statusLabel),
        ],
      ),
    );

    if (onTap == null) return body;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: body,
      ),
    );
  }
}
