import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

import '../../../app/functions.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/network/failure.dart';
import '../../auth/data/auth_repository.dart';
import '../../custom_service/data/custom_service_repository.dart';
import '../../custom_service/data/models/custom_service_models.dart';
import '../../custom_service/presentation/custom_request_detail_screen.dart';
import '../../custom_service/presentation/custom_service_screen.dart';
import '../../payments/data/payments_repository.dart';
import '../../payments/presentation/points_wallet_screen.dart';
import '../../services/data/models/address_models.dart';
import '../../services/data/models/existed_service.dart';
import '../../services/data/services_repository.dart';
import '../../services/presentation/addresses_list_screen.dart';
import '../../services/presentation/service_detail_screen.dart';
import '../../services/presentation/widgets/address_place_type.dart';
import 'widgets/home_header.dart';
import 'widgets/home_problem_card.dart';
import 'widgets/home_sections.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<ExistedService> _services = [];
  List<CustomRequest> _recentRequests = [];
  CustomerAddress? _defaultAddress;
  String _pointsBalance = '0';
  String? _avatarUrl;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final servicesRepo = context.read<ServicesRepository>();
      final customRepo = context.read<CustomServiceRepository>();

      final results = await Future.wait([
        servicesRepo.getExistedServices(),
        servicesRepo.getAddresses(),
        customRepo.getCustomRequests(),
      ]);

      final services = results[0] as List<ExistedService>;
      final addresses = results[1] as List<CustomerAddress>;
      final requests = results[2] as List<CustomRequest>;

      String points = '0';
      String? avatarUrl;
      try {
        if (!mounted) return;
        final wallet =
            await context.read<PaymentsRepository>().getPointsWallet();
        points = wallet.pointsBalance.toStringAsFixed(0);
      } catch (_) {}

      try {
        if (!mounted) return;
        final profile =
            await context.read<AuthRepository>().getCustomerProfile();
        avatarUrl = profile.avatar;
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _services = services;
        _defaultAddress = addresses.isEmpty
            ? null
            : addresses.firstWhere(
                (a) => a.isDefault,
                orElse: () => addresses.first,
              );
        _recentRequests = requests.take(8).toList();
        _pointsBalance = points;
        _avatarUrl = avatarUrl;
        _loading = false;
      });
    } on ServerFailure catch (e) {
      if (mounted) {
        setState(() {
          _error = e.errMessage;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _locationText {
    final a = _defaultAddress;
    if (a == null) return LocaleKeys.mosaedSelectLocationShort.tr();
    final city = a.cityName.trim();
    final district = a.district.trim();
    if (city.isNotEmpty && district.isNotEmpty) return '$city، $district';
    if (city.isNotEmpty) return city;
    return a.fullAddress;
  }

  String get _quickAddressLabel {
    final a = _defaultAddress;
    if (a == null) return LocaleKeys.mosaedLabelHome.tr();
    final raw = a.label?.trim() ?? '';
    if (raw.isEmpty) return LocaleKeys.mosaedLabelHome.tr();
    final type = addressPlaceTypeFromLabel(raw);
    if (type == AddressPlaceType.other) {
      final v = raw.toLowerCase();
      if (v != 'other' && v != 'أخرى' && v != 'اخرى') return raw;
    }
    return type.label;
  }

  void _openCustomService() {
    AppFunctions.navigateTo(
      context,
      const CustomServiceScreen(),
      PageTransitionType.rightToLeft,
    );
  }

  void _openService(ExistedService service) {
    AppFunctions.navigateTo(
      context,
      ServiceDetailScreen(serviceId: service.id),
      PageTransitionType.rightToLeft,
    );
  }

  void _openRequest(CustomRequest request) {
    AppFunctions.navigateTo(
      context,
      CustomRequestDetailScreen(requestId: request.id),
      PageTransitionType.rightToLeft,
    );
  }

  void _openAddresses() {
    AppFunctions.navigateTo(
      context,
      const AddressesListScreen(),
      PageTransitionType.rightToLeft,
    );
  }

  void _openPoints() {
    AppFunctions.navigateTo(
      context,
      const PointsWalletScreen(),
      PageTransitionType.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.read<AuthRepository>().userName;

    return ColoredBox(
      color: MosaedColors.background,
      child: SafeArea(
        child: RefreshIndicator(
          color: MosaedColors.brand,
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: HomeHeader(
                  userName: userName,
                  avatarUrl: _avatarUrl,
                  locationText: _locationText,
                  onLocationTap: _openAddresses,
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 16.h)),
              SliverToBoxAdapter(
                child: HomeProblemCard(onStart: _openCustomService),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 22.h)),
              SliverToBoxAdapter(
                child: HomeServicesSection(
                  loading: _loading,
                  services: _services,
                  error: _error,
                  onTap: _openService,
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 22.h)),
              SliverToBoxAdapter(
                child: HomeRecentRequestsStrip(
                  loading: _loading,
                  requests: _recentRequests,
                  onTap: _openRequest,
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 22.h)),
              SliverToBoxAdapter(
                child: HomeQuickAccessSection(
                  pointsBalance: _pointsBalance,
                  addressLabel: _quickAddressLabel,
                  onAddressesTap: _openAddresses,
                  onPointsTap: _openPoints,
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 28.h)),
            ],
          ),
        ),
      ),
    );
  }
}
