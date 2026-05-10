import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tezocare_mobile/firebase_options.dart';
import 'config/routes/app_router.dart';
import 'config/themes/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/refresh_token_usecase.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('Firebase initialized successfully, DI is next');

  await di.init();
  runApp(const TezoCareApp());
}

class TezoCareApp extends StatelessWidget {
  const TezoCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = di.sl<AppRouter>();
    debugPrint('AppRouter initialized: $appRouter');
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            loginUseCase: di.sl<LoginUseCase>(),
            logoutUseCase: di.sl<LogoutUseCase>(),
            getCurrentUserUseCase: di.sl<GetCurrentUserUseCase>(),
            refreshTokenUseCase: di.sl<RefreshTokenUseCase>(),
          ),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, _) => MaterialApp.router(
          title: 'TezoCare',
          theme: AppTheme.lightTheme,
          routerConfig: appRouter.router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
