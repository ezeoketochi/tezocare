import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/services/app_toast.dart';
import '../bloc/auth_form_bloc.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendOtp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthFormBloc>().add(
        ForgotPasswordRequested(email: _emailController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthFormBloc, AuthFormState>(
        listener: (context, state) {
          if (state is AuthFormSuccess) {
            AppToast.success(context, title: state.message);
            context.push(
              '${RouteNames.verifyOtp}?email=${_emailController.text.trim()}',
            );
          } else if (state is AuthFormError) {
            AppToast.error(context, title: state.message);
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
                                Icons.lock_reset_rounded,
                                size: 36.sp,
                                color: AppColors.primary,
                              ),
                            ).animate().fadeIn(duration: 500.ms).scaleXY(
                              begin: 0.8,
                              end: 1,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Forgot Password',
                              style: AppTextStyles.displayMedium.copyWith(
                                color: AppColors.white,
                              ),
                            ).animate().fadeIn(
                              duration: 600.ms,
                              delay: 100.ms,
                            ).slideY(begin: 0.2, end: 0),
                            SizedBox(height: 6.h),
                            Text(
                              'Enter your email to receive an OTP',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ).animate().fadeIn(
                              duration: 600.ms,
                              delay: 200.ms,
                            ).slideY(begin: 0.2, end: 0),
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
                          ),
                          SizedBox(height: 8.h),
                          AppTextField(
                            controller: _emailController,
                            hint: 'Enter your registered email',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              size: 20.sp,
                              color: AppColors.primary,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 32.h),
                          AppButton(
                            label: 'Send OTP',
                            onPressed:
                                state is AuthFormLoading ? null : _onSendOtp,
                            isLoading: state is AuthFormLoading,
                            isDisabled: state is AuthFormLoading,
                          ),
                          SizedBox(height: 24.h),
                          Center(
                            child: TextButton(
                              onPressed: () => context.go(RouteNames.login),
                              child: Text(
                                'Back to Sign In',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
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
