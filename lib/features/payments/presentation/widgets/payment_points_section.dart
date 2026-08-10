import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/functions.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../auth/presentation/widgets/mosaed_buttons.dart';
import '../../data/models/customer_points_wallet.dart';
import '../../data/models/payment_request.dart';
import '../cubit/payment_cubit.dart';

/// Apply / remove loyalty points before choosing payment method.
/// Custom requests only — not used for existed-service bookings.
class PaymentPointsSection extends StatefulWidget {
  const PaymentPointsSection({
    super.key,
    required this.paymentRequestId,
    required this.baseAmount,
    this.initialPayment,
    required this.onPaymentUpdated,
  });

  final String paymentRequestId;
  final double baseAmount;
  final PaymentRequest? initialPayment;
  final ValueChanged<PaymentRequest?> onPaymentUpdated;

  @override
  State<PaymentPointsSection> createState() => _PaymentPointsSectionState();
}

class _PaymentPointsSectionState extends State<PaymentPointsSection> {
  CustomerPointsWallet? _wallet;
  PaymentRequest? _payment;
  bool _loadingWallet = true;
  final _pointsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _payment = widget.initialPayment;
    _loadWallet();
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _loadWallet() async {
    setState(() => _loadingWallet = true);
    final wallet = await context.read<PaymentCubit>().loadPointsWallet();
    if (!mounted) return;
    setState(() {
      _wallet = wallet;
      _loadingWallet = false;
      // Leave empty so the customer chooses how many points to use.
    });
  }

  Future<void> _apply() async {
    final raw = _pointsController.text.trim();
    final points = num.tryParse(raw);
    if (points == null || points <= 0) {
      AppFunctions.showsToast(
        'mosaedPointsInvalidAmount'.tr(),
        MosaedColors.danger,
        context,
      );
      return;
    }

    final updated = await context.read<PaymentCubit>().applyPoints(
          paymentRequestId: widget.paymentRequestId,
          points: points,
        );
    if (!mounted) return;
    if (updated == null) return;

    setState(() => _payment = updated);
    widget.onPaymentUpdated(updated);
    await _loadWallet();
    if (!mounted) return;
    AppFunctions.showsToast(
      'mosaedPointsApplied'.tr(),
      MosaedColors.success,
      context,
    );
  }

  Future<void> _remove() async {
    final updated = await context.read<PaymentCubit>().removePoints(
          widget.paymentRequestId,
        );
    if (!mounted) return;
    if (updated == null) return;

    setState(() => _payment = updated);
    widget.onPaymentUpdated(updated);
    await _loadWallet();
    if (!mounted) return;
    AppFunctions.showsToast(
      'mosaedPointsRemoved'.tr(),
      MosaedColors.success,
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = 'mosaedCurrency'.tr();
    final payable = _payment?.payableAmount ?? widget.baseAmount;
    final pointsApplied = _payment?.hasPointsApplied == true;

    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        final busy = state is PaymentPointsBusy;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          margin: EdgeInsets.only(bottom: 14.h),
          decoration: BoxDecoration(
            color: MosaedColors.shieldBg,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: MosaedColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.stars_rounded,
                    color: MosaedColors.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'mosaedLoyaltyPoints'.tr(),
                      style: getBoldStyle(
                        fontSize: 14.sp,
                        color: MosaedColors.textPrimary,
                      ),
                    ),
                  ),
                  if (_loadingWallet)
                    SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_wallet != null)
                    Text(
                      '${_wallet!.pointsBalance.toStringAsFixed(0)} ${'mosaedPointsUnit'.tr()}',
                      style: getBoldStyle(
                        fontSize: 13.sp,
                        color: MosaedColors.primary,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'mosaedPointsPayHint'.tr(),
                style: getRegularStyle(
                  fontSize: 12.sp,
                  color: MosaedColors.textSecondary,
                ),
              ),
              if (pointsApplied) ...[
                SizedBox(height: 10.h),
                Text(
                  '${'mosaedPointsUsed'.tr()}: ${(_payment?.pointsUsed ?? 0).toStringAsFixed(0)}'
                  '  •  ${'mosaedPointsDiscount'.tr()}: ${(_payment?.pointsDiscountAmount ?? 0).toStringAsFixed(0)} $currency',
                  style: getMediumStyle(
                    fontSize: 12.sp,
                    color: MosaedColors.success,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${'mosaedFinalAmount'.tr()}: ${payable.toStringAsFixed(0)} $currency',
                  style: getBoldStyle(
                    fontSize: 14.sp,
                    color: MosaedColors.primary,
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: OutlinedButton(
                    onPressed: busy ? null : _remove,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: MosaedColors.danger),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: busy
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'mosaedRemovePoints'.tr(),
                            style: getBoldStyle(
                              fontSize: 13.sp,
                              color: MosaedColors.danger,
                            ),
                          ),
                  ),
                ),
              ] else if (_wallet != null && _wallet!.hasPoints) ...[
                SizedBox(height: 10.h),
                TextField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'mosaedPointsToUse'.tr(),
                    hintText:
                        '${'mosaedPointsAvailable'.tr()}: ${_wallet!.pointsBalance.toStringAsFixed(0)}',
                    filled: true,
                    fillColor: MosaedColors.surfaceWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    suffixIcon: TextButton(
                      onPressed: busy
                          ? null
                          : () {
                              _pointsController.text =
                                  _wallet!.pointsBalance.toStringAsFixed(0);
                            },
                      child: Text(
                        'mosaedUseAllPoints'.tr(),
                        style: getMediumStyle(
                          fontSize: 11.sp,
                          color: MosaedColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                MosaedPrimaryButton(
                  text: 'mosaedApplyPoints'.tr(),
                  icon: Icons.check_rounded,
                  isLoading: busy,
                  onPressed: busy ? null : _apply,
                ),
              ] else if (!_loadingWallet) ...[
                SizedBox(height: 8.h),
                Text(
                  'mosaedNoPointsAvailable'.tr(),
                  style: getMediumStyle(
                    fontSize: 12.sp,
                    color: MosaedColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
