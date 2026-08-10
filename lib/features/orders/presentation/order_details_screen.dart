import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/functions.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../../core/network/failure.dart';
import '../../auth/presentation/widgets/mosaed_buttons.dart';
import '../../orders/data/completion_form_model.dart';
import '../../orders/data/order_model.dart';
import '../../payments/data/models/payment_request.dart';
import '../../payments/presentation/widgets/booking_payment_panel.dart';
import '../../payments/presentation/widgets/payment_status_section.dart';
import '../../services/data/services_repository.dart';

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
  late bool _complaintSubmitted;
  final _complaintController = TextEditingController();
  bool _submittingComplaint = false;
  bool _confirmingArrival = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _syncLocalState(_order);
    _loadDetail();
  }

  @override
  void dispose() {
    _complaintController.dispose();
    super.dispose();
  }

  void _syncLocalState(ServiceOrder order) {
    _customerRating = order.customerRating;
    _complaintSubmitted = order.complaintSubmitted;
  }

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
      } on ServerFailure catch (_) {
        // Completion may not exist yet for pending bookings.
      }

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

  ServiceOrder get order => _order;

  String _val(String value) => value.startsWith('mosaed') ? value.tr() : value;

  /// بعد `is_finished`: استخدم `payment_request_id` من completion فقط
  /// ثم `POST /api/payments/<id>/select-method/`.
  Widget _buildFinishedPaymentBlock() {
    final completion = _completion;
    final amount = order.agreedAmount;
    final paymentId = completion?.paymentRequestId?.trim() ?? '';
    final paymentStatus = completion?.paymentStatus;

    if (completion != null && completion.isPaymentPaid) {
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

    if (paymentId.isEmpty) {
      return _PaymentPreparingCard(onRetry: () => _loadDetail(silent: true));
    }

    return BookingPaymentPanel(
      paymentRequestId: paymentId,
      paymentStatus: paymentStatus,
      amount: amount,
      onAfterAction: _refreshAfterPayment,
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

  void _submitRating(int stars) {
    setState(() => _customerRating = stars.toDouble());
    AppFunctions.showsToast(
      'mosaedRatingSubmitted'.tr(),
      MosaedColors.success,
      context,
    );
  }

  Future<void> _submitComplaint() async {
    final text = _complaintController.text.trim();
    if (text.isEmpty) {
      AppFunctions.showsToast(
        'mosaedComplaintRequired'.tr(),
        MosaedColors.danger,
        context,
      );
      return;
    }
    setState(() => _submittingComplaint = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _complaintSubmitted = true;
      _submittingComplaint = false;
    });
    AppFunctions.showsToast(
      'mosaedComplaintSubmitted'.tr(),
      MosaedColors.success,
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MosaedColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'mosaedOrderDetails'.tr(args: [order.id]),
          style: getBoldStyle(fontSize: 18.sp, color: MosaedColors.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadDetail,
            icon: Icon(
              Icons.refresh_rounded,
              color: MosaedColors.primary,
              size: 22.sp,
            ),
          ),
        ],
      ),
      body: _loading && _order.bookingId != null
          ? const Center(
              child: CircularProgressIndicator(
                color: MosaedColors.primaryContainer,
              ),
            )
          : _error != null && _order.serviceTitle.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: getRegularStyle(
                            fontSize: 14.sp,
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
                )
              : RefreshIndicator(
                  onRefresh: _loadDetail,
                  color: MosaedColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_error != null) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            margin: EdgeInsets.only(bottom: 12.h),
                            decoration: BoxDecoration(
                              color: MosaedColors.danger.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              _error!,
                              style: getRegularStyle(
                                fontSize: 12.sp,
                                color: MosaedColors.danger,
                              ),
                            ),
                          ),
                        ],
                        _HeaderCard(order: order),
                        // حالة الشغل من completion — المصدر الأدق.
                        if (_completion?.needsArrivalConfirm == true) ...[
                          SizedBox(height: 12.h),
                          _HighlightBanner(
                            icon: Icons.pending_actions_rounded,
                            title: 'mosaedCompletionStatusWaiting'.tr(),
                            subtitle: 'mosaedConfirmProviderArrivedHint'.tr(),
                            color: const Color(0xFFF59E0B),
                            background: const Color(0xFFFFF7ED),
                          ),
                        ] else if (_completion != null &&
                            _completion!.isProviderArrived &&
                            !_completion!.hasFinished) ...[
                          SizedBox(height: 12.h),
                          _HighlightBanner(
                            icon: Icons.engineering_rounded,
                            title: 'mosaedWorkerArrivedTitle'.tr(),
                            subtitle: _completion!.startedAtFormatted ??
                                'mosaedWorkerArrivedBanner'.tr(),
                            color: MosaedColors.primary,
                            background: MosaedColors.shieldBg,
                          ),
                        ] else if (_completion?.hasFinished == true ||
                            order.isCompleted) ...[
                          SizedBox(height: 12.h),
                          _HighlightBanner(
                            icon: Icons.task_alt_rounded,
                            title: 'mosaedServiceFinishedTitle'.tr(),
                            subtitle: _completion?.finishedAtFormatted ??
                                _val(order.finishedAt),
                            color: MosaedColors.success,
                            background: MosaedColors.successBg,
                          ),
                          if (_completion?.hasFinished == true) ...[
                            SizedBox(height: 16.h),
                            _buildFinishedPaymentBlock(),
                          ],
                        ] else if (order.hasWorkerArrived) ...[
                          SizedBox(height: 12.h),
                          _HighlightBanner(
                            icon: Icons.engineering_rounded,
                            title: 'mosaedWorkerArrivedTitle'.tr(),
                            subtitle: _val(order.arrivedAt),
                            color: MosaedColors.primary,
                            background: MosaedColors.shieldBg,
                          ),
                        ] else if (order.isPriceProposed &&
                            order.agreedAmount > 0) ...[
                          SizedBox(height: 12.h),
                          _HighlightBanner(
                            icon: Icons.sell_rounded,
                            title: 'mosaedPriceProposed'.tr(),
                            subtitle:
                                '${'mosaedProposedPrice'.tr()}: ${order.agreedAmount.toStringAsFixed(0)} ${'mosaedCurrency'.tr()}',
                            color: MosaedColors.primary,
                            background: MosaedColors.shieldBg,
                          ),
                        ],
                        SizedBox(height: 16.h),
                        _Section(
                          title: 'mosaedWorkerInfo'.tr(),
                          child: _WorkerCard(order: order),
                        ),
                        if (_completion?.needsArrivalConfirm == true) ...[
                          SizedBox(height: 16.h),
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
                        if (_completion != null) ...[
                          SizedBox(height: 16.h),
                          _Section(
                            title: 'mosaedWorkProgress'.tr(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _InfoRow(
                                  label: 'mosaedCompletionStatus'.tr(),
                                  value: _completion!.statusLabelKey.tr(),
                                  valueColor: _completion!.hasFinished
                                      ? MosaedColors.success
                                      : _completion!.isProviderArrived
                                          ? MosaedColors.primary
                                          : const Color(0xFFF59E0B),
                                ),
                                if (_completion!.startedAtFormatted != null)
                                  _InfoRow(
                                    label: 'mosaedArrivalTime'.tr(),
                                    value: _completion!.startedAtFormatted!,
                                    valueColor: MosaedColors.primary,
                                  ),
                                if (_completion!.finishedAtFormatted != null)
                                  _InfoRow(
                                    label: 'mosaedFinishTime'.tr(),
                                    value: _completion!.finishedAtFormatted!,
                                    valueColor: MosaedColors.success,
                                  ),
                                if (_completion!.notes != null) ...[
                                  SizedBox(height: 4.h),
                                  Text(
                                    'mosaedOrderNotes'.tr(),
                                    style: getMediumStyle(
                                      fontSize: 13.sp,
                                      color: MosaedColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    _completion!.notes!,
                                    style: getRegularStyle(
                                      fontSize: 13.sp,
                                      color: MosaedColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        if (_completion != null &&
                            (_completion!.hasBeforeImage ||
                                _completion!.hasAfterImage)) ...[
                          SizedBox(height: 16.h),
                          _Section(
                            title: 'mosaedWorkPhotos'.tr(),
                            child: Row(
                              children: [
                                if (_completion!.hasBeforeImage)
                                  Expanded(
                                    child: _WorkPhoto(
                                      label: 'mosaedBefore'.tr(),
                                      url: _completion!.beforeImage!,
                                    ),
                                  ),
                                if (_completion!.hasBeforeImage &&
                                    _completion!.hasAfterImage)
                                  SizedBox(width: 10.w),
                                if (_completion!.hasAfterImage)
                                  Expanded(
                                    child: _WorkPhoto(
                                      label: 'mosaedAfter'.tr(),
                                      url: _completion!.afterImage!,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        if (order.bookingItems.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          _Section(
                            title: 'mosaedOrderItems'.tr(),
                            child: Column(
                              children: order.bookingItems.map((item) {
                                final currency = 'mosaedCurrency'.tr();
                                final lineCost = item.cost ??
                                    (item.unitCost != null
                                        ? item.unitCost! * item.value
                                        : null);
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.attributeName,
                                              style: getMediumStyle(
                                                fontSize: 13.sp,
                                                color: MosaedColors.textPrimary,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              '${item.value}${item.unitCost != null ? ' × ${item.unitCost!.toStringAsFixed(0)} $currency' : ''}',
                                              style: getRegularStyle(
                                                fontSize: 12.sp,
                                                color:
                                                    MosaedColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (lineCost != null)
                                        Text(
                                          '${lineCost.toStringAsFixed(0)} $currency',
                                          style: getBoldStyle(
                                            fontSize: 13.sp,
                                            color: MosaedColors.primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                        SizedBox(height: 16.h),
                        _Section(
                          title: 'mosaedPaymentInfo'.tr(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (order.agreedAmount > 0)
                                _InfoRow(
                                  label: order.isPriceProposed
                                      ? 'mosaedProposedPrice'.tr()
                                      : 'mosaedAgreedAmount'.tr(),
                                  value:
                                      '${order.agreedAmount.toStringAsFixed(0)} ${'mosaedCurrency'.tr()}',
                                  valueColor: order.isPriceProposed
                                      ? MosaedColors.primary
                                      : null,
                                )
                              else
                                _InfoRow(
                                  label: 'mosaedAgreedAmount'.tr(),
                                  value: 'mosaedPriceSetByDashboard'.tr(),
                                  valueColor: MosaedColors.textSecondary,
                                ),
                              if (order.serviceVisitCost != null)
                                _InfoRow(
                                  label: 'mosaedVisitCost'.tr(),
                                  value:
                                      '${order.serviceVisitCost!.toStringAsFixed(0)} ${'mosaedCurrency'.tr()}',
                                ),
                              if (order.discountAmount != null &&
                                  order.discountAmount! > 0)
                                _InfoRow(
                                  label: 'mosaedDiscount'.tr(),
                                  value:
                                      '-${order.discountAmount!.toStringAsFixed(0)} ${'mosaedCurrency'.tr()}',
                                  valueColor: MosaedColors.success,
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _Section(
                          title: 'mosaedTimeline'.tr(),
                          child: Column(
                            children: [
                              _InfoRow(
                                label: 'mosaedScheduledTime'.tr(),
                                value: _val(order.scheduledSlot),
                              ),
                              if (order.createdAt != null)
                                _InfoRow(
                                  label: 'mosaedCreatedAt'.tr(),
                                  value: order.createdAt!,
                                ),
                              if (!order.isPending)
                                _InfoRow(
                                  label: 'mosaedArrivalTime'.tr(),
                                  value: _completion?.startedAtFormatted ??
                                      _val(order.arrivedAt),
                                  valueColor:
                                      order.hasWorkerArrived || order.isCompleted
                                          ? MosaedColors.primary
                                          : null,
                                ),
                              if (order.isCompleted ||
                                  _completion?.hasFinished == true)
                                _InfoRow(
                                  label: 'mosaedFinishTime'.tr(),
                                  value: _completion?.finishedAtFormatted ??
                                      _val(order.finishedAt),
                                  valueColor: MosaedColors.success,
                                ),
                            ],
                          ),
                        ),
                        if (!order.isPending) ...[
                          SizedBox(height: 16.h),
                          _Section(
                            title: 'mosaedUsedItems'.tr(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'mosaedToolsUsed'.tr(),
                                  style: getMediumStyle(
                                    fontSize: 13.sp,
                                    color: MosaedColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                if ((_completion?.toolsUsed.isNotEmpty == true
                                        ? _completion!.toolsUsed
                                        : order.toolsUsed)
                                    .isEmpty)
                                  Text('mosaedNotAvailableYet'.tr())
                                else
                                  Wrap(
                                    spacing: 8.w,
                                    runSpacing: 8.h,
                                    children: (_completion?.toolsUsed
                                                    .isNotEmpty ==
                                                true
                                            ? _completion!.toolsUsed
                                            : order.toolsUsed)
                                        .map((tool) => _Chip(text: _val(tool)))
                                        .toList(),
                                  ),
                                SizedBox(height: 14.h),
                                Text(
                                  'mosaedMaterialsUsed'.tr(),
                                  style: getMediumStyle(
                                    fontSize: 13.sp,
                                    color: MosaedColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                if ((_completion?.materialsUsed.isNotEmpty ==
                                            true
                                        ? _completion!.materialsUsed
                                        : order.materialsUsed)
                                    .isEmpty)
                                  Text('mosaedNotAvailableYet'.tr())
                                else
                                  Wrap(
                                    spacing: 8.w,
                                    runSpacing: 8.h,
                                    children: (_completion?.materialsUsed
                                                    .isNotEmpty ==
                                                true
                                            ? _completion!.materialsUsed
                                            : order.materialsUsed)
                                        .map((item) => _Chip(text: _val(item)))
                                        .toList(),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        if (order.isCompleted) ...[
                          SizedBox(height: 16.h),
                          _Section(
                            title: 'mosaedRatingSection'.tr(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _InfoRow(
                                  label: 'mosaedWorkerRating'.tr(),
                                  value: order.workerRating > 0
                                      ? '${order.workerRating} ⭐'
                                      : 'mosaedNotAvailableYet'.tr(),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'mosaedYourRating'.tr(),
                                  style: getMediumStyle(
                                    fontSize: 13.sp,
                                    color: MosaedColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                if (_customerRating > 0)
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < _customerRating.round()
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        color: const Color(0xFFF59E0B),
                                        size: 32.sp,
                                      ),
                                    ),
                                  )
                                else
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => IconButton(
                                        onPressed: () => _submitRating(i + 1),
                                        icon: Icon(
                                          Icons.star_outline_rounded,
                                          color: const Color(0xFFF59E0B),
                                          size: 36.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _Section(
                            title: 'mosaedComplaintSection'.tr(),
                            child: _complaintSubmitted
                                ? Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(14.w),
                                    decoration: BoxDecoration(
                                      color: MosaedColors.successBg,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: MosaedColors.success
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: MosaedColors.success,
                                        ),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: Text(
                                            'mosaedComplaintReceived'.tr(),
                                            style: getMediumStyle(
                                              fontSize: 13.sp,
                                              color: MosaedColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'mosaedComplaintHint'.tr(),
                                        style: getRegularStyle(
                                          fontSize: 13.sp,
                                          color: MosaedColors.textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      TextField(
                                        controller: _complaintController,
                                        maxLines: 4,
                                        decoration: InputDecoration(
                                          hintText:
                                              'mosaedComplaintPlaceholder'.tr(),
                                          filled: true,
                                          fillColor: MosaedColors.inputFill,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(14.r),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                      MosaedPrimaryButton(
                                        text: 'mosaedSubmitComplaint'.tr(),
                                        icon: Icons.send_rounded,
                                        isLoading: _submittingComplaint,
                                        onPressed: _submitComplaint,
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                        SizedBox(height: 16.h),
                        _Section(
                          title: 'mosaedOrderNotes'.tr(),
                          child: Text(
                            _val(order.notes),
                            style: getRegularStyle(
                              fontSize: 14.sp,
                              color: MosaedColors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _PaymentPreparingCard extends StatelessWidget {
  const _PaymentPreparingCard({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
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
          Text(
            'mosaedPaymentPreparingTitle'.tr(),
            style: getBoldStyle(
              fontSize: 15.sp,
              color: MosaedColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'mosaedPaymentPreparingHint'.tr(),
            textAlign: TextAlign.center,
            style: getRegularStyle(
              fontSize: 13.sp,
              color: MosaedColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          TextButton.icon(
            onPressed: () => onRetry(),
            icon: const Icon(Icons.refresh_rounded),
            label: Text('mosaedRetry'.tr()),
          ),
        ],
      ),
    );
  }
}

class _HighlightBanner extends StatelessWidget {
  const _HighlightBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: getBoldStyle(fontSize: 14.sp, color: color),
                ),
                SizedBox(height: 4.h),
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
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.order});

  final ServiceOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: MosaedColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: MosaedColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.serviceTitle,
                  style: getBoldStyle(
                    fontSize: 20.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: order.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  order.statusKey.tr(),
                  style: getMediumStyle(
                    fontSize: 11.sp,
                    color: order.statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16.sp,
                color: MosaedColors.primary,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  order.locationText,
                  style: getRegularStyle(
                    fontSize: 13.sp,
                    color: MosaedColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  const _WorkerCard({required this.order});

  final ServiceOrder order;

  @override
  Widget build(BuildContext context) {
    if (order.workerName == 'mosaedWorkerPending') {
      return Text(
        'mosaedWorkerAssigning'.tr(),
        style: getRegularStyle(
          fontSize: 14.sp,
          color: MosaedColors.textSecondary,
        ),
      );
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 28.r,
          backgroundColor: MosaedColors.shieldBg,
          child: Icon(Icons.engineering_rounded, color: MosaedColors.primary),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.workerName,
                style: getBoldStyle(
                  fontSize: 16.sp,
                  color: MosaedColors.textPrimary,
                ),
              ),
              if (order.workerPhone != null &&
                  order.workerPhone!.trim().isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  order.workerPhone!,
                  style: getRegularStyle(
                    fontSize: 13.sp,
                    color: MosaedColors.primary,
                  ),
                ),
              ],
              if (order.workerRating > 0 || order.workerJobsCount > 0) ...[
                SizedBox(height: 4.h),
                Text(
                  '${order.workerRating > 0 ? '${order.workerRating} ⭐' : ''}'
                  '${order.workerRating > 0 && order.workerJobsCount > 0 ? ' • ' : ''}'
                  '${order.workerJobsCount > 0 ? '${order.workerJobsCount} ${'mosaedCompletedJobs'.tr()}' : ''}',
                  style: getRegularStyle(
                    fontSize: 12.sp,
                    color: MosaedColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkPhoto extends StatelessWidget {
  const _WorkPhoto({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getMediumStyle(
            fontSize: 12.sp,
            color: MosaedColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.network(
            url,
            height: 120.h,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 120.h,
              color: MosaedColors.inputFill,
              alignment: Alignment.center,
              child: Icon(Icons.broken_image_outlined, color: MosaedColors.textHint),
            ),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: MosaedColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: MosaedColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: getBoldStyle(fontSize: 15.sp, color: MosaedColors.textPrimary),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: getRegularStyle(
                fontSize: 13.sp,
                color: MosaedColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: getMediumStyle(
              fontSize: 13.sp,
              color: valueColor ?? MosaedColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: MosaedColors.inputFill,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: getMediumStyle(fontSize: 12.sp, color: MosaedColors.textPrimary),
      ),
    );
  }
}
