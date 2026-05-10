import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tezocare_mobile/firebase_options.dart';
import 'config/routes/app_router.dart';
import 'config/themes/app_theme.dart';
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
    return MaterialApp.router(
      title: 'TezoCare',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
