import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

import '../../../app/functions.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../../core/network/failure.dart';
import '../../auth/presentation/widgets/mosaed_buttons.dart';
import '../../chat/presentation/chat_screen.dart';
import '../data/custom_service_repository.dart';
import '../data/models/custom_service_models.dart';

class OfferDetailScreen extends StatefulWidget {
  const OfferDetailScreen({
    super.key,
    required this.requestId,
    required this.offer,
    this.requestTitle,
    this.canAccept = true,
  });

  final String requestId;
  final CustomOffer offer;
  final String? requestTitle;
  final bool canAccept;

  @override
  State<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen> {
  late CustomOffer _offer;
  bool _accepting = false;

  @override
  void initState() {
    super.initState();
    _offer = widget.offer;
  }

  Future<void> _acceptOffer() async {
    setState(() => _accepting = true);
    try {
      await context.read<CustomServiceRepository>().acceptOffer(
            requestId: widget.requestId,
            offerId: _offer.id,
          );
      if (!mounted) return;
      AppFunctions.showsToast(
        'mosaedOfferAccepted'.tr(),
        MosaedColors.success,
        context,
      );
      setState(() {
        _offer = CustomOffer(
          id: _offer.id,
          price: _offer.price,
          note: _offer.note,
          status: 'accepted',
          providerId: _offer.providerId,
          providerName: _offer.providerName,
          providerRating: _offer.providerRating,
          providerJobsCount: _offer.providerJobsCount,
          createdAt: _offer.createdAt,
        );
      });
      await _openChat();
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ServerFailure catch (e) {
      if (mounted) {
        AppFunctions.showsToast(e.errMessage, MosaedColors.danger, context);
      }
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  Future<void> _openChat() async {
    final providerName = _offer.providerName?.trim();
    await AppFunctions.navigateTo(
      context,
      ChatScreen(
        requestId: widget.requestId,
        requestTitle: widget.requestTitle,
        peerName: providerName?.isNotEmpty == true
            ? providerName
            : 'mosaedChat'.tr(),
      ),
      PageTransitionType.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = 'mosaedCurrency'.tr();
    final providerName = _offer.providerName?.trim().isNotEmpty == true
        ? _offer.providerName!
        : 'mosaedWorkerPending'.tr();

    return Scaffold(
      backgroundColor: MosaedColors.background,
      appBar: AppBar(
        backgroundColor: MosaedColors.surfaceWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_forward_rounded,
            color: MosaedColors.primary,
            size: 22.sp,
          ),
        ),
        title: Text(
          'mosaedOfferDetails'.tr(),
          style: getBoldStyle(fontSize: 18.sp, color: MosaedColors.textPrimary),
        ),
        actions: [
          if (_offer.canChat)
            IconButton(
              tooltip: 'mosaedOpenChat'.tr(),
              onPressed: _openChat,
              icon: Icon(
                Icons.chat_bubble_outline_rounded,
                color: MosaedColors.primary,
                size: 22.sp,
              ),
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: MosaedColors.surfaceWhite,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: _offer.isAccepted
                    ? MosaedColors.success
                    : MosaedColors.border,
              ),
              boxShadow: MosaedColors.softShadow,
            ),
            child: Column(
              children: [
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    color: MosaedColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: MosaedColors.primary,
                    size: 34.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  providerName,
                  style: getBoldStyle(
                    fontSize: 18.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
                if (_offer.providerRating != null) ...[
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 18.sp,
                        color: const Color(0xFFF59E0B),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _offer.providerRating!.toStringAsFixed(1),
                        style: getMediumStyle(
                          fontSize: 14.sp,
                          color: MosaedColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 16.h),
                Text(
                  '${_offer.price.toStringAsFixed(0)} $currency',
                  style: getBoldStyle(
                    fontSize: 28.sp,
                    color: MosaedColors.primary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'mosaedTotalPrice'.tr(),
                  style: getRegularStyle(
                    fontSize: 12.sp,
                    color: MosaedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_offer.note != null && _offer.note!.trim().isNotEmpty) ...[
            SizedBox(height: 14.h),
            _infoCard(
              title: 'mosaedOfferNote'.tr(),
              value: _offer.note!,
              icon: Icons.notes_rounded,
            ),
          ],
          if (_offer.canChat) ...[
            SizedBox(height: 14.h),
            _infoCard(
              title: 'mosaedChat'.tr(),
              value: 'mosaedChatAfterAcceptHint'.tr(),
              icon: Icons.forum_outlined,
            ),
          ],
          SizedBox(height: 24.h),
          if (widget.canAccept && _offer.isPending) ...[
            MosaedPrimaryButton(
              text: 'mosaedAcceptOffer'.tr(),
              isLoading: _accepting,
              onPressed: _accepting ? null : _acceptOffer,
            ),
          ],
          if (_offer.isAccepted) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: MosaedColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'mosaedOfferAcceptedBadge'.tr(),
                textAlign: TextAlign.center,
                style: getMediumStyle(
                  fontSize: 13.sp,
                  color: MosaedColors.success,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            MosaedPrimaryButton(
              text: 'mosaedChatWithWorker'.tr(),
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: _openChat,
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: MosaedColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: MosaedColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: MosaedColors.primary, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: getMediumStyle(
                    fontSize: 12.sp,
                    color: MosaedColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: getRegularStyle(
                    fontSize: 14.sp,
                    color: MosaedColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
