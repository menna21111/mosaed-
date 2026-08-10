import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../data/models/customer_points_wallet.dart';
import '../data/payments_repository.dart';

/// محفظة نقاط العميل — تفتح من البروفايل.
class PointsWalletScreen extends StatefulWidget {
  const PointsWalletScreen({super.key});

  @override
  State<PointsWalletScreen> createState() => _PointsWalletScreenState();
}

class _PointsWalletScreenState extends State<PointsWalletScreen> {
  CustomerPointsWallet? _wallet;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final wallet =
          await context.read<PaymentsRepository>().getPointsWallet();
      if (!mounted) return;
      setState(() {
        _wallet = wallet;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _wallet = null;
        _loading = false;
        _error = 'mosaedPointsLoadFailed'.tr();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MosaedColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'mosaedLoyaltyPoints'.tr(),
          style: getBoldStyle(fontSize: 18.sp, color: MosaedColors.textPrimary),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: MosaedColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20.w),
          children: [
            if (_loading)
              Padding(
                padding: EdgeInsets.only(top: 80.h),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: MosaedColors.primaryContainer,
                  ),
                ),
              )
            else if (_error != null)
              Padding(
                padding: EdgeInsets.only(top: 60.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      size: 48.sp,
                      color: MosaedColors.textHint,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: getMediumStyle(
                        fontSize: 14.sp,
                        color: MosaedColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextButton(
                      onPressed: _load,
                      child: Text('retry'.tr()),
                    ),
                  ],
                ),
              )
            else if (_wallet != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MosaedColors.primary.withValues(alpha: 0.14),
                      MosaedColors.surface,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: MosaedColors.border),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: MosaedColors.primary,
                      size: 40.sp,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      _wallet!.pointsBalance.toStringAsFixed(0),
                      style: getBoldStyle(
                        fontSize: 40.sp,
                        color: MosaedColors.primary,
                      ),
                    ),
                    Text(
                      'mosaedPointsBalance'.tr(),
                      style: getMediumStyle(
                        fontSize: 14.sp,
                        color: MosaedColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'mosaedPointsEarned'.tr(),
                      value: _wallet!.totalEarnedPoints.toStringAsFixed(0),
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _StatCard(
                      label: 'mosaedPointsRedeemed'.tr(),
                      value: _wallet!.totalRedeemedPoints.toStringAsFixed(0),
                      icon: Icons.trending_down_rounded,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                'mosaedPointsWalletHint'.tr(),
                textAlign: TextAlign.center,
                style: getRegularStyle(
                  fontSize: 13.sp,
                  color: MosaedColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'mosaedRecentTransactions'.tr(),
                  style: getBoldStyle(
                    fontSize: 15.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              if (_wallet!.recentTransactions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: MosaedColors.surface,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: MosaedColors.border),
                  ),
                  child: Text(
                    'mosaedNoTransactionsYet'.tr(),
                    textAlign: TextAlign.center,
                    style: getMediumStyle(
                      fontSize: 13.sp,
                      color: MosaedColors.textSecondary,
                    ),
                  ),
                )
              else
                ..._wallet!.recentTransactions.map(
                  (tx) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: MosaedColors.surface,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: MosaedColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (tx.points >= 0)
                                ? Icons.add_circle_outline_rounded
                                : Icons.remove_circle_outline_rounded,
                            color: tx.points >= 0
                                ? MosaedColors.success
                                : MosaedColors.danger,
                            size: 22.sp,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.description?.trim().isNotEmpty == true
                                      ? tx.description!
                                      : (tx.type ?? 'mosaedLoyaltyPoints'.tr()),
                                  style: getMediumStyle(
                                    fontSize: 13.sp,
                                    color: MosaedColors.textPrimary,
                                  ),
                                ),
                                if (tx.createdAt != null) ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    tx.createdAt!,
                                    style: getRegularStyle(
                                      fontSize: 11.sp,
                                      color: MosaedColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            '${tx.points >= 0 ? '+' : ''}${tx.points.toStringAsFixed(0)}',
                            style: getBoldStyle(
                              fontSize: 14.sp,
                              color: tx.points >= 0
                                  ? MosaedColors.success
                                  : MosaedColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: MosaedColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: MosaedColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: MosaedColors.primary, size: 22.sp),
          SizedBox(height: 10.h),
          Text(
            value,
            style: getBoldStyle(
              fontSize: 20.sp,
              color: MosaedColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: getRegularStyle(
              fontSize: 12.sp,
              color: MosaedColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
