import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/themes/app_colors.dart';

class AppLoading {
  AppLoading._();

  static Widget fullScreen() {
    return Container(
      color: AppColors.background.withValues(alpha: 0.8),
      child: Center(
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  static Widget inline({double? size}) {
    return SizedBox(
      width: size ?? 20.w,
      height: size ?? 20.w,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.primary,
        ),
      ),
    );
  }

  static Widget _base({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: AppColors.white,
      child: child,
    );
  }

  /// Generic shimmer card
  static Widget shimmerCard({double height = 100}) {
    return _base(
      child: Container(
        height: height.h,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }

  /// Generic shimmer list of shimmerCards
  static Widget shimmerList({int count = 3}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, _) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: shimmerCard(),
      ),
    );
  }

  // ── Dashboard-specific shimmer ──────────────────────────────────────

  /// Full dashboard skeleton: header + stat grid + patient cards
  static Widget dashboard() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          _shimmerDashboardHeader(),
          SizedBox(height: 20.h),
          _shimmerStatGrid(),
          SizedBox(height: 20.h),
          _shimmerSectionHeader(),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: List.generate(3, (_) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _shimmerPatientCard(),
              )),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _shimmerDashboardHeader() {
    return _base(
      child: Container(
        width: double.infinity,
        height: 100.h,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
      ),
    );
  }

  static Widget _shimmerStatGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (_, _) => _base(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _shimmerSectionHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _base(
            child: Container(
              width: 120.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          _base(
            child: Container(
              width: 50.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _shimmerPatientCard() {
    return _base(
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: const BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    width: 100.w,
                    height: 11.h,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20.sp, color: AppColors.divider),
          ],
        ),
      ),
    );
  }

  // ── Card-specific shimmer helpers ───────────────────────────────────

  /// Patient list card skeleton
  static Widget patientCard() {
    return _shimmerPatientCard();
  }

  /// List of patient card skeletons
  static Widget patientListShimmer({int count = 3}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, _) => Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: patientCard(),
      ),
    );
  }

  /// Medication / refill card skeleton
  static Widget refillCard() {
    return _base(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: const BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    width: 80.w,
                    height: 11.h,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 60.w,
              height: 22.h,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// List of refill card skeletons
  static Widget refillListShimmer({int count = 3}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, _) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: refillCard(),
      ),
    );
  }

  /// Follow-up card skeleton (same layout as refill)
  static Widget followUpCard() => refillCard();

  /// List of follow-up card skeletons
  static Widget followUpListShimmer({int count = 3}) => refillListShimmer(count: count);

  /// Stat card skeleton (for dashboard grid)
  static Widget statCard() {
    return _base(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: const BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: 50.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              width: 70.w,
              height: 11.h,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Page-specific shimmer skeletons ─────────────────────────────────

  /// Patient detail skeleton: gradient header, tab bar, tab content
  static Widget patientDetail() {
    final shimmer = _ShimmerBuilder();
    return shimmer.build(
      children: [
        // Header area
        Container(
          width: double.infinity,
          height: 200.h,
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              shimmer.circle(size: 64),
              SizedBox(height: 10.h),
              shimmer.line(width: 150, height: 16),
              SizedBox(height: 6.h),
              shimmer.line(width: 100, height: 12),
              SizedBox(height: 20.h),
            ],
          ),
        ),
        // Tab bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: List.generate(3, (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: shimmer.line(height: 32),
              ),
            )),
          ),
        ),
        SizedBox(height: 16.h),
        // Tab content cards
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: List.generate(4, (_) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _shimmerPatientCard(),
            )),
          ),
        ),
      ],
    );
  }

  /// Visit detail skeleton: app bar, section cards
  static Widget visitDetail() {
    final shimmer = _ShimmerBuilder();
    return shimmer.build(
      children: [
        // Section cards
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
          child: Column(
            children: List.generate(4, (_) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    shimmer.line(width: 120, height: 14),
                    SizedBox(height: 10.h),
                    shimmer.line(height: 40),
                    SizedBox(height: 6.h),
                    shimmer.line(height: 40),
                  ],
                ),
              ),
            )),
          ),
        ),
      ],
    );
  }

  /// Profile skeleton: gradient header, menu item groups
  static Widget profile() {
    final shimmer = _ShimmerBuilder();
    return shimmer.build(
      children: [
        // Header
        Container(
          width: double.infinity,
          height: 180.h,
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              shimmer.circle(size: 60),
              SizedBox(height: 10.h),
              shimmer.line(width: 140, height: 16),
              SizedBox(height: 4.h),
              shimmer.line(width: 80, height: 12),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        // Menu groups
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              ...List.generate(3, (_) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _shimmerMenuItem(),
              )),
              SizedBox(height: 24.h),
              ...List.generate(2, (_) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _shimmerMenuItem(),
              )),
              SizedBox(height: 24.h),
              _shimmerLogoutRow(),
            ],
          ),
        ),
      ],
    );
  }

  /// Edit patient form skeleton
  static Widget editPatientForm() {
    final shimmer = _ShimmerBuilder();
    return shimmer.build(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: List.generate(6, (_) => Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shimmer.line(width: 80, height: 12),
                SizedBox(height: 6.h),
                shimmer.line(height: 45),
              ],
            ),
          )),
        ),
      ),
    );
  }

  /// Medication list item skeleton (for search results page)
  static Widget medicationListItem() {
    return _base(
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            shimmerCircle(size: 36),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmerLine(width: 140, height: 14),
                  SizedBox(height: 4.h),
                  shimmerLine(width: 90, height: 11),
                ],
              ),
            ),
            shimmerLine(width: 50, height: 22),
          ],
        ),
      ),
    );
  }

  /// Visit card skeleton (for patient detail visits tab)
  static Widget visitCard() {
    return _base(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmerLine(width: 100, height: 14),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      shimmerLine(width: 60, height: 20),
                      SizedBox(width: 6.w),
                      shimmerLine(width: 50, height: 20),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  shimmerLine(width: 80, height: 11),
                ],
              ),
            ),
            shimmerLine(width: 55, height: 22),
            SizedBox(width: 4.w),
            Icon(Icons.chevron_right_rounded, size: 20.sp, color: AppColors.divider),
          ],
        ),
      ),
    );
  }

  /// List of visit card skeletons
  static Widget visitListShimmer({int count = 3}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(20.w),
      itemCount: count,
      itemBuilder: (_, _) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: visitCard(),
      ),
    );
  }

  /// Medication card skeleton (for patient detail medications tab)
  static Widget medicationCard() {
    return _base(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmerLine(width: 130, height: 14),
                  SizedBox(height: 4.h),
                  shimmerLine(width: 180, height: 11),
                  SizedBox(height: 4.h),
                  shimmerLine(width: 100, height: 11),
                ],
              ),
            ),
            shimmerLine(width: 60, height: 20),
            SizedBox(width: 4.w),
            Icon(Icons.chevron_right_rounded, size: 20.sp, color: AppColors.divider),
          ],
        ),
      ),
    );
  }

  /// List of medication card skeletons
  static Widget medicationListShimmer({int count = 3}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(20.w),
      itemCount: count,
      itemBuilder: (_, _) => Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: medicationCard(),
      ),
    );
  }
}

// ── Internal helpers to reduce boilerplate ────────────────────────────

Widget shimmerLine({double? width, double height = 14}) {
  return Container(
    width: width?.w,
    height: height.h,
    decoration: BoxDecoration(
      color: AppColors.divider,
      borderRadius: BorderRadius.circular(4.r),
    ),
  );
}

Widget shimmerCircle({double size = 44}) {
  return Container(
    width: size.w,
    height: size.w,
    decoration: const BoxDecoration(
      color: AppColors.divider,
      shape: BoxShape.circle,
    ),
  );
}

Widget _shimmerMenuItem() {
  return _ShimmerBuilder().build(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        children: [
          shimmerCircle(size: 36),
          SizedBox(width: 12.w),
          Expanded(child: shimmerLine(height: 14)),
          SizedBox(width: 8.w),
          Icon(Icons.chevron_right, size: 20.sp, color: AppColors.divider),
        ],
      ),
    ),
  );
}

Widget _shimmerLogoutRow() {
  return _ShimmerBuilder().build(
    child: Container(
      height: 45.h,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(10.r),
      ),
    ),
  );
}

/// Helper that wraps children in shimmer animation.
class _ShimmerBuilder {
  Widget build({List<Widget>? children, Widget? child}) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: AppColors.white,
      child: child ??
        (children != null
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)
            : const SizedBox.shrink()),
    );
  }

  Widget line({double? width, double height = 14}) =>
      shimmerLine(width: width, height: height);

  Widget circle({double size = 44}) =>
      shimmerCircle(size: size);
}