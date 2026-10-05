import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import 'chat_header_avatar.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({
    super.key,
    required this.title,
    this.peerImage,
  });

  final String title;
  final String? peerImage;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MosaedColors.surfaceWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios,
          color: MosaedColors.textPrimary,
          size: 18.sp,
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ChatHeaderAvatar(url: peerImage, name: title),
          SizedBox(width: 10.w),
          Flexible(
            child: Text(
              title,
              style: getBoldStyle(
                fontSize: 15.sp,
                color: MosaedColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      centerTitle: false,
    );
  }
}
