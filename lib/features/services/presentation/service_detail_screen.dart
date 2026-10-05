import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';

import '../../../app/functions.dart';
import '../../../core/constants/assets_manager.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../../core/widgets/service_thumbnail.dart';
import '../../auth/presentation/widgets/mosaed_buttons.dart';
import '../data/models/existed_service.dart';
import '../data/services_repository.dart';
import 'cubit/service_detail_cubit.dart';
import 'service_booking_screen.dart';
import 'widgets/service_detail_tabs.dart';
import 'widgets/service_info_row.dart';
import 'widgets/service_work_gallery.dart';

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ServiceDetailCubit(context.read<ServicesRepository>())..load(serviceId),
      child: _ServiceDetailView(serviceId: serviceId),
    );
  }
}

class _ServiceDetailView extends StatefulWidget {
  const _ServiceDetailView({required this.serviceId});

  final String serviceId;

  @override
  State<_ServiceDetailView> createState() => _ServiceDetailViewState();
}

class _ServiceDetailViewState extends State<_ServiceDetailView> {
  int _selectedTab = 0;

  void _openBooking() {
    AppFunctions.navigateTo(
      context,
      ServiceBookingScreen(serviceId: widget.serviceId),
      PageTransitionType.rightToLeft,
    );
  }

  String _warrantyLabel(ServiceWarranty? warranty) {
    if (warranty == null) return '—';
    return '${warranty.durationValue} ${warranty.durationType}';
  }

  String _descriptionText(ExistedServiceDetail detail) {
    final attr = detail.attributes.isNotEmpty ? detail.attributes.first : null;
    final fromAttr = attr?.details?.trim();
    if (fromAttr != null && fromAttr.isNotEmpty) return fromAttr;
    final fromDetail = detail.details?.trim();
    if (fromDetail != null && fromDetail.isNotEmpty) return fromDetail;
    return detail.title;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServiceDetailCubit, ServiceDetailState>(
      listenWhen: (previous, current) => current is ServiceDetailFailure,
      listener: (context, state) {
        if (state is ServiceDetailFailure) {
          AppFunctions.showsToast(state.message, MosaedColors.danger, context);
          Navigator.pop(context);
        }
      },
      child: BlocBuilder<ServiceDetailCubit, ServiceDetailState>(
        builder: (context, state) {
          if (state is ServiceDetailLoading || state is ServiceDetailInitial) {
            return Scaffold(
              backgroundColor: MosaedColors.surfaceWhite,
              appBar: _topBar(),
              body: const Center(
                child: CircularProgressIndicator(
                  color: MosaedColors.primaryContainer,
                ),
              ),
            );
          }

          if (state is! ServiceDetailLoaded) {
            return Scaffold(
              backgroundColor: MosaedColors.surfaceWhite,
              appBar: _topBar(),
              body: const SizedBox.shrink(),
            );
          }

          final detail = state.detail;
          final previousWorks = state.previousWorks;
          final description = _descriptionText(detail);

          return Scaffold(
            backgroundColor: MosaedColors.surfaceWhite,
            appBar: _topBar(),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _heroImage(detail),
                        SizedBox(height: 16.h),
                        ServiceDetailTabs(
                          selectedIndex: _selectedTab,
                          onChanged: (index) =>
                              setState(() => _selectedTab = index),
                        ),
                        SizedBox(height: 16.h),
                        if (_selectedTab == 0)
                          _buildDetailsTab(detail, description)
                        else
                          ServiceWorkGallery(
                            serviceTitle: detail.title,
                            works: previousWorks,
                          ),
                      ],
                    ),
                  ),
                ),
                _bottomBar(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsTab(ExistedServiceDetail detail, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          detail.title,
          style: getBoldStyle(
            fontSize: 17.sp,
            color: MosaedColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          description,
          style: getRegularStyle(
            fontSize: 13.sp,
            color: MosaedColors.textSecondary,
            height: 1.55,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
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
              Text(
                LocaleKeys.mosaedServiceDetails.tr(),
                style: getBoldStyle(
                  fontSize: 14.sp,
                  color: MosaedColors.brand,
                ),
              ),
              ServiceInfoRow(
                svgAsset: ImageAssets.note01,
                label: 'mosaedAttributeName'.tr(),
                value: detail.title,
              ),
              Divider(height: 1, thickness: 1, color: MosaedColors.fieldBorder),
              ServiceInfoRow(
                svgAsset: ImageAssets.message02,
                label: LocaleKeys.mosaedServiceDescriptionLabel.tr(),
                value: description,
              ),
              if (detail.warranty != null) ...[
                Divider(
                  height: 1,
                  thickness: 1,
                  color: MosaedColors.fieldBorder,
                ),
                ServiceInfoRow(
                  svgAsset: ImageAssets.checkmarkBadge01,
                  label: LocaleKeys.mosaedWarrantyDurationLabel.tr(),
                  value: _warrantyLabel(detail.warranty),
                  valueColor: MosaedColors.success,
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E8),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: MosaedColors.cardBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                ImageAssets.note01,
                width: 18.w,
                height: 18.w,
                colorFilter: const ColorFilter.mode(
                  MosaedColors.brand,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  LocaleKeys.mosaedPriceAfterInspection.tr(),
                  style: getMediumStyle(
                    fontSize: 12.sp,
                    color: MosaedColors.textPrimary,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        border: Border(top: BorderSide(color: MosaedColors.fieldBorder)),
      ),
      child: SafeArea(
        top: false,
        child: MosaedPrimaryButton(
          text: '+ ${'mosaedRequestService'.tr()}',
          onPressed: _openBooking,
        ),
      ),
    );
  }

  PreferredSizeWidget _topBar() {
    return AppBar(
      backgroundColor: MosaedColors.surfaceWhite,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        LocaleKeys.mosaedOrderDetailsTab.tr(),
        style: getBoldStyle(
          fontSize: 16.sp,
          color: MosaedColors.textPrimary,
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: MosaedColors.textPrimary,
          size: 18.sp,
        ),
      ),
    );
  }

  Widget _heroImage(ExistedServiceDetail detail) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: detail.hasImage
            ? Image.network(
                detail.image!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _headerFallback(detail),
              )
            : _headerFallback(detail),
      ),
    );
  }

  Widget _headerFallback(ExistedService detail) {
    return Container(
      color: detail.accentColor.withValues(alpha: 0.15),
      child: Center(
        child: ServiceThumbnail(
          service: detail,
          size: 64.w,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}
