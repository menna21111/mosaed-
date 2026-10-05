import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/assets_manager.dart';
import '../../../../../core/constants/locale_keys.dart';
import '../../../../../core/constants/mosaed_colors.dart';
import '../../../../../core/constants/styles_manager.dart';
import '../../../../../core/widgets/mosaed_icon_circle.dart';
import '../../../../../core/widgets/mosaed_horizontal_photos.dart';
import '../../../../../core/widgets/mosaed_meta_bits.dart';
import '../../../../../core/widgets/mosaed_network_avatar.dart';
import '../../../../../core/widgets/mosaed_price_text.dart';
import '../../../../../core/widgets/mosaed_svg_chip.dart';
import '../../../data/completion_form_model.dart';
import '../../models/active_order_view_data.dart';

class ActiveOrderSectionCard extends StatelessWidget {
  const ActiveOrderSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 8.h),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: MosaedColors.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: getBoldStyle(
                    fontSize: 15.sp,
                    color: MosaedColors.brand,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class ActiveOrderDetailRow extends StatelessWidget {
  const ActiveOrderDetailRow({
    super.key,
    required this.label,
    required this.child,
    this.icon,
    this.svgAsset,
    this.leading,
  }) : assert(icon != null || svgAsset != null || leading != null);

  final IconData? icon;
  final String? svgAsset;
  final String label;
  final Widget child;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leading ??
            MosaedIconCircle(
              icon: icon,
              svgAsset: svgAsset,
              size: 40,
              radius: 10,
            ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: getBoldStyle(fontSize: 13.sp, color: MosaedColors.brand),
              ),
              SizedBox(height: 6.h),
              child,
            ],
          ),
        ),
      ],
    );
  }
}

class ActiveOrderSectionDivider extends StatelessWidget {
  const ActiveOrderSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Divider(height: 1, thickness: 1, color: MosaedColors.fieldBorder),
    );
  }
}

class ActiveOrderHeaderChip extends StatelessWidget {
  const ActiveOrderHeaderChip({super.key, required this.chip});

  final ActiveOrderChipData chip;

  @override
  Widget build(BuildContext context) {
    if (chip.outlined) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: MosaedColors.surfaceWhite,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: MosaedColors.fieldBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chip.svgAsset != null) ...[
              SvgPicture.asset(
                chip.svgAsset!,
                width: 13.w,
                height: 13.w,
                colorFilter: const ColorFilter.mode(
                  MosaedColors.brand,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 4.w),
            ] else if (chip.icon != null) ...[
              Icon(chip.icon, size: 13.sp, color: MosaedColors.brand),
              SizedBox(width: 4.w),
            ],
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: chip.maxLabelWidth.w),
              child: Text(
                chip.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getMediumStyle(
                  fontSize: 11.sp,
                  color: MosaedColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (chip.svgAsset != null) {
      return MosaedSvgChip(
        svgAsset: chip.svgAsset!,
        label: chip.label,
        tintSvg: true,
        labelColor: MosaedColors.brand,
        maxLabelWidth: chip.maxLabelWidth,
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: MosaedColors.brandTransparent,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chip.icon != null) ...[
            Icon(chip.icon, size: 13.sp, color: MosaedColors.brand),
            SizedBox(width: 4.w),
          ],
          Text(
            chip.label,
            style: getMediumStyle(
              fontSize: 11.sp,
              color: MosaedColors.brand,
            ),
          ),
        ],
      ),
    );
  }
}

class ActiveOrderSummaryHeader extends StatelessWidget {
  const ActiveOrderSummaryHeader({super.key, required this.data});

  final ActiveOrderViewData data;

  @override
  Widget build(BuildContext context) {
    final badge = data.displayBadge;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: MosaedColors.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: getBoldStyle(
                    fontSize: 18.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
              ),
              if (badge != null) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: badge.backgroundColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    badge.labelKey.tr(),
                    style: getMediumStyle(fontSize: 11.sp, color: badge.color),
                  ),
                ),
              ],
            ],
          ),
          if (data.dayLabel != null && data.dayLabel!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            MosaedClockLabel(
              label: data.dayLabel!,
              iconSize: 14,
              fontSize: 12,
            ),
          ],
          if (data.chips.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: data.chips
                  .map((chip) => ActiveOrderHeaderChip(chip: chip))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class ActiveOrderWorkPhotosSection extends StatelessWidget {
  const ActiveOrderWorkPhotosSection({super.key, required this.completion});

  final CompletionForm completion;

  @override
  Widget build(BuildContext context) {
    final hasBoth = completion.hasBeforeImage && completion.hasAfterImage;

    return ActiveOrderSectionCard(
      title: 'mosaedWorkPhotos'.tr(),
      child: hasBoth
          ? Row(
              children: [
                if (completion.hasAfterImage)
                  Expanded(
                    child: _WorkPhoto(
                      label: 'mosaedAfter'.tr(),
                      url: completion.afterImage!,
                    ),
                  ),
                if (completion.hasBeforeImage && completion.hasAfterImage)
                  SizedBox(width: 10.w),
                if (completion.hasBeforeImage)
                  Expanded(
                    child: _WorkPhoto(
                      label: 'mosaedBefore'.tr(),
                      url: completion.beforeImage!,
                    ),
                  ),
              ],
            )
          : _WorkPhoto(
              label: completion.hasAfterImage
                  ? 'mosaedAfter'.tr()
                  : 'mosaedBefore'.tr(),
              url: completion.hasAfterImage
                  ? completion.afterImage!
                  : completion.beforeImage!,
            ),
    );
  }
}

class _WorkPhoto extends StatelessWidget {
  const _WorkPhoto({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Stack(
        children: [
          Image.network(
            url,
            height: 140.h,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 140.h,
              color: MosaedColors.surfaceContainerLow,
              alignment: Alignment.center,
              child: Icon(
                Icons.broken_image_outlined,
                color: MosaedColors.textHint,
                size: 24.sp,
              ),
            ),
          ),
          PositionedDirectional(
            top: 8.h,
            end: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                label,
                style: getMediumStyle(
                  fontSize: 11.sp,
                  color: MosaedColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActiveOrderDetailsSection extends StatelessWidget {
  const ActiveOrderDetailsSection({
    super.key,
    required this.data,
    required this.collapsed,
    this.onToggle,
  });

  final ActiveOrderViewData data;
  final bool collapsed;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final address = data.address?.trim().isNotEmpty == true
        ? data.address!
        : 'mosaedNotAvailableYet'.tr();

    return ActiveOrderSectionCard(
      title: LocaleKeys.mosaedDetailsSection.tr(),
      trailing: onToggle != null
          ? GestureDetector(
              onTap: onToggle,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    collapsed
                        ? LocaleKeys.mosaedShowMore.tr()
                        : LocaleKeys.mosaedShowLess.tr(),
                    style: getMediumStyle(
                      fontSize: 12.sp,
                      color: MosaedColors.brand,
                    ),
                  ),
                  Icon(
                    collapsed
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    color: MosaedColors.brand,
                    size: 18.sp,
                  ),
                ],
              ),
            )
          : null,
      child: Column(
        children: [
          ActiveOrderDetailRow(
            svgAsset: data.isCatalogBooking
                ? ImageAssets.orders
                : ImageAssets.note01,
            label: data.isCatalogBooking
                ? 'mosaedAttributeName'.tr()
                : LocaleKeys.mosaedProblemLabel.tr(),
            child: Text(
              data.isCatalogBooking ? data.title : data.problemTitle,
              style: getMediumStyle(
                fontSize: 13.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
          ),
          if (!collapsed) ...[
            const ActiveOrderSectionDivider(),
            ActiveOrderDetailRow(
              svgAsset: ImageAssets.message02,
              label: data.isCatalogBooking
                  ? LocaleKeys.mosaedServiceDescriptionLabel.tr()
                  : LocaleKeys.mosaedProblemDescription.tr(),
              child: Text(
                data.problemDescription,
                style: getRegularStyle(
                  fontSize: 13.sp,
                  color: MosaedColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
            if (!data.isCatalogBooking &&
                data.serviceType?.trim().isNotEmpty == true) ...[
              const ActiveOrderSectionDivider(),
              ActiveOrderDetailRow(
                svgAsset: ImageAssets.orders,
                label: LocaleKeys.mosaedServiceType.tr(),
                child: Text(
                  data.serviceType!,
                  style: getMediumStyle(
                    fontSize: 13.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
              ),
            ],
            if (!data.isCatalogBooking && data.problemPhotos.isNotEmpty) ...[
              const ActiveOrderSectionDivider(),
              ActiveOrderDetailRow(
                svgAsset: ImageAssets.image02,
                label: LocaleKeys.mosaedProblemPhotos.tr(),
                child: MosaedHorizontalPhotos(urls: data.problemPhotos),
              ),
            ],
            const ActiveOrderSectionDivider(),
            ActiveOrderDetailRow(
              svgAsset: ImageAssets.chooseCity,
              label: LocaleKeys.mosaedServiceLocation.tr(),
              child: Text(
                address,
                style: getMediumStyle(
                  fontSize: 13.sp,
                  color: MosaedColors.textPrimary,
                ),
              ),
            ),
            const ActiveOrderSectionDivider(),
            ActiveOrderDetailRow(
              svgAsset: ImageAssets.time04,
              label: LocaleKeys.mosaedAppointment.tr(),
              child: Text(
                data.scheduleLabel,
                style: getMediumStyle(
                  fontSize: 13.sp,
                  color: MosaedColors.textPrimary,
                ),
              ),
            ),
            const ActiveOrderSectionDivider(),
            ActiveOrderDetailRow(
              svgAsset: ImageAssets.orderHash,
              label: LocaleKeys.mosaedOrderNumber.tr(),
              child: Text(
                data.orderNumber,
                style: getBoldStyle(
                  fontSize: 13.sp,
                  color: MosaedColors.textPrimary,
                ),
              ),
            ),
          ],
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}

class ActiveOrderCollaborationSection extends StatelessWidget {
  const ActiveOrderCollaborationSection({super.key, required this.data});

  final ActiveOrderViewData data;

  @override
  Widget build(BuildContext context) {
    final collaboration = data.collaboration;

    return ActiveOrderSectionCard(
      title: LocaleKeys.mosaedCollaborationDetails.tr(),
      child: Column(
        children: [
          if (collaboration.price != null) ...[
            ActiveOrderDetailRow(
              svgAsset: ImageAssets.moneyOrderDetails,
              label: LocaleKeys.mosaedCollaborationValue.tr(),
              child: MosaedPriceText(
                amount: collaboration.price!,
                style: getBoldStyle(
                  fontSize: 14.sp,
                  color: MosaedColors.textPrimary,
                ),
              ),
            ),
            const ActiveOrderSectionDivider(),
          ],
          ActiveOrderDetailRow(
            svgAsset: ImageAssets.userIconProfile,
            label: LocaleKeys.mosaedSelectedTechnician.tr(),
            leading: MosaedNetworkAvatar(
              url: collaboration.technicianImage,
              size: 40,
            ),
            child: Text(
              collaboration.technicianName,
              style: getMediumStyle(
                fontSize: 13.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
          ),
          const ActiveOrderSectionDivider(),
          ActiveOrderDetailRow(
            svgAsset: ImageAssets.message02,
            label: LocaleKeys.mosaedYourNotes.tr(),
            child: Text(
              collaboration.notes,
              style: getRegularStyle(
                fontSize: 13.sp,
                color: MosaedColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}

class ActiveOrderTechnicianSection extends StatelessWidget {
  const ActiveOrderTechnicianSection({super.key, required this.data});

  final ActiveOrderViewData data;

  @override
  Widget build(BuildContext context) {
    final collaboration = data.collaboration;
    final assigned = data.hasAssignedProvider;
    final phone = collaboration.technicianPhone?.trim() ?? '';

    return ActiveOrderSectionCard(
      title: LocaleKeys.mosaedTechnicianInfo.tr(),
      child: assigned
          ? Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  MosaedNetworkAvatar(
                    url: collaboration.technicianImage,
                    size: 48,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collaboration.technicianName,
                          style: getBoldStyle(
                            fontSize: 14.sp,
                            color: MosaedColors.brand,
                          ),
                        ),
                        if (phone.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            phone,
                            style: getMediumStyle(
                              fontSize: 13.sp,
                              color: MosaedColors.textPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  const MosaedIconCircle(
                    svgAsset: ImageAssets.userIconProfile,
                    size: 40,
                    radius: 10,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      LocaleKeys.mosaedTechnicianNotSelected.tr(),
                      style: getMediumStyle(
                        fontSize: 13.sp,
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

class ActiveOrderCostSection extends StatelessWidget {
  const ActiveOrderCostSection({super.key, required this.data});

  final ActiveOrderViewData data;

  @override
  Widget build(BuildContext context) {
    final price = data.collaboration.price;
    final visit = data.visitCost;

    return ActiveOrderSectionCard(
      title: LocaleKeys.mosaedCostSection.tr(),
      child: Column(
        children: [
          ActiveOrderDetailRow(
            svgAsset: ImageAssets.moneyOrderDetails,
            label: LocaleKeys.mosaedCostSection.tr(),
            child: price != null
                ? MosaedPriceText(
                    amount: price,
                    style: getBoldStyle(
                      fontSize: 14.sp,
                      color: MosaedColors.textPrimary,
                    ),
                  )
                : Text(
                    LocaleKeys.mosaedPriceNotDetermined.tr(),
                    style: getMediumStyle(
                      fontSize: 13.sp,
                      color: MosaedColors.textPrimary,
                    ),
                  ),
          ),
          if (visit != null) ...[
            const ActiveOrderSectionDivider(),
            ActiveOrderDetailRow(
              svgAsset: ImageAssets.moneyOrderDetails,
              label: LocaleKeys.mosaedVisitCost.tr(),
              child: MosaedPriceText(
                amount: visit,
                style: getBoldStyle(
                  fontSize: 14.sp,
                  color: MosaedColors.textPrimary,
                ),
              ),
            ),
          ],
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}

class ActiveOrderStatusBanner extends StatelessWidget {
  const ActiveOrderStatusBanner({super.key, required this.messageKey});

  final String messageKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE6A800).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_top_rounded,
            size: 20.sp,
            color: const Color(0xFFE6A800),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              messageKey.tr(),
              style: getMediumStyle(
                fontSize: 12.sp,
                color: MosaedColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActiveOrderSparePartsBanner extends StatelessWidget {
  const ActiveOrderSparePartsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_rounded,
            size: 18.sp,
            color: MosaedColors.brand,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              LocaleKeys.mosaedSparePartsDisclaimer.tr(),
              style: getRegularStyle(
                fontSize: 12.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
