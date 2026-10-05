import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../../core/widgets/mosaed_price_text.dart';

class ChatOrderSummaryBar extends StatelessWidget {
  const ChatOrderSummaryBar({
    super.key,
    required this.title,
    required this.onViewDetails,
    this.price,
  });

  final String title;
  final double? price;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: MosaedColors.brand.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getBoldStyle(
                    fontSize: 13.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
                if (price != null && price! > 0) ...[
                  SizedBox(height: 4.h),
                  MosaedPriceText(
                    amount: price!,
                    style: getMediumStyle(
                      fontSize: 12.sp,
                      color: MosaedColors.brand,
                    ),
                    iconSize: 12,
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: onViewDetails,
            child: Text(
              LocaleKeys.mosaedViewDetails.tr(),
              style: getBoldStyle(
                fontSize: 12.sp,
                color: MosaedColors.brand,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
