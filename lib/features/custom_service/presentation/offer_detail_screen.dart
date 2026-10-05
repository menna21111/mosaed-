import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

import '../../../app/functions.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../../core/network/failure.dart';
import '../../auth/presentation/widgets/mosaed_buttons.dart';
import '../../chat/presentation/chat_screen.dart';
import '../data/custom_service_repository.dart';
import '../data/models/custom_service_models.dart';
import 'widgets/accept_offer_sheet.dart';
import 'widgets/offer_details_info_card.dart';
import 'widgets/offer_provider_card.dart';

class OfferDetailScreen extends StatefulWidget {
  const OfferDetailScreen({
    super.key,
    required this.requestId,
    required this.offer,
    this.requestTitle,
    this.scheduledLabel,
    this.canAccept = true,
  });

  final String requestId;
  final CustomOffer offer;
  final String? requestTitle;
  final String? scheduledLabel;
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

  Future<void> _confirmAndAccept() async {
    final confirmed = await AcceptOfferSheet.show(
      context,
      offer: _offer,
      requestTitle: widget.requestTitle,
      scheduledLabel: widget.scheduledLabel,
    );
    if (confirmed == true && mounted) {
      await _acceptOffer();
    }
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
      setState(() => _offer = _offer.copyWith(status: 'accepted'));
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
            : LocaleKeys.mosaedWorkerPending.tr(),
        peerImage: _offer.providerImage,
        price: _offer.price > 0 ? _offer.price : null,
      ),
      PageTransitionType.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    final showActions = widget.canAccept && _offer.isPending;

    return Scaffold(
      backgroundColor: MosaedColors.background,
      appBar: AppBar(
        backgroundColor: MosaedColors.surfaceWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_forward_ios_rounded,
            color: MosaedColors.textPrimary,
            size: 18.sp,
          ),
        ),
        title: Text(
          LocaleKeys.mosaedOfferDetails.tr(),
          style: getBoldStyle(
            fontSize: 16.sp,
            color: MosaedColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              children: [
                OfferProviderCard(offer: _offer),
                SizedBox(height: 12.h),
                OfferDetailsInfoCard(
                  offer: _offer,
                  scheduledLabel: widget.scheduledLabel,
                ),
                if (_offer.isAccepted) ...[
                  SizedBox(height: 16.h),
                  MosaedPrimaryButton(
                    text: 'mosaedChatWithWorker'.tr(),
                    icon: Icons.chat_bubble_outline_rounded,
                    onPressed: _openChat,
                  ),
                ],
              ],
            ),
          ),
          if (showActions)
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
              decoration: BoxDecoration(
                color: MosaedColors.surfaceWhite,
                border: Border(top: BorderSide(color: MosaedColors.fieldBorder)),
              ),
              child: SafeArea(
                top: false,
                child: MosaedPrimaryButton(
                  text: LocaleKeys.mosaedAccept.tr(),
                  isLoading: _accepting,
                  onPressed: _accepting ? null : _confirmAndAccept,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
