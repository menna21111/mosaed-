import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';

/// Opens the React Moyasar checkout page and watches navigation for callback.
///
/// URL: `{FRONTEND}/payments/{payment_request_id}?token={access_token}`
class PaymentCheckoutWebView extends StatefulWidget {
  const PaymentCheckoutWebView({
    super.key,
    required this.checkoutUrl,
    required this.paymentRequestId,
  });

  final String checkoutUrl;
  final String paymentRequestId;

  @override
  State<PaymentCheckoutWebView> createState() => _PaymentCheckoutWebViewState();
}

class _PaymentCheckoutWebViewState extends State<PaymentCheckoutWebView> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (request) {
            _maybeHandleCallback(request.url);
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            final url = change.url;
            if (url != null) _maybeHandleCallback(url);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _maybeHandleCallback(String url) {
    if (_closing) return;
    final lower = url.toLowerCase();
    final id = widget.paymentRequestId.toLowerCase();

    final isCallback = lower.contains('/callback') ||
        lower.contains('status=paid') ||
        lower.contains('payment=success') ||
        lower.contains('/success') ||
        (lower.contains(id) &&
            (lower.contains('paid=true') || lower.contains('status=failed')));

    if (!isCallback) return;

    final failed = lower.contains('failed') || lower.contains('status=failed');
    _closing = true;
    if (!mounted) return;
    Navigator.of(context).pop(failed ? false : true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MosaedColors.background,
      appBar: AppBar(
        backgroundColor: MosaedColors.surface,
        elevation: 0,
        title: Text(
          'mosaedOpenPaymentPage'.tr(),
          style: getBoldStyle(fontSize: 16.sp, color: MosaedColors.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: MosaedColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(null),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(
                color: MosaedColors.primaryContainer,
              ),
            ),
        ],
      ),
    );
  }
}
