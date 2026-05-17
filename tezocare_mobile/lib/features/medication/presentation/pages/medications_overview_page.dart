import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_event.dart';
import '../../../dashboard/presentation/bloc/dashboard_state.dart';

class MedicationsOverviewPage extends StatefulWidget {
  const MedicationsOverviewPage({super.key});

  @override
  State<MedicationsOverviewPage> createState() =>
      _MedicationsOverviewPageState();
}

class _MedicationsOverviewPageState extends State<MedicationsOverviewPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<DashboardBloc>();
    if (bloc.state is! DashboardLoaded) {
      bloc.add(const GetDashboardStatsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              child: Text(
                'Medications Overview',
                style: AppTextStyles.headlineMedium,
              ),
            ),
            Expanded(
              child: BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return Padding(
                      padding: EdgeInsets.all(20.w),
                      child: AppLoading.shimmerList(),
                    );
                  }
                  if (state is DashboardError) {
                    return AppEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Something went wrong',
                      message: state.message,
                      actionLabel: 'Retry',
                      onAction: () => context
                          .read<DashboardBloc>()
                          .add(const GetDashboardStatsEvent()),
                    );
                  }
                  if (state is DashboardLoaded) {
                    final upcomingRefills = state.stats.upcomingRefills;
                    if (upcomingRefills.isEmpty) {
                      return const AppEmptyState(
                        icon: Icons.medication_outlined,
                        title: 'No Upcoming Refills',
                        message: 'All medications are up to date',
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<DashboardBloc>()
                            .add(const GetDashboardStatsEvent());
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: upcomingRefills.length,
                        itemBuilder: (context, index) {
                          final refill = upcomingRefills[index] as Map<String, dynamic>;
                          final isOverdue = refill['is_overdue'] as bool? ?? false;
                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              leading: Container(
                                width: 44.w,
                                height: 44.w,
                                decoration: BoxDecoration(
                                  color: (isOverdue
                                          ? AppColors.danger
                                          : AppColors.primary)
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isOverdue
                                      ? Icons.warning_rounded
                                      : Icons.medication_outlined,
                                  color: isOverdue
                                      ? AppColors.danger
                                      : AppColors.primary,
                                  size: 20.sp,
                                ),
                              ),
                              title: Text(
                                refill['medication_name'] as String? ?? '',
                                style: AppTextStyles.titleMedium,
                              ),
                              subtitle: Text(
                                '${refill['patient_name'] as String? ?? ''} \u2022 Due: ${refill['next_refill_date'] as String? ?? ''}',
                                style: AppTextStyles.bodySmall,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
