import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/services/app_toast.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            AppToast.success(context, title: 'Login successful');
            context.go(RouteNames.dashboard);
          } else if (state is AuthError) {
            AppToast.error(context, title: state.message);
          } else if (state is AuthValidationError) {
            final firstError = state.errors.values.first;
            AppToast.error(context, title: firstError);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 280.h,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppColors.splashGradient,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -60.h,
                        right: -40.w,
                        child: Container(
                          width: 180.w,
                          height: 180.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40.h,
                        left: -30.w,
                        child: Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72.w,
                              height: 72.w,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Icon(
                                Icons.local_hospital_rounded,
                                size: 36.sp,
                                color: AppColors.primary,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .scaleXY(begin: 0.8, end: 1),
                            SizedBox(height: 16.h),
                            Text(
                              'Welcome Back',
                              style: AppTextStyles.displayMedium.copyWith(
                                color: AppColors.white,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 100.ms)
                                .slideY(begin: 0.2, end: 0),
                            SizedBox(height: 6.h),
                            Text(
                              'Sign in to continue',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 200.ms)
                                .slideY(begin: 0.2, end: 0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 28.w,
                      vertical: 32.h,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Address',
                            style: AppTextStyles.titleSmall,
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 300.ms)
                              .slideY(begin: 0.2, end: 0),
                          SizedBox(height: 8.h),
                          AppTextField(
                            controller: _emailController,
                            hint: 'Enter your email',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              size: 20.sp,
                              color: AppColors.primary,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 400.ms)
                              .slideY(begin: 0.2, end: 0),
                          SizedBox(height: 20.h),
                          Text(
                            'Password',
                            style: AppTextStyles.titleSmall,
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 500.ms)
                              .slideY(begin: 0.2, end: 0),
                          SizedBox(height: 8.h),
                          AppTextField(
                            controller: _passwordController,
                            hint: 'Enter your password',
                            prefixIcon: Icon(
                              Icons.lock_outlined,
                              size: 20.sp,
                              color: AppColors.primary,
                            ),
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 600.ms)
                              .slideY(begin: 0.2, end: 0),
                          SizedBox(height: 12.h),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forgot Password?',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 700.ms),
                          SizedBox(height: 32.h),
                          AppButton(
                            label: 'Sign In',
                            onPressed: state is AuthLoading ? null : _onLogin,
                            isLoading: state is AuthLoading,
                            isDisabled: state is AuthLoading,
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 800.ms)
                              .slideY(begin: 0.2, end: 0),
                          SizedBox(height: 24.h),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppColors.textTertiary.withValues(alpha: 0.3),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Text(
                                  'OR',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppColors.textTertiary.withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 900.ms),
                          SizedBox(height: 24.h),
                          Center(
                            child: Text(
                              'Need help? Contact your administrator',
                              style: AppTextStyles.caption,
                              textAlign: TextAlign.center,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 1000.ms),
                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
