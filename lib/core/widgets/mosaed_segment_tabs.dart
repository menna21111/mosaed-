import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/mosaed_colors.dart';
import '../constants/styles_manager.dart';

/// Shared two-or-more tab bar: orange underline when active, grey when inactive.
class MosaedSegmentTabs extends StatelessWidget {
  const MosaedSegmentTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(labels.length, (index) {
            return Expanded(
              child: _SegmentTab(
                label: labels[index],
                selected: selectedIndex == index,
                onTap: () => onChanged(index),
              ),
            );
          }),
        ),
        Divider(height: 1, thickness: 1, color: MosaedColors.fieldBorder),
      ],
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: getBoldStyle(
                fontSize: 13.sp,
                color: selected
                    ? MosaedColors.brand
                    : MosaedColors.textSecondary,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 3.h,
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: selected ? MosaedColors.brand : Colors.transparent,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }
}
