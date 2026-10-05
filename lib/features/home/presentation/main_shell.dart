import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/assets_manager.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../notifications/presentation/cubit/notification_cubit.dart';
import '../../profile/presentation/profile_tab.dart';
import 'chats_tab.dart';
import 'home_tab.dart';
import 'orders_tab.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;
  final _ordersKey = GlobalKey<OrdersTabState>();

  late final List<Widget> _pages = [
    const HomeTab(),
    OrdersTab(key: _ordersKey),
    const ChatsTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<NotificationCubit>();
      cubit.onOrdersChanged = () => _ordersKey.currentState?.reload();
      cubit.startRealtime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MosaedColors.background,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: MosaedColors.surfaceWhite,
          border: Border(
            top: BorderSide(color: MosaedColors.fieldBorder, width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(top: 6, bottom: 2),
            child: Row(
              children: [
                _NavItem(
                  asset: ImageAssets.elements1,
                  label: 'home'.tr(),
                  selected: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                _NavItem(
                  asset: ImageAssets.taskIcon,
                  label: LocaleKeys.mosaedMyOrders.tr(),
                  selected: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
                _NavItem(
                  asset: ImageAssets.icon1,
                  label: LocaleKeys.mosaedMyChats.tr(),
                  selected: _index == 2,
                  onTap: () => setState(() => _index = 2),
                ),
                _NavItem(
                  asset: ImageAssets.icon2,
                  label: LocaleKeys.mosaedMore.tr(),
                  selected: _index == 3,
                  onTap: () => setState(() => _index = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.asset,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String asset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? MosaedColors.brand : MosaedColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              asset,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
               selected ? MosaedColors.brand : color,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getMediumStyle(fontSize: 10.sp, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
