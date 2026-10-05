import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/assets_manager.dart';

class MosaedRiyalIcon extends StatelessWidget {
  const MosaedRiyalIcon({
    super.key,
    this.size = 14,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      ImageAssets.saudiRiyal,
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}

class MosaedPriceText extends StatelessWidget {
  const MosaedPriceText({
    super.key,
    required this.amount,
    required this.style,
    this.prefix,
    this.iconSize,
    this.maxLines,
    this.overflow,
  });

  final num amount;
  final TextStyle style;
  final String? prefix;
  final double? iconSize;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final size = iconSize ?? style.fontSize ?? 14;
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          if (prefix != null && prefix!.isNotEmpty) TextSpan(text: prefix),
          TextSpan(text: amount.toStringAsFixed(0)),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 4.w),
              child: MosaedRiyalIcon(size: size, color: style.color),
            ),
          ),
        ],
      ),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.visible,
    );
  }
}
