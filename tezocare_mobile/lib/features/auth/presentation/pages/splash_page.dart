import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_pharmacy_rounded,
                      size: 48.sp,
                      color: AppColors.primary,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                  SizedBox(height: 24.h),
                  Text('TezoCare', style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.textPrimary,
                  ))
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .slideY(begin: 0.2, end: 0),
                  SizedBox(height: 8.h),
                  Text(
                    'Pharmacy Management',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textDark,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideY(begin: 0.2, end: 0),
                  SizedBox(height: 60.h),
                  SizedBox(
                    width: 32.w,
                    height: 32.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
