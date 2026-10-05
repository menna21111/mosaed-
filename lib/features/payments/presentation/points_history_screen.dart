import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/assets_manager.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../services/presentation/widgets/address_chrome.dart';
import '../data/models/customer_points_wallet.dart';

class PointsHistoryScreen extends StatefulWidget {
  const PointsHistoryScreen({super.key, required this.transactions});

  final List<PointsTransaction> transactions;

  @override
  State<PointsHistoryScreen> createState() => _PointsHistoryScreenState();
}

enum _PointsFilter { all, earned, used }

class _PointsHistoryScreenState extends State<PointsHistoryScreen> {
  _PointsFilter _filter = _PointsFilter.all;

  List<PointsTransaction> get _filtered {
    switch (_filter) {
      case _PointsFilter.earned:
        return widget.transactions.where((t) => t.isEarn).toList();
      case _PointsFilter.used:
        return widget.transactions.where((t) => !t.isEarn).toList();
      case _PointsFilter.all:
        return widget.transactions;
    }
  }

  DateTime? _parse(String? raw) => DateTime.tryParse(raw ?? '')?.toLocal();

  String _sectionLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return LocaleKeys.mosaedToday.tr();
    if (diff == 1) return LocaleKeys.mosaedYesterday.tr();
    return DateFormat('d MMMM yyyy', context.locale.toString()).format(date);
  }

  String _itemDate(PointsTransaction tx) {
    final dt = _parse(tx.createdAt);
    if (dt == null) return tx.createdAt ?? '';
    return DateFormat('d MMMM yyyy', context.locale.toString()).format(dt);
  }

  List<(String, List<PointsTransaction>)> _grouped() {
    final items = [..._filtered]..sort((a, b) {
        final da = _parse(a.createdAt) ?? DateTime(1970);
        final db = _parse(b.createdAt) ?? DateTime(1970);
        return db.compareTo(da);
      });

    final map = <String, List<PointsTransaction>>{};
    for (final tx in items) {
      final dt = _parse(tx.createdAt) ?? DateTime.now();
      final key = _sectionLabel(dt);
      map.putIfAbsent(key, () => []).add(tx);
    }
    return map.entries.map((e) => (e.key, e.value)).toList();
  }

  String _pointsLabel(PointsTransaction tx) {
    final amount = NumberFormat('#,###').format(tx.points.abs().round());
    final sign = tx.isEarn ? '+' : '-';
    return '$sign$amount ${'mosaedPointsUnit'.tr()}';
  }

  @override
  Widget build(BuildContext context) {
    final groups = _grouped();

    return Scaffold(
      backgroundColor: MosaedColors.surfaceWhite,
      appBar: AddressAppBar(title: LocaleKeys.mosaedPointsHistory.tr()),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
            child: Row(
              children: [
                _FilterChip(
                  label: LocaleKeys.mosaedPointsAll.tr(),
                  selected: _filter == _PointsFilter.all,
                  onTap: () => setState(() => _filter = _PointsFilter.all),
                ),
                SizedBox(width: 8.w),
                _FilterChip(
                  label: LocaleKeys.mosaedPointsEarnedFilter.tr(),
                  selected: _filter == _PointsFilter.earned,
                  onTap: () => setState(() => _filter = _PointsFilter.earned),
                ),
                SizedBox(width: 8.w),
                _FilterChip(
                  label: LocaleKeys.mosaedPointsUsedFilter.tr(),
                  selected: _filter == _PointsFilter.used,
                  onTap: () => setState(() => _filter = _PointsFilter.used),
                ),
              ],
            ),
          ),
          Expanded(
            child: groups.isEmpty
                ? Center(
                    child: Text(
                      'mosaedNoTransactionsYet'.tr(),
                      style: getRegularStyle(
                        fontSize: 13.sp,
                        color: MosaedColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SectionHeader(
                              label: group.$1,
                              trailing: index == 0
                                  ? LocaleKeys.mosaedLast7Days.tr()
                                  : null,
                            ),
                            SizedBox(height: 10.h),
                            ...group.$2.map(
                              (tx) => Padding(
                                padding: EdgeInsets.only(bottom: 14.h),
                                child: _HistoryRow(
                                  transaction: tx,
                                  dateLabel: _itemDate(tx),
                                  pointsLabel: _pointsLabel(tx),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.trailing});

  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: MosaedColors.fieldBorder)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            label,
            style: getRegularStyle(
              fontSize: 12.sp,
              color: MosaedColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: trailing == null
              ? Divider(color: MosaedColors.fieldBorder)
              : Row(
                  children: [
                    Expanded(child: Divider(color: MosaedColors.fieldBorder)),
                    SizedBox(width: 8.w),
                    Text(
                      trailing!,
                      style: getRegularStyle(
                        fontSize: 11.sp,
                        color: MosaedColors.textHint,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.transaction,
    required this.dateLabel,
    required this.pointsLabel,
  });

  final PointsTransaction transaction;
  final String dateLabel;
  final String pointsLabel;

  @override
  Widget build(BuildContext context) {
    final earn = transaction.isEarn;
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: earn ? MosaedColors.otpFill : const Color(0xFFE8F8F0),
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            earn ? ImageAssets.gift : ImageAssets.moneyRemove02,
            width: 20.w,
            height: 20.w,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.description?.trim().isNotEmpty == true
                    ? transaction.description!
                    : LocaleKeys.mosaedLoyaltyPoints.tr(),
                style: getMediumStyle(
                  fontSize: 13.sp,
                  color: MosaedColors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                dateLabel,
                style: getRegularStyle(
                  fontSize: 11.sp,
                  color: MosaedColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          pointsLabel,
          style: getBoldStyle(
            fontSize: 13.sp,
            color: const Color(0xFF0C8F58),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MosaedColors.surfaceWhite,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: selected ? MosaedColors.brand : const Color(0xFFD8D8D8),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Text(
            label,
            style: getMediumStyle(
              fontSize: 13.sp,
              color: selected ? MosaedColors.brand : MosaedColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
