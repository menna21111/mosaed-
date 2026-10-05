import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../auth/presentation/widgets/mosaed_buttons.dart';
import '../../data/models/custom_service_models.dart';
import 'custom_offer_card.dart';
import 'custom_request_detail_bits.dart';
import 'custom_request_summary_card.dart';

class CustomRequestOffersTab extends StatelessWidget {
  const CustomRequestOffersTab({
    super.key,
    required this.request,
    required this.offers,
    required this.acceptedOffer,
    required this.showOffersList,
    required this.onRefresh,
    required this.onOfferTap,
    required this.onChat,
  });

  final CustomRequest request;
  final List<CustomOffer> offers;
  final CustomOffer? acceptedOffer;
  final bool showOffersList;
  final Future<void> Function() onRefresh;
  final void Function(CustomOffer offer, {required bool canAccept}) onOfferTap;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final count = offers.isNotEmpty ? offers.length : (request.offersCount ?? 0);
    final empty = (!showOffersList || offers.isEmpty) && !request.hasAcceptedOffer;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: MosaedColors.brand,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [
          CustomRequestSummaryCard(request: request),
          SizedBox(height: 18.h),
          if (request.hasAcceptedOffer) ...[
            Text(
              'mosaedAcceptedOffer'.tr(),
              style: getBoldStyle(
                fontSize: 15.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),
            if (acceptedOffer != null)
              CustomOfferCard(
                offer: acceptedOffer!,
                onTap: () => onOfferTap(acceptedOffer!, canAccept: false),
              )
            else
              AcceptedProviderBanner(request: request),
            SizedBox(height: 12.h),
            MosaedPrimaryButton(
              text: 'mosaedChatWithWorker'.tr(),
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: onChat,
            ),
            SizedBox(height: 20.h),
          ],
          OffersSectionHeader(count: count),
          SizedBox(height: 12.h),
          if (empty)
            const EmptyOffersCard()
          else
            ...offers.map(
              (offer) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: CustomOfferCard(
                  offer: offer,
                  onTap: () => onOfferTap(
                    offer,
                    canAccept: !request.hasAcceptedOffer && offer.isPending,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomRequestDetailsTab extends StatelessWidget {
  const CustomRequestDetailsTab({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: MosaedColors.brand,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [child],
      ),
    );
  }
}
