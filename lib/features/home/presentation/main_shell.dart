import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import 'home_tab.dart';
import 'orders_tab.dart';
import 'profile_tab.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [HomeTab(), OrdersTab(), ProfileTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MosaedColors.background,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: MosaedColors.surface,
          border: Border(top: BorderSide(color: MosaedColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (value) => setState(() => _index = value),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: MosaedColors.primary,
          unselectedItemColor: MosaedColors.textSecondary,
          selectedLabelStyle:
              getMediumStyle(fontSize: 11.sp, color: MosaedColors.primary),
          unselectedLabelStyle: getMediumStyle(
            fontSize: 11.sp,
            color: MosaedColors.textSecondary,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_rounded),
              label: 'home'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_outlined),
              activeIcon: const Icon(Icons.receipt_long_rounded),
              label: 'mosaedOrders'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_rounded),
              activeIcon: const Icon(Icons.person_rounded),
              label: 'profile'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
