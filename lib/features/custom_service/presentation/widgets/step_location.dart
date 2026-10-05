import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/assets_manager.dart';
import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/mosaed_map_style.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../services/data/models/address_models.dart';
import '../../../services/presentation/widgets/address_place_type.dart';
import 'custom_request_chrome.dart';

class StepLocation extends StatelessWidget {
  const StepLocation({
    super.key,
    required this.address,
    required this.onChangeLocation,
  });

  final CustomerAddress? address;
  final VoidCallback onChangeLocation;

  LatLng get _latLng {
    final lat = double.tryParse(address?.lat ?? '') ?? 24.713552;
    final lng = double.tryParse(address?.lng ?? '') ?? 46.675297;
    return LatLng(lat, lng);
  }

  String get _label {
    if (address == null) return LocaleKeys.mosaedSelectAddress.tr();
    final city = address!.cityName.trim();
    final district = address!.district.trim();
    if (city.isNotEmpty && district.isNotEmpty) return '$city، $district';
    return address!.fullAddress;
  }

  String get _placeLabel {
    final raw = address?.label?.trim() ?? '';
    if (raw.isEmpty) return LocaleKeys.mosaedLabelHome.tr();
    final type = addressPlaceTypeFromLabel(raw);
    if (type == AddressPlaceType.other) {
      final v = raw.toLowerCase();
      if (v != 'other' && v != 'أخرى' && v != 'اخرى') return raw;
    }
    return type.label;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      children: [
        CustomRequestStepHeader(
          title: LocaleKeys.mosaedWhereNeedService.tr(),
          subtitle: LocaleKeys.mosaedLocationStepSubtitle.tr(),
        ),
        SizedBox(height: 22.h),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            LocaleKeys.mosaedYourLocation.tr(),
            style: getBoldStyle(
              fontSize: 14.sp,
              color: MosaedColors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            SvgPicture.asset(
              ImageAssets.locationFill,
              width: 16.w,
              height: 16.w,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                _label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getMediumStyle(
                  fontSize: 13.sp,
                  color: MosaedColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: SizedBox(
            height: 210.h,
            width: double.infinity,
            child: address == null
                ? Container(
                    color: MosaedColors.surfaceContainerLow,
                    child: Icon(
                      Icons.map_outlined,
                      size: 48.sp,
                      color: MosaedColors.textHint,
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      GoogleMap(
                        key: ValueKey(
                            '${_latLng.latitude}-${_latLng.longitude}'),
                        style: mosaedMapStyle,
                        initialCameraPosition: CameraPosition(
                          target: _latLng,
                          zoom: 15,
                        ),
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: false,
                        compassEnabled: false,
                        scrollGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              color: MosaedColors.brand,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: MosaedColors.brand
                                      .withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: 26.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: MosaedColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(8.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              _placeLabel,
                              style: getMediumStyle(
                                fontSize: 12.sp,
                                color: MosaedColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
        SizedBox(height: 14.h),
        GestureDetector(
          onTap: onChangeLocation,
          child: CustomPaint(
            painter: _DashedPainter(
              color: MosaedColors.brand,
              radius: 12.r,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: MosaedColors.brandTransparent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    ImageAssets.locationFill,
                    width: 16.w,
                    height: 16.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    LocaleKeys.mosaedChangeAddress.tr(),
                    style: getBoldStyle(
                      fontSize: 13.sp,
                      color: MosaedColors.brand,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedPainter extends CustomPainter {
  _DashedPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

Future<CustomerAddress?> showAddressPickerSheet({
  required BuildContext context,
  required List<CustomerAddress> addresses,
  required String? selectedId,
  required VoidCallback onAddAddress,
}) {
  return showModalBottomSheet<CustomerAddress>(
    context: context,
    backgroundColor: MosaedColors.surfaceWhite,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: MosaedColors.fieldBorder,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                LocaleKeys.mosaedSelectAddress.tr(),
                style: getBoldStyle(
                  fontSize: 16.sp,
                  color: MosaedColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              if (addresses.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Column(
                    children: [
                      Image.asset(
                        ImageAssets.chooseAddress,
                        width: 180.w,
                        height: 140.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        LocaleKeys.mosaedNoAddressYet.tr(),
                        textAlign: TextAlign.center,
                        style: getRegularStyle(
                          fontSize: 13.sp,
                          color: MosaedColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 320.h),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: MosaedColors.fieldBorder,
                    ),
                    itemBuilder: (context, index) {
                      final a = addresses[index];
                      final selected = a.id == selectedId;
                      return ListTile(
                        leading: SvgPicture.asset(
                          ImageAssets.locationProfile,
                          width: 20.w,
                          height: 20.w,
                          colorFilter: ColorFilter.mode(
                            selected
                                ? MosaedColors.brand
                                : MosaedColors.textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                        title: Text(
                          a.label?.isNotEmpty == true
                              ? a.label!
                              : a.cityName,
                          style: getBoldStyle(
                            fontSize: 13.sp,
                            color: MosaedColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          a.fullAddress,
                          style: getRegularStyle(
                            fontSize: 11.sp,
                            color: MosaedColors.textSecondary,
                          ),
                        ),
                        trailing: selected
                            ? Icon(Icons.check_circle,
                                color: MosaedColors.brand)
                            : null,
                        onTap: () => Navigator.pop(context, a),
                      );
                    },
                  ),
                ),
              SizedBox(height: 8.h),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onAddAddress();
                },
                icon: Icon(Icons.add_rounded, color: MosaedColors.brand),
                label: Text(
                  LocaleKeys.mosaedAddNewAddress.tr(),
                  style: getBoldStyle(
                    fontSize: 13.sp,
                    color: MosaedColors.brand,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
