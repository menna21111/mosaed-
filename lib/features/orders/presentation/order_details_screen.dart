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
import '../../chat/presentation/chat_screen.dart';
import '../../payments/data/models/payment_request.dart';
import '../../payments/presentation/widgets/booking_payment_panel.dart';
import '../../payments/presentation/widgets/payment_status_section.dart';
import '../../services/data/services_repository.dart';
import '../data/completion_form_model.dart';
import '../data/order_model.dart';
import 'models/active_order_view_data.dart';
import 'widgets/active_order/active_order_body.dart';
import 'widgets/active_order/active_order_footer.dart';
import 'widgets/active_order/active_order_payment_actions.dart';
import 'widgets/active_order/technician_rating_sheet.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.order});

  final ServiceOrder order;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late ServiceOrder _order;
  CompletionForm? _completion;
  bool _loading = false;
  String? _error;

  late double _customerRating;
  bool _confirmingArrival = false;
  final _paymentSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _syncLocalState(_order);
    _loadDetail();
  }

  void _syncLocalState(ServiceOrder order) {
    _customerRating = order.customerRating;
  }

  ServiceOrder get order => _order;

  Future<void> _loadDetail({bool silent = false}) async {
    final bookingId = _order.bookingId;
    if (bookingId == null || bookingId.isEmpty) return;

    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final repo = context.read<ServicesRepository>();
      final booking = await repo.getBookingDetail(bookingId);

      CompletionForm? completion;
      try {
        completion = await repo.getBookingCompletion(bookingId);
      } on ServerFailure catch (_) {}

      if (!mounted) return;
      final updated = booking.toServiceOrder().applyingCompletion(completion);
      setState(() {
        _order = updated;
        _completion = completion;
        _syncLocalState(updated);
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
        _error = 'mosaedOrdersLoadError'.tr();
        _loading = false;
      });
    }
  }

  Future<void> _refreshAfterPayment() => _loadDetail(silent: true);

  Widget _buildFinishedPaymentBlock() {
    final completion = _completion;
    final amount = order.agreedAmount;
    final paymentId = completion?.paymentRequestId?.trim() ?? '';
    final paymentStatus = completion?.paymentStatus;

    if (completion == null || !completion.hasFinished) {
      return const SizedBox.shrink();
    }

    if (completion.isPaymentPaid) {
      return PaymentStatusSection(
        payment: PaymentRequest(
          id: paymentId,
          requestId: order.bookingId ?? '',
          amount: amount,
          status: 'paid',
          paymentMethod: paymentStatus,
        ),
        onRefresh: _refreshAfterPayment,
      );
    }

    if (completion.isAwaitingGatewayPayment) {
      return BookingPaymentPanel(
        paymentRequestId: paymentId,
        paymentStatus: paymentStatus,
        amount: amount,
        onAfterAction: _refreshAfterPayment,
      );
    }

    if (completion.isAwaitingPaymentCreation || paymentId.isEmpty) {
      return MosaedPaymentPreparingCard(
        onRetry: () => _loadDetail(silent: true),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _onPayTap() async {
    await ActiveOrderPaymentActions(
      completion: _completion,
      amount: order.agreedAmount,
      paymentRequestId: _completion?.paymentRequestId,
      bookingId: order.bookingId,
      onRefresh: _refreshAfterPayment,
      paymentSectionKey: _paymentSectionKey,
    ).handlePayTap(context);
  }

  Future<void> _openRatingSheet(ActiveOrderViewData viewData) async {
    await TechnicianRatingSheet.show(
      context,
      technicianName: viewData.collaboration.technicianName,
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

  Future<void> _confirmProviderArrived() async {
    final bookingId = order.bookingId;
    if (bookingId == null || bookingId.isEmpty) return;

    setState(() => _confirmingArrival = true);
    try {
      final completion = await context
          .read<ServicesRepository>()
          .confirmBookingProviderArrived(bookingId);
      if (!mounted) return;
      AppFunctions.showsToast(
        'mosaedProviderArrivedConfirmed'.tr(),
        MosaedColors.success,
        context,
      );
      setState(() => _completion = completion);
      await _loadDetail();
    } on ServerFailure catch (e) {
      if (mounted) {
        AppFunctions.showsToast(e.errMessage, MosaedColors.danger, context);
      }
    } finally {
      if (mounted) setState(() => _confirmingArrival = false);
    }
  }

  Future<void> _confirmServiceReceived() async {
    AppFunctions.showsToast(
      LocaleKeys.mosaedReceivedServiceComingSoon.tr(),
      MosaedColors.brand,
      context,
    );
  }

  void _openChat() {
    final chatId = order.bookingId ?? order.id;
    AppFunctions.navigateTo(
      context,
      ChatScreen(
        requestId: chatId,
        requestTitle: order.serviceTitle,
        peerName: order.workerName.startsWith('mosaed')
            ? order.workerName.tr()
            : order.workerName,
        peerImage: order.workerImage,
        price: order.agreedAmount > 0 ? order.agreedAmount : null,
      ),
      PageTransitionType.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewData = ActiveOrderViewData.fromServiceOrder(
      order: order,
      completion: _completion,
      customerRating: _customerRating,
    );

    return Scaffold(
      backgroundColor: MosaedColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: MosaedColors.surfaceWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: MosaedColors.textPrimary,
            size: 18.sp,
          ),
        ),
        title: Text(
          LocaleKeys.mosaedServiceDetails.tr(),
          style: getBoldStyle(fontSize: 16.sp, color: MosaedColors.textPrimary),
        ),
      ),
      body: _loading && _order.bookingId != null
          ? const Center(
              child: CircularProgressIndicator(
                color: MosaedColors.primaryContainer,
              ),
            )
          : _error != null && _order.serviceTitle.isEmpty
              ? _buildErrorState()
              : Column(
                  children: [
                    if (_error != null)
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                        child: _InlineErrorBanner(message: _error!),
                      ),
                    Expanded(
                      child: ActiveOrderBody(
                        data: viewData,
                        onRefresh: _loadDetail,
                        paymentSectionKey: _paymentSectionKey,
                        paymentSection: _buildFinishedPaymentBlock(),
                      ),
                    ),
                    ActiveOrderFooter(
                      data: viewData,
                      confirmingArrival: _confirmingArrival,
                      onConfirmArrival: _confirmProviderArrived,
                      onChat: _openChat,
                      onReceiveService: _confirmServiceReceived,
                      onPay: _onPayTap,
                      onRateTechnician: () => _openRatingSheet(viewData),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: getRegularStyle(
                fontSize: 12.sp,
                color: MosaedColors.textSecondary,
              ),
            ),
            SizedBox(height: 12.h),
            TextButton.icon(
              onPressed: _loadDetail,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('mosaedRetry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: MosaedColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        message,
        style: getRegularStyle(fontSize: 12.sp, color: MosaedColors.danger),
      ),
    );
  }
}
