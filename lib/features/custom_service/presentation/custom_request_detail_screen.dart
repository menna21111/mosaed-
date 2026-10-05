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
import '../../../core/widgets/mosaed_payment_preparing_card.dart';
import '../../../core/widgets/mosaed_pill_tabs.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../home/presentation/main_shell.dart';
import '../../orders/data/completion_form_model.dart';
import '../../orders/data/order_model.dart';
import '../../payments/data/models/payment_request.dart';
import '../../payments/presentation/widgets/payment_status_section.dart';
import '../../orders/presentation/models/active_order_view_data.dart';
import '../../orders/presentation/widgets/active_order/active_order_body.dart';
import '../../orders/presentation/widgets/active_order/active_order_footer.dart';
import '../../orders/presentation/widgets/active_order/active_order_payment_actions.dart';
import '../../orders/presentation/widgets/active_order/technician_rating_sheet.dart';
import '../data/custom_service_repository.dart';
import '../data/models/custom_service_models.dart';
import 'offer_detail_screen.dart';
import 'widgets/custom_request_detail_bits.dart';
import 'widgets/custom_request_details_card.dart';
import 'widgets/custom_request_offers_tab.dart';

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

class _CustomRequestDetailScreenState extends State<CustomRequestDetailScreen>
    with SingleTickerProviderStateMixin {
  CustomRequest? _request;
  List<CustomOffer> _offers = [];
  CompletionForm? _completion;
  bool _loading = true;
  bool _confirmingArrival = false;
  bool _cancelling = false;
  String? _error;
  late final TabController _tabController;
  final _paymentSectionKey = GlobalKey();
  double _customerRating = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

      List<CustomOffer> offers = List<CustomOffer>.from(request.offers);
      try {
        final fetched = await repo.getCustomRequestOffers(widget.requestId);
        if (fetched.isNotEmpty) {
          offers = fetched;
        }
      } on ServerFailure catch (_) {
        // Nested offers on the request remain the source of truth.
      }

      if (request.acceptedProviderId != null) {
        offers = offers
            .map(
              (offer) => offer.providerId == request.acceptedProviderId
                  ? offer.copyWith(status: 'accepted')
                  : offer,
            )
            .toList();
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

    if (completion == null || !completion.hasFinished) {
      return const SizedBox.shrink();
    }

    if (completion.isPaymentPaid) {
      return PaymentStatusSection(
        payment: PaymentRequest(
          id: completion.paymentRequestId ?? '',
          requestId: widget.requestId,
          amount: amount,
          status: 'paid',
          paymentMethod: completion.paymentStatus,
        ),
        enableLoyaltyPoints: true,
        onRefresh: _refreshAfterPayment,
      );
    }

    if (completion.isAwaitingGatewayPayment) {
      return PaymentStatusSection(
        payment: PaymentRequest(
          id: completion.paymentRequestId ?? '',
          requestId: widget.requestId,
          amount: amount,
          status: completion.paymentStatus ?? 'awaiting_gateway_payment',
          paymentMethod: 'online',
        ),
        enableLoyaltyPoints: true,
        onRefresh: _refreshAfterPayment,
      );
    }

    if (completion.isAwaitingPaymentCreation) {
      return MosaedPaymentPreparingCard(onRetry: _refreshAfterPayment);
    }

    return const SizedBox.shrink();
  }

  Future<void> _onPayTap() async {
    final amount = _request?.acceptedOffer?.price ?? 0;
    await ActiveOrderPaymentActions(
      completion: _completion,
      amount: amount,
      paymentRequestId: _completion?.paymentRequestId,
      onRefresh: _refreshAfterPayment,
      enableLoyaltyPoints: true,
      paymentSectionKey: _paymentSectionKey,
    ).handlePayTap(context);
  }

  Future<void> _openRatingSheet(ActiveOrderViewData viewData) async {
    final name = viewData.collaboration.technicianName;
    await TechnicianRatingSheet.show(
      context,
      technicianName: name,
      technicianImage: viewData.collaboration.technicianImage,
      onSubmit: (stars, comment) async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        setState(() => _customerRating = stars.toDouble());
        AppFunctions.showsToast(
          'mosaedRatingSubmitted'.tr(),
          MosaedColors.success,
          context,
        );
      },
    );
  }

  Future<void> _openOfferDetail(
    CustomOffer offer, {
    required bool canAccept,
  }) async {
    await AppFunctions.navigateTo(
      context,
      OfferDetailScreen(
        requestId: widget.requestId,
        offer: offer,
        requestTitle: _request?.title ?? widget.initialOrder?.serviceTitle,
        scheduledLabel: _request != null ? _scheduleLabel(_request!) : null,
        canAccept: canAccept,
      ),
      PageTransitionType.rightToLeft,
    );
    if (mounted) await _load(silent: true);
  }

  List<CustomOffer> _offersForDisplay() {
    return _offers.where((o) => !o.isRejected).toList();
  }

  void _openChat(CustomOffer? offer) {
    final providerName =
        offer?.providerName?.trim() ?? _request?.providerName?.trim();
    final image = offer?.providerImage;
    final price = offer?.price ?? widget.initialOrder?.agreedAmount;
    AppFunctions.navigateTo(
      context,
      ChatScreen(
        requestId: widget.requestId,
        requestTitle: _request?.title ?? widget.initialOrder?.serviceTitle,
        peerName: providerName?.isNotEmpty == true
            ? providerName
            : LocaleKeys.mosaedWorkerPending.tr(),
        peerImage: image,
        price: (price != null && price > 0) ? price : null,
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

  String _scheduleLabel(CustomRequest request) =>
      ActiveOrderViewData.formatScheduleLabel(request.scheduledDate);

  Future<void> _confirmServiceReceived() async {
    AppFunctions.showsToast(
      LocaleKeys.mosaedReceivedServiceComingSoon.tr(),
      MosaedColors.brand,
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = _request;
    final isActiveOrder = request?.hasAcceptedOffer == true;

    return Scaffold(
      backgroundColor: MosaedColors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: MosaedColors.surfaceWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              AppFunctions.navigateToAndFinish(
                context,
                const MainShell(initialIndex: 1),
              );
            }
          },
          icon: Icon(
            Icons.arrow_forward_ios_rounded,
            color: MosaedColors.textPrimary,
            size: 18.sp,
          ),
        ),
        title: Text(
          LocaleKeys.mosaedOrderDetailsTab.tr(),
          style: getBoldStyle(
            fontSize: 16.sp,
            color: MosaedColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          if (!isActiveOrder)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
              child: AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  return MosaedPillTabs(
                    labels: [
                      LocaleKeys.mosaedOrderDetailsTab.tr(),
                      LocaleKeys.mosaedOffersTab.tr(),
                    ],
                    selectedIndex: _tabController.index,
                    onChanged: _tabController.animateTo,
                  );
                },
              ),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: MosaedColors.primaryContainer),
      );
    }

    if (_error != null) {
      return RequestLoadError(message: _error!, onRetry: _load);
    }

    final request = _request!;
    final acceptedOffer = request.resolveAcceptedOffer(_offers);

    if (request.hasAcceptedOffer) {
      final viewData = ActiveOrderViewData.fromCustomRequest(
        request: request,
        acceptedOffer: acceptedOffer,
        completion: _completion,
        customerRating: _customerRating,
      );

      return Column(
        children: [
          Expanded(
            child: ActiveOrderBody(
              data: viewData,
              onRefresh: _load,
              paymentSectionKey: _paymentSectionKey,
              paymentSection: _buildFinishedPaymentBlock(),
            ),
          ),
          ActiveOrderFooter(
            data: viewData,
            confirmingArrival: _confirmingArrival,
            onConfirmArrival: _confirmProviderArrived,
            onChat: () => _openChat(acceptedOffer),
            onReceiveService: _confirmServiceReceived,
            onPay: _onPayTap,
            onRateTechnician: () => _openRatingSheet(viewData),
          ),
        ],
      );
    }

    final pendingOffers = _offers.where((o) => o.isPending).toList();
    final showOffersList =
        !request.hasAcceptedOffer || pendingOffers.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              CustomRequestDetailsTab(
                onRefresh: _load,
                child: CustomRequestDetailsCard(request: request),
              ),
              CustomRequestOffersTab(
                request: request,
                offers: _offersForDisplay(),
                acceptedOffer: acceptedOffer,
                showOffersList: showOffersList,
                onRefresh: _load,
                onOfferTap: _openOfferDetail,
                onChat: () => _openChat(acceptedOffer),
              ),
            ],
          ),
        ),
        if (request.canCancel)
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              if (_tabController.index != 0) {
                return const SizedBox.shrink();
              }
              return CustomRequestActionsBar(
                onEdit: () {
                  AppFunctions.showsToast(
                    LocaleKeys.mosaedEditComingSoon.tr(),
                    MosaedColors.brand,
                    context,
                  );
                },
                onCancel: _cancelRequest,
                cancelling: _cancelling,
              );
            },
          ),
      ],
    );
  }
}
