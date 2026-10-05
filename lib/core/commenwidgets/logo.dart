import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/assets_manager.dart';

class Logo extends StatelessWidget {
  const Logo({super.key, this.issplach});

  final bool? issplach;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      width: 200.w,
      margin: const EdgeInsets.only(bottom: 20),
      child: SvgPicture.asset(
        ImageAssets.logo,
        fit: BoxFit.contain,
      ),
    );
  }
}
