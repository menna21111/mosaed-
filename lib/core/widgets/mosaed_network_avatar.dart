import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/mosaed_colors.dart';

class MosaedNetworkAvatar extends StatelessWidget {
  const MosaedNetworkAvatar({
    super.key,
    required this.url,
    this.size = 40,
    this.fallbackIcon = Icons.person_rounded,
  });

  final String? url;
  final double size;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final dim = size.w;
    final hasPhoto = url != null && url!.trim().isNotEmpty;
    final icon = Icon(
      fallbackIcon,
      color: MosaedColors.brand,
      size: (size * 0.5).sp,
    );

    return ClipOval(
      child: Container(
        width: dim,
        height: dim,
        color: MosaedColors.brandTransparent,
        child: hasPhoto
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => icon,
              )
            : icon,
      ),
    );
  }
}
