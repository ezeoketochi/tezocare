import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../injection_container.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final storage = sl<FlutterSecureStorage>();
      final token = await storage.read(key: ApiConstants.accessTokenKey);

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        context.go(RouteNames.dashboard);
      } else {
        context.go(RouteNames.login);
      }
    } catch (e) {
      if (!mounted) return;
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_pharmacy, size: 80, color: Colors.teal),
            SizedBox(height: 16),
            Text(
              'TezoCare',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Pharmacy Management',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
