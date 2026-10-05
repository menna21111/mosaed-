import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/mosaed_colors.dart';
import '../../../data/completion_form_model.dart';
import '../../models/active_order_view_data.dart';
import '../order_progress_stepper.dart';
import 'active_order_payment_actions.dart';
import 'active_order_shared.dart';

class ActiveOrderBody extends StatefulWidget {
  const ActiveOrderBody({
    super.key,
    required this.data,
    required this.onRefresh,
    required this.paymentSection,
    this.paymentSectionKey,
    this.extraSections = const [],
  });

  final ActiveOrderViewData data;
  final Future<void> Function() onRefresh;
  final Widget paymentSection;
  final GlobalKey? paymentSectionKey;
  final List<Widget> extraSections;

  @override
  State<ActiveOrderBody> createState() => _ActiveOrderBodyState();
}

class _ActiveOrderBodyState extends State<ActiveOrderBody> {
  bool _detailsExpanded = false;

  ActiveOrderProgress get _progress => widget.data.progress;

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    final canCollapse =
        progress.showWorkPhotos && !widget.data.isCatalogBooking;
    final collapsed = canCollapse && !_detailsExpanded;
    final completion = widget.data.completion;
    final statusBanner = _progress.statusBannerKey;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: MosaedColors.brand,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [
          ActiveOrderSummaryHeader(data: widget.data),
          if (progress.showStepper) ...[
            SizedBox(height: 12.h),
            OrderProgressStepper(progress: progress),
          ],
          if (statusBanner != null &&
              !(widget.data.isCatalogBooking && progress.isAwaitingProvider)) ...[
            SizedBox(height: 12.h),
            ActiveOrderStatusBanner(messageKey: statusBanner),
          ],
          if (progress.showWorkPhotos && completion != null) ...[
            SizedBox(height: 16.h),
            ActiveOrderWorkPhotosSection(completion: completion),
          ],
          SizedBox(height: 16.h),
          ActiveOrderDetailsSection(
            data: widget.data,
            collapsed: collapsed,
            onToggle: canCollapse
                ? () => setState(() => _detailsExpanded = !_detailsExpanded)
                : null,
          ),
          SizedBox(height: 12.h),
          if (widget.data.isCatalogBooking) ...[
            ActiveOrderTechnicianSection(data: widget.data),
            SizedBox(height: 12.h),
            ActiveOrderCostSection(data: widget.data),
          ] else
            ActiveOrderCollaborationSection(data: widget.data),
          if (_shouldShowInlinePayment(completion)) ...[
            SizedBox(height: 16.h),
            KeyedSubtree(
              key: widget.paymentSectionKey,
              child: widget.paymentSection,
            ),
          ],
          ...widget.extraSections,
        ],
      ),
    );
  }

  bool _shouldShowInlinePayment(CompletionForm? completion) {
    if (completion == null || !completion.hasFinished) return false;
    if (completion.isPaymentPaid) return true;
    if (completion.isAwaitingCashPayment) return false;
    if (completion.needsPaymentMethodChoice) return false;
    return completion.isAwaitingGatewayPayment ||
        completion.isAwaitingPaymentCreation;
  }
}
