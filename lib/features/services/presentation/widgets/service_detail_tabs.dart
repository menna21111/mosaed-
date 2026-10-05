import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/locale_keys.dart';
import '../../../../core/widgets/mosaed_pill_tabs.dart';

class ServiceDetailTabs extends StatelessWidget {
  const ServiceDetailTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return MosaedPillTabs(
      labels: [
        LocaleKeys.mosaedServiceDetails.tr(),
        LocaleKeys.mosaedWorkGallery.tr(),
      ],
      selectedIndex: selectedIndex,
      onChanged: onChanged,
    );
  }
}
