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
import '../../orders/data/completion_form_model.dart';
import '../../orders/data/order_model.dart';
import '../../payments/data/models/payment_request.dart';
import '../../payments/presentation/widgets/payment_method_choice_panel.dart';
import '../../payments/presentation/widgets/payment_status_section.dart';
import '../data/custom_service_repository.dart';
import '../data/models/custom_service_models.dart';
import 'offer_detail_screen.dart';

class CustomRequestDetailScreen extends StatefulWidget {
  const CustomRequestDetailScreen({
    super.key,
    required this.requestId,
    this.initialOrder,
  });

  final String requestId;
  final ServiceOrder? initialOrder;

  @override
  State<CustomRequestDetailScreen> createState() =>
      _CustomRequestDetailScreenState();
}

class _CustomRequestDetailScreenState extends State<CustomRequestDetailScreen> {
  CustomRequest? _request;
  List<CustomOffer> _offers = [];
  CompletionForm? _completion;
  bool _loading = true;
  bool _acceptingOfferIdBusy = false;
  String? _busyOfferId;
  bool _confirmingArrival = false;
  bool _cancelling = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final repo = context.read<CustomServiceRepository>();
      final request = await repo.getCustomRequestDetail(widget.requestId);

      List<CustomOffer> offers = [];
      try {
        offers = await repo.getCustomRequestOffers(widget.requestId);
        if (request.acceptedProviderId != null) {
          offers = offers
              .map(
                (offer) => offer.providerId == request.acceptedProviderId
                    ? CustomOffer(
                        id: offer.id,
                        price: offer.price,
                        note: offer.note,
                        status: 'accepted',
                        providerId: offer.providerId,
                        providerName: offer.providerName,
                        providerRating: offer.providerRating,
                        providerJobsCount: offer.providerJobsCount,
                        createdAt: offer.createdAt,
                      )
                    : offer,
              )
              .toList();
        }
      } on ServerFailure catch (_) {
        // Offers endpoint may not be available for some statuses.
      }

      CompletionForm? completion;
      try {
        completion = await repo.getCustomRequestCompletion(widget.requestId);
      } on ServerFailure catch (_) {
        // Completion may not exist yet.
      }

      if (!mounted) return;
      setState(() {
        _request = request;
        _offers = offers;
        _completion = completion;
        _loading = false;
      });
    } on ServerFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.errMessage;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'mosaedCustomRequestLoadError'.tr();
        _loading = false;
      });
    }
  }

  Future<void> _refreshAfterPayment() => _load(silent: true);

  /// بعد `is_finished`:
  /// - awaiting_gateway_payment → WebView مباشرة (من غير select-method)
  /// - لسه null / مختارش → أونلاين / كاش
  /// الدفع من الـ completion فقط (من غير GET /api/payments/<id>/).
  Widget _buildFinishedPaymentBlock() {
    final completion = _completion;
    final amount = _request?.acceptedOffer?.price ?? 0;

    final PaymentRequest? resolved =
        completion != null &&
                completion.hasPaymentRequest &&
                !completion.needsPaymentMethodChoice
            ? PaymentRequest(
                id: completion.paymentRequestId!,
                requestId: widget.requestId,
                amount: amount,
                status: completion.paymentStatus ?? 'awaiting_gateway_payment',
                paymentMethod: completion.isAwaitingGatewayPayment
                    ? 'online'
                    : completion.isAwaitingCashPayment
                        ? 'cash'
                        : null,
              )
            : null;

    if (resolved != null && !resolved.isAwaitingMethod) {
      return PaymentStatusSection(
        payment: resolved,
        enableLoyaltyPoints: true,
        onRefresh: _refreshAfterPayment,
      );
    }

    return PaymentMethodChoicePanel(
      paymentRequestId: completion?.paymentRequestId,
      amount: amount,
      enableLoyaltyPoints: true,
      onAfterAction: _refreshAfterPayment,
    );
  }

  Future<void> _acceptOffer(CustomOffer offer) async {
    setState(() {
      _acceptingOfferIdBusy = true;
      _busyOfferId = offer.id;
    });
    try {
      final updated = await context.read<CustomServiceRepository>().acceptOffer(
            requestId: widget.requestId,
            offerId: offer.id,
          );
      if (!mounted) return;
      AppFunctions.showsToast(
        'mosaedOfferAccepted'.tr(),
        MosaedColors.success,
        context,
      );
      setState(() => _request = updated);
      await _load();
      if (!mounted) return;
      _openChat(offer);
    } on ServerFailure catch (e) {
      if (mounted) {
        AppFunctions.showsToast(e.errMessage, MosaedColors.danger, context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _acceptingOfferIdBusy = false;
          _busyOfferId = null;
        });
      }
    }
  }

  Future<void> _openOfferDetail(
    CustomOffer offer, {
    required bool canAccept,
  }) async {
    final accepted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OfferDetailScreen(
          requestId: widget.requestId,
          offer: offer,
          requestTitle: _request?.title ?? widget.initialOrder?.serviceTitle,
          canAccept: canAccept,
        ),
      ),
    );
    if (accepted == true && mounted) {
      await _load();
    }
  }

  void _openChat(CustomOffer? offer) {
    final providerName = offer?.providerName?.trim() ?? _request?.providerName?.trim();
    AppFunctions.navigateTo(
      context,
      ChatScreen(
        requestId: widget.requestId,
        requestTitle: _request?.title ?? widget.initialOrder?.serviceTitle,
        peerName: providerName?.isNotEmpty == true
            ? providerName
            : 'mosaedChat'.tr(),
      ),
      PageTransitionType.rightToLeft,
    );
  }

  Future<void> _confirmProviderArrived() async {
    setState(() => _confirmingArrival = true);
    try {
      final updated = await context
          .read<CustomServiceRepository>()
          .confirmProviderArrived(widget.requestId);
      if (!mounted) return;
      AppFunctions.showsToast(
        'mosaedProviderArrivedConfirmed'.tr(),
        MosaedColors.success,
        context,
      );
      setState(() => _request = updated);

      // Refresh completion form so started_at / status update.
      try {
        final completion = await context
            .read<CustomServiceRepository>()
            .getCustomRequestCompletion(widget.requestId);
        if (mounted) setState(() => _completion = completion);
      } on ServerFailure catch (_) {}

      await _load();
    } on ServerFailure catch (e) {
      if (mounted) {
        AppFunctions.showsToast(e.errMessage, MosaedColors.danger, context);
      }
    } finally {
      if (mounted) setState(() => _confirmingArrival = false);
    }
  }

  Future<void> _cancelRequest() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('mosaedCancelCustomRequest'.tr()),
        content: Text('mosaedCancelCustomRequestConfirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'mosaedConfirmCancel'.tr(),
              style: const TextStyle(color: MosaedColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    try {
      final updated = await context
          .read<CustomServiceRepository>()
          .cancelCustomRequest(widget.requestId);
      if (!mounted) return;
      AppFunctions.showsToast(
        'mosaedCustomRequestCancelled'.tr(),
        MosaedColors.success,
        context,
      );
      setState(() => _request = updated);
      await _load();
    } on ServerFailure catch (e) {
      if (mounted) {
        AppFunctions.showsToast(e.errMessage, MosaedColors.danger, context);
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  Color _statusColor(CustomRequest request) {
    final s = request.rawStatus.toLowerCase().trim();
    if (s.contains('accept')) return MosaedColors.success;
    if (s.contains('cancel')) return MosaedColors.danger;
    if (s.contains('complete') || s.contains('done') || s.contains('finish')) {
      return MosaedColors.success;
    }
    return request.status.statusColor;
  }

  String _val(String value) => value.startsWith('mosaed') ? value.tr() : value;

  String _formatDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('yyyy-MM-dd • HH:mm').format(dt.toLocal());
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.initialOrder?.serviceTitle ??
        _request?.title ??
        'mosaedCustomServiceTitle'.tr();

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
          'mosaedCustomRequestDetails'.tr(),
          style: getBoldStyle(fontSize: 18.sp, color: MosaedColors.textPrimary),
        ),
      ),
      body: _buildBody(title),
    );
  }

  Widget _buildBody(String title) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: MosaedColors.primaryContainer),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 48.sp, color: MosaedColors.textHint),
              SizedBox(height: 12.h),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: getRegularStyle(
                  fontSize: 14.sp,
                  color: MosaedColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              TextButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
                label: Text('mosaedRetry'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    final request = _request!;
    final acceptedOffer = request.resolveAcceptedOffer(_offers);
    final statusColor = _statusColor(request);
    final pendingOffers = _offers.where((o) => o.isPending).toList();
    final showOffers = !request.hasAcceptedOffer || pendingOffers.isNotEmpty;

    return RefreshIndicator(
      onRefresh: _load,
      color: MosaedColors.primary,
      child: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          if (request.image != null && request.image!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: Image.network(
                request.image!,
                height: 180.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder(),
              ),
            )
          else
            _imagePlaceholder(),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: MosaedColors.surfaceWhite,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: MosaedColors.border),
              boxShadow: MosaedColors.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: MosaedColors.primaryFixed,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'mosaedCustomRequestBadge'.tr(),
                        style: getMediumStyle(
                          fontSize: 11.sp,
                          color: MosaedColors.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        request.displayStatusKey.tr(),
                        style: getMediumStyle(
                          fontSize: 11.sp,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  title,
                  style: getBoldStyle(
                    fontSize: 20.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '#${request.id.length > 8 ? request.id.substring(0, 8) : request.id}',
                  style: getRegularStyle(
                    fontSize: 12.sp,
                    color: MosaedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (request.status == OrderStatus.workerArrived) ...[
            SizedBox(height: 12.h),
            _banner(
              icon: Icons.engineering_rounded,
              title: 'mosaedWorkerArrivedTitle'.tr(),
              subtitle: request.providerArrivedAt != null
                  ? _formatDateTime(request.providerArrivedAt!)
                  : 'mosaedWorkerArrivedBanner'.tr(),
              color: MosaedColors.primary,
              background: MosaedColors.shieldBg,
            ),
          ],
          SizedBox(height: 12.h),
          _infoCard(
            title: 'mosaedSpecialization'.tr(),
            value: request.specializationName ?? 'mosaedNotAvailableYet'.tr(),
            icon: Icons.handyman_outlined,
          ),
          SizedBox(height: 12.h),
          _infoCard(
            title: 'mosaedPreferredDay'.tr(),
            value: request.scheduledDate != null
                ? _val(request.scheduledDate!)
                : 'mosaedNotAvailableYet'.tr(),
            icon: Icons.calendar_today_outlined,
          ),
          SizedBox(height: 12.h),
          _infoCard(
            title: 'mosaedServiceLocation'.tr(),
            value: request.addressText?.trim().isNotEmpty == true
                ? request.addressText!
                : 'mosaedNotAvailableYet'.tr(),
            icon: Icons.location_on_outlined,
          ),
          SizedBox(height: 12.h),
          _infoCard(
            title: 'mosaedProblemDescription'.tr(),
            value: request.description,
            icon: Icons.description_outlined,
          ),
          if (request.hasAcceptedOffer) ...[
            SizedBox(height: 16.h),
            Text(
              'mosaedAcceptedOffer'.tr(),
              style: getBoldStyle(
                fontSize: 16.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),
            if (acceptedOffer != null)
              _offerCard(
                acceptedOffer,
                canAccept: false,
              )
            else
              _acceptedProviderCard(request),
            SizedBox(height: 12.h),
            MosaedPrimaryButton(
              text: 'mosaedChatWithWorker'.tr(),
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: () => _openChat(acceptedOffer),
            ),
          ],
          if (showOffers) ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                Text(
                  'mosaedOffers'.tr(),
                  style: getBoldStyle(
                    fontSize: 16.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_offers.isNotEmpty ? _offers.length : (request.offersCount ?? 0)}',
                  style: getMediumStyle(
                    fontSize: 13.sp,
                    color: MosaedColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            if (_offers.isEmpty)
              _emptyOffers()
            else
              ..._offers.map(
                (offer) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _offerCard(
                    offer,
                    canAccept: !request.hasAcceptedOffer && offer.isPending,
                  ),
                ),
              ),
          ],
          if ((_completion?.needsArrivalConfirm == true) ||
              (request.canConfirmProviderArrived &&
                  _completion == null)) ...[
            SizedBox(height: 20.h),
            MosaedPrimaryButton(
              text: 'mosaedConfirmProviderArrived'.tr(),
              icon: Icons.engineering_rounded,
              isLoading: _confirmingArrival,
              onPressed: _confirmProviderArrived,
            ),
            SizedBox(height: 8.h),
            Text(
              'mosaedConfirmProviderArrivedHint'.tr(),
              textAlign: TextAlign.center,
              style: getRegularStyle(
                fontSize: 12.sp,
                color: MosaedColors.textSecondary,
              ),
            ),
          ],
          if (_completion != null &&
              _completion!.hasStarted &&
              !_completion!.isFinished) ...[
            SizedBox(height: 12.h),
            _banner(
              icon: Icons.engineering_rounded,
              title: 'mosaedWorkerArrivedTitle'.tr(),
              subtitle: _completion!.startedAt != null
                  ? _formatDateTime(_completion!.startedAt!)
                  : 'mosaedWorkerArrivedBanner'.tr(),
              color: MosaedColors.primary,
              background: MosaedColors.shieldBg,
            ),
          ],
          if (_completion != null &&
              (_completion!.hasBeforeImage || _completion!.hasAfterImage)) ...[
            SizedBox(height: 16.h),
            Text(
              'mosaedWorkPhotos'.tr(),
              style: getBoldStyle(
                fontSize: 16.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                if (_completion!.hasBeforeImage)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'mosaedBefore'.tr(),
                          style: getMediumStyle(
                            fontSize: 12.sp,
                            color: MosaedColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(
                            _completion!.beforeImage!,
                            height: 120.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 120.h,
                              color: MosaedColors.inputFill,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: MosaedColors.textHint,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_completion!.hasBeforeImage && _completion!.hasAfterImage)
                  SizedBox(width: 10.w),
                if (_completion!.hasAfterImage)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'mosaedAfter'.tr(),
                          style: getMediumStyle(
                            fontSize: 12.sp,
                            color: MosaedColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(
                            _completion!.afterImage!,
                            height: 120.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 120.h,
                              color: MosaedColors.inputFill,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: MosaedColors.textHint,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          if (_completion?.hasFinished == true) ...[
            SizedBox(height: 16.h),
            _buildFinishedPaymentBlock(),
          ],
          if (request.canCancel) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: OutlinedButton.icon(
                onPressed: _cancelling ? null : _cancelRequest,
                icon: _cancelling
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: MosaedColors.danger,
                        ),
                      )
                    : Icon(
                        Icons.cancel_outlined,
                        color: MosaedColors.danger,
                        size: 20.sp,
                      ),
                label: Text(
                  'mosaedCancelCustomRequest'.tr(),
                  style: getBoldStyle(
                    fontSize: 14.sp,
                    color: MosaedColors.danger,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: MosaedColors.danger),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _emptyOffers() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: MosaedColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.local_offer_outlined, size: 32.sp, color: MosaedColors.textHint),
          SizedBox(height: 8.h),
          Text(
            'mosaedNoOffersYet'.tr(),
            style: getMediumStyle(
              fontSize: 14.sp,
              color: MosaedColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'mosaedNoOffersYetHint'.tr(),
            textAlign: TextAlign.center,
            style: getRegularStyle(
              fontSize: 12.sp,
              color: MosaedColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _acceptedProviderCard(CustomRequest request) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: MosaedColors.success),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: MosaedColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: MosaedColors.success,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.providerName?.trim().isNotEmpty == true
                      ? request.providerName!
                      : 'mosaedWorkerPending'.tr(),
                  style: getBoldStyle(
                    fontSize: 14.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'mosaedOfferAcceptedBadge'.tr(),
                  style: getMediumStyle(
                    fontSize: 12.sp,
                    color: MosaedColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _offerCard(CustomOffer offer, {required bool canAccept}) {
    final currency = 'mosaedCurrency'.tr();
    final isBusy = _acceptingOfferIdBusy && _busyOfferId == offer.id;

    return InkWell(
      onTap: () => _openOfferDetail(offer, canAccept: canAccept),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: MosaedColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: offer.isAccepted ? MosaedColors.success : MosaedColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: MosaedColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: MosaedColors.primary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.providerName?.trim().isNotEmpty == true
                            ? offer.providerName!
                            : 'mosaedWorkerPending'.tr(),
                        style: getBoldStyle(
                          fontSize: 14.sp,
                          color: MosaedColors.textPrimary,
                        ),
                      ),
                      if (offer.providerRating != null) ...[
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14.sp,
                              color: const Color(0xFFF59E0B),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              offer.providerRating!.toStringAsFixed(1),
                              style: getRegularStyle(
                                fontSize: 12.sp,
                                color: MosaedColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (offer.canChat)
                  IconButton(
                    tooltip: 'mosaedOpenChat'.tr(),
                    onPressed: () => _openChat(offer),
                    icon: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: MosaedColors.primary,
                      size: 20.sp,
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'mosaedTotalPrice'.tr(),
                      style: getRegularStyle(
                        fontSize: 10.sp,
                        color: MosaedColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${offer.price.toStringAsFixed(0)} $currency',
                      style: getBoldStyle(
                        fontSize: 16.sp,
                        color: MosaedColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (offer.note != null && offer.note!.trim().isNotEmpty) ...[
              SizedBox(height: 10.h),
              Text(
                offer.note!,
                style: getRegularStyle(
                  fontSize: 13.sp,
                  color: MosaedColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            if (canAccept) ...[
              SizedBox(height: 12.h),
              MosaedPrimaryButton(
                text: 'mosaedAcceptOffer'.tr(),
                isLoading: isBusy,
                onPressed:
                    _acceptingOfferIdBusy ? null : () => _acceptOffer(offer),
              ),
            ],
            if (offer.isAccepted) ...[
              SizedBox(height: 10.h),
              Text(
                'mosaedOfferAcceptedBadge'.tr(),
                style: getMediumStyle(
                  fontSize: 12.sp,
                  color: MosaedColors.success,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _banner({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color background,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: getBoldStyle(fontSize: 13.sp, color: color),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: getRegularStyle(
                    fontSize: 12.sp,
                    color: MosaedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 140.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: MosaedColors.primaryFixed,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Icon(
        Icons.home_repair_service_rounded,
        size: 48.sp,
        color: MosaedColors.primary,
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
