import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/locale_keys.dart';

class ChatLoadOlderButton extends StatelessWidget {
  const ChatLoadOlderButton({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: loading ? null : onPressed,
      child: Text(loading ? '...' : LocaleKeys.mosaedLoadOlderMessages.tr()),
    );
  }
}
