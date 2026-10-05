import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_constants.dart';
import '../constants/mosaed_colors.dart';
import '../../features/services/data/models/existed_service.dart';

class ServiceThumbnail extends StatelessWidget {
  const ServiceThumbnail({
    super.key,
    required this.service,
    this.size,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final ExistedService service;
  final double? size;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  String? get _url {
    final raw = service.image?.trim();
    if (raw == null || raw.isEmpty || raw.toLowerCase() == 'null') return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.startsWith('//')) return 'https:$raw';
    final base = AppConstants.baseUrl;
    return raw.startsWith('/') ? '$base$raw' : '$base/$raw';
  }

  /// Figma/Cloudinary "svg" files are PNG wrappers. Ask Cloudinary for PNG.
  String? get _rasterUrl {
    final url = _url;
    if (url == null) return null;
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    if (!path.endsWith('.svg')) return url;
    if (url.contains('res.cloudinary.com')) {
      return url.replaceFirst(RegExp(r'\.svg$', caseSensitive: false), '.png');
    }
    if (url.contains('/upload/')) {
      return url.replaceFirst('/upload/', '/upload/f_png/');
    }
    return url;
  }

  bool _isSvg(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return path.endsWith('.svg');
  }

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? 44.w;
    final radius = borderRadius ?? BorderRadius.circular(12.r);
    final raster = _rasterUrl;
    final raw = _url;

    if (raster != null && !_isSvg(raster)) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.network(
          raster,
          width: dimension,
          height: dimension,
          fit: fit,
          errorBuilder: (_, __, ___) {
            if (raw != null && _isSvg(raw)) {
              return _svg(raw, dimension, radius);
            }
            return _iconBox(dimension, radius);
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _loadingBox(dimension, radius);
          },
        ),
      );
    }

    if (raw != null && _isSvg(raw)) {
      return _svg(raw, dimension, radius);
    }

    return _iconBox(dimension, radius);
  }

  Widget _svg(String url, double dimension, BorderRadius radius) {
    return ClipRRect(
      borderRadius: radius,
      child: SvgPicture.network(
        url,
        width: dimension,
        height: dimension,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => _loadingBox(dimension, radius),
      ),
    );
  }

  Widget _iconBox(double dimension, BorderRadius radius) {
    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        color: service.accentColor.withValues(alpha: 0.12),
        borderRadius: radius,
      ),
      child: Icon(
        service.icon,
        color: service.accentColor,
        size: dimension * 0.55,
      ),
    );
  }

  Widget _loadingBox(double dimension, BorderRadius radius) {
    return Container(
      width: dimension,
      height: dimension,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MosaedColors.inputFill,
        borderRadius: radius,
      ),
      child: SizedBox(
        width: dimension * 0.35,
        height: dimension * 0.35,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
