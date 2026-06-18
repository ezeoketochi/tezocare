import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/themes/app_colors.dart';
import '../../config/themes/app_text_styles.dart';

class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    String? actionLabel,
    VoidCallback? onAction,
    bool showClose = true,
    bool showDragHandle = true,
    double? heightFactor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _AppBottomSheetContent(
        title: title,
        actionLabel: actionLabel,
        onAction: onAction,
        showClose: showClose,
        showDragHandle: showDragHandle,
        heightFactor: heightFactor,
        child: child,
      ),
    );
  }
}

class _AppBottomSheetContent extends StatelessWidget {
  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showClose;
  final bool showDragHandle;
  final double? heightFactor;

  const _AppBottomSheetContent({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
    this.showClose = true,
    this.showDragHandle = true,
    this.heightFactor,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: heightFactor != null
          ? BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * heightFactor!,
            )
          : null,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle) ...[
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
          ],
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (showClose)
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.sp,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                bottom: bottomPadding + 16.h,
              ),
              physics: const BouncingScrollPhysics(),
              child: child,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
              child: SizedBox(
                width: double.infinity,
                height: 45.h,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    actionLabel!,
                    style: AppTextStyles.labelLarge,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
