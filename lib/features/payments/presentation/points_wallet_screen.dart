import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/assets_manager.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../home/presentation/widgets/more_card_tile.dart';
import '../../services/presentation/widgets/address_chrome.dart';
import '../data/models/customer_points_wallet.dart';
import '../data/payments_repository.dart';
import 'points_history_screen.dart';
import 'points_rules_screen.dart';

class PointsWalletScreen extends StatefulWidget {
  const PointsWalletScreen({super.key});

  @override
  State<PointsWalletScreen> createState() => _PointsWalletScreenState();
}

class _PointsWalletScreenState extends State<PointsWalletScreen> {
  CustomerPointsWallet? _wallet;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final wallet = await context.read<PaymentsRepository>().getPointsWallet();
      if (!mounted) return;
      setState(() {
        _wallet = wallet;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _wallet = const CustomerPointsWallet(
          pointsBalance: 0,
          totalEarnedPoints: 0,
          totalRedeemedPoints: 0,
        );
        _loading = false;
      });
    }
  }

  String _formatPoints(num value) {
    return NumberFormat('#,###').format(value.round());
  }

  @override
  Widget build(BuildContext context) {
    final balance = _wallet?.pointsBalance ?? 0;

    return Scaffold(
      backgroundColor: MosaedColors.surfaceWhite,
      appBar: AddressAppBar(title: LocaleKeys.mosaedLoyaltyPoints.tr()),
      body: RefreshIndicator(
        color: MosaedColors.brand,
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          children: [
            if (_loading)
              Padding(
                padding: EdgeInsets.only(top: 80.h),
                child: const Center(
                  child: CircularProgressIndicator(color: MosaedColors.brand),
                ),
              )
            else ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20.w, 22.h, 16.w, 22.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: const LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Color(0xFFF7842C),
                      Color(0xFFF9B05A),
                      Color(0xFFFFD7A3),
                    ],
                    stops: [0.0, 0.42, 1.0],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.mosaedYourPointsBalance.tr(),
                            style: getMediumStyle(
                              fontSize: 13.sp,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '${_formatPoints(balance)} ${'mosaedPointsUnit'.tr()}',
                            style: getBoldStyle(
                              fontSize: 26.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Image.asset(
                      ImageAssets.pointsCoin,
                      width: 84.w,
                      height: 84.w,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                decoration: BoxDecoration(
                  color: MosaedColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: MosaedColors.fieldBorder),
                ),
                child: Column(
                  children: [
                    MoreCardTile(
                      title: LocaleKeys.mosaedPointsHistory.tr(),
                      leadingAsset: ImageAssets.timeQuarterPass,
                      circleIcon: true,
                      showBorder: false,
                      trailing: Icon(
                        Icons.chevron_left_rounded,
                        size: 20.sp,
                        color: MosaedColors.textHint,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PointsHistoryScreen(
                              transactions:
                                  _wallet?.recentTransactions ?? const [],
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Divider(
                        height: 1,
                        color: MosaedColors.fieldBorder,
                      ),
                    ),
                    MoreCardTile(
                      title: LocaleKeys.mosaedProgramRules.tr(),
                      leadingAsset: ImageAssets.gift,
                      circleIcon: true,
                      showBorder: false,
                      trailing: Icon(
                        Icons.chevron_left_rounded,
                        size: 20.sp,
                        color: MosaedColors.textHint,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PointsRulesScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
