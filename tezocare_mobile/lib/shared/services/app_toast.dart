import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../../config/themes/app_colors.dart';

class AppToast {
  AppToast._();

  static void _show({
    required BuildContext context,
    required String title,
    String? description,
    required ToastificationType type,
    required Color primaryColor,
    required Color backgroundColor,
    required IconData icon,
  }) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flatColored,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      description: description != null
          ? Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withValues(alpha: 0.6),
              ),
            )
          : null,
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      icon: Icon(icon, size: 20),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      animationDuration: const Duration(milliseconds: 400),
      closeOnClick: true,
      pauseOnHover: true,
      showProgressBar: false,
    );
  }

  static void success(BuildContext context, {
    required String title,
    String? description,
  }) {
    _show(
      context: context,
      title: title,
      description: description,
      type: ToastificationType.success,
      primaryColor: AppColors.success,
      backgroundColor: AppColors.successLight,
      icon: Icons.check_circle_rounded,
    );
  }

  static void error(BuildContext context, {
    required String title,
    String? description,
  }) {
    _show(
      context: context,
      title: title,
      description: description,
      type: ToastificationType.error,
      primaryColor: AppColors.danger,
      backgroundColor: AppColors.dangerLight,
      icon: Icons.error_rounded,
    );
  }

  static void warning(BuildContext context, {
    required String title,
    String? description,
  }) {
    _show(
      context: context,
      title: title,
      description: description,
      type: ToastificationType.warning,
      primaryColor: AppColors.warning,
      backgroundColor: AppColors.warningLight,
      icon: Icons.warning_rounded,
    );
  }

  static void info(BuildContext context, {
    required String title,
    String? description,
  }) {
    _show(
      context: context,
      title: title,
      description: description,
      type: ToastificationType.info,
      primaryColor: AppColors.info,
      backgroundColor: AppColors.infoLight,
      icon: Icons.info_rounded,
    );
  }
}
