import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_section_header.dart';
import '../../../../shared/widgets/app_stat_card.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const GetDashboardStatsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'TezoCare',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8.w),
              child: IconButton(
                icon: Icon(
                  Icons.logout_rounded,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.read<AuthBloc>().add(
                              const AuthLogoutRequested(),
                            );
                          },
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DashboardError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48.sp,
                        color: AppColors.coral,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is DashboardLoaded) {
              final stats = state.stats;
              final statVariants = [
                StatCardVariant.primary,
                StatCardVariant.success,
                StatCardVariant.gold,
                StatCardVariant.coral,
              ];
              final statIcons = [
                Icons.pets_rounded,
                Icons.medical_services_rounded,
                Icons.calendar_today_rounded,
                Icons.refresh_rounded,
              ];
              final statLabels = [
                'Total Patients',
                'Active Visits',
                "Today's Appointments",
                'Pending Refills',
              ];
              final statValues = [
                stats.totalPatients.toString(),
                stats.activeVisits.toString(),
                stats.todayAppointments.toString(),
                stats.pendingRefills.toString(),
              ];

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(
                    const GetDashboardStatsEvent(),
                  );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                        child: Text(
                          'Overview',
                          style: AppTextStyles.headlineMedium,
                        ),
                      ),
                      Padding(
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
                          itemBuilder: (context, index) {
                            return AppStatCard(
                              value: statValues[index],
                              label: statLabels[index],
                              icon: statIcons[index],
                              variant: statVariants[index],
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 24.h),
                      const AppSectionHeader(title: 'Quick Actions'),
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildQuickAction(
                                label: 'Patients',
                                icon: Icons.pets_rounded,
                                color: AppColors.primary,
                                onTap: () => context.push('/patients'),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildQuickAction(
                                label: 'Visits',
                                icon: Icons.medical_services_rounded,
                                color: AppColors.accent,
                                onTap: () => context.push('/visits/create'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildQuickAction(
                                label: 'Medications',
                                icon: Icons.medication_rounded,
                                color: AppColors.coral,
                                onTap: () => context.push('/medications'),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildQuickAction(
                                label: 'Add Patient',
                                icon: Icons.person_add_rounded,
                                color: AppColors.gold,
                                onTap: () => context.push('/patients/create'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (state.refillsDue.isNotEmpty) ...[
                        SizedBox(height: 24.h),
                        const AppSectionHeader(title: 'Refills Due'),
                        SizedBox(height: 12.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            children: state.refillsDue.map(
                              (refill) => Container(
                                margin: EdgeInsets.only(bottom: 8.h),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.06),
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
                                      color: (refill.isOverdue
                                              ? AppColors.coral
                                              : AppColors.warning)
                                          .withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.refresh_rounded,
                                      color: refill.isOverdue
                                          ? AppColors.coral
                                          : AppColors.warning,
                                      size: 20.sp,
                                    ),
                                  ),
                                  title: Text(
                                    refill.medicationName,
                                    style: AppTextStyles.titleMedium,
                                  ),
                                  subtitle: Text(
                                    '${refill.patientName} - Due: ${refill.nextRefillDate.toLocal().toString().split(' ')[0]}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  trailing: AppBadge(
                                    text: refill.isOverdue ? 'Overdue' : 'Pending',
                                    variant: refill.isOverdue
                                        ? BadgeVariant.critical
                                        : BadgeVariant.pending,
                                  ),
                                ),
                              ),
                            ).toList(),
                          ),
                        ),
                      ],
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
