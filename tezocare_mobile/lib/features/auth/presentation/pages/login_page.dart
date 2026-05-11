import 'package:flutter/material.dart';
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
            context.go(RouteNames.dashboard);
          } else if (state is AuthError) {
            AppToast.error(context, title: state.message);
          } else if (state is AuthValidationError) {
            final messages = state.errors.values.join('\n');
            AppToast.warning(context, title: messages);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72.w,
                          height: 72.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.local_pharmacy_rounded,
                            size: 36.sp,
                            color: AppColors.accentLight,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'TezoCare',
                          style: AppTextStyles.displayMedium.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Veterinary Clinic Management',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32.r),
                        topRight: Radius.circular(32.r),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 32.h,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back',
                              style: AppTextStyles.headlineLarge,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Sign in to your account',
                              style: AppTextStyles.bodyMedium,
                            ),
                            SizedBox(height: 32.h),
                            AppTextField(
                              controller: _emailController,
                              label: 'Email',
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
                            ),
                            SizedBox(height: 16.h),
                            AppTextField(
                              controller: _passwordController,
                              label: 'Password',
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
                            ),
                            SizedBox(height: 32.h),
                            AppButton(
                              label: 'Sign In',
                              onPressed: state is AuthLoading ? null : _onLogin,
                              isLoading: state is AuthLoading,
                              isDisabled: state is AuthLoading,
                            ),
                          ],
                        ),
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
