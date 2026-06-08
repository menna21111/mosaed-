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
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await DioHelper.init();
  await CacheHelper().init();
  await initAppModule();

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
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ThemeCubit()..setLightTheme()),
            BlocProvider(
              create: (context) => AuthCubit(context.read<AuthRepository>()),
            ),
          ],
          child: MyApp(),
        ),
      ),
    ),
  );
}
