import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'app/bloc_observer.dart';
import 'app/di.dart';

import 'app/theme_cubit.dart/theme_cubit.dart';
import 'core/caching/cach_helper.dart';
import 'core/network/dio_helper.dart';
import 'core/services/notification/push_notification_service.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/chat/data/chat_repository.dart';
import 'features/custom_service/data/custom_service_repository.dart';
import 'features/notifications/data/notifications_repository.dart';
import 'features/notifications/presentation/cubit/notification_cubit.dart';
import 'features/payments/data/payments_repository.dart';
import 'features/payments/presentation/cubit/payment_cubit.dart';
import 'features/services/data/services_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await DioHelper.init();
  await CacheHelper().init();
  await initAppModule();

  // Same pattern as reefsaudi: Firebase before runApp, messaging after.
  await PushNotificationService.initializeFirebase();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('ar'),
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (_) => AuthRepository()),
          RepositoryProvider(create: (_) => ServicesRepository()),
          RepositoryProvider(create: (_) => CustomServiceRepository()),
          RepositoryProvider(create: (_) => ChatRepository()),
          RepositoryProvider(create: (_) => PaymentsRepository()),
          RepositoryProvider(create: (_) => NotificationsRepository()),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ThemeCubit()..setLightTheme()),
            BlocProvider(
              create: (context) => AuthCubit(context.read<AuthRepository>()),
            ),
            BlocProvider(
              create: (context) =>
                  PaymentCubit(context.read<PaymentsRepository>()),
            ),
            BlocProvider(
              create: (context) {
                final repository = context.read<NotificationsRepository>();
                final cubit = NotificationCubit(repository);
                PushNotificationService.bindNotificationsRepository(repository);
                PushNotificationService.onForegroundPushData =
                    cubit.handlePushPayload;
                return cubit;
              },
            ),
          ],
          child: MyApp(),
        ),
      ),
    ),
  );

  unawaited(PushNotificationService.initializeMessaging());
}
